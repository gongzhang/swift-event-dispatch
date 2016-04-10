# INTRODUCTION

`EventDispatch` is a helper class that can be used to implement **observer pattern** in Swift. It provides an extremely convenience way to implementing **callbacks**, **event publish-subscribe**, and **MVC/MVP/MVVM patterns**.

It's also a **replacement for KVO** (Key-Value-Observing, a traditional Objective-C feature).

# EXAMPLE

Want to get notified when the value changes?

```swift
var price: Double = 100.0
```

On the **publisher** side, define the event like this:

```swift
// define the event
let onPriceChange = EventDispatch<Double>()

var price: Double = 100.0 {
    // trigger the event
    didSet { onPriceChange <- (oldValue, price) }
}
```

On the **subscriber** side, observe the event like this:

```swift
onPriceChange += {
    // observe the event with block
    print("the price has changed to \($0)")
}

price = 90.0 // will print 'the price has changed to 90.0'
```

# INSTALLATION

Copy `EventDispatch.swift` and `EventDispatchOperator.swift`(optional) to your project. And here you go.

(The source files are located in folder `EventDispatch.playground/Sources/`.)

# HOW TO USE

## 1. Define/trigger an event (Publisher side)

Use `EventDispatch` class to define an event. Event may have an argument that stores extra information.

```swift
// an event with an Double argument
let onPriceChange = EventDispatch<Double>()

// or with an object argument
let onDateUpdate = EventDispatch<NSDate>()

// or with a tuple
let onGotResponse = EventDispatch<(Int, String)>()

// or just a simple callback without extra information
let onCallback = EventDispatch<Void>()

```

You trigger an event by calling `notify:` method:

```swift
// the argument will be passed to all subscribers
onPriceChange.notify(90.0)
 onDateUpdate.notify(NSDate())
onGotResponse.notify((200, "ok"))
   onCallback.notify()
```

or using shorthand operator `<-`:

```swift
onPriceChange <- 90.0
onDateUpdate  <- NSDate()
onGotResponse <- (200, "ok")
onCallback    <- ()
```

If the argument type comforms to Swift `Equatable` protocol, you can trigger the event **only if the value does not equal to the old one**. This feature is really handy for implementing "value-change" events. Call `notifyIfChanged(old:new:)` method or use same `<-` operator with two parameters:

```swift
var price: Double = 100.0 {
    // trigger only if the value changed
    didSet { onPriceChange <- (oldValue, price) }
}

price = 100.0 // not trigger
price = 90.0  // trigger
price = 90.0  // not trigger
price = 90.0  // not trigger
price = 90.0  // not trigger
price = 100.0 // trigger
```

## 2. Observe events (Subscriber side)

You observe an event by adding handler on it. The argument is passed into your handler.

```swift
onGotResponse.addHandler { (code, msg) in
    // handle the event here...
}
```

You can also use shorthand `+=` operator to observe an event:

```swift
onCallback += {
    // handle the event here...
}
```

Handlers can also be removed. **This is particular important when you want to release captured objects or break retain cycle**:

```swift
// hold the id when you add a handler
let handler_id = onCallback.addHandler {...}

// remove a handler later, by its identifier
onCallback.removeHandler(handler_id)
```

Sometimes your handler is expected to be called only once (e.g. handling the result of a long task). Then you can use `handleOnce:` method instead of `addHandler:`:

```swift
onCallback.handleOnce {
    // this handler will be automatically removed
    // after handling a result. No worry about retain
    // cycle.
}
```

# BEHAVIORS DETAILS

## 1. Threading

`EventDispatch` is **not** thread-safe, and your handlers will be called right after you fire the event. This behavior is similar with Swift's property observer `willSet` and `didSet`. In most situation, follow these conventions will give you a good practice:

- call methods of `EventDispatch` only from **main thread**
- using GCD api in handlers to sync with other threads

## 2. Handlers calling order

According to the concept of observer design pattern, you **should not** depend on the calling order of handlers. However, `EventDispatch` has a determined handler calling order (that is, *earlier added, earlier called*) , which makes your code more stable and debuggable.

## 3. Add/remove handler in a handler

You **can** add/remove handler in a handler. Something like this:

```swift
var handler2: EventDispatch<Void>.HandlerIdentifier!

let handler1 = onCallback.addHandler {
    ...
    // remove handler2
    onCallback.removeHandler(handler2)
}

handler2 = onCallback.addHandler { ... }
```

If you modify the handlers in a handler, the modification will take effect **at the next time** the event get triggered. Therefore, in the example above, `handler1` and `handler2` will be both triggered on the first time of `onCallback` get triggered, and after that, only `handler1` will be triggered.

# CONTACT

gong@me.com


