# frozen_string_literal: true

module Stubberry
  module Assertions
    # controlling the flow with minimum side effects
    def assert_method_called(object, method, inspect_params_callable = nil, &block)
      object_unbound_method = object.method(method.to_sym).unbind
      object.stub_must(method, ->(*args, **kwargs, &blk) {
        inspect_params_callable&.call(*args, **kwargs)
        object_unbound_method.bind(object).call(*args, **kwargs, &blk)
      }, &block)
    end
  end
end
