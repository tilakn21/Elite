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
