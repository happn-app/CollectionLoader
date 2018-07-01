# Collection Loader

## What is this project?
TODO

## Swift Compatibility

This tables gives the known compatibilities of the project and the version of Xcode with which
the `xcodeproj` has been updated.

| CollectionLoader Version | Min Swift Version | Max Swift Version | `xcodeproj` Last Updated With |
| --- | --- | --- | --- |
| 0.9.0 | 4.0 | 4.1 | Xcode 9.2 |
| 0.9.1 | 4.0 | 4.1 | Xcode 9.3 |
| 0.9.2 | 4.0 | 4.1 | Xcode 9.3 |

## For Maintainers
The `XCODE_XCCONFIG_FILE` part of the command line below is optional; it allows dependencies
to be compiled as static Frameworks instead of dynamic ones. As we’re not building an executable
here and the dependencies will be compiled by the clients anyway, it won’t change much how the
dependencies are compiled.
```
XCODE_XCCONFIG_FILE="$(pwd)/Xcode Supporting Files/StaticCarthageBuild.xcconfig" carthage update --use-ssh
```
