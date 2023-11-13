# Class to store extended forecast day from pulled data.

class ForecastDay

    attr_reader :date, :maxtemp, :mintemp, :condition, :condition_icon

    def initialize(data = {})
        @date = Date.parse(data[:date])
        @maxtemp = data.dig(:day, :maxtemp_f).to_i
        @mintemp = data.dig(:day, :mintemp_f).to_i
        @condition = data.dig(:day, :condition, :text)
        @condition_icon = data.dig(:day, :condition, :icon)
    end
end