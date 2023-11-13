require 'rails_helper'

describe Services::ForecastRequestor do

    let(:data) do
        {"location"=>
        {"name"=>"Mc Lean",
         "region"=>"Virginia"},
       "current"=>
        {"temp_c"=>5.0,
         "temp_f"=>41.0,
         "condition"=>{"text"=>"Partly cloudy", "icon"=>"//cdn.weatherapi.com/weather/64x64/night/116.png", "code"=>1003}},
       "forecast"=>
        {"forecastday"=>
          [{"date"=>"2023-11-11",
            "day"=>
             {"maxtemp_c"=>15.0,
              "maxtemp_f"=>59.0,
              "mintemp_c"=>1.3,
              "mintemp_f"=>34.3,
              "condition"=>{"text"=>"Partly cloudy", "icon"=>"//cdn.weatherapi.com/weather/64x64/day/116.png", "code"=>1003}}},
           {"date"=>"2023-11-12",
            "date_epoch"=>1699747200,
            "day"=>
             {"maxtemp_c"=>9.1,
              "maxtemp_f"=>48.4,
              "mintemp_c"=>4.0,
              "mintemp_f"=>39.2,
              "condition"=>{"text"=>"Cloudy", "icon"=>"//cdn.weatherapi.com/weather/64x64/day/119.png", "code"=>1006}}},
           {"date"=>"2023-11-13",
            "date_epoch"=>1699833600,
            "day"=>
             {"maxtemp_c"=>15.0,
              "maxtemp_f"=>59.0,
              "mintemp_c"=>-0.8,
              "mintemp_f"=>30.6,
              "condition"=>{"text"=>"Sunny", "icon"=>"//cdn.weatherapi.com/weather/64x64/day/113.png", "code"=>1000}}}]}} 
    end

    let(:error_data) do
      {"error"=>{"code"=>1006, "message"=>"No matching location found."}}
    end

    before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(OpenStruct.new(status: 200,
                                                                                              body: data.to_json))
    end

    subject { result = described_class.get_for(12345) }

    describe '.get_for' do
      context 'When no errors' do
          it 'should return a deep symbolized hash' do
            result = subject
            expect(result.class).to be Hash
            expect(result.keys).to eq([:location, :current, :forecast])
            expect(result.dig(:forecast, :forecastday)&.first&.dig(:day, :condition, :text)).to eq("Partly cloudy")
          end
      end
      context 'When errors' do
        before do
          allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(OpenStruct.new(status: 400,
                                                                                                  body: error_data.to_json))
        end
        it 'should return nil' do
          expect(subject).to eq(nil)
        end
        it 'should log an error' do
          expect(Rails.logger).to receive(:error).with(/No matching location found/)
          subject
        end
      end
    end
end