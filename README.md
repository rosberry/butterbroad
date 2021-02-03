# ButterBroad

ButterBroad is a lightweight aggregator for different analytic components such as Facebook, Firebase, Crashlytics e.t.c.

## Features
- Combines different analytics components
- Simple program interface

## Requirements

- iOS 10.0+
- Xcode 8.0+

## Installation

### Depo

[Depo](https://github.com/rosberry/depo) is a universal dependency manager that combines CocoaPods, Carthage and SPM.
To integrate ButterBroad into your Xcode project using Depo, specify it in your `Depofile`:
```yaml
carts:
  - kind: github
    identifier: rosberry/ButterBroad
```

### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the framework to your project.

```
github "rosberry/ButterBroad"
```

### Manually

Drag `Sources` folder from [last release](https://github.com/rosberry/butterbroad/releases) into your project.

## Usage
- Provide an adapter for analytic component by the implementing of  `Analytics` protocol
- Combine adapters using an instance of `Butter` class
```swift
import ButterBroad

extension Butter {
    static let common: Butter = .init(broads: <YOUR ADAPTERS THERE>)
}
```
- Use `logEvent` method to send an event with custom name  

## Favorite broads

- [AnalogBroad](https://github.com/rosberry/AnalogBroad)
- [FirebaseBroad](https://github.com/rosberry/CrashlyticsBroad)
- [FacebookBroad](https://github.com/rosberry/FacebookBroad)

```swift
//  Butter+ApplicationBroads.swift
import UIKit
import ButterBroad
import AnalogBroad
import FacebookBroad
import FirebaseBroad

extension Butter {
    static let analog: AnalogBroad = .init()
    static let facebook: FacebookBroad = .init()
    static let firebase: FirebaseBroad = .init()
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
