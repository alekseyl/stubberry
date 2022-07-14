# frozen_string_literal: true

module Stubberry
  module Object
    # this is an enrichment of an original stub method from the minitest/mock
    def stub_must(name, val_or_callable, *block_args, **block_kwargs)
      method_new_name = "__minitest_stub__#{name}"

      singleton_has_stubbing_method = singleton_methods.map(&:to_s).include?(name.to_s)

      Stubberry.__define_method_mimic_replacement(self, name)

      singleton_class.alias_method(method_new_name, name)

      call_happened = []

      singleton_class.define_method(name) do |*args, **kwargs, &blk|
        call_happened << true

        if val_or_callable.respond_to?(:call)
          val_or_callable.call(*args, **kwargs, &blk)
        else
          blk&.call(*block_args, **block_kwargs)
          val_or_callable
        end
      end

      (yield self).tap do
        raise "#{name} wasn't called" if call_happened.empty?
      end
    ensure
      singleton_class.__stbr_clear_singleton_class(name, method_new_name, singleton_has_stubbing_method)
    end

    # the reverse method of stub_must -- will raise an issue whenever method
    # was called inside a stubbing block
    def stub_must_not(name, message = nil)
      method_new_name = "__minitest_stub__#{name}"
      singleton_has_stubbing_method = singleton_methods.map(&:to_s).include?(name.to_s)

      Stubberry.__define_method_mimic_replacement(self, name)

      singleton_class.alias_method(method_new_name, name)

      singleton_class.define_method(name) { |*| raise message || "#{name} was called!" }

      yield self
    ensure
      singleton_class.__stbr_clear_singleton_class(name, method_new_name, singleton_has_stubbing_method)
    end

    # just for fun multiple stub_must in one call
    def stub_must_all(name_to_var_or_callable, &block)
      if name_to_var_or_callable.length == 1
        stub_must(*name_to_var_or_callable.shift, &block)
      else
        stub_must(*name_to_var_or_callable.shift) { stub_must_all(name_to_var_or_callable, &block) }
      end
    end

    # stub only if respond otherwise just execute
    def stub_if_def(name, val_or_callable, *block_args, &block)
      respond_to?(name) ? stub(name, val_or_callable, *block_args, &block) : yield
    end

    # stub_must only if respond otherwise just execute
    def stub_must_if_def(name, val_or_callable, *block_args, &block)
      # stub only if respond otherwise just execute
      respond_to?(name) ? stub_must(name, val_or_callable, *block_args, &block) : yield
    end

    def __stbr_clear_singleton_class(name, new_name, had_method_before)
      raise Stubberry::Error, "This is a singleton_class methods only!" unless singleton_class?

      remove_method(name)
      alias_method(name, new_name) if had_method_before
      remove_method(new_name)
    end
  end
end

Object.include(Stubberry::Object)
