require "active_record"
require "fatalistic"

module ActiveRecord
  module Locking
    module Fatalistic
      # Performs a table-level lock. If this method is invoked with a block,
      # then a new transaction is begun, and the table is locked inside the
      # transaction. If invoked without a block, then it simple emits the
      # appropriate +LOCK TABLE+ statement.
      def lock(lock_statement = nil, &block)
        locker = ::Fatalistic::Locker.for(self)
        if block_given?
          transaction do
            begin
              locker.lock(lock_statement)
              yield
            ensure
              locker.unlock
            end
          end
        else
          locker.lock(lock_statement)
        end
      end

      # Unlock the table. This is only needed by MySQL. If you called +lock+
      # with a block, then this is invoked for you automatically.
      def unlock
        ::Fatalistic::Locker.for(self).unlock
      end
    end
  end
end

ActiveRecord::Base.method(:lock).owner.send :remove_method, :lock
ActiveRecord::Base.extend ActiveRecord::Locking::Fatalistic
