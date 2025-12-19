# AutomaInfraCore

[![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg?style=flat&logo=swift)](https://swift.org/)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-lightgrey.svg)](https://developer.apple.com/)
[![Vapor](https://img.shields.io/badge/Vapor-4-2D68F7.svg?logo=vapor)](https://vapor.codes/)

AutomaInfraCore is the core infrastructure powering the Automa application, providing both backend services and shared application components. This monorepo contains everything needed to run the Automa platform, including the server-side components and shared client libraries.

## 📦 Project Structure

The repository is organized into several main components:

### Backend (`/Backend`)
The server-side component built with Vapor 4, providing:
- RESTful API endpoints
- Database models and migrations (PostgreSQL)
- Authentication and authorization
- Background job processing
- Integration with external services (Twitter, OpenAI, etc.)
- Metrics and monitoring (Prometheus, Loki)

### App (`/App`)
Contains the client-side applications and shared components:
- **AutomaApp**: Main iOS/macOS application
- **AutomaAppShared**: Shared code between platforms
  - Network layer
  - Data models
  - Business logic
- **AutomaUIKit**: Shared UI components and theming

### DataTypes (`/Backend/DataTypes`)
Shared data models and type definitions used across the application.

## 🚀 Features

- **Cross-Platform Support**: Native applications for both iOS and macOS
- **Modern Architecture**: Built with Swift 6.2 and Swift Concurrency
- **Scalable Backend**: Powered by Vapor 4 with PostgreSQL
- **AI Integration**: OpenAI integration for intelligent features
- **Social Media Integration**: Post Tweet via Twitter API integration
- **Monitoring**: Built-in metrics and logging

## 🛠️ Technical Stack

- **Backend**: Swift 6.2, Vapor 4, PostgreSQL
- **iOS/macOS**: SwiftUI
- **Infrastructure**: Docker, AWS (via Soto)
- **Hosting**: Fly.io
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus, Loki, Grafana
- **Dependencies**:
  - Vapor ecosystem (Fluent, Leaf, JWT)
  - Alamofire for networking
  - OpenAI SDK
  - TwitterAPIKit
  - SwiftSoup for HTML parsing

## 🔧 Setup (Coming Soon)

A comprehensive setup guide for self-hosting Automa or running it locally will be provided in the future. This will include:

1. Prerequisites and system requirements
2. Database setup and configuration
3. Environment variables and secrets
4. Building and running the backend
5. Building and running the client applications
6. Deployment options

## 🤝 Contributing

Contributions are welcome!

## 📄 License

This project is open source and available under the MIT License. See the [LICENSE](LICENSE.md) file for more information.

## 📬 Contact

For inquiries, contact the Automa team at [william@getautoma.app](mailto:william@getautoma.app) or [ceo@getautoma.app](mailto:ceo@getautoma.app).
