# ButterBroad

ButterBroad is a lightweight aggregator for different analytic components such as Facebook, Firebase, e.t.c.

## Features
- Combines different analytics components
- Simple program interface

## Requirements

- iOS 10.0+
- Xcode 8.0+

## Installation

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the framework to your project.

```
github "rosberry/ButterBroad"
```

### Manually

Drag `Sources` folder from [last release](https://github.com/rosberry/butterbroad/releases) into your project.

## Usage
- Provide an adapter for analytic component by the implementing of  `Analytics` protocol
- Combine adapters using an instance of `Butter` class
- Activate a `Butter` instance in `application(_:didFinishLaunchingWithOptions:)`

```swift
import ButterBroad

extension Butter {
    static let common: Butter = .init(broads: <YOUR ADAPTERS THERE>)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Butter.common.activate()
        return true
    }
}
```
- Use `logEvent` method to send an event with custom name  

## Favorite broads

- [AnalogBroad](#analog-broad)
- [FirebaseBroad](#firebase-broad)
- [FacebookBroad](#facebook-broad)

### Analog broad

[Analog](https://github.com/rosberry/analog) is a simple logger for any events you want. It gives you a simple sessions mechanics and two ways to view events right in your app. To integrate `AnalogBroad` into your project you need to integrate `Analog` via carthage before following the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application):

```sh
github "rosberry/Analog"
```

Then copy [AnalogBroad](https://github.com/rosberry/butterbroad/blob/master/Sources/Broads/AnalogBroad.swift) into your project and put an `AnalogBroad` instance into `ButterBroad`:

```swift
//  Butter+ApplicationBroads.swift

import ButterBroad

extension Butter {
    static let analog: AnalogBroad = .init()
    static let common: Butter = .init(broads: analog)
}
```

### Firebase broad

To integrate `FirebaseBroad` into your project you need to integrate `Firebase` and `FirebaseAnalytics` by any available way before. For example there is an [oficial interation instuction](https://firebase.google.com/docs/analytics/get-started?platform=ios) from Firebase. If you preffer `Carthage` then you can use following binaries:

```
binary "https://dl.google.com/dl/firebase/ios/carthage/FirebaseAnalyticsBinary.json"
binary "https://dl.google.com/dl/firebase/ios/carthage/FirebaseCrashlyticsBinary.json"
```

Unlike `Pod installation` `FirebaseCrashlytics.framework`  built via carthage has not required  `run` and `upload-symbols` scripts, so we packed them into `ButterBroad.framework` for your convenience. To use them create run script phase `Crashlytics` with content

```sh
"$PROJECT_DIR/Carthage/Build/iOS/ButterBroad.framework/run"
```

and put `DSYM` and `Info.plist` files as `Input files` of the scipt
```sh
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
```

Then copy [FirebaseBroad](https://github.com/rosberry/butterbroad/blob/master/Sources/Broads/FirebaseBroad.swift) into your project and put an `FirebaseBroad` instance into  `ButterBroad`:

```swift
//  Butter+ApplicationBroads.swift

import ButterBroad

extension Butter {
    static let firebase: FirebaseBroad = .init(with: .default)
    static let common: Butter = .init(broads: analog)
}
```

You can put one of the following activation types into initializer:

- `.none`: No action required.  `FirebaseApp.configure`  should be triggered from the application. Use it if your app has other firebase features and firebase app configuration is your strict responsibility. This value is assumed by default.
- `.default`: perform `FirebaseApp.configure()` in the `FirebaseBroad`. Use it if you do not use other firebase features.
- `.custom`: perform specific `FirebaseApp.configure` in the `FirebaseBroad`. Use it if you do not use other firebase features but you need to specify some configuration parameters. 

### Facebook broad

To integrate `FacebookBroad` into your project you need to integrate `Facebook` and `FacebookAnalytics` by [any available way](https://developers.facebook.com/docs/analytics/quickstart-list/ios/) before.

Then copy [FacebookBroad](https://github.com/rosberry/butterbroad/blob/master/Sources/Broads/FacebookBroad.swift) into your project and put an `FacebookBroad` instance into  `ButterBroad`:

```swift
//  Butter+ApplicationBroads.swift

import ButterBroad

extension Butter {
    static let facebook: FacebookBroad = .init(with: .default)
    static let common: Butter = .init(broads: facebook)
}
```

You can put one of the following activation types into initializer:

- `.none`: No action required.  `AppEvents.activateApp`  should be triggered from the application. Use it if your app has other facebook features and facebook app configuration is your strict responsibility. This value is assumed by default.
- `.default`: perform `AppEvents.activateApp()` in the `FacebookBroad`. Use it if you do not use other facebook features.
- `.custom`: perform specific `AppEvents.activateApp` in the `FacebookBroad`. Use it if you do not use other facebook features but you need to specify some configuration parameters. 

If you use `.default` or `.custom` activation type please do not forget to activate the `FacebookBroad` in `func applicationDidBecomeActive`

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        Butter.facebook.activate()
    }
}
```

### User defined broad

To specify your own analytics aggregator create class that implements `ButterBroad.Analytics` protocol and specify `public func log(_ event: Event)` method to send data to some analytics. `Event` contains `String` name and `[String: AnyCodable]` parameters, where [`AnyCodable`](https://github.com/Flight-School/AnyCodable/tree/master/Sources/AnyCodable) is type eraser for `Codable` generic protocol. If the analytics assumes some activation you can specify `public func activate()` method. To do it in a more convenient way `ButterBroad` contains `enum Activation`. Look on the `FirebaseBroad` implementation for example

```swift
import ButterBroad
import Firebase

final public class FirebaseBroad: ButterBroad.Analytics {

    private let activation: Activation

    public init(with activation: Activation = .none) {
        self.activation = activation
    }

    public func log(_ event: Event) {
        Firebase.Analytics.logEvent(event.name, parameters: event.params)
    }

    public func activate() {
        switch activation {
        case .custom(let activationHandler):
            activationHandler()
        case .default:
            FirebaseApp.configure()
        case .none:
            return
        }
    }
}
```

## Example

```swift
//  Butter+ApplicationBroads.swift
import UIKit
import ButterBroad

extension Butter {
    static let analog: AnalogBroad = .init()
    static let facebook: FacebookBroad = .init(with: .default)
    static let firebase: FirebaseBroad = .init(with: .default)
    static let common: Butter = .init(broads: analog, facebook, firebase)
}

//  AppDelegate.swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Butter.common.activationHandler?()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Butter.facebook.activationHandler?()
    }
}

//  ViewController.swift

func logButtonClick() {
    Butter.common.logEvent(with: "button_click")
}
```

## Authors

* Nikolay Tyunin, nikolay.tyunin@rosberry.com

## About

<img src="https://github.com/rosberry/Foundation/blob/master/Assets/full_logo.png?raw=true" height="100" />

This project is owned and maintained by [Rosberry](http://rosberry.com). We build mobile apps for users worldwide 🌏.

Check out our [open source projects](https://github.com/rosberry), read [our blog](https://medium.com/@Rosberry) or give us a high-five on 🐦 [@rosberryapps](http://twitter.com/RosberryApps).

## License

Butterbroad is available under the MIT license. See the LICENSE file for more info.
