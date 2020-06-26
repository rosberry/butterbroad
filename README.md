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
- Activate a `Butter` instace in `application(_,didFinishLaunchingWithOptions)`

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

[Analog](https://github.com/rosberry/analog) is a simple logger for any events you want. It gives you a simple sessions mechanics and two ways to view events right in your app. To integrate `AnalogBroad` into your project you integrate `Analog` via carthage following the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application):

```sh
$ github "rosberry/Analog"
```

Then copy [AnalogBroad](https://github.com/rosberry/butterbroad/tree/Sources/Broads/AnalogBroad.swift) into your project and put an `AnalogBroad` instance into  `ButterBroad`:

```swift
//  Butter+ApplicationBroads.swift

import ButterBroad

extension Butter {
    static let analog: AnalogBroad = .init()
    static let common: Butter = .init(broads: analog)
}
```

### Firebase broad

To integrate `FirebaseBroad` into your project you integrate `Firebase` and `FirebaseAnalytics` by any awailable way. For example there is an [oficial interation instuction](https://firebase.google.com/docs/analytics/get-started?platform=ios) from Firebase. If you preffer `Carthage` then you can use folowing binaries:

```
binary "https://dl.google.com/dl/firebase/ios/carthage/FirebaseAnalyticsBinary.json"
binary "https://dl.google.com/dl/firebase/ios/carthage/FirebaseCrashlyticsBinary.json"
```

Unlike `Pod installation` `FirebaseCrashlytics.framework`  builded via carthage has not required scripts `run` and `upload-symbols` scripts, so we packed them into `ButterBroad.framework` for your convenience. To use them create run script phase `Crashlytics` with content

```sh
"$PROJECT_DIR/Carthage/Build/iOS/ButterBroad.framework/run"
```

and put `DSYM` and `Info.plist` files as `Input files` of the scipt
```sh
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
```

Then copy [FirebaseBroad](https://github.com/rosberry/butterbroad/tree/Sources/Broads/FirebaseBroad.swift) into your project and put an `FirebaseBroad` instance into  `ButterBroad`:

```swift
//  Butter+ApplicationBroads.swift

import ButterBroad

extension Butter {
    static let firebase: FirebaseBroad = .init(with: default)
    static let common: Butter = .init(broads: analog)
}
```

You can put one of the folowing activation types into initializer:

- `.none`: No action requered.  `FirebaseApp.configure`  should be triggerd from the application. Use it if your app has other firebase features and firbase app configuration is your strict responsibility. This value is asumed by default.
- `.default`: perform `FirebaseApp.configure()` in the `FirebaseBroad`. Use it if you do not use other firebase features.
- `.custom`: perform specific `FirebaseApp.configure` in the `FirebaseBroad`. Use it if you do not use other firebase features but you need to specify some configuration parameters. 

### Facebook broad

To integrate `FacebookBroad` into your project you integrate `Facebook` and `FacebookAnalytics` by [any awailable way](https://developers.facebook.com/docs/analytics/quickstart-list/ios/).

Then copy [FacebookBroad](https://github.com/rosberry/butterbroad/tree/Sources/Broads/FacebookBroad.swift) into your project and put an `FacebookBroad` instance into  `ButterBroad`:

```swift
//  Butter+ApplicationBroads.swift

import ButterBroad

extension Butter {
    static let facebook: FacebookBroad = .init(with: default)
    static let common: Butter = .init(broads: facebook)
}
```

You can put one of the folowing activation types into initializer:

- `.none`: No action requered.  `AppEvents.activateApp`  should be triggerd from the application. Use it if your app has other facebook features and facebook app configuration is your strict responsibility. This value is asumed by default.
- `.default`: perform `AppEvents.activateApp()` in the `FacebookBroad`. Use it if you do not use other facebook features.
- `.custom`: perform specific `AppEvents.activateApp` in the `FacebookBroad`. Use it if you do not use other facebook features but you need to specify some configuration parameters. 

If you use `.default` or `.custom` activation type so do not forget to activate the `FacebookBroad` in `func applicationDidBecomeActive`

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        Butter.facebook.activate()
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
