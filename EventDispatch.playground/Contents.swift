import UIKit

// some useful custom operators (optional)
infix operator <- { associativity none precedence 100 }
infix operator += { associativity right precedence 90 }
infix operator -= { associativity right precedence 90 }
infix operator +-= { associativity right precedence 90 }


// PUBLISHER SIDE:
// An example datatype - Book
struct Book {
    
    // properties:
    
    var title: String {
        // trigger the event when title changes
        didSet { onTitleChange <- (oldValue, title) }
    }
    
    var price: Double {
        didSet {
            // trigger the event when price changes
            onPriceChange <- (oldValue, price)
            // trigger the event when price is going down
            if price < oldValue {
                onSale <- ()
            }
        }
    }
    
    // published events:
    
    let onTitleChange = EventDispatch<String>()
    let onPriceChange = EventDispatch<Double>()
    let onSale = EventDispatch<Void>()
    
}


// SUBSCRIBER SIDE:
// Usage of events

var book1 = Book(title: "Pride and Prejudice", price: 30.0)

// we want to be notified when the book is on sale...
book1.onSale += {
    print("the book is on sale")
}

book1.price = 35.0
book1.price = 40.0
book1.price = 35.0 // on sale
book1.price = 40.0
book1.price = 35.0 // on sale
book1.price = 30.0 // on sale
