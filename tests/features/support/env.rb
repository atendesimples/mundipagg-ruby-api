begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
begin require 'rspec/mocks'; rescue LoadError; require 'spec/mocks'; end
$:.unshift(File.dirname(__FILE__) + '/../../../lib')
require 'mundipagg'
require 'bigdecimal'
require_relative '../../test_helper.rb'
require_relative '../../test_configuration.rb'
