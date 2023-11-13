# Class to store current weather from pulled data.

class Current
    attr_reader :city, :state, :temp, :condition, :condition_icon

    def initialize(location, data)
        @city = location[:name]
        @state = location[:region]
        @temp = data[:temp_f].to_i
        @condition = data.dig(:condition, :text)
        @condition_icon = data.dig(:condition, :text)
    end
end