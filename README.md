SwiftPickers 
============

[![Language](http://img.shields.io/badge/language-Swift-yellow.svg)](https://developer.apple.com/swift/)
[![Platform](http://img.shields.io/badge/platform-ios-blue.svg)](https://developer.apple.com/iphone/index.action)
[![License](http://img.shields.io/badge/license-BSD-orange.svg)](http://opensource.org/licenses/BSD-3-Clause)
[![Issues](http://img.shields.io/github/issues/FahimF/SwiftPickers.svg)](https://github.com/FahimF/SwiftPickers/issues?state=open)

- [Overview](#overview)
- [Installation](#installation)
	- [Pickers](#pickers)
	- [Button Pickers](#button-pickers)
		- [Via Interface Builder](#via-interface-builder)
		- [Via Code](#via-code)
- [Credits](#credits)
- [Questions](#questions)

## Overview ##

This is a Swift port of [ActionSheetPicker-3.0](https://github.com/skywinder/ActionSheetPicker-3.0/). However, this project contains some functionality which is different from the original component and certain design decisions have been taken to keep things simpler for this version.

The `SwiftPicker` components can be used in one of two ways - you can either invoke the picker directly from code:

![swift-pickers](https://cloud.githubusercontent.com/assets/181110/5330510/142547dc-7e34-11e4-9d32-4dba71480d8c.gif)

Or, you can use the easy to use picker buttons which can be added to a storyboard or instantiated via. The buttons require a couple of lines to set up the picker and then the button will handle the rest:

![picker-buttons](https://cloud.githubusercontent.com/assets/181110/5330509/141fb6a0-7e34-11e4-9fff-b64beeb96be7.gif)

As you will note above, each button displays the current selection value as its title.

## Installation ##

You can use the `SwiftPicker` components two ways:

### Pickers ###

The basic picker components of `SwiftPickers` are not visual components that can be added via Interface Builder. Instead, you have to create them via code.

There are several different picker components depending on the type of value you want to display but one of the most basic picker components is the `StringSwiftPicker`, which allows you to pick a value from a list of string values passed to the picker.

Instantiating and invoking a `StringSwiftPicker` is as simple as:
```Swift
let data = ["Red", "Blue", "Green", "Yellow"]
let p = StringSwiftPicker(title:"Colours", data:data, selected:0, done:{(pv, index, value) in
	println("Selected item: \(index) with value: \(value)")
}, cancel:{(pv) in
	println("Cancelled selection")
})
p.showPicker(self)
```

**Note:** Till the documentation is updated to reflect all functionality, refer to the `ViewController.swift` file in the included sample project for all the different ways that the various picker components can be invoked via code. 

### Button Pickers ###

The button picker components are the visual components in the `SwiftPicker` collection. They can be added to your application in two different ways:

#### Via Interface Builder ####

- Add a standard `UIButton` instance to your view on your storyboard.
- Change the class for the button to the `SwiftPicker` button class of your choice (ex: `StringPickerButton`, `DatePickerButton` etc.)
- Set up an outlet for the button in your view controller and connect the button to the outlet.
- Set up any configuration values for the button that can't be set via the storyboard in your code. You always have to pass a view controller instance to the button but the other configuration values vary depending on the type of picker button.

#### Via Code ####

- Create an instance of a `SwiftPicker` button in your view controller:

```Swift
let data = ["Red", "Blue", "Green", "Yellow"]
let btn = StringPickerButton(vc:self, title:"Colour Picker", data:data, selected:1, picked:{(val, ndx) in
	println("Picked the value: \(val) with index: \(ndx)")
})
```
- Add the button to your view and you're done :)

**Note:** Till the documentation is updated to reflect all functionality, refer to the `ButtonsViewController.swift` file and the storyboard in the included sample project for all the different ways that the various button pickers can be used in a project. 

## Credits ##

- The inspiration for `SwiftPickers`, ActionSheetPicker, was originally created by [Tim Cinel](http://github.com/TimCinel) ([@TimCinel](http://twitter.com/TimCinel))
- The version of the code that I used as the basis for this version of `SwiftPickers` was created by [Petr Korolev](http://github.com/skywinder)

## Questions? ##

* Email: [fahimf (at) gmail (dot) com](mailto:fahimf (at) gmail.com)
* Web: [http://rooksoft.sg/](http://rooksoft.sg/)
* Twitter: [http://twitter.com/FahimFarook](http://twitter.com/FahimFarook)



