require 'rails_helper'

describe Forecast do

    let(:data) do
        {:location=>{:name=>"Mc Lean", :region=>"Virginia"},
        :current=>{:temp_c=>6.1, :temp_f=>43.0, :condition=>{:text=>"Clear", :icon=>"113.png"}},
        :forecast=>{
            :forecastday=>[
                {:date=>"2023-11-12", :day=>{:maxtemp_f=>49.5, :mintemp_f=>39.9,
                :condition=>{:text=>"Cloudy", :icon=>"119.png"}}},
                {:date=>"2023-11-13", :day=>{:maxtemp_f=>76.1, :mintemp_f=>61.0,
                :condition=>{:text=>"Sunny", :icon=>"113.png"}}},
                {:date=>"2023-11-14", :day=>{:maxtemp_f=>59.0, :mintemp_f=>36.7,
                :condition=>{:text=>"Sunny", :icon=>"113.png"}}  
                }]}}
    end

    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }
    let(:cache_key) { "#{described_class::CACHE_PREFIX}12345" }

    before do
        allow(Services::ForecastRequestor).to receive(:get_for).and_return(data)
        allow(Rails).to receive(:cache).and_return(memory_store)
        Rails.cache.clear
    end

    let(:address) { "1234 Chestnut St, Abc, TA 12345" }

    subject { described_class.get_for(address) }

    describe '.get_for' do

        context 'valid zip code' do

            context 'no cached data' do

                it 'should request the data' do
                    expect(Services::ForecastRequestor).to receive(:get_for).with("12345", described_class::DAYS_IN_THE_FUTURE)
                    subject
                end

                it 'should return a forecast instance with cached not flagged' do
                    instance = subject
                    expect(instance.errors).to be_empty
                    expect(instance.cached).to be false
                end

                it 'should set forecast_days and current' do
                    instance = subject
                    expect(instance.current).to be_an_instance_of(Current)
                    expect(instance.current.condition).to eq("Clear")
                    expect(instance.forecast_days.size).to eq(3)
                    expect(instance.forecast_days.last&.condition).to eq("Sunny")
                end

                it 'should cache the data' do
                    subject
                    expect(Rails.cache.exist?(cache_key)).to be true
                end
            end

            context 'cached data' do

                before do
                    Rails.cache.write(cache_key, data, expires_in: 3.minute)
                end

                it 'should not call the requestor' do
                    expect(Services::ForecastRequestor).not_to receive(:get_for)
                    subject
                end

                it 'should return a forecast instance with cached flagged' do
                    instance = subject
                    expect(instance.errors).to be_empty
                    expect(instance.cached).to be true
                end

                it 'should set forecast_days and current' do
                    instance = subject
                    expect(instance.current).to be_an_instance_of(Current)
                    expect(instance.current.temp).to eq(43)
                    expect(instance.forecast_days.size).to eq(3)
                    expect(instance.forecast_days.first&.maxtemp).to eq(49)
                end
            end

            context 'when errors' do

                context 'invalid zip code' do
                    before do
                        allow(AddressProcessor).to receive(:get_valid_zip_code).and_return(nil)
                    end

                    it 'should add an error' do
                        instance = subject
                        expect(instance.errors).not_to be_empty
                        expect(instance.errors.first).to eq('Invalid US address or zip code.')
                    end
                end

                context 'from the API' do
                    before do
                        allow(Services::ForecastRequestor).to receive(:get_for).and_return(nil)
                    end

                    it 'should add an error' do
                        instance = subject
                        expect(instance.errors).not_to be_empty
                        expect(instance.errors.first).to eq('Unable to obtain weather data at this moment. Please, try again later.')
                    end
                end

                context 'setting current forecast' do
                    before do
                        data[:current] = nil
                    end

                    it 'should add an error' do
                        instance = subject
                        expect(instance.errors).not_to be_empty
                        expect(instance.errors.first).to eq('Current data not available.')
                    end
                end

                context 'setting forecast_days' do
                    before do
                        data[:forecast][:forecastday] = nil
                    end

                    it 'should add an error' do
                        instance = subject
                        expect(instance.errors).not_to be_empty
                        expect(instance.errors.first).to eq('Extended data not available.')
                    end
                end
            end
        end
    end
end