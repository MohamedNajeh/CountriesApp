# CountriesApp

An iOS country explorer app built with SwiftUI, SwiftData, and MVVM architecture using the REST Countries API.

---

## Features

- Auto-detects the user's country via GPS on first launch
- Falls back to Egypt if location permission is denied
- Search countries by name, capital, or currency
- Add up to 5 countries to the main view
- Remove countries from the main view
- Detailed view showing capital city, currency, region, and population
- Full offline support — saved countries persist via SwiftData
- Animated dark UI with glassmorphism cards

---

## Architecture

- **Pattern:** MVVM + Protocol-driven services
- **UI:** 100% SwiftUI — no storyboards, no XIBs
- **Persistence:** SwiftData (iOS 17+)
- **Async:** async/await throughout
- **Testability:** All services abstracted behind protocols

---

## Project Structure

```
CountriesApp/
├── App/                    # Entry point, ModelContainer setup
├── Models/                 # Country, Currency, SavedCountry
├── Services/               # CountryService, LocationService + Protocols
├── ViewModels/             # MainViewModel, SearchViewModel
├── Views/                  # MainView, SearchView, CountryDetailView
├── Components/             # AnimatedGradientBackground, LoadingSkeletonView
├── Extensions/             # Color+Theme, String+FlagEmoji, Int+Formatted
└── Tests/                  # Unit tests with 65%+ coverage
```

---

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

---

## Installation

1. Clone the repository
2. Open `CountriesApp.xcodeproj`
3. Select an iOS 17+ simulator
4. Build and run (`Cmd+R`)

---

## Testing

Run the test suite with `Cmd+U` in Xcode.

**Test coverage includes:**
- `MainViewModel` — add/remove/limit/duplicate/fallback logic
- `SearchViewModel` — filtering by name, capital, currency
- `CountryService` — real service tested via `MockURLProtocol` (no network calls)
- `CountryAPIResponse` — v3.1 JSON mapping to domain model
- `SavedCountry` — model init, computed properties, SwiftData persistence
- Extensions — `flagEmoji`, `formattedPopulation`, `Currency.displayText`

---

## API

Uses [REST Countries API v3.1](https://restcountries.com)

```
GET https://restcountries.com/v3.1/all?fields=name,cca2,capital,currencies,region,population
```
