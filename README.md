# Web Forum API Documentation

The Web Forum API is designed to facilitate interactions within a web forum, allowing for user registrations, login functionalities, category management, and discussion threads creation and management. This documentation outlines the setup, usage, and endpoint details of the API.

## Setup

### Prerequisites

- Docker installed on your machine
- Git (for version control)

### Installation

To get started with the Web Forum API, clone the repository and run the application using Docker.

1. Clone the repository:
   ```bash
   git clone <REPOSITORY_SSH_URL>
   ```

2. Navigate to the project directory:
   ```bash
   cd <PROJECT_DIRECTORY>
   ```

3. Build the Docker image:
   ```bash
   docker build -t web-forum-api .
   ```
   or generate database and networks as well with:
   ```
   bin/docker setup
   ```

4. Run the Docker container:
   ```bash
   docker run -p <API_LISTENING_PORT>:<API_LISTENING_PORT> web-forum
   ```
## API Endpoints
### User Registration Endpoint

**Endpoint:** `POST /user/register`

**Description:** Allows new users to register to the web forum by providing a username, password, and email.

**Request Body:**

```json
{
  "username": "newUser123",
  "password": "userPassword123",
  "email": "newuser123@example.com"
}
```

**Response Codes:**

- `201 Created` - Registration was successful.
- `400 Bad Request` - The provided data was invalid or incomplete.
- `418 I'm a teapot` - The email is already associated with an existing account.

### Login Endpoint

**Endpoint:** `POST /user/login`

**Description:** Authenticates users by verifying their credentials and initiates a session.

**Request Body:**

```json
{
  "username": "existingUser",
  "password": "userPassword123"
}
```

**Successful Response:**

- **Status Code:** `200 OK`
- **Response Body:**

  ```json
  {
    "username": "existingUser",
    "email": "user@example.com"
  }
  ```
- **Response Headers:** Includes a `Set-Cookie` header with a session cookie.

**Error Handling:**

- `401 Unauthorized` - The username or password is incorrect.

### List and Create Categories Endpoint

#### Create Categories

**Endpoint:** `POST /categories`

**Description:** Allows for the creation of new categories within the forum. Requires an admin API key for authentication.

**Headers:** `Token: <admin_api_key>`

**Request Body:**

```json
{
  "categories": ["Technology", "Health"]
}
```

**Response Codes:**

- `201 Created` - Successfully created new categories.

#### List Categories

**Endpoint:** `GET /categories`

**Description:** Retrieves a list of all forum categories, including the default "Default" category.

**Successful Response:**

- **Status Code:** `200 OK`
- **Response Body:** `["Default", "Technology", "Health"]`

**Error Handling:**

- `401 Unauthorized` - Invalid session cookie or admin API key.

### Filter and Create Threads Endpoint

#### Create Thread

**Endpoint:** `POST /thread`

**Description:** Enables authenticated users to create a new thread within a specified category.

**Request Body:**

```json
{
  "category": "Default",
  "title": "Exciting Discussion",
  "openingPost": {
    "text": "Let's talk about something exciting!"
  }
}
```

**Response Codes:**

- `201 Created` - Thread creation was successful.

#### List Threads

**Endpoint:** `GET /thread`

**Description:** Allows users to retrieve a list of threads filtered by categories, authors, or sorting preferences.

**Query Parameters:** `categories=Default&newest_first=true&page=0&page_size=10`

**Successful Response:**

- **Status Code:** `200 OK`
- **Response Body:**

  ```json
  {
    "threads": [
      {
        "id": 1,
        "category": "Default",
        "title": "Exciting Discussion",
        "author": "user123",
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ]
  }
  ```

**Error Handling:**

- `401 Unauthorized` - Requires a valid session cookie.
- `404 Not Found` - Requested category does not exist.


### Get and Create Thread Posts Endpoint

#### Add Posts

**Endpoint:** `POST /thread/post`

**Description:** Allows authenticated users to add one or more posts to an existing thread.

**Request Body:**

```json
{
  "threadId": 1,
  "posts": [
    {"text": "I completely agree with this point!"},
    {"text": "Here's an interesting fact that might add to the discussion..."}
  ]
}
```

**Response Codes:**

- `201 Created` - Successfully added new posts to the thread.

#### Get Posts

**Endpoint:** `GET /thread/post`

**Description:** Retrieves all posts within a specified thread, facilitating continuous conversation flow.

**Query Parameters:** `thread_id=1`

**Successful Response:**

- **Status Code:** `200 OK`
- **Response Body:**

  ```json
  {
    "posts": [
      {
        "author": "user123",
        "text": "I completely agree with this point!",
        "createdAt": "2024-01-01T01:00:00Z"
      },
      {
        "author": "user456",
        "text": "Here's an interesting fact that might add to the discussion...",
        "createdAt": "2024-01-01T02:00:00Z"
      }
    ]
  }
  ```

### Search Endpoint

**Endpoint:** `GET /search`

**Description:** Enables users to search for threads containing specific text, improving discoverability and user engagement.

**Query Parameters:** `text=but smith was actually a banana`

**Successful Response:**

- **Status Code:** `200 OK`
- **Response Body:**

  ```json
  {
    "searchResults": {
      "31": [
        "...astonishing happened – but Smith was actually a banana. This surreal transformation..."
      ],
      "72": [
        "...one amazing day, Smith was actually a banana. What the hell?...."
      ]
    }
  }
  ```

### Delete Thread Endpoint

**Endpoint:** `DELETE /thread`

**Description:** Allows administrators to remove threads, maintaining content quality and relevancy.

**Query Parameters:** `id=2`

**Headers:** `Token: <admin_api_key>`

**Response Codes:**

- `204 No Content` - Thread successfully deleted.

### Delete Categories Endpoint

**Endpoint:** `DELETE /categories`

**Description:** Enables forum administration to dynamically manage forum categories.

**Query Parameters:** `category=Tech`

**Headers:** `Token: <admin_api_key>`

**Response Codes:**

- `200 OK` - Category successfully deleted.

### Import Users via CSV Endpoint

**Endpoint:** `POST /csv`

**Description:** Facilitates bulk user registration through CSV file uploads, streamlining the onboarding process for administrators.

**Headers:** `Token: <admin_api_key>`, `Content-Type: text/csv`

**Request Body:** CSV content following the format `username,password,email`.

**Successful Response:**

- **Status Code:** `201 Created` - Indicates that the users have been successfully registered.

**Error Handling:**

- `400 Bad Request` - Invalid CSV format or user data.
- `200 OK` - Returned on an empty CSV import.

## Environment Variables

The application requires the following environment variables for configuration:

- `ADMIN_API_KEY` - Secret API key for admin endpoints.
- `API_LISTENING_PORT` - Port for the API server.
- `DB_HOST` - Hostname for the database server.
- `DB_PASSWORD` - Database password.
- `DB_PORT` - Database server port.
- `DB_SCHEMA_NAME` - Database schema name.
- `DB_USERNAME` - Username for database access.

## Additional Notes

- **"Default" Category:** This category cannot be deleted and is included by default in the list of categories.
- **Security Measures:** The API is secured against common vulnerabilities, including SQL injection and oversized payloads.
- **Data Validation:** Inputs are validated to prevent malformed requests and ensure data integrity.



