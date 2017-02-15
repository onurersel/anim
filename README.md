[![CocoaPods](https://img.shields.io/cocoapods/v/anim.svg)](https://cocoapods.org/pods/anim)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/onurersel/anim.svg?branch=master)](https://travis-ci.org/onurersel/anim)
[![codecov.io](https://codecov.io/github/onurersel/anim/coverage.svg?branch=master)](https://codecov.io/github/onurersel/anim?branch=master)

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

It supports a bunch of easing functions and chaining multiple animations. It's a wrapper on Apple's `UIViewPropertyAnimator` on its core, and falls back to `UIView.animate` on versions before iOS 10.
It uses `NSAnimationContext` on macOS.


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

Or simply drag the swift files inside `src/` folder into your project.

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

```swift
// or initialize layout constraint animations just by passing the parent view
anim(constraintParent: self.view) {
    // animation block
}

anim(constraintParent: self.view) { (settings) -> (anim.Closure) in
    // settings...
    return {
        // animation block
    }
}

// you don't need to call layoutIfNeeded() before or inside the
// animation blocks, it's handled by anim
//
// for example to update constant value of a constraint,
// you can just change it inside the animation block
let width: NSLayoutConstraint //...
anim(constraintParent: self.view) {
    width.constant = 100 // new value
}
// that's it!
```

Chain animations with `then` function.

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

```swift
anim {}
.then(constraintParent: self.view) {
    // chaining constraint animations
}
.then(constraintParent: self.view) { (settings) -> anim.Closure in
    settings.duration = 1
    return {
        // next animation block for constraints
    }
}
```

Wait between animation steps with `wait` function.

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

Stop animations with `stop` function.

```swift
let animation = anim{}.then{} // ...
animation.stop()
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
- [x] Constraint animations
- [X] iOS 8 and 9 support
- [X] macOS support
- [ ] tvOS support
- [ ] Shape animations

# License

`anim` is released under the MIT license. See LICENSE for details.
