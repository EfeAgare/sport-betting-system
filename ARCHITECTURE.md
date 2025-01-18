# Architecture Documentation

## Overview
This application is a sports betting platform that allows users to register, place bets, and receive real-time updates on game statuses and leaderboards. It utilizes a RESTful API built with Ruby on Rails, along with WebSocket for real-time communication, Redis for caching and pub/sub messaging, and background jobs for processing tasks.

## Components

### 1. Controllers
- **BetsController**: Manages user bets, including creating new bets, retrieving all bets for a user, and fetching betting history.
- **EventsController**: Handles the creation and updating of events related to games.
- **GamesController**: Manages game data, including creating new games and retrieving game information.
- **SessionsController**: Handles user authentication, including login and logout functionality.
- **RegistrationsController**: Manages user registration and token generation upon successful signup.
- **UsersController**: Handles user-related actions, such as listing users and updating user information.

### 2. Models
- **User**: Represents a user in the system, including attributes for email, username, and balance. It manages user authentication and associations with bets.
- **Bet**: Represents a bet placed by a user on a game, including validations for amount, type, and odds.
- **Event**: Represents an event that occurs within a game, with validations for event type, team, player, and minute.
- **Game**: Represents a game that users can place bets on, including validations for teams, scores, and status.
- **JwtBlacklist**: Manages blacklisted JWT tokens to prevent reuse.

### 3. Services
- **GameService**: Provides methods for retrieving games with pagination and date filtering, as well as clearing cached game data.
- **LeaderboardService**: Manages leaderboard data, including updating user stats and calculating leaderboard rankings.
- **BettingOddsService**: Calculates betting odds based on the total bets placed on a game.

### 4. Validators
- **BetValidator**: Validates the parameters for creating a bet, ensuring all required fields are present and valid.
- **EventValidator**: Validates the parameters for creating and updating events.
- **GameValidator**: Validates the parameters for creating a game.
- **RegistrationValidator**: Validates user registration parameters.
- **SessionValidator**: Validates user login parameters.

### 5. Middleware
- **Authenticable**: Provides methods for user authentication, including token validation and user retrieval.
- **ErrorHandling**: Centralizes error handling for various exceptions, providing standardized error responses.

### 6. Background Jobs
- **LeaderboardUpdateJob**: A background job that updates the leaderboard asynchronously.

### 7. Caching and Pub/Sub
- **Redis**: Used for caching data and implementing a pub/sub mechanism to broadcast game updates and leaderboard changes to connected clients.

## Data Flow
1. **User  Registration**: Users can register through the `RegistrationsController`, which validates input and creates a new user.
2. **User  Authentication**: Users log in via the `SessionsController`, which validates credentials and generates a JWT token.
3. **Placing Bets**: Users place bets through the `BetsController`, which validates the bet parameters, checks the user's balance, and saves the bet.
4. **Real-Time Updates**: The application uses WebSocket (via Socket.IO) to send real-time updates to clients when game events occur or when leaderboard data changes.
5. **Data Storage**: All data is stored in a relational database (e.g., PostgreSQL), with Redis used for caching and pub/sub messaging.

## Error Handling
- The application includes robust error handling for various scenarios, including:
  - **Record Not Found**: Returns a 404 error if a requested resource does not exist.
  - **Validation Errors**: Returns a 422 error with validation messages if input data is invalid.
  - **Unauthorized Access**: Returns a 401 error if authentication fails.
  - **Insufficient Balance**: Returns a 422 error if a user attempts to place a bet exceeding their balance.

## Deployment
- **Environment Variables**: Ensure the following environment variables are set:
  - `HMAC_SECRET`: Secret key for JWT encoding.
  - `HMAC_ALGORITHM`: Algorithm used for JWT encoding.
  - `BASE_URL`: Base URL for external API calls.
  - `REDIS_URL`: Connection string for Redis.
- **Dependencies**: Install dependencies using `bundle install`.

## Setup Instructions
1. Clone the repository.
2. Run `bundle install` to install dependencies.
3. Set up environment variables in a `.env` file.
4. Start the server with `rails server`.

## Conclusion
This documentation provides an overview of the architecture and components of the application. For further details, refer to the code comments and individual component documentation.
