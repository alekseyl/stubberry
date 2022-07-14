# frozen_string_literal: true

require "test_helper"

class MiniTestAssertionTest < ActiveSupport::TestCase
  extend ::ActiveSupport::Testing::Declarative
  include Stubberry::Assertions

  class Example
    attr_reader :inner_state

    def initialize
      @inner_state = 0
    end

    def self.test_class_method(*, **)
      :do_nothing
    end

    def test_instance_method(*args, **kwargs)
      self.class.test_class_method(*args, **kwargs)
      test_private_method
    end

    def increment
      @inner_state += 1
    end

    private

    def test_private_method
      :private_method
    end
  end

  test "assert_method_called worked on the instance" do
    obj = Example.new

    assert_method_called(obj, :test_instance_method) { obj.test_instance_method }

    assert_raises(RuntimeError) do
      assert_method_called(obj, :test_instance_method) {}
    end
  end
  test "assert_method_called worked on the class" do
    assert_method_called(Example, :test_class_method) { Example.new.test_instance_method }

    assert_raises(RuntimeError) do
      assert_method_called(Example, :test_class_method) {}
    end
  end

  test "assert_method_called worked on private method" do
    obj = Example.new
    assert_method_called(obj, :test_private_method) { obj.test_instance_method }
  end

  test "assert_method_called allows to check params" do
    assert_method_called(Example, :test_class_method, ->(arg) {
      assert_equal(arg, :arg)
    }) { Example.new.test_instance_method(:arg) }
  end

  test "assert_method_called on the instance with params inspector" do
    obj = Example.new
    assert_method_called(obj, :test_instance_method, ->(sym) {
      assert_equal(:worked, sym)
    }) { obj.test_instance_method(:worked) }
  end

  test "assert_method call will change obj state when called" do
    obj = Example.new
    assert_equal(obj.inner_state, 0)
    assert_method_called(obj, :increment) { obj.increment }
    assert_equal(obj.inner_state, 1)
  end
end
