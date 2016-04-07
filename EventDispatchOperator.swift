import Foundation

infix operator <- { associativity none precedence 100 }
infix operator += { associativity right precedence 90 }
infix operator -= { associativity right precedence 90 }
infix operator +-= { associativity right precedence 90 }

public func += <EventType> (event: EventDispatch<EventType>, handler: EventType -> ()) {
    event.addHandler(handler)
}

public func -= <EventType> (event: EventDispatch<EventType>, handler: EventDispatch<EventType>.HandlerIdentifier) {
    event.removeHandler(handler)
}

public func +-= <EventType> (event: EventDispatch<EventType>, handler: EventType -> ()) {
    event.handleOnce(handler)
}

public func <- <EventType> (event: EventDispatch<EventType>, value: EventType) {
    event.notify(value)
}

public func <- <EventType: Equatable> (event: EventDispatch<EventType>, pair: (oldValue: EventType, newValue: EventType)) {
    event.notifyIfChanged(old: pair.oldValue, new: pair.newValue)
}
