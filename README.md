# Elite Signs Management System

A comprehensive internal management system for Elite Signs, built with Flutter and Supabase.

## Features

- Role-based access control (RBAC)
- Cross-platform support (Web, Android, iOS, macOS, Linux, Windows)
- Real-time updates and notifications
- Secure authentication and data handling
- Role-specific dashboards and functionality

## User Roles

- Admin
- Project Director
- Sales Director
- Marketing Director
- Receptionist
- Salesperson
- Designer
- Production Manager
- Printing Manager
- Accountant
- Labor/Drivers

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Real-time**: Supabase Realtime
- **Storage**: Supabase Storage

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Supabase account and project

### Environment Setup

1. Clone the repository
2. Create a `.env` file in the root directory with the following variables:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

### Installation

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Generate code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── services/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── jobs/
│   ├── appointments/
│   ├── employees/
│   ├── orders/
│   ├── reports/
│   └── settings/
├── models/
├── providers/
├── routes/
└── widgets/
```

## Database Schema

The application uses the following main tables in Supabase:

- `profiles`: User profiles and role information
- `jobs`: Job tracking and management
- `appointments`: Customer appointments
- `orders`: Order processing
- `employees`: Employee information
- `documents`: File storage and management

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
