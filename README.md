# ButterBroad

ButterBroad is a lightweight agregator for different analytic components such as Facebook, Firebase, Crashlytics e.t.c.

## Features
- Combines different analytics components
- Simple program interface

## Requirements

- iOS 9.0+
- Xcode 8.0+

## Installation

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the framework to your project.

```
github "rosberry/ButterBroad"
```

## Usage
- Provide an adapter for analytic component by the implementing of  `Analytics` protocol
- Combine adapters using an instance of  `Butter`  class
```swift
import ButterBroad

extension Butter {
    static let common: Butter = .init(broads: <YOUR ADAPTERS THERE>)
}
```
- Use `logEvent` method to send an event with custom name  

## Authors

* Nikolay Tyunin, nikolay.tyunin@rosberry.com

## About

<img src="https://github.com/rosberry/Foundation/blob/master/Assets/full_logo.png?raw=true" height="100" />

This project is owned and maintained by [Rosberry](http://rosberry.com). We build mobile apps for users worldwide 🌏.

Check out our [open source projects](https://github.com/rosberry), read [our blog](https://medium.com/@Rosberry) or give us a high-five on 🐦 [@rosberryapps](http://twitter.com/RosberryApps).

## License

Product Name is available under the MIT license. See the LICENSE file for more info.
