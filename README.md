[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/ustwo/formvalidator-swift/blob/master/LICENSE.md)
[![CocoaPods](https://img.shields.io/cocoapods/v/anim.svg)](https://cocoapods.org/pods/anim)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/onurersel/anim.svg?branch=master)](https://travis-ci.org/onurersel/anim)
[![codecov.io](https://codecov.io/github/onurersel/anim/coverage.svg?branch=master)](https://codecov.io/github/onurersel/anim?branch=master)
[![Platform](https://img.shields.io/cocoapods/p/anim.svg)](http://onurersel.github.io/anim/)
![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)
[![Twitter](https://img.shields.io/badge/twitter-@ethestel-blue.svg?style=flat)](http://twitter.com/ethestel)

# anim

`anim` is an animation library written in Swift with a simple, declarative API in mind.

```swift
// moves box to 100,100 with default settings
anim {
    self.box.frame.origin = CGPoint(x:100, y:100)
}
// after that, waits 100 ms
.wait(0.1)
// moves box to 0,0 after waiting
.then {
    self.box.frame.origin = CGPoint(x:0, y:0)
}
// displays message after all animations are done
.callback {
    print("Just finished moving 📦 around.")
}
```

It supports a bunch of easing functions and chaining multiple animations. It's a wrapper on Apple's `UIViewPropertyAnimator` on its core.

It only supports iOS 10 at the moment.

# Installation

#### Cocoapods

```
pod 'anim'
```

#### Carthage

```
github "onurersel/anim"
```

#### Manually

Or simply drag the file `src/anim.swift` into your project.

# API

For complete documentation, visit [http://onurersel.github.io/anim/](http://onurersel.github.io/anim/).

Initialize animations with `anim` constructor.

```swift
// Initialize with default settings
anim {
    // animation block
}
```

```swift
// or initialize with it's own settings
anim { (settings) -> (anim.Closure) in
    settings.delay = 1
    settings.duration = 0.7
    settings.ease = .easeInOutBack

    return {
        // animation block
    }
}
```

Chain animations with `.then` function.

```swift
anim {}
.then{
    // next animation block
}
```

```swift
anim {}
.then { (settings) -> anim.Closure in
    settings.duration = 1
    return {
        // next animation block
    }
}
```

Wait between animation steps with `.wait` function.

```swift
anim{}.wait(0.25).then{} //...
```

Insert callbacks between animation steps with `.callback` function.

```swift
anim{}
.callback {
    // custom block
}
.then{} //...
```

#### Default settings

You can change default animation settings through `anim.defaultSettings` property.

```swift
anim.defaultSettings.ease = .easeInOutCubic
```

#### Easing

`anim.Ease` exposes a bunch of easing options.


# Roadmap

- [x] Chaining animations
- [x] Wait, callback functions
- [ ] API for animating layout constraints
- [ ] iOS9 support
- [ ] tvOS, macOS support
- [ ] Shape animations

# Licence

`anim` is released under the MIT license. See LICENSE for details.
