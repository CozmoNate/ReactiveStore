# ReactiveStore

[![License](https://img.shields.io/badge/license-MIT-ff69b4.svg)](https://github.com/kzlekk/ReactiveStore/raw/master/LICENSE)
[![Language](https://img.shields.io/badge/swift-5.0-orange.svg)](https://swift.org/blog/swift-5-released/)
[![Build Status](https://travis-ci.com/kzlekk/ReactiveStore.svg?branch=master)](https://travis-ci.com/kzlekk/ReactiveStore)
[![Coverage Status](https://coveralls.io/repos/github/kzlekk/ReactiveStore/badge.svg?branch=master)](https://coveralls.io/github/kzlekk/ReactiveStore?branch=master)

ReactiveStore framework consists of lightweight implementation of **Dispatcher** from **Flux** pattern and reactive observable store. ActionDispatcher protocol provides methods and properties allowing to control data flow by sending and handling actions. ReactiveStore protocol provides basic reactive functionality allowing to subscribe to store changes.

## Installation

### Swift Package Manager

Add "ReactiveStore" dependency in XCode

### CocoaPods

```ruby
pod 'ReactiveStore'
```

Add extension to support "conventional" observing:

```ruby
pod 'ReactiveStore/Observing'
```

This will install the extension to ReactiveStore that enables possibility to observe store changes without using Combine or any other library. With this extension you'll be able to subscribe to store changes by calling "addObserver" method and providing a change handler closure. "addObserver" returns a subscription object. Store subscription will be active until cancelled or the subscription object is disposed. You can use "notify" method inside the store action handlers and send notifications to subscribers with the information about which store properties has being changed by passing an array of "PartialKeyPath" objects.
