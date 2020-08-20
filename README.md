# ReactiveStore

[![License](https://img.shields.io/badge/license-MIT-ff69b4.svg)](https://github.com/kzlekk/ReactiveStore/raw/master/LICENSE)
[![Language](https://img.shields.io/badge/swift-5.0-orange.svg)](https://swift.org/blog/swift-5-released/)
[![Build Status](https://travis-ci.com/kzlekk/ClassyFlux.svg?branch=master)](https://travis-ci.com/kzlekk/ReactiveStore)
[![Coverage Status](https://coveralls.io/repos/github/kzlekk/ReactiveStore/badge.svg?branch=master)](https://coveralls.io/github/kzlekk/ReactiveStore?branch=master)

Simple reactive store implementation for state management written in Swift. 

ReactiveStore can be used as a model part of MVC paradigm derivatives, as a global shared state or even with SwiftUI. 

To use ReactiveStore with SwiftUI it is required to add ObservableObject conformance to store implementation class and mark all mutable 
properties with @Published decorator.
