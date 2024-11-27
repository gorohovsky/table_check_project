module ParamSchemas
  module Products
    CustomType = Dry::Types(default: :strict)

    module CustomType
      File = Instance(ActionDispatch::Http::UploadedFile)
    end

    Import = Dry::Schema.Params do
      required(:csv).value(CustomType::File)
    end
  end
end
