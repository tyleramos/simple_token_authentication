require 'sequel'
require 'simple_token_authentication/adapter'

module SimpleTokenAuthentication
  module Adapters
    class SequelAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.base_class
        ::Sequel::Model
      end
    end
  end
end
