# Go-Rust-FreeST

Comparing Go, Rust and FreeST.

## Algorithm

Behaviour for the customer:
```Java
class Customer {
	Address addr;
	double price, maxPrice;
	bool loop := true;
	String journeyPref;
	new Agency.sell {
		sendWhile (loop) {
			send( journeyPref );
			price := receive;
			loop := evalOffer(journeyPref,price);
			// implementation of evalOffer omitted
		};
		sendCase( evalPrice(price,maxPrice) ) {
			ACCEPT . send( addr ); Date date := receive;
			REJECT . null; /* customer rejects price,end of protocol */ 
		}
	} /* End method invocation */
}
```
Behaviour for the Agency:

```Java
class Agency {
	String journeyPref;
	void acceptOrder sell {
		receiveWhile {
			journeyPref := receive;
			double price := getPrice( journeyPref );
			// implementation of getPrice omitted
			send( price );
		}
		receiveCase (x) { // buyer accepts price
			ACCEPT . new Service • orderDelivery { } ,
			REJECT . null;/* receiveCase : buyer rejects */ 
                }
	} /* End method sell */
}
```

Behaviour for the Service:
```Java
class Service {
	void receiveOrderSession orderDelivery() {
		Address custAddress := receive;
	Date date := new Date();
	send( date );
	}
}
```

## How to execute:

### Go
In the directory Go/plane_ticket:

* Compile: ``` go install ```
* Execute: ``` plane_ticket ```

### Rust
In the directory Rust/plane_ticket:

* Compile: ``` cargo build --bin plane_ticket```
* Check for errors without compiling: ``` cargo check --bin plane_ticket```
* Execute: ``` cargo run --bin plane_ticket```

### FreeST
In the directory FreeST:

* Execute: ``` freest plane_ticket.fst ```

## Links

### Rust
* Rust book: https://doc.rust-lang.org/stable/book/

### Go
* Go Documentation: https://golang.org/doc/
* Concurrency Patterns in Go: https://youtu.be/YEKjSzIwAdA?list=WL
* Rob Pikes Talk: https://youtu.be/f6kdp27TYZs

### FreeST
* FreeST Tutorial: http://rss.di.fc.ul.pt/tryit/FreeST
* FreeST Website: http://rss.di.fc.ul.pt/tools/freest/
