# Class to process and store pulled data from API. Handle errors and cache data.

class Forecast
    DAYS_IN_THE_FUTURE = 3 # since the free API version only allows 3 days
    CACHE_TTL = 30.minutes
    CACHE_PREFIX = 'WEATHER_FOR_ZIP_'.freeze

    attr_reader :errors, :cached, :forecast_days, :current

    def self.get_for(address)
        a = new(address)
        a.send(:process_data)
        a
    end

    private

    def initialize(address)
      @address = address
      @errors = []
      @cached = false
      @data = {}
      @forecast_days = []
      @current = nil
      @zip_code = nil
    end

    def process_data
        begin
            extract_zip_code
            get_data
            set_current
            set_forecast_days
        rescue => e
            Rails.logger.error(e.message)
            @errors << "Unable to process the request at this moment. Please, try again later." if @errors.blank?
        end
    end

    def extract_zip_code
       @zip_code = AddressProcessor.get_valid_zip_code(@address)
       # Raise an error if zip code is not found.
       if @zip_code.blank?
            errors << 'Invalid US address or zip code.'
            # Raise error text for logging.
            raise "Invalid address #{@address}"
       end
    end

    def get_data
        # Get data from cache storage if it is still available.
        cached_data = Rails.cache.read("#{CACHE_PREFIX}#{@zip_code}")
        if cached_data
            @data = cached_data
            @cached = true # flag cached as true.
        else
            @data = Services::ForecastRequestor.get_for(@zip_code, DAYS_IN_THE_FUTURE)
            if @data.nil?
                @errors << "Unable to obtain weather data at this moment. Please, try again later."
                raise 'Unable to get data from Weather API.'
            else
                # Cache data for next requests.
                Rails.cache.write("#{CACHE_PREFIX}#{@zip_code}", @data, expires_in: CACHE_TTL)
            end
        end
    end

    def set_current
        if  @data[:current].blank? || @data[:location].blank?
            @errors << 'Current data not available.'
            raise 'Unable to locate current data in API response.'
        end
        @current = Current.new(@data[:location], @data[:current])
    end

    def set_forecast_days
        forecast_data = @data.dig(:forecast, :forecastday)
        if forecast_data.blank?
            @errors << 'Extended data not available.'
            raise 'Unable to locate forecast data in API response.'
        end
        forecast_data.each do |day|
            @forecast_days << ForecastDay.new(day)
        end
    end
end