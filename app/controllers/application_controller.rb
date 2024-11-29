class ApplicationController < ActionController::API
  include ParamsGuard

  rescue_from Mongoid::Errors::Validations, with: :document_invalid_response
  rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found_response

  private

  def document_invalid_response(error)
    document = error.document
    render json: { error: document.errors, document: }, status: 422
  end

  def document_not_found_response(error)
    render json: { error: error.problem }, status: 404
  end
end
