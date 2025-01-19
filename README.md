# Sports Betting and Leaderboard System

The system should allow users to place bets, update odds dynamically, and maintain a live leaderboard of top bettors.

## Technologies
- Ruby
- Git
- RSpec
- Sidekiq
- Redis
- PostgreSQL

## Setup
1. Ensure you have [Ruby](https://rvm.io/rvm/install) installed on your device and also [Redis](https://phoenixnap.com/kb/install-redis-on-mac) for background processes.
   ```
   Ruby = 3.3.6
   ```

2. Clone this repository and navigate into the cloned folder, then run the following commands:
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

3. To run the server:
   ```
   rails s
   ```
   ```
   redis-server
   ```
   ```
   bundle exec sidekiq
   ```

## Test 
To run all tests:
```
bundle exec rspec 
```
To run a specific test:
```
rspec 'relative path to file'
```

## API Documentation
Visit the API documentation at:
```
http://localhost:3000/api-docs/index.html


https://github.com/EfeAgare/sport-betting-system/blob/main/swagger/v1/swagger.yaml
```

## Architecture
The application follows the MVC (Model-View-Controller) architecture. The key components include:
- **Models**: Represent the data and business logic.
- **Views**: Handle the presentation layer.
- **Controllers**: Manage the flow of data between models and views.

