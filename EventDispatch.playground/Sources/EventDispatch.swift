import Foundation

public class EventDispatch<Event>: EventDispatchProtocol {
    
    public typealias HandlerIdentifier = Int
    
    private typealias Handler = Event -> ()
    private var handlerIds = [HandlerIdentifier]()
    private var handlers = [Handler]()
    private var lastId: HandlerIdentifier = 0
    
    public init() {}
    
    public func addHandler(handler: Event -> ()) -> HandlerIdentifier {
        lastId += 1
        handlerIds.append(lastId)
        handlers.append(handler)
        return lastId
    }
    
    public func handleOnce(handler: Event -> ()) {
        var id: HandlerIdentifier!
        id = addHandler { [weak self] event in
            handler(event)
            self?.removeHandler(id)
        }
    }
    
    public func removeHandler(handler: HandlerIdentifier) -> Bool {
        if let index = handlerIds.indexOf(handler) {
            handlerIds.removeAtIndex(index)
            let _ = handlers.removeAtIndex(index)
            return true
        } else {
            return false
        }
    }
    
    public func notify(event: Event) {
        let copiedHandlers = handlers
        for handler in copiedHandlers {
            handler(event)
        }
    }
    
}

public protocol EventDispatchProtocol {
    associatedtype EventType
    func notify(event: EventType)
}

extension EventDispatchProtocol where EventType: Equatable {
    
    public func notifyIfChanged(old old: EventType, new: EventType) {
        if old != new {
            notify(new)
        }
    }
    
}

extension EventDispatchProtocol where EventType == Void {
    
    public func notify() {
        notify(())
    }
    
}
