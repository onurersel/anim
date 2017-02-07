`anim` is an animation library written in Swift with a simple, declarative API in mind.

```swift
// moves box to 100,100 with default settings
anim {
    self.box.frame.origin = CGPoint(x:100, y:100)
}
// after that, waits 100 ms
.wait(100)
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

[![CocoaPods](https://img.shields.io/cocoapods/v/anim.svg)](https://cocoapods.org/pods/anim)
[![CI Status](http://img.shields.io/travis/onurersel/anim.svg?style=flat)](https://travis-ci.org/onurersel/anim)

Using Cocoapods
```
pod 'anim'
```

Or simply drag the file `anim.swift` into your project.

# API

Initialize animations with `anim` constructor
```swift
// Initialize with default settings
anim {
    // animation block
}
```
```swift
// or initialize with it's own settings
anim { (settings) -> (anim.Closure) in
    settings.delay = 1000
    settings.duration = 700
    settings.ease = .easeInOutBack

    return {
        // animation block
    }
}
```

Chain animations with `.then` function
```swift
anim {}
.then{
    // next animation block
}
```
```swift
anim {}
.then { (settings) -> anim.Closure in
    settings.duration = 1000
    return {
        // next animation block
    }
}
```

Wait between animation steps with `.wait` function
```swift
anim{}.wait(250).then{} //...
```

Insert callbacks between animation steps with `.callback` function
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
