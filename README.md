# Thoth

Thoth is an example Swift Package to showcase the possibility of centralising your app's configuration objects into something that can be shipped sepearately, if required.

## Installation

Install via [Swift Package Manager](https://swift.org/package-manager/).

You're going to want to fork Thoth so you can add your own configuration.

Then add the following to the `dependencies` in your **Package.swift**:

```swift
.package("https://github.com/<your fork>/thoth.git", .branch("master"))
```

Or in Xcode: File -> Swift Packages -> Add Package Dependency.

### Dependencies

If you want to deploy to an S3 bucket make sure you install the [AWS CLI](https://aws.amazon.com/cli/) and have setup an account and bucket.

## Basic Usage

* Fork Thoth.
* Change the URL and refresh interval in **Thoth.swift** to whatever you like
* Add your own configuration structure to **Sources/Config/**

**Important:** Make sure your properties are _mutable_ (i.e. use `var` and not `let`), otherwise Codable will not synthesize decoding of those properties and all this is for naught.

* Add the Thoth package as a dependency within your app.
* Call `Thoth.shared.<keyPath>` to access your configuration.
* Thoth will automatically refresh from the URL as appropriate.
* If you're using SwiftUI, Thoth implements `ObservableObject`, so you can use it with `@ObservedObject` to react to changes.

* Update the properties in the Makefile for your AWS deployment.

### Deploying Config JSON

1. Run `make`. The Thoth Builder will `JSONEncoder` your Config structure and output it to **.export/thoth.json**.
2. Run `make test`. Swift will run the tests you add to **ConfigTests** (you did add tests right? :P)
3. Run `make deploy`. The AWS CLI will sync your exported **thoth.json** to the configured S3 bucket ready for access by your app.
4. Bonus: If you want to run this as a GitHub action, install [Docker Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac) and you can use `make linux-test` to ensure your Config and everything passes tests on the Linux version of Swift.


## API Details

### Thoth.swift

The `Thoth` class is a wrapper around your `Config` object. It implements `@dynamicMemberLookup` to pass through property lookups to your `Config` object, while refreshing the config as appropriate.

The `Thoth.Constants` enum has a number of properties you can tweak as you need, including:

* `url`: The `URL` to your **thoth.json** file.
* `refreshGranularity`: A `Calendar.Component`-based frequency to refresh at. Thoth refreshes when this component changes using `Calendar.compare(_:to:toGranularity:)`. So if it is set to `Calendar.Component.day`, then Thoth will refresh once when the date changes.
* `cacheFilename`: The filename for Thoth to cache its configuration in your app's `Library/ Caches` folder.

### Config.swift

Put your config in here. You can use whatever structure you like as long as everything is `Codable` and is a `public var`.

If you don't make it `public` it won't be accessable from your app, and if you don't make it mutable (`var`) then it cannot be updated from the JSON.

### Makefile

This is used for building, testing and deploying Thoth JSON files. The commands are listed above in Deploying Config JSON.

The following variables can be configured in your **Makefile**:

* `BUCKET`: The S3 bucket you want to deploy your **thoth.json** to.
* `REGION`: The AWS region the bucket lives in.
* `PROFILE`: The profile you've configured for the AWS CLI. If you've installed it fresh and only added one account this is probably `Default`.

## GitHub Action

Thoth also includes an example GitHub action. This means that, on push, GitHub will run `swift test` on your Config, and if they pass, deploy the **thoth.json** to the bucket directly.

See **.github/workflows/swift.yml** for more.