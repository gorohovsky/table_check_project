class PrettyMongoidError
  PREFIX_TO_REMOVE = 'The following errors were found: '.freeze

  def initialize(exception)
    @exception = exception
  end

  def as_json(_)
    { error: message, error_details: @exception.document }
  end

  private

  def message
    "#{@exception.problem} #{useful_summary}"
  end

  def useful_summary
    @exception.summary.delete_prefix PREFIX_TO_REMOVE
  end
end
