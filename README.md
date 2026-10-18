# Dustbin Finder - Flutter

## Overview

Dustbin Finder is a location-based waste-disposal discovery application that helps users find nearby dustbins, explore their locations on an interactive map, and contribute to the platform by reporting new disposal points.

Built with **Flutter and Dart**, the application connects to a FastAPI backend to retrieve nearby dustbins and submit new locations with supporting details and images.

The platform aims to make waste-disposal points easier to locate while building a community-driven map of accessible dustbins.

## Core Workflows

### 1. Nearby Dustbin Discovery

Users can discover nearby dustbins based on their current location.

```text
User opens the application
          |
          v
Request location permission
          |
          v
Retrieve current coordinates
          |
          v
Request nearby dustbins
          |
          v
Display nearby locations
          |
          v
Explore list or map
          |
          v
Select a dustbin
```

The application presents nearby dustbins in a list and on an interactive map, allowing users to explore available locations and view their details.

### 2. Interactive Map and Navigation

The map provides a visual representation of nearby dustbins and their geographic locations.

```text
Load nearby dustbins
          |
          v
Display map markers
          |
          v
User selects a marker
          |
          v
View dustbin details
          |
          v
Open the location in
an external navigation app
```

OpenStreetMap provides the map interface, while external navigation applications can help users reach a selected dustbin.

### 3. Community Dustbin Contributions

Users can contribute to the platform by submitting dustbins that are not already listed.

```text
User selects Add Dustbin
          |
          v
Capture current location
          |
          v
Enter dustbin information
          |
          v
Capture supporting photo
          |
          v
Submit location and details
          |
          v
FastAPI validates the request
          |
          v
Refresh nearby dustbins
          |
          v
View updated locations
```

The submission workflow collects relevant details, geographic coordinates, and photographic evidence to help expand the platform's coverage.

### 4. Location-Based Data Retrieval

The application communicates with the backend to retrieve location-specific information and submit user contributions.

```text
Flutter application
          |
          v
Dustbin Controller
          |
          v
Repository Layer
          |
          v
Dio API Client
          |
          v
FastAPI Backend
          |
          v
PostgreSQL Database
          |
          v
Return dustbin data
          |
          v
Update application UI
```

The controller manages application state, while the repository handles API communication and response parsing. This separation keeps the interface independent of the underlying data-fetching logic.

## Technology Stack

- **Frontend:** Flutter, Dart
- **State Management:** Riverpod
- **Networking:** Dio
- **Dependency Injection:** GetIt, Injectable
- **Maps:** OpenStreetMap
- **Location Services:** Device geolocation
- **Backend Integration:** FastAPI REST API
- **Image Uploads:** Multipart form-data
- **Platforms:** Android

## Project Goals

- Make nearby waste-disposal locations easy to discover.
- Provide an interactive map for exploring dustbin locations.
- Allow users to contribute missing dustbins with location details and photos.
- Integrate mobile location services with a centralized waste-disposal platform.
- Establish a foundation for community-driven waste-disposal mapping and verification.

