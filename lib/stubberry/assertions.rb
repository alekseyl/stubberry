module Stubberry::Assertions

  # it close to Object stub definition except its not
  # stubbing the original method instead its just controlling the flow
  # with minimum side effects
  def assert_method_called( object, method, inspect_params_callable = nil )
    base_method_new_name = "__old_#{method}_method"
    metaclass = object.singleton_class

    singleton_has_stubbing_method = object.singleton_methods.map(&:to_s).include?( method.to_s )

    # dynamic methods should be explicitly defined
    if object.respond_to?( method ) && !object.methods.map(&:to_s).include?( method.to_s )
      metaclass.define_method( method ) { |*args, **kargs, &block| super(*args, **kargs, &block) }
    end

    metaclass.alias_method base_method_new_name, method

    call_happened = []

    metaclass.define_method( method ) do |*args, **kargs, &blk|
      inspect_params_callable.call(*args, **kargs) if inspect_params_callable
      call_happened << true
      send(base_method_new_name, *args, **kargs, &blk)
    end

    yield.tap { raise "#{method} wasn't called" if call_happened.length == 0 }

  ensure
    metaclass.__stbr_clear_singleton_class( method, base_method_new_name, singleton_has_stubbing_method )
  end

end

