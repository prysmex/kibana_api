# frozen_string_literal: true

module Kibana
  module Transport
    module ApiExceptions
      # base
      APIExceptionError = Class.new(StandardError)

      # http code errors
      BadRequestError = Class.new(APIExceptionError)
      UnauthorizedError = Class.new(APIExceptionError)
      ForbiddenError = Class.new(APIExceptionError)
      NotFoundError = Class.new(APIExceptionError)
      UnprocessableEntityError = Class.new(APIExceptionError)

      # generic
      ApiError = Class.new(APIExceptionError)
    end
  end
end