require 'active_support/concern'
require 'simple_token_authentication/token_generator'

module SimpleTokenAuthentication
  module ActsAsTokenAuthenticatable
    extend ::ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :generate_authentication_token
      private :token_suitable?
      private :token_generator
    end

    # Set an authentication token if missing
    #
    # Because it is intended to be used as a filter,
    # this method is -and should be kept- idempotent.
    def ensure_authentication_token
      if authentication_token.blank?
        self.authentication_token = generate_authentication_token(token_generator)
      end
    end

    def generate_authentication_token(token_generator)
      loop do
        token = token_generator.generate_token
        break token if token_suitable?(token)
      end
    end

    def token_suitable?(token)
      self.class.where(authentication_token: token).count == 0
    end

    # Private: Get one (always the same) object which behaves as a token generator
    def token_generator
      @token_generator ||= TokenGenerator.new
    end

    module ClassMethods
      def acts_as_token_authenticatable(options = {})
        if respond_to? :before_save
          before_save :ensure_authentication_token
        else
          define_before_save :ensure_authentication_token
        end
      end

      def define_before_save(*methods)
        define_method :before_save do |*methods, &block|
          methods.each { |method| send(method) }
          super
        end
      end
    end
  end
end
