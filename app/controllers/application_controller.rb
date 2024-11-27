class ApplicationController < ActionController::API
  rescue_from Mongoid::Errors::Validations, with: :document_invalid
  rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found

  private

  def validation_schema
    ParamSchemas.const_get "#{controller_name.camelcase}::#{action_name.camelcase}"
  end

  def document_invalid(error)
    render json: { errors: error.document.errors }, status: 422
  end

  def document_not_found(error)
    render json: { errors: error.problem }, status: 404
  end
end
