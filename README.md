# Weather APP

Weather APP is an application that displays the current weather and extended forecast for a given US address or zip code. The data is obtained from [Weather API](https://www.weatherapi.com/).

## Features

* Retrieve the current forecast data for the given US address or zip code.
* Include an extended forecast for the next 2 days.
* Cache the forecast data for 30 minutes for next requests with the same zip code.
* Alert the user when the data displayed was pulled from cache.

## Technologies and Dependencies

 * Ruby (3.2.2)
 * Rails (7.0.8)
 * jQuery (1.12.4)
 * Bootstrap (5.3.2)
 * Rspec
 * Haml
 
 ## How to run it in development

* Go to the directory and run bundle install.

    ```bash
    cd forecast_app
    ```
    ```bash
    bundle install
    ```
* Run the following command to enable caching in development.

    ```bash
    rails dev:cache
    ```
* Start the server.

    ```bash
    rails s
    ```

* Go to http://localhost:3000.


 ## How to run the test suite

* You can run all specs with the following command.

    ```bash
    rspec