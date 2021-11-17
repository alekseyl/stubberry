$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'active_support'
require "stubberry"

require "minitest/autorun"
require 'ruby_jard'
require_relative 'active_record_test_helper'
