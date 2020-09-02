module ApiExceptions
  APIExceptionError = Class.new(StandardError)
  BadRequestError = Class.new(APIExceptionError)
  UnauthorizedError = Class.new(APIExceptionError)
  ForbiddenError = Class.new(APIExceptionError)
  NotFoundError = Class.new(APIExceptionError)
  UnprocessableEntityError = Class.new(APIExceptionError)
  ApiError = Class.new(APIExceptionError)
end