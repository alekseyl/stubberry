module Stubberry::Object
  def stub_must( name, val_or_callable, *block_args )
    new_name = "__minitest_stub__#{name}"
    call_happened_method_name = "__#{name}_call_happened"

    metaclass = class << self; self; end

    if respond_to? name and not methods.map(&:to_s).include? name.to_s then
      metaclass.send :define_method, name do |*args|
        super(*args)
      end
    end

    metaclass.send :alias_method, new_name, name

    # this will make a closure without spoiling class with any instance vars and so
    call_happened = []
    metaclass.send :define_method, call_happened_method_name do
      call_happened << true
    end

    metaclass.send :define_method, name do |*args, &blk|
      __send__(call_happened_method_name)

      if val_or_callable.respond_to? :call then
        val_or_callable.call(*args, &blk)
      else
        blk.call(*block_args) if blk
        val_or_callable
      end
    end

    (yield self).tap do
      raise  "#{name} wasnt called" if call_happened.length == 0
    end
  ensure
    metaclass.send :undef_method, name
    metaclass.send :alias_method, name, new_name
    metaclass.send :undef_method, new_name
    metaclass.send :undef_method, call_happened_method_name
  end

  def stub_must_not( name, message = nil )
    new_name = "__minitest_stub__#{name}"

    metaclass = class << self; self; end

    if respond_to?(name) && !methods.map(&:to_s).include?( name.to_s )
      metaclass.define_method( name ) { | *args | super(*args) }
    end

    metaclass.alias_method( new_name, name )
    metaclass.define_method( name ) { |*| raise message || "#{name} was called!" }

    yield self
  ensure
    metaclass.undef_method( name )
    metaclass.alias_method( name, new_name )
    metaclass.undef_method( new_name )
  end

  def stub_must_all( name_to_var_or_callable, &block )
    name_to_var_or_callable.length == 1 ? stub_must( *name_to_var_or_callable.shift, &block )
      : stub_must( *name_to_var_or_callable.shift ) { stub_must_all(name_to_var_or_callable, &block ) }
  end
end