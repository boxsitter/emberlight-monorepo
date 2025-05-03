# Project Description: Bessie App, Ember Core, and Ember Fire

## Overview
This document provides a comprehensive description of the three interconnected modules that make up the Bessie application ecosystem:
1. Bessie App - The frontend Flutter application
2. Ember Core - The core business logic and data model library
3. Ember Fire - The Firebase backend implementation

## 1. Bessie App

### Context and Purpose
Bessie is a camp logistics manager application built with Flutter. It serves as the user interface for managing camp-related activities, schedules, and resources.

### Structure
- **Architecture**: Uses the Get package for state management
- **Main Components**:
  - `bessie_app.dart` - Main application entry point
  - `bessie_frontend.dart` - Frontend implementation for Ember Core
  - Pages organized by feature (activity_preferences, etc.)
  - Common services for UI functionality (popup_service, etc.)

### Technical Details
- **Framework**: Flutter
- **State Management**: GetX (get: ^4.7.2)
- **UI Components**: Uses shadcn_ui, lottie animations, and custom components
- **Dependencies**:
  - ember_core - Core business logic
  - ember_fire - Firebase backend
  - Various UI packages (shadcn_ui, lottie, shimmer, etc.)
  - Terminal support via xterm

### Project State
The application appears to be in active development, currently at version 0.1.0.

## 2. Ember Core

### Context and Purpose
Ember Core is the central business logic and data model library that powers the Bessie application. It provides a backend-agnostic interface for data operations and business rules.

### Structure
- **Architecture**: Modular design with clear separation of concerns
- **Main Components**:
  - Models - Core data objects
    - Domain objects (Organization, Branch, Season, Session)
    - Principal objects
    - Dependent objects
    - Schedule blocks
  - Services - Business logic implementations
  - Frontend - Interface for UI components
  - Backend - Interface for data storage implementations

### Technical Details
- **Language**: Dart
- **State Management**: GetX
- **Key Concepts**:
  - Backend interface allowing different implementations
  - Frontend interface for UI integration
  - Commit-based data modification pattern
  - Service-oriented architecture

### Project State
Currently at version 0.1.0, with a well-defined architecture but some implementations marked as TODO.

## 3. Ember Fire

### Context and Purpose
Ember Fire is the Firebase implementation of the backend interface defined in Ember Core. It handles data persistence, real-time updates, and cloud synchronization.

### Structure
- **Architecture**: Implements the CoreBackend interface from Ember Core
- **Main Components**:
  - Repositories
    - PullRepository - Retrieves data from Firebase
    - CommitRepository - Handles data modifications
    - LiveDataRepository - Manages real-time data streams
    - DumbPushRepository - Simple data pushing implementation
  - Services
    - DatabaseRepairService - Handles data integrity
    - PathService - Manages Firebase paths

### Technical Details
- **Backend**: Firebase (Firestore)
- **Key Features**:
  - Real-time data synchronization
  - Collection watching
  - Commit-based data modification
  - Support for both production and emulator environments

### Project State
Currently at version 0.1.0, with some features like deletion still marked as unimplemented.

## System Architecture and Practices

### Overall Architecture
The system follows a clean, layered architecture:
1. **UI Layer** (Bessie App) - Handles user interaction
2. **Business Logic Layer** (Ember Core) - Contains domain models and business rules
3. **Data Layer** (Ember Fire) - Manages data persistence and synchronization

### Development Practices
- **Dependency Injection**: Uses GetX for service location and dependency injection
- **Interface-based Design**: Backend and frontend interfaces allow for different implementations
- **Modular Structure**: Clear separation between modules with well-defined responsibilities
- **Versioning**: All modules currently at 0.1.0

### Data Flow
1. UI triggers actions via the frontend interface
2. Core services process business logic
3. Backend interface handles data persistence
4. Real-time updates flow back through the system

## Integration Points

### Bessie App ↔ Ember Core
- Bessie implements the frontend interface defined in Ember Core
- Uses services from Ember Core for business logic

### Ember Core ↔ Ember Fire
- Ember Fire implements the backend interface defined in Ember Core
- Provides concrete implementations for data operations

## Technical Debt and Future Improvements
- Some methods in Ember Fire are marked as unimplemented (e.g., deleteObject)
- TODOs exist in various parts of the codebase
- The system appears to be in active development with a solid foundation for future enhancements