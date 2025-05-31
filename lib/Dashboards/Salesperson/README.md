# Salesperson Dashboard

This folder contains all widgets and pages specific to the Salesperson dashboard UI.

## Recent Updates (May 2025)

- **Integration with Receptionist Module**: The Salesperson module now works in conjunction with the Receptionist module for job request assignments.
- **Status Management**: Salespersons can update their status (e.g., available, on a visit, busy) which is reflected in the Receptionist's view.
- **Profile Management**: Includes functionality for salespersons to manage their profiles and view assigned jobs.

## Features
- View assigned job requests
- Update job status
- Manage availability
- View customer details for assigned jobs

## Codebase Overview

This module is organized into three main directories: `models`, `screens`, and `widgets`.

### `models`
Contains the data structures used within the Salesperson module.
- **`salesperson_job_details.dart`**: Defines the `SalespersonJobDetails` class, which models the detailed information for a job, including customer details, job specifications, materials, timings, and measurements. It includes methods for serialization and deserialization (`fromMap`, `toMap`).
- **`salesperson_profile.dart`**: Defines the `SalespersonProfile` class, representing the profile information of a salesperson, such as name, phone number, email, and age. It includes `fromMap` and `toMap` methods for data handling.
- **`site_visit_item.dart`**: Defines the `SiteVisitItem` class, used to represent a job item in lists, typically on the home screen. It includes details like site ID, customer name, date, submission status, and the raw JSON data for the job, salesperson, and receptionist.

### `screens`
Contains the main UI pages for the Salesperson dashboard.
- **`details_screen.dart`**: Implements the UI for viewing and editing the details of a specific job. It allows salespersons to input information like material, tools, production/fitting times, measurements, and add images. It handles image picking (camera/gallery) and submission of job details to a Supabase backend, including image uploads.
- **`home_screen.dart`**: The main dashboard screen for salespersons. It displays a list of assigned jobs (`SiteVisitItem`), fetches data from Supabase, and allows navigation to the `SalespersonDetailsScreen` for pending jobs. It shows job status (Pending/Submitted).
- **`profile_screen.dart`**: Displays the salesperson's profile information, fetched from a Supabase `employee` table. It also includes a logout functionality.

### `widgets`
Contains reusable UI components used across different screens in the Salesperson module.
- **`salesperson_sidebar.dart`**: Implements the navigation sidebar for the Salesperson dashboard, allowing users to switch between "Home" and "Profile" sections. It adapts its layout for mobile and desktop views.
- **`salesperson_topbar.dart`**: Implements the top app bar for the Salesperson dashboard. It displays the "Salesperson" title and a menu button for mobile view to toggle the sidebar.
