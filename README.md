# Benaiah App

A modern Flutter application built with performance, scalability, and maintainability in mind.

## 🚀 Getting Started

### Prerequisites

- [FVM](https://fvm.app/docs/getting_started/installation) OR [Puro](https://puro.dev/) (recommended for version management)
- [Mason CLI](https://docs.brickhub.dev/mason-cli/installation)
- [CocoaPods](https://cocoapods.org/) (for iOS development)

### Setup

Run the following command to set up the project environment. This script detects your SDK manager (Puro or FVM), installs the correct Flutter version, fetches dependencies, installs pods, activates necessary CLIs, and **configures VS Code launch settings for all flavors**.

```bash
bash scripts/project_setup.sh
```

For non-interactive environments (CI):

```bash
FVM_SETUP_NONINTERACTIVE=1 bash scripts/project_setup.sh
```

### Running the App

The project uses flavors for different environments (`dev`, `qa`, `prod`). 

#### 1. VS Code (Recommended)
The setup script generates a `.vscode/launch.json` file. You can simply go to the **Run and Debug** tab and select:
- `Benaiah [DEV]` (Default)
- `Benaiah [QA]`
- `Benaiah [PROD]`

#### 2. Makefile Commands
You can also run the app using the provided `Makefile`:
- **Development:** `make run-dev`
- **QA:** `make run-qa`
- **Production:** `make run-prod`

#### 3. CLI
Alternatively, using the Flutter CLI (prefixed with your manager):

```bash
fvm flutter run --flavor dev -t lib/main.dart
# OR
puro flutter run --flavor dev -t lib/main.dart
```

### Code Generation

This project uses `build_runner` for generating code (Freezed, Injectable, Riverpod, etc.) and `flutter_gen` for assets.

To run all code generation:

```bash
make gen
```

## 🏗 Scaffolding

We use [Mason](https://docs.brickhub.dev/) to quickly scaffold new features and pages according to our project's architecture.

### Create a New Feature

To generate a full feature module (data, domain, and presentation layers):

```bash
mason make feature --name <feature_name>
```

### Create a New Page

To add a new page (screen, sections, widgets) to an existing feature:

```bash
mason make page --feature <feature_name> --name <page_name>
```

> [!TIP]
> Always run `make gen` after creating a new feature to generate the necessary `injectable`, `riverpod`, and `json_serializable` code.

## 📂 Project Structure

Navigate through the project using this guide:

- **`lib/`**: Source code of the application.
  - **`core/`**: Shared infrastructure and utilities.
    - `config/`: Environment configurations and constants.
    - `di/`: Dependency injection setup (Injectable).
    - `error/`: Error handling logic and sealed classes.
    - `network/`: Dio networking module and interceptors.
    - `router/`: Navigation setup using GoRouter.
    - `theme/`: Design system, colors, and typography.
  - **`features/`**: Feature-based modules (to be added).
  - `app.dart`: Root widget of the application.
  - `main.dart`: Entry point of the app.
  - `flavors.dart`: Flavor-specific configuration.
- **`assets/`**: Static assets.
  - `translations/`: Localization files (CSV format).
  - `images/`: Image assets.
  - `icons/`: Icon assets.
- **`scripts/`**: Automation scripts and Makefiles.
- **`bricks/`**: Mason bricks for rapid feature and component scaffolding.
- **`test/`**: Unit and widget tests.

## 🛠 Tech Stack

- **State Management:** [Hooks Riverpod](https://riverpod.dev/)
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
- **Networking:** [Dio](https://pub.dev/packages/dio)
- **Dependency Injection:** [Get It](https://pub.dev/packages/get_it) & [Injectable](https://pub.dev/packages/injectable)
- **Code Generation:** [Freezed](https://pub.dev/packages/freezed), [Riverpod Generator](https://pub.dev/packages/riverpod_generator)
- **Localization:** [Easy Localization](https://pub.dev/packages/easy_localization)
- **Observability:** [Sentry](https://sentry.io/)

## 🎨 Design System

The design system is located in `lib/core/theme`. It uses a primary color palette of black and white, ensuring a clean and minimalist aesthetic. Responsive design is handled via `ResponsiveConfig` initialized in `main.dart`.