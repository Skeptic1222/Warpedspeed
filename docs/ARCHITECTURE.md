# Warped Speed - Architecture Documentation

## System Overview

Warped Speed uses a modern web architecture with a clear separation of concerns between frontend, backend, database, and AI services. The system is designed to be modular, scalable, and maintainable with a focus on database-driven content.

```
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│   Frontend    │     │    Backend    │     │   Database    │
│   (React)     │◄───►│  (Node.js)    │◄───►│   (SQL)       │
└───────────────┘     └───────┬───────┘     └───────────────┘
                              │
                              ▼
                      ┌───────────────┐
                      │ External APIs │
                      │ (OpenAI/Dzine)│
                      └───────────────┘
```

## Frontend Architecture

### Core Principles

1. **Component-Based Structure**
   - Reusable UI components
   - Clear component hierarchy
   - React hooks for stateful logic

2. **State Management**
   - React Context for global state
   - Redux for complex state requirements
   - Local component state for UI-specific concerns

3. **Styling**
   - CSS modules for component scoping
   - Database-driven styling variables
   - Responsive design patterns

### Key Components

1. **App Container**
   - Main layout structure
   - Route definitions
   - Global providers

2. **Game UI**
   - Narrative display
   - Action buttons system
   - Status displays
   - Image display

3. **Character Creation**
   - Step-by-step creation process
   - Dynamic form elements
   - Validation and confirmation

4. **Inventory System**
   - Grid-based inventory display
   - Item interaction
   - Equipment management

5. **Map System**
   - 100x100 grid rendering
   - Panning and zooming
   - Points of interest

## Backend Architecture

### API Layer

The backend provides a RESTful API for the frontend with the following endpoints:

1. **Game State**
   - `/api/game/state` - Get/update game state
   - `/api/game/save` - Save current game
   - `/api/game/load` - Load saved game

2. **Content Generation**
   - `/api/generate/text` - Generate narrative text
   - `/api/generate/actions` - Generate action buttons
   - `/api/generate/image` - Generate images

3. **Database Operations**
   - `/api/db/query` - Execute database queries
   - `/api/db/character` - Character CRUD
   - `/api/db/location` - Location CRUD
   - `/api/db/item` - Item CRUD

4. **User Management**
   - `/api/user/auth` - Authentication
   - `/api/user/profile` - User profile
   - `/api/user/settings` - User settings

### Service Layer

The service layer contains the business logic of the application:

1. **GPT Service**
   - Handles prompt construction
   - Manages API calls to OpenAI
   - Processes and formats responses

2. **Image Service**
   - Image generation coordination
   - Database lookup before generation
   - Storage of generated images

3. **Game Logic Service**
   - Core game rules implementation
   - State transitions
   - Event handling

4. **Database Service**
   - Database connection management
   - Query execution
   - Transaction handling

### Middleware

1. **Authentication**
   - JWT validation
   - Session management
   - Authorization checks

2. **Error Handling**
   - Centralized error processing
   - Consistent error responses
   - Logging and monitoring

3. **Rate Limiting**
   - API request throttling
   - Protection against abuse
   - Fair usage enforcement

4. **Caching**
   - Response caching
   - Query result caching
   - Resource optimization

## Database Architecture

### Database Systems

The primary database is SQL Server, chosen for its robustness, transaction support, and advanced features.

### Schema Structure

The database is organized into logical groups:

1. **Game Content**
   ```
   characters
   locations
   items
   quests
   lore
   ```

2. **Media Assets**
   ```
   images
   audio
   videos
   ```

3. **User Data**
   ```
   users
   saves
   preferences
   ```

4. **System Configuration**
   ```
   settings
   ui_config
   game_rules
   ```

5. **Prompt Templates**
   ```
   prompts
   prompt_variables
   prompt_categories
   ```

### Data Access Patterns

1. **Repository Pattern**
   - Encapsulated data access logic
   - Type-safe query methods
   - Business logic isolation

2. **Query Builder**
   - Dynamic query construction
   - Parameterized queries
   - SQL injection prevention

3. **Stored Procedures**
   - Complex operations at database level
   - Performance optimization
   - Reduced network overhead

## AI Integration Architecture

### OpenAI GPT Integration

1. **Prompt Management**
   - Database-stored prompt templates
   - Dynamic variable substitution
   - Context window optimization

2. **Role-Based GPT Usage**
   - Narrator GPT for story generation
   - Combat GPT for battle sequences
   - Dialogue GPT for conversations
   - World-building GPT for environments

3. **Response Processing**
   - JSON extraction from responses
   - Error handling and retries
   - Content filtering

### Image Generation

1. **Dzine API Pipeline**
   - Request submission
   - Polling mechanism
   - Response handling

2. **Database Integration**
   - Image categorization
   - Metadata storage
   - Binary storage options

3. **Fallback Mechanisms**
   - DALL-E as backup
   - Cached images as fallback
   - Default placeholders

## Application Flow

### Startup Sequence

1. Load environment configuration
2. Initialize database connections
3. Start Express server
4. Load system settings from database
5. Initialize middleware
6. Register API routes
7. Start listening on configured port

### Request Lifecycle

1. Client makes request to API endpoint
2. Middleware processes request (auth, validation)
3. Route handler receives request
4. Service layer processes business logic
5. Database operations executed if needed
6. External API calls made if needed
7. Response formatted and returned
8. Client renders updates based on response

### Game Loop

1. Player selects action
2. Action sent to server
3. Server processes action logic
4. Narrative generation triggered
5. Response returned with new game state
6. Client updates UI with new state
7. New actions generated from context

## Deployment Architecture

### Development Environment

- Local Node.js development server
- Local or dockerized SQL Server
- Environment variables for API keys

### Testing Environment

- CI/CD pipeline with automated tests
- Test database with seed data
- Mocked external API responses

### Production Environment

- Node.js server on hosting platform
- Production SQL Server instance
- CDN for static assets
- Environment variable security

## Security Architecture

1. **Authentication**
   - JWT-based authentication
   - Secure password handling
   - Session management

2. **Data Protection**
   - HTTPS for all communications
   - Encryption of sensitive data
   - Input validation and sanitization

3. **API Security**
   - API key management
   - Rate limiting
   - CORS configuration

4. **External Service Security**
   - Secure handling of third-party API keys
   - Validation of external responses
   - Fallback mechanisms for service outages

## Performance Optimization

1. **Frontend Optimization**
   - Code splitting
   - Lazy loading
   - Asset optimization

2. **Backend Optimization**
   - Query optimization
   - Connection pooling
   - Response caching

3. **AI Request Optimization**
   - Batch processing where possible
   - Context window management
   - Prompt optimization

## Error Handling Architecture

1. **Client-Side Error Handling**
   - Global error boundary
   - Graceful fallbacks
   - User-friendly error messages

2. **Server-Side Error Handling**
   - Centralized error middleware
   - Structured error logging
   - Error classification

3. **Database Error Handling**
   - Transaction rollbacks
   - Connection retry logic
   - Data validation

4. **External API Error Handling**
   - Retry mechanisms with backoff
   - Fallback content strategies
   - Circuit breaker pattern

## Extensibility

The architecture is designed to be extensible in several ways:

1. **Genre Adaptation**
   - Database-driven content enables complete genre changes
   - Prompt templates can be updated to change tone and style
   - UI theming controlled via database

2. **Feature Expansion**
   - Modular services allow for new features
   - Consistent API patterns for new endpoints
   - Component system for UI extensions

3. **Integration Points**
   - Well-defined interfaces for new services
   - Middleware hooks for cross-cutting concerns
   - Event system for loose coupling

## Conclusion

This architecture provides a solid foundation for the Warped Speed rebuild, emphasizing database-driven content, modular design, and separation of concerns. By following these architectural guidelines, the system will be maintainable, extensible, and capable of supporting all planned phases of development. 