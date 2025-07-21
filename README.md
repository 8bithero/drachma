# Getting Started

## Installation
```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Start the server
rails server
```

---
## API Endpoints

```ruby
POST   /api/v1/auth/login
DELETE /api/v1/auth/logout
POST   /api/v1/auth/refresh

POST   /api/v1/users
GET    /api/v1/users/:id

GET    /api/v1/statements
GET    /api/v1/statements/:slug
POST   /api/v1/statements/:slug/line_items
GET    /api/v1/statements/:slug/line_items

GET    /api/v1/line_items
GET    /api/v1/line_items/:id
PUT    /api/v1/line_items/:id
DELETE /api/v1/line_items/:id
```

**Points of interest**
- The `:slug` needs to be in the format `YYYY-MM` as it represents a date
- The `GET /api/v1/statements` and `GET /api/v1/statements/:slug` support the query param `?include_line_items=true` which returns all related line items. This is too illustrate how filtered or scopped params can be added in the future

___
## API Usage
‼️ Included in the repository is a **postman collection**  [`Drachma.postman_collection.json`](Drachma.postman_collection.json)

Ordinarily you would first need to hit the `auth/login` endpoint and copy the `access_token` that is returned to be used with the header
```javascript
Authentication: Bearer {{access_token}}
```

However if you use the postman collection, all saving of access_tokens is handled automatically using scripts included in the collection.

---
## Tests
Tests can be run with the following
```bash
# Run all tests
rails test

# Run the following if you want to measure test coverage
COVERAGE=true rails test
```

---
# Architecture & Design Patterns

## Controllers
For the majority of the endpoints, controllers act as orchestrators, and not business processors. This approach improves readability and reducing entanglement.

---
## Models
Although some logic remains in the models, rather than relying on ActiveRecord models as behavioural units ("fat model"), the system pushes business operations into discrete service classes that adhere to Single Responsibility Principles and statelessness.

---
## Authentication
### JWT Authentication with Refresh Tokens

For authentication I have implemented a secure **dual-token authentication system**.
Users login by sending their email and password to the login endpoint.
In response they will receive an **access_token** and a **refresh_token**.

- **Access Tokens**: Short-lived JWT tokens for API access
- **Refresh Tokens**: Long-lived secure random tokens for token renewal
- **Token Rotation**: New refresh tokens generated on each refresh

---
## Services
The application extensively uses the **Service Object Pattern** for business logic encapsulation and heavily leans into functional programming principles:

- **Base Service Class**: All services inherit from `BaseService` and use the `dry-monads` gem for functional programming patterns
- **Result Objects**: Services return `Success` or `Failure` monads for predictable error handling
- **Single Responsibility**: Each service handles one specific business operation
- **Stateless / Immutable Data Flow**: Data tends to be treated as immutable to avoid side affects outside their boundaries.
- **Functional Programming Influence**: Services use `bind` operations for service composition (Implementing `dry-transactions` be a logical future improvement)

---
## Serializers
Instead of using gems like `active_model_serializers`, the app implements custom serializer classes:
- Consistent JSON output formatting
- Conditional field inclusion (e.g., include_line_items option)
- Collection serialisation support
- Clean separation of presentation logic

---
## Why did you do that?

### Why Service Objects?
- **Testability**: Easy to unit test business logic in isolation
- **Reusability**: Services can be composed and reused across controllers
- **Maintainability**: Clear separation of concerns and single responsibility
- **Error Handling**: Consistent pattern for handling success/failure scenarios

### Why Custom Serializers?
- **Control**: Full control over JSON output format
- **Performance**: No extra gem dependencies or magic
- **Flexibility**: Easy to add conditional fields and custom formatting
- **Simplicity**: Straightforward implementation without complex DSLs

### Why Dual Token Authentication?
- **Security**: Short-lived access tokens limit exposure window
- **User Experience**: Long-lived refresh tokens prevent frequent re-authentication
- **Flexibility**: Can revoke refresh tokens for immediate logout across devices
- **Scalability**: Stateless access tokens work well with horizontal scaling
