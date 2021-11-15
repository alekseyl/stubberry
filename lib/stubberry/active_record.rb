module Stubberry::ActiveRecord
  extend ActiveSupport::Concern

  # for any active record object for classes included Stubberry::ActiveRecord
  # we adding after_find callback extending object with self.class.extend_any
  # default implementation of self.class.extend_any does nothing
  included do
    after_find {|obj| self.class.extend_any(obj) }
  end

  module ClassMethods
    def stub_orm_attr(id, obj_or_attributes )
      stub(:extend_any, -> (obj) {
        return unless obj.id == id && obj.is_a?( self )
        obj.assign_attributes( obj_or_attributes.try(:attributes) || obj_or_attributes )
      }) do
        yield
      end
    end

    def stub_orm_method(id, method, val_or_callable, *block_args  )
      stub(:extend_any, -> (obj) {
        return unless obj.id == id && obj.is_a?( self )
        define_stub_method(obj, method, val_or_callable, *block_args )
      }) do
        yield
      end
    ensure
      undef_all(id, method)
    end

    private_class_method

    def define_stub_method( object, method, val_or_callable, *block_args )
      old_method = stub_method_name(method, obj: object)
      object.singleton_class.send :alias_method, old_method, method
      object.define_singleton_method method do |*args, &blk|
        if val_or_callable.respond_to? :call
          val_or_callable.call(*args, &blk)
        else
          blk.call(*block_args) if blk
          val_or_callable
        end
      end
      stubbed_objects(old_method) << object
    end

    def stub_method_name( method, obj: nil, id: nil)
      # __stub_class_method_id
      "__stub_#{to_s}_#{method}_#{obj&.id || id}"
    end

    def undef_all(id, method)
      old_method = stub_method_name( method, id: id)
      stubbed_objects(old_method).map(&:singleton_class).each do |metaclass|
        metaclass.send :undef_method, method
        metaclass.send :alias_method, method, old_method
        metaclass.send :undef_method, old_method
      end
    end

    def stubbed_objects(method_name)
      (@@extended_obj ||= {})[method_name] ||= []
    end

    def extend_any(_obj); :do_nothing end
  end
end if defined?(ActiveRecord)