use std::sync::mpsc;
use std::thread;

struct Address {
    country: String,
    city: String,
    street: String,
}

struct Message {
    journey_preference: Option<String>,
    // journeyDate: DateTime<Utc>,
    journey_price: Option<f64>,
    customer_address: Option<Address>,
    decision: Option<String>,
}

fn eval_offer(i: f64) -> bool {
    true
}

fn main() {
    //some mock values
    let max_price: f64 = 1000.00;
    let country = String::from("Portugal");
    let city = String::from("Lisbon");
    let street = String::from("Rua Augusta");
    let addr: Address = Address {
        country,
        city,
        street,
    };
    //channel that will be used in the communication
    let (tx, rx): (mpsc::Sender<Message>, mpsc::Receiver<Message>) = mpsc::channel();

    let customer = thread::spawn(move || {
        println!("Starting the customer!");
        thread::spawn(move || {
            println!("Starting the agency!");
            let m = rx.recv().unwrap();
            match m.customer_address {
                Some(addr) => println!("Address: {} {} {}", addr.country, addr.city, addr.street),
                None => (),
            }
            println!("Closing the agency!");
        });

        tx.send(Message {
            journey_preference: None,
            customer_address: Some(addr),
            journey_price: None,
            decision: None,
        })
        .unwrap();

        println!("Closing the customer!");
    });

    let _ = customer.join();
}
