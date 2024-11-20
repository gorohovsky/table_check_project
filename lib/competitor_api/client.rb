module CompetitorApi
  class Client
    URL = ENV.fetch('COMPETITOR_URL').freeze
    HEADERS = { 'Accept' => 'application/json' }.freeze

    def self.fetch_data(url = URL)
      response = HTTP.use(logging: { logger: Rails.logger }).headers(HEADERS).get url

      response.status.success? ? response.parse : raise(Errors::BadResponse)
    end
  end
end
