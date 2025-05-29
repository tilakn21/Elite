# Elite Signboard Management Software

A comprehensive cross-platform application for managing signboard manufacturing operations. Built with Flutter for desktop, web, and mobile platforms.

## Features

### 1. Multi-Role Access
- **Admin Dashboard**: System administration and user management
- **Receptionist Dashboard**: Handle incoming job requests and salesperson allocation
- **Salesperson Dashboard**: Manage site visits and client interactions
- **Design Dashboard**: Design approval workflow and client communication
- **Production Dashboard**: Track manufacturing progress
- **Accounts Dashboard**: Handle invoicing and financial operations
- **Printing Dashboard**: Manage printing operations

### 2. Key Functionalities

#### Receptionist Module
- New job request management
- Salesperson allocation
- Calendar management for appointments
- Job tracking and status updates

#### Salesperson Module
- Site visit management
- Image capture and upload
- Job details collection
- Client communication

#### Design Module
- Design upload and management
- Client approval workflow
- Chat system with image sharing
- Design iteration tracking

#### Production Module
- Job status tracking
- Labor assignment
- Progress monitoring
- Quality control

#### Accounts Module
- Invoice generation
- Payment tracking
- Financial reporting
- Employee payroll

### 3. Technical Features
- Real-time chat with image sharing
- Multi-file upload support
- Responsive UI for all screen sizes
- Offline data persistence
- Cloud storage integration
- Cross-platform compatibility

## Setup

### Prerequisites
- Flutter SDK ^3.6.1
- Dart SDK ^3.6.1
- Supabase account for backend services

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Supabase credentials in `lib/utils/supabase_keys.dart`
4. Run `flutter run` for your target platform

### Dependencies
- Provider for state management
- Supabase for backend services
- File and image picking functionality
- Chart visualization
- Calendar integration
- Custom fonts (Poppins)
