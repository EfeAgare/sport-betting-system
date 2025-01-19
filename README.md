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

## Deployment
To deploy the application to Render, follow these steps:

1. **Configure Environment Variables**:
   - Set the following environment variables in Render:
     - `RAILS_MASTER_KEY`: Your Rails master key.
     - `REDIS_URL`: The URL for your Redis instance.

2. **Update `config/deploy.yml`**:
   - Ensure that the `config/deploy.yml` file is correctly configured with your application name, image, and server details.

3. **SSL Configuration**:
   - Make sure SSL is enabled in your deployment configuration.

4. **Job Processing with Sidekiq**:
   - Configure Sidekiq to run in the background by setting `SOLID_QUEUE_IN_PUMA` to true in your environment variables.


## API Documentation
Visit the API documentation at:
```
http://localhost:3000/api-docs/index.html
https://github.com/EfeAgare/sport-betting-system/blob/main/swagger/v1/swagger.yaml
```
