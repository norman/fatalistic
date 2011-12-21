require "forwardable"

# Table locking for Active Record.
module Fatalistic

  VERSION = "0.0.1"

  # This class provides syntax abstraction for table locking. If this
  # functionality is ever added to Active Record, the final code will end up
  # looking much different: it's currently set up with as much functionality
  # outside AR as possible, in order to simplify testing and reduce
  # dependencies.
  class Locker
    extend Forwardable
    attr :model_class
    def_delegators :model_class, :connection, :quoted_table_name

    # Factory method to get an instance of the appropriate Locker subclass.
    def self.for(model_class)
      adapter_name = model_class.connection.adapter_name.downcase
      klass = if adapter_name.index("post")
        PostgresLocker
      elsif adapter_name.index("my")
        MySQLLocker
      else
        self
      end
      klass.new(model_class)
    end

    def initialize(model_class)
      @model_class = model_class
    end

    # Lock the table.
    def lock(lock_statement = nil)
    end

    # Unlock the table. This is a no-op on all databases other than MySQL.
    def unlock
    end
  end

  # Table locking for Postgres.
  class PostgresLocker < Locker
    def lock(lock_statement = nil)
      stmt = "LOCK TABLE #{quoted_table_name}"
      stmt.insert(-1, " #{lock_statement}") if lock_statement
      connection.execute(stmt)
    end
  end

  # Table locking for MySQL.
  class MySQLLocker < Locker
    def lock(lock_statement = nil)
      stmt = "LOCK TABLES #{quoted_table_name}"
      lock_statement ||= "WRITE"
      stmt.insert(-1, " #{lock_statement}")
      connection.execute(stmt)
    end

    def unlock
      connection.execute("UNLOCK TABLES")
    end
  end
end
