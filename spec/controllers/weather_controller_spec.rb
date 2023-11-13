require 'rails_helper'

describe WeatherController, type: :controller do

    render_views

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
    let(:cache_key) { "#{Forecast::CACHE_PREFIX}12345" }

    before do
        allow(Services::ForecastRequestor).to receive(:get_for).and_return(data)
        allow(Rails).to receive(:cache).and_return(memory_store)
        Rails.cache.clear
    end

    describe "GET /index" do
        it "renders a successful response" do
          get :index
          expect(response).to be_successful
        end
    end

    describe "POST /retrieve" do

        context 'valid zip code' do

            it "renders a successful response" do
                post :retrieve, params: {address: 'abc 21204'}, xhr: true
                expect(response).to be_successful
                expect(response.body).not_to include("alert-danger")
            end

            it "should render the forecast data" do
                post :retrieve, params: {address: 'abc 21204'}, xhr: true
                expect(response.body).to include("Mc Lean, Virginia")
                expect(response.body).to include("43°")
            end

            it "should not render a cached data alert" do
                post :retrieve, params: {address: 'abc 21204'}, xhr: true
                expect(response.body).not_to include("Cached data")
            end

            context 'and cached data' do
                 before do
                    Rails.cache.write(cache_key, data, expires_in: 3.minute)
                end

                it "should render an alert" do
                    post :retrieve, params: {address: 'abc 12345'}, xhr: true
                    expect(response.body).to include("Cached data")
                end
            end
        end

        context 'invalid zip code' do

            it "renders errors in response" do
                post :retrieve, params: {address: 'abc'}, xhr: true
                expect(response).to be_successful
                expect(response.body).to include("alert-danger")
                expect(response.body).to include("Invalid US address or zip code")
            end
        end
    end
end