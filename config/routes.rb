Rails.application.routes.draw do
  get 'weather/index'
  post 'weather/retrieve'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
   root to: "weather#index"
end
