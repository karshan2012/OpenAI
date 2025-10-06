# PocketGPT Monorepo

This repository hosts both the PocketGPT iOS client and the FastAPI backend service. Together they deliver a ChatGPT-style mobile experience with persistent conversations, tool calling, and integrations.

## Projects

- [`PocketGPT/`](PocketGPT) – SwiftUI iOS 17+ application packaged with Swift Package Manager.
- [`server/`](server) – FastAPI backend with PostgreSQL, Redis, and OpenAI streaming proxy.

## Getting Started

Refer to the individual READMEs in each project directory for setup instructions, environment configuration, and testing commands.

## Continuous Integration

GitHub Actions (`.github/workflows/ci.yml`) runs backend unit tests on pushes and pull requests.

## Security

See [SECURITY.md](SECURITY.md) for vulnerability disclosure guidelines. The repository is licensed under the [MIT License](LICENSE).
