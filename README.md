# anim
### Swift animations with more easing options.

As you may already familiar with, UIView.animateWithDuration only allows you to use 4 different easing options. *anim* allows you to use 21 more easing variations with almost identical syntax.

## Installation

You can install manually by copying *anim/anim.swift* in your project.


Or you can use Cocoapods
> pod 'anim'


## Usage

	anim(duration: 1, easing: Ease.CircInOut) {
		// animation block...
	}

	anim(duration: 1, delay: 0.5, easing: Ease.QuintOut) {
		// animation block...
	}

	anim(duration: 1, delay: 2, easing: Ease.CubicIn, options: UIViewAnimationOptions.AllowUserInteraction, animation: {
		// animation block...
	}) { (finished : Bool)  in
	    // completion block...
	}

	// animating constraints
	anim(duration: 10, easing: Ease.QuartOut, animation: self.view.layoutIfNeeded)


## Easing

- Linear
- SineOut
- SineIn
- SineInOut
- QuadOut
- QuadIn
- QuadInOut
- QuintOut
- QuintIn
- QuintInOut
- CubicOut
- CubicIn
- CubicInOut
- QuartOut
- QuartIn
- QuartInOut
- ExpoOut
- ExpoIn
- ExpoInOut
- CircOut
- CircIn
- CircInOut
- BackOut
- BackIn
- BackInOut


