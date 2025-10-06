# PocketGPT iOS

PocketGPT is a SwiftUI iOS 17+ client for the PocketGPT backend. It supports streaming ChatGPT-style conversations, offline caching, OAuth integrations, and configurable model settings.

## Features

- SwiftUI chat experience with live streaming tokens
- Conversation list with rename/delete stubs
- SQLite-based offline cache for chat metadata
- SSE client built on `URLSession` async bytes
- Keychain storage for access tokens
- Settings screen with model controls and integration toggles
- OAuth launchers for Google Calendar and Notion
- Unit tests covering the SSE parser

## Requirements

- Xcode 15+
- iOS 17 simulator or device
- Swift Package Manager (no external dependencies)

## Configuration

Create a `.env.example` file for build-time configuration:

```
BASE_URL=https://api.pocketgpt.local
BUILD_ENV=development
```

Populate these values via Xcode build settings or a build script. The app reads the base URL from the `POCKETGPT_BASE_URL` Info.plist entry.

## Running the App

1. Open `PocketGPT/Package.swift` in Xcode. The SwiftPM manifest generates an iOS application target.
2. Update the signing team identifier in `Package.swift` if needed.
3. Provide a valid backend base URL via Info.plist (Key: `POCKETGPT_BASE_URL`).
4. Build and run on an iOS 17 simulator.

## Tests

Run unit tests from Xcode or via command line:

```
xcodebuild -scheme PocketGPT -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Analytics & Logging

- Network calls log basic error messages to the console.
- Future enhancements can pipe metrics to the backend analytics endpoints.
