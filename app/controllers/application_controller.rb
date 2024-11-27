class ApplicationController < ActionController::API
  rescue_from Mongoid::Errors::Validations, with: :document_invalid_response
  rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found_response

  private

  def validation_schema
    ParamSchemas.const_get "#{controller_name.camelcase}::#{action_name.camelcase}"
  end

  def document_invalid_response(error)
    document = error.document
    render json: { error: document.errors, document: }, status: 422
  end

  def document_not_found_response(error)
    render json: { error: error.problem }, status: 404
  end
end
