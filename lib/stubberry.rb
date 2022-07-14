# frozen_string_literal: true

require "stubberry/version"
require "stubberry/object"
require "stubberry/active_record"
require "stubberry/assertions"

module Stubberry
  class Error < StandardError; end

  def self.__define_method_mimic_replacement(object, method)
    return unless __is_a_method_mimic?(object, method)

    object.define_singleton_method(method) { |*args, **kargs, &block| super(*args, **kargs, &block) }
  end

  # object responds to 'method' but, the are no such method among methods,
  # i.e. it's run through a method_missing
  def self.__is_a_method_mimic?(object, method)
    object.respond_to?(method) && !object.methods.map(&:to_s).include?(method.to_s)
  end
end
