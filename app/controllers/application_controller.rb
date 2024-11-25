class ApplicationController < ActionController::API
  rescue_from Mongoid::Errors::Validations, with: :record_invalid

  private

  def record_invalid(error)
    render json: { errors: error.document.errors }, status: 422
  end
end
