# ReactiveStore

[![License](https://img.shields.io/badge/license-MIT-ff69b4.svg)](https://github.com/kzlekk/ReactiveStore/raw/master/LICENSE)
[![Language](https://img.shields.io/badge/swift-5.0-orange.svg)](https://swift.org/blog/swift-5-released/)
[![Build Status](https://travis-ci.com/kzlekk/ClassyFlux.svg?branch=master)](https://travis-ci.com/kzlekk/ReactiveStore)
[![Coverage Status](https://coveralls.io/repos/github/kzlekk/ReactiveStore/badge.svg?branch=master)](https://coveralls.io/github/kzlekk/ReactiveStore?branch=master)

Lightweight reactive store implementation for state management written in Swift. ReactiveStore protocol provides methods and properties allowing to handle actions send to the store and modify store properties accordingly. Dispatching actions (which can be asynchronous) to the store is performed serially and grantees  that the mutations will be applied in the proper order. ReactiveStore protocol allows for custom implementation that adapts running store actions in the background thread or perform any custom syncing logic.

ReactiveStore can be used as a model part of MVC paradigm derivatives, as a global shared state or even with SwiftUI. 

To use ReactiveStore with SwiftUI it is required to add ObservableObject conformance to store implementation class and mark all mutable 
properties with @Published decorator.

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
