module ApplicationHelper
  def cents_to_dollars(value)
    format '%.2f', (value.to_d / 100).round(2)
  end
end
