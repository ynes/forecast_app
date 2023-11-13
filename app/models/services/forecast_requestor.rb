# Module to connect to Weather API and pull data for a given zip code.
# The API free version includes up to 3 days extended forecast.

module Services::ForecastRequestor

    def self.get_for(zip_code, days = 1)
        params = {
                    key: Rails.application.credentials.weather_api_key,
                    q: zip_code,
                    days: days
                 }
        begin
            conn = Faraday.new(
                url: Rails.application.config.weather_api_url,
                params: params,
                headers: {'Content-Type' => 'application/json'}
            )
            response = conn.get
            raise response.body unless response.status == 200
            JSON.parse(response.body, symbolize_names: true)
        rescue => e
            Rails.logger.error("Unable to get forecast data. Error: #{e.message}")
            nil
        end
    end
end