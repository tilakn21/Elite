# Receptionist Dashboard
This folder contains all widgets and pages specific to the Receptionist dashboard UI.

## Backend Readiness Update (May 2025)

The Receptionist module has been updated to prepare for backend integration. Key changes include:

### 1. Data Models (`models/`)
- **`job_request.dart`**:
    - `JobRequest` and `ReceptionistJob` models updated with an `id` field.
    - Serialization methods renamed from `fromMap`/`toMap` to `fromJson`/`toJson` for consistency.
- **`salesperson.dart`**:
    - `Salesperson` model updated with an `id` field.
    - Serialization methods renamed from `fromMap`/`toMap` to `fromJson`/`toJson`.

### 2. Service Layer (`services/`)
- **`receptionist_service.dart`**:
    - Created to handle business logic and data fetching for job requests and salespersons.
    - Currently uses mock data but is structured for future API integration.
    - Provides methods for:
        - Fetching job requests and salespersons.
        - Adding new job requests.
        - Updating job request statuses.
        - Updating salesperson statuses.

### 3. State Management (`providers/`)
- **`job_request_provider.dart`**:
    - Manages state for job requests using `ChangeNotifier`.
    - Interacts with `ReceptionistService` for data operations.
- **`salesperson_provider.dart`**:
    - Manages state for salespersons using `ChangeNotifier`.
    - Interacts with `ReceptionistService` for data operations.

### 4. Provider Registration (`lib/main.dart`)
- `ReceptionistService`, `JobRequestProvider`, and `SalespersonProvider` have been registered in `main.dart` to make them available throughout the widget tree.

### 5. Import Path Adjustments
- Import paths within the Receptionist module files (service, providers) were updated to use relative paths (e.g., `../models/job_request.dart`) to resolve "Target of URI doesn't exist" lint errors that occurred with package-style imports.

These changes lay the groundwork for connecting the Receptionist module to a live backend, enabling dynamic data handling.

## File Functionality

This section provides an overview of each file within the Receptionist module.

### `models/`
- **`job_request.dart`**: Defines the `JobRequest` class, representing a customer's request for a job, and the `ReceptionistJob` class. It includes properties like customer details, job status, and relevant dates. It also contains `fromJson` and `toJson` methods for data serialization.
- **`models.dart`**: This file appears to be a barrel file, intended to export other model files from this directory. Currently, it is empty.
- **`salesperson.dart`**: Defines the `Salesperson` class, representing a salesperson with properties like name, status (e.g., available, busy), and avatar. It includes `fromJson` and `toJson` methods for data serialization.

### `providers/`
- **`job_request_provider.dart`**: A `ChangeNotifier` provider that manages the state of job requests. It fetches job requests using `ReceptionistService`, handles loading and error states, and provides methods to add new job requests and update their status.
- **`salesperson_provider.dart`**: A `ChangeNotifier` provider that manages the state of salespersons. It fetches salesperson data using `ReceptionistService`, handles loading and error states, and provides a method to update salesperson status.

### `screens/`
- **`assign_salesperson_screen.dart`**: This screen provides the UI for assigning an available salesperson to an unassigned job request. It displays lists of unassigned jobs and available salespersons, allowing the receptionist to make an assignment.
- **`dashboard_screen.dart`**: The main dashboard screen for the receptionist. It displays an overview of key information using various cards, such as new job requests, sales allocation, job request overview, and a calendar.
- **`new_job_request_screen.dart`**: This screen provides a form for the receptionist to create and submit a new job request. It includes fields for customer details, shop information, address, visit details, and salesperson assignment.
- **`view_all_jobs_screen.dart`**: This screen displays a comprehensive list of all job requests in a tabular format. It allows the receptionist to view details of each job and their current status (e.g., assigned, unassigned).

### `services/`
- **`receptionist_service.dart`**: This service class encapsulates the business logic for fetching and managing receptionist-related data. It includes methods to:
    - Fetch job requests and salespersons (initially from mock data, with added methods for Supabase integration).
    - Add new job requests.
    - Update the status of job requests and salespersons.
    - Interact with a Supabase backend for persisting and retrieving job and employee (salesperson) data.

### `widgets/`
- **`calendar_card.dart`**: A widget that displays a monthly calendar view. It's used on the dashboard to provide a visual representation of dates.
- **`job_requests_overview_card.dart`**: A dashboard card widget that presents an overview of job requests, typically using a bar chart to show monthly counts.
- **`new_job_request_card.dart`**: A dashboard card widget that displays a summary list of new job requests, showing key details like name, phone, email, and status.
- **`sales_allocation_card.dart`**: A dashboard card widget that shows the current status (e.g., available, unavailable) of salespersons.
- **`sidebar.dart`**: A reusable sidebar widget for navigation within the receptionist dashboard. It includes links to different screens like Dashboard and New Request, and a logout button.
- **`topbar.dart`**: A reusable top bar widget displayed at the top of receptionist screens. It shows the screen title, user information, and potentially a search bar and notification icons depending on the context (dashboard or other screens).
