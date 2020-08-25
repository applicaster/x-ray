# General Purpose Logger

## Overview

Library provides general purpose logging facilities for Android, iOS, and React Native.


## Features:
- Custom sinks, as in Serilog: ADB, file, etc.
- Extensions: crash reporting, notification controls
- Deep object dump support with moshi

## Android Setup

In minimal configuration, only core is required. It contains all required logging interfaces, filtering rules, and basic sinks.

### Linking with the Library

Project can be connected in a number of ways:
1. Using maven artifacts:

Maven artifacts is enough for building native Android applications.
Add the following repository to your project top level gradle

`maven { url 'https://dl.bintray.com/applicaster-ltd/maven_plugins' }`

Link the core:
`implementation('com.applicaster:xray-core:0.0.4-alpha')`

Optionally link extensions needed:
`implementation('com.applicaster:xray-crashreporter:0.0.4-alpha')`

2. From npm repository

NPM package includes the project in source code form. Convenient for react-native projects.

3. As a git submodule

Useful for developers working on new extensions or expanding the library itself.

### Android Initialization and Basic Usage

Initialize and attach the sinks.
```
        val fileLogSink = PackageFileLogSink(this, "default.log");

        Core.get()
            .addSink("adb", ADBSink())
            .addSink("file", fileLogSink)
```

Optionally, configure crash reporter extension
```
        Reporting.init("crash@example.com", fileLogSink.file)
        Reporting.enableForCurrentThread(this, true)
```

Start logging:
```
        val rootLogger = Logger.get()
        rootLogger
            .d("Test")
            .message("Basic message")
```

Log from some particular component of some subsystem:
```
        val logger = Logger.get("subsystem/component")
        logger
            .d("Test")
            .message("Basic message")
```

# Android Building and Deployment

Project can be published to both npm and maven.
Maven publishing is done with CI, but can be performed manually. Please refer to [.circleci/config.yml](.circleci/config.yml) for publishing steps.

Artifact version for maven publishing must match `releaseVersion` constant in `android/gradle/constants.gradle`.

Note that xray component dependencies for extensions are imported using special helper functions `xrayAPI`, for example:

```xrayAPI(dependencies, ':xray-core')```

This helper dynamically resolves dependency to either project or maven artifact, and also stores dependency information in the project.
Stored dependency information later used by maven publishing script to build POM file.
This approach allows to avoid dependency resolution failures due to the fact that, during publishing, extensions are dependent on the artifacts that only about to be published.


# To Do:
- Dynamic Context Providers in loggers (thread, etc)
- Mapper configuration
- Use Dummy EventBuilder if log event will not be recorded to save performance
- Event formatters with time, tag, etc placeholders
- Named placeholders in templates (WIP)
- In-memory circular buffer event sink
- Maybe output file sinks to cache and not data storage, so user can wipe it without losing data
- Trim/rotate file sinks

## Issues:
- Using Android-specific nullable annotations
- Uses Kotlin internally
