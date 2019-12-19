require "active_support/core_ext/object/blank"

module TinyAuth
  module Controller
    # Extract a token from a request
    # @param request [ActionDispatch::HTTP::Request]
    # @return [String,nil]
    def self.token(request)
      header = request.authorization.to_s
      header[/^Bearer (.*)$/, 1].presence
    end

    # Defines a before action that will authenticate the resource.
    # It also defines methods for accessing the currently authenticated
    # resource.
    # @param model [ActiveRecord::Base]
    # @param name [Symbol] Used to define methods like `current_user`
    # @param options [Hash] Additional arguments for `before_action`
    #
    # @example
    #   class ApplicationController < ActionController::Base
    #     extend TinyAuth::Controller
    #
    #     authenticates model: User, only: :index
    #
    #     def index
    #       if user_signed_in?
    #         render json: current_user
    #       else
    #         head :unauthorized
    #       end
    #     end
    #   end
    def authenticates(model:, name: model.model_name.singular, **options)
      authenticate = :"authenticate_#{name}"
      current = :"current_#{name}"
      current_ivar = :"@current_#{name}"
      signed_in = :"#{name}_signed_in?"

      attr_reader current

      define_method(signed_in) do
        !send(current).nil?
      end

      define_method(authenticate) do
        token = TinyAuth::Controller.token(request)

        if token
          resource = model.find_by_token(token)
          instance_variable_set(current_ivar, resource)
        end
      end

      before_action(authenticate, **options)
    end
  end
end
