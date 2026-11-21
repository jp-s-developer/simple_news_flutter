# Simple News App – Flutter

A modern, responsive Flutter News Application that fetches and displays the latest space-related news articles using the **Spaceflight News API v4**.

The application is built using Flutter and Dart, following the MVVM (Model-View-ViewModel) architecture with Provider for state management and Dio for REST API integration.

The application supports Android and iOS devices with responsive layouts for mobile phones, tablets, and iPads.

## 1. Features

### News Listing
- Fetch and display news articles from the Spaceflight News API.
- Display article thumbnail, title, news source, and published date.
- Search articles by title.
- Infinite scrolling with pagination.
- Pull-to-refresh functionality.
- Loading, empty, and error states.

### Article Details
- Display full article information.
- Show article image, title, news source, published date, and summary.
- Open the original article using the Read Full Article button.
- Swipe left and right to navigate between articles.
- Automatically fetch the next page when reaching the end of the loaded articles.

### UI and User Experience
- Responsive design for mobile, tablet, and iPad.
- Light and dark theme support.
- Cached network images.
- Reusable UI components.
- Smooth navigation and interactions.
- Proper loading indicators and error messages.

## 2. Project Setup and Installation

### Prerequisites

Make sure the following tools are installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android SDK / Xcode (for iOS development)
- Git

Check Flutter installation:

```bash
flutter doctor
```

### Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
```

Navigate to the project directory:

```bash
cd space_news_flutter
```

### Install Dependencies

```bash
flutter pub get
```

### Run the Application

```bash
flutter run
```

### Build APK

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ios --release
```

Note: iOS builds require macOS and Xcode.

### Analyze the Project

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

## 3. API Integration

This application uses the Spaceflight News API v4 to retrieve news articles.

**API Documentation:**

https://api.spaceflightnewsapi.net/v4/docs/

**Articles Endpoint:**

```http
GET https://api.spaceflightnewsapi.net/v4/articles/
```

**Search Articles:**

```http
GET https://api.spaceflightnewsapi.net/v4/articles/?title_contains=cricket
```

**Article Details:**

```http
GET https://api.spaceflightnewsapi.net/v4/articles/{id}
```

The application uses Dio to manage HTTP requests, API responses, request timeouts, and error handling.

## 4. Architecture Overview

The application follows the **MVVM (Model-View-ViewModel)** architecture.

The architecture separates the UI, business logic, data management, and API communication to improve maintainability, scalability, and testability.

### Architecture Layers

**1. Model**
- Defines the structure of news articles.
- Handles JSON serialization and deserialization.
- Manages nullable API response fields.

**2. View**
- Displays news articles and article details.
- Handles user interactions.
- Uses reusable widgets and responsive layouts.

**3. ViewModel**
- Manages application state using ChangeNotifier.
- Handles loading, success, empty, and error states.
- Manages search, pagination, and refresh operations.
- Communicates with the repository layer.

**4. Repository**
- Acts as an intermediary between ViewModel and API services.
- Manages news data retrieval.
- Separates data operations from UI logic.

**5. API Service**
- Handles HTTP requests using Dio.
- Manages API endpoints and response parsing.
- Handles network errors and request timeouts.

### Architecture Flow

```text
        UI / View
            |
            v
        ViewModel
       (Provider)
            |
            v
        Repository
            |
            v
        API Service
          (Dio)
            |
            v
    Spaceflight News API
            |
            v
        JSON Response
            |
            v
        Data Model
            |
            v
       Update UI
```

## 5. Project Structure

```text
space_news_flutter/
│
├── android/
├── ios/
├── assets/
│
├── lib/
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart
│   │   │   └── api_exception.dart
│   │   │
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   │
│   │   └── utils/
│   │
│   ├── data/
│   │   ├── models/
│   │   │   └── article_model.dart
│   │   │
│   │   └── repositories/
│   │       └── news_repository.dart
│   │
│   ├── presentation/
│   │   ├── viewmodels/
│   │   │   └── news_viewmodel.dart
│   │   │
│   │   ├── views/
│   │   │   ├── news_list_screen.dart
│   │   │   └── news_detail_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── article_card.dart
│   │       ├── loading_widget.dart
│   │       ├── error_widget.dart
│   │       └── empty_widget.dart
│   │
│   └── main.dart
│
├── test/
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## 6. Packages and Dependencies

The following packages are used to implement the application.

| Package | Purpose |
|---|---|
| flutter | Cross-platform application development |
| dio | REST API integration and HTTP requests |
| provider | State management using ChangeNotifier |
| cached_network_image | Network image caching |
| intl | Date and time formatting |
| url_launcher | Open original news articles in a browser |
| flutter_lints | Code quality and linting |

Install the packages using:

```bash
flutter pub add dio provider cached_network_image intl url_launcher
```

For development:

```bash
flutter pub add --dev flutter_lints
```

## 7. State Management

Provider is used for application state management through ChangeNotifier.

The NewsViewModel manages:

- News article list.
- Loading state.
- Search query.
- Pagination and next-page loading.
- Pull-to-refresh.
- API error handling.
- Empty search results.
- Article navigation.

This approach keeps business logic separate from UI components and makes the application easier to maintain and test.

## 8. Assumptions and Implementation Details

### API Data
- The Spaceflight News API v4 is used as the primary news data source.
- The application uses the API-provided article information.
- Categories and trending labels are not directly available in the API, so the news source (`news_site`) is used where appropriate.
- Author avatars are not available consistently, so fallback UI is used where necessary.

### Search
- Search functionality uses the API's `title_contains` parameter.
- Search requests should be debounced to avoid unnecessary API calls.
- Search results are displayed independently from the default news list.

### Pagination
- Articles are loaded page by page.
- Additional articles are requested when the user approaches the end of the list.
- Duplicate requests are prevented while a pagination request is in progress.
- Pagination errors provide a retry option.

### Image Handling
- CachedNetworkImage is used for loading and caching article images.
- Placeholder widgets are displayed while images load.
- Fallback UI is displayed when an image is missing or fails to load.

### Error Handling
The application handles:

- No internet connection.
- API request failures.
- Request timeouts.
- Empty API responses.
- Missing or null JSON fields.
- Search results not found.
- Pagination failures.

Retry actions are provided wherever appropriate.

### Responsive Design
- MediaQuery and LayoutBuilder are used to calculate available screen space.
- Mobile devices use a single-column article list.
- Tablets and iPads use wider layouts or multi-column layouts where appropriate.
- UI components adapt to different screen sizes.

### Navigation
- Users can navigate between the article list and detail screens.
- Swipe navigation supports moving between previously loaded and next articles.
- When the user reaches the end of the loaded articles, the next page is fetched.

### Theme
- Light and dark themes are supported.
- Text, backgrounds, and UI components adapt to the selected theme.

### Resource Management
- Controllers and listeners are properly disposed of.
- Search debounce resources are cancelled when no longer required.
- API calls and pagination are managed to avoid unnecessary requests.

## 9. Testing and Code Quality

The following checks are recommended before submitting the application:

- Validate API response parsing.
- Test news listing and article details.
- Test search functionality.
- Test pagination and pull-to-refresh.
- Test swipe navigation.
- Test loading, empty, and error states.
- Test responsive layouts on different screen sizes.
- Verify light and dark themes.
- Run Flutter analyzer.
- Execute unit and widget tests.

Commands:

```bash
flutter analyze
flutter test
```

## 10. Limitations

- News content depends on the availability of the external API.
- Internet connectivity is required to retrieve new articles.
- Some articles may not contain images or complete descriptions.
- API response speed depends on the external server.
- Offline article browsing is not included unless local persistence is implemented.

## 11. Future Enhancements

- Bookmark and save favorite articles.
- Offline reading support.
- Push notifications for new articles.
- Advanced search and filtering.
- Share articles with other applications.
- Local database integration.
- Automated unit and widget testing.

## 12. Screenshots and Demo

Add application screenshots below after capturing them from the running application.

```text
screenshots/
├── news_list.png
├── news_search.png
├── news_details.png
└── dark_theme.png
```

You can also add a short demo video demonstrating:

1. News listing.
2. Search functionality.
3. Pull-to-refresh.
4. Infinite scrolling.
5. Article detail navigation.
6. Swipe navigation.
7. Responsive UI.

## 13. Author

**Mobile Application Developer**

Technologies: Flutter | Dart | Provider | Dio | MVVM

GitHub: https://github.com/jp-s-developer/simple_news_flutter.git


---

**Note:** This project was developed to demonstrate Flutter application development, REST API integration, MVVM architecture, Provider state management, pagination, error handling, and responsive UI development.
