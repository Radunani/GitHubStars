# GitHubStars

`GitHubStars` is a small iOS demo app that shows:

- secure token storage with Keychain
- loading repositories from the GitHub API
- live star-count updates inside a repository list and detail screen
- a mix of UIKit, SwiftUI, Combine, and Swift concurrency

## Purpose

This project is for demonstration purposes only.

It is meant to show patterns and tradeoffs, not to be a production-ready GitHub client. Some implementation choices are intentionally simplified so the code is easier to read, discuss, and iterate on in a learning/demo context.

## What This Demo Shows

- `UIKit` screen flow for token input and repository list
- `SwiftUI` for repository detail rendering
- `Combine` for publisher-based star updates
- `async/await` for GitHub API requests
- `actor` isolation in the mock live-update service
- `@MainActor` boundaries for UI-facing state and coordination

## Demo-Oriented Choices

The following parts are intentionally demo-oriented:

- `MockLiveServer` simulates live star updates instead of using a real-time backend
- the repository organisation is currently hardcoded to `swiftlang`
- token validation is intentionally lightweight
- some architecture decisions are optimized for showing concepts clearly rather than minimizing abstraction
- there is currently no full automated test suite

These choices are useful for demonstration, but they should not automatically be treated as best production defaults.

## Project Structure

- `GitHubStars/GitHubStarsApp.swift`
  App coordinator and app startup wiring
- `GitHubStars/Screens/TokenInput View`
  Token entry flow
- `GitHubStars/Screens/Repositories List`
  Repository list flow with presenter/interactor/router split
- `GitHubStars/Screens/Repository View`
  Repository detail screen and star view model
- `GitHubStars/MockLiveServer`
  Demo-only live star update simulation
- `GitHubStars/KeychainHelper`
  Token persistence abstractions and Keychain implementation
- `GitHubStars/GitHubAPI`
  GitHub API models and requests

## Running the App

1. Open `GitHubStars.xcodeproj` in Xcode.
2. Select the `GitHubStars` scheme.
3. Build and run on an iPhone simulator or device.

If you want higher GitHub API rate limits, enter a personal access token in the app. The token is stored in Keychain.

## Notes

- This repository is licensed under the MIT License. See [`LICENSE`](LICENSE).
- If you evolve this project beyond demo use, the first areas to improve are test coverage, runtime error handling, configuration, and removal of demo-specific assumptions.
