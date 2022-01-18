# this module provide two methods for active record classes
# to easily stub any record attributes and methods disregarding the way
# record was obtained inside the yielding block, you just need an id.
#
# i.e. alternative way of dealing with any record with id could be stub of
# the specific method like where or find with a given set of params e.t.c.
# that's a very error prone approach, with stub_orm_* methods we
# do not care about the way object was obtained as long as after_find
# callback was executed
module Stubberry::ActiveRecord
  extend ActiveSupport::Concern

  # for any active record object for classes included Stubberry::ActiveRecord
  # we adding after_find callback extending object with self.class.extend_any
  # default implementation of self.class.extend_any does nothing
  included do
    after_find {|obj| self.class.__extend_any(obj) }
  end

  module ClassMethods

    # This method could be used whenever there is a need for stubbing
    # the exact ActiveRecord object attributes inside some execution flow
    # __WITHOUT__!!  underlying record change
    def stub_orm_attr(id, obj_or_attributes )
      stub(:__extend_any, -> (obj) {
        return unless obj.id == id && obj.is_a?( self )
        obj.assign_attributes( obj_or_attributes.try(:attributes) || obj_or_attributes )
      }) do
        yield
      end
    end

    # This method could be used whenever there is a need for stubbing
    # the specific Active Record object's methods inside some flow piece
    # with ANY way of object retrieval
    def stub_orm_method(id, method, val_or_callable, *block_args  )
      stub(:__extend_any, -> (obj) {
        return unless obj.id == id && obj.is_a?( self )
        __define_stub_method(obj, method, val_or_callable, *block_args )
      }) do
        yield
      end
    ensure
      __revert_all_methods(id, method)
    end

    private_class_method

    def __define_stub_method(object, method, val_or_callable, *block_args )
      method_new_name = __stub_method_name(method, obj: object)

      __define_dynamic_method_replacement( object, method )

      object.singleton_class.alias_method( method_new_name, method )
      
      object.define_singleton_method method do |*args, &blk|
        if val_or_callable.respond_to? :call
          val_or_callable.call(*args, &blk)
        else
          blk.call(*block_args) if blk
          val_or_callable
        end
      end
      __stubbed_objects(method_new_name) << object
    end

    def __define_dynamic_method_replacement( object, method )
      # this means method is dynamic 
      return unless object.respond_to?( method ) && !object.methods.map(&:to_s).include?( method.to_s )

      object.define_singleton_method( method ) { | *args, **kargs, &block | super(*args, **kargs, &block) }
    end

    def __stub_method_name(method, obj: nil, id: nil)
      # __stub_class_method_id
      "__stub_#{to_s}_#{method}_#{obj&.id || id}"
    end

    def __revert_all_methods(id, method)
      method_new_name = __stub_method_name(method, id: id)

      __stubbed_objects(method_new_name).map(&:singleton_class).each do |metaclass|
        metaclass.send :undef_method, method
        metaclass.send :alias_method, method, method_new_name
        metaclass.send :undef_method, method_new_name
      end
    end

    def __stubbed_objects(method_name)
      (@@__extended_objects ||= {})[method_name] ||= []
    end

    def __extend_any(_obj); :do_nothing end
  end
end if defined?(ActiveRecord)