class WeatherController < ApplicationController

  # POST /retrieve
  # from remote form.
  def retrieve
    @forecast = Forecast.get_for(params[:address])

    respond_to do |format|
      format.turbo_stream
    end
  end
end
