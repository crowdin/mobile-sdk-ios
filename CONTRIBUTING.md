# Contributing

:tada: First off, thanks for taking the time to contribute! :tada:

The following is a set of guidelines for contributing to Crowdin iOS SDK. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

This project and everyone participating in it are governed by the [Code of Conduct](/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How can I contribute?

### Star this repo

It's quick and goes a long way! :stars:

### Reporting Bugs

This section guides you through submitting a bug report for Crowdin iOS SDK. Following these guidelines helps maintainers and the community understand your report :pencil:, reproduce the behavior :iphone:, and find related reports :mag_right:.

When you are creating a bug report, please include as many details as possible. Fill out the required issue template, the information it asks for helps us resolve issues faster.

#### How Do I Submit a Bug Report?

Bugs are tracked as [GitHub issues](https://github.com/crowdin/mobile-sdk-ios/issues/).

Explain the problem and include additional details to help maintainers reproduce the problem:

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Describe the exact steps which reproduce the problem** in as many details as possible. Don't just say what you did, but explain how you did it.
* **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
* **Explain which behavior you expected to see instead and why.**

Include details about your configuration and environment:

* Which version of iOS are you using?
* Which version of Crowdin iOS SDK are you using?
* Are you using a physical device or some simulator?

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for Crowdin iOS SDK, including completely new features and minor improvements to existing functionality. Following these guidelines helps maintainers and the community understand your suggestion :pencil: and find related suggestions :mag_right:.

When you are creating an enhancement suggestion, please include as many details as possible. Fill in feature request, including the steps that you imagine you would take if the feature you're requesting existed.

#### How Do I Submit an Enhancement Suggestion?

Enhancement suggestions are tracked as [GitHub issues](https://github.com/crowdin/mobile-sdk-ios/issues/). 

Create an issue on that repository and provide the following information:

* **Use a clear and descriptive title** for the issue to identify the suggestion.
* **Provide a step-by-step description of the suggested enhancement** in as many details as possible.
* **Describe the current behavior** and **explain which behavior you expected to see instead** and why.
* **Explain why this enhancement would be useful** to most iOS SDK users.

### Your First Code Contribution

Unsure where to begin contributing to Crowdin iOS SDK? You can start by looking through these `good-first-issue` and `help-wanted` issues:

* [Good first issue](https://github.com/crowdin/mobile-sdk-ios/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22) - issues which should only require a small amount of code, and a test or two.
* [Help wanted](https://github.com/crowdin/mobile-sdk-ios/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22) - issues which should be a bit more involved than `Good first issue` issues.

#### Pull Request Checklist

Before sending your pull requests, make sure you followed the list below:

- Read these guidelines.
- Read [Code of Conduct](/CODE_OF_CONDUCT.md).
- Ensure that your code adheres to standard conventions, as used in the rest of the project.
- Ensure that there are Unit tests for your code.
- Ensure that your code will work correctly on **iOS**, **tvOS**, **watchOS**.
- Run Unit tests.

> **Note**
> Integration tests are available in this project but are disabled by default to avoid external dependencies during regular development. They run automatically on a weekly schedule via GitHub Actions. To enable them locally, set the `RUN_INTEGRATION_TESTS=1` environment variable when running tests:
> ```bash
> cd Tests
> RUN_INTEGRATION_TESTS=1 xcodebuild test \
>   -sdk iphonesimulator \
>   -workspace ./Tests.xcworkspace \
>   -scheme Tests \
>   -configuration Debug \
>   -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
> ```

> **Note**
> This project uses the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification for commit messages and PR titles.

### Code Style

This project uses [SwiftLint](https://github.com/realm/SwiftLint) to enforce code style and best practices. SwiftLint is integrated in two ways:

1. **Build-time integration**: SwiftLint is integrated directly into the Swift Package Manager build process using the [SwiftLintPlugins](https://github.com/SimplyDanny/SwiftLintPlugins) package. It will run automatically when you build the package.

2. **Git pre-commit hook**: SwiftLint will run automatically when you commit changes, preventing commits that introduce linting errors.

To run SwiftLint manually:

```bash
./run_swiftlint.sh
```

The SwiftLint configuration is defined in `.swiftlint.yml` in the root directory.

### Development Setup

To set up the development environment, including git hooks for automatic version synchronization and linting:

```bash
./install_hooks.sh
```

This will configure git to use the hooks defined in the root directory.

#### Contributing to the docs

The documentation is based on [Docusaurus](https://docusaurus.io/) framework. Source inside the [website](https://github.com/crowdin/mobile-sdk-ios/tree/master/website) directory.

- Go to the `website` directory:

  ```sh
  cd website
  ```

- Install dependencies:

   ```sh
   npm install
   ```

- To build the docs, watch for changes and preview documentation locally at [http://localhost:3000/](http://localhost:3000/):

   ```sh
   npm start
   ```

- It's also possible to run `npm run build` for single build. Incremental builds are much faster than the first one as only changed files are built.

Open `http://127.0.0.1:3000` in browser

#### Philosophy of code contribution

- Include unit tests when you contribute new features, as they help to a) prove that your code works correctly, and b) guard against future breaking changes to lower the maintenance cost.
- Bug fixes also generally require unit tests, because the presence of bugs usually indicates insufficient test coverage.
