# Sports betting and leaderboard system
 The system should allow users to place bets, update odds dynamically, and maintain a live leaderboard of top bettors.

## Technologies
  * Ruby
  * Git
  * Rspec
  * Sidekiq
  * redis-server
  * Postgres

## Setup
- Ensure you have [ruby](https://rvm.io/rvm/install) installed on your device and also [redis](https://phoenixnap.com/kb/install-redis-on-mac) for background processes

  ```
   Ruby = 3.3.6
  ```

  Clone this repository and cd into the clone specific folder and run the following command 
  accordingly


  ```
   bundle install
  ```

  ```
   rails db:create 
  ```

  ```
   rails db:migrate
   rails db:seed
  ```

  After to run server

  ```
  rails s
  ```

  ```
  redis-server
  ```

  ```
   sidekiq
  ```

## Test 
To run all test
```
bundle exec rspec 
```

and to run a specific test 
 ```
 rspec 'relative path to file'
 ```

To get the api-doc

vist

base_url/api-docs/index.html

## Set Environment Variables
Create a .env file in the root of your Rails project and follow the pattern of variables in env.example
