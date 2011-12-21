require "rubygems"

$LOAD_PATH << File.expand_path("../../lib", __FILE__)
$LOAD_PATH.uniq!

require "minitest/spec"
require "minitest/autorun"
require "fatalistic"

class MockModel
  attr_accessor :connection

  def quoted_table_name
    "dummy_table"
  end
end

describe Fatalistic::PostgresLocker do

  describe "#lock" do

    before do
      @model = MockModel.new
      @model.connection = MiniTest::Mock.new
      @locker = Fatalistic::PostgresLocker.new(@model)
    end

    it "should execute a default lock statement" do
      @model.connection.expect :execute, 'LOCK TABLE "dummy_table"', [String]
      @locker.lock
      assert @model.connection.verify
    end

    it "should execute a modified lock statement" do
      @model.connection.expect :execute, 'LOCK TABLE "dummy_table" foo', [String]
      @locker.lock "foo"
      assert @model.connection.verify
    end
  end

end

describe Fatalistic::MySQLLocker do

  before do
    @model = MockModel.new
    @model.connection = MiniTest::Mock.new
    @locker = Fatalistic::MySQLLocker.new(@model)
  end

  describe "#lock" do
    it "should execute a default lock statement" do
      @model.connection.expect :execute, 'LOCK TABLES "dummy_table" WRITE', [String]
      @locker.lock
      assert @model.connection.verify
    end

    it "should execute a modified lock statement" do
      @model.connection.expect :execute, 'LOCK TABLES "dummy_table" foo', [String]
      @locker.lock "foo"
      assert @model.connection.verify
    end
  end

  describe "#unlock" do
    it "should execute an unlock statement" do
      @model.connection.expect :execute, 'UNLOCK TABLES', [String]
      @locker.unlock
      assert @model.connection.verify
    end
  end
end
