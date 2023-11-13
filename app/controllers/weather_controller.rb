class WeatherController < ApplicationController

  # POST /retrieve
  # from remote form.
  def retrieve
    @forecast = Forecast.get_for(params[:address])
  end
end
