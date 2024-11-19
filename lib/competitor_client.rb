class CompetitorClient
  URL = ENV.fetch('COMPETITOR_URL').freeze

  def self.fetch_prices(url = URL)
    HTTP.use(logging: { logger: Rails.logger }).get url
  end
end
