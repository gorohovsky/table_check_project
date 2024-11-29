module ParamsGuard
  extend ActiveSupport::Concern

  private

  def validate_params
    validation = validation_schema.call(params.to_unsafe_h)
    if validation.success?
      @valid_params = validation.to_h
    else
      render json: { errors: validation.messages.to_h }, status: 400
    end
  end

  def validation_schema
    ParamSchemas.const_get "#{controller_name.camelcase}::#{action_name.camelcase}"
  end
end
