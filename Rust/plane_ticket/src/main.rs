use crate::customer::*;

extern crate chan;

mod agency;
mod customer;
mod message;
mod service;

fn main() {
    //some mock values
    let max_price: f64 = 1000.00;
    let country = String::from("Portugal");
    let city = String::from("Lisbon");
    let street = String::from("Rua Augusta");
    let addr: Address = Address::new(country, city, street);
    let journey_pref: String = String::from("Rome");

    //channel that will be used in the communication
    let (send, recv) = chan::sync::<message::Message>(0);
    customer::order(send, recv, max_price, addr, journey_pref);
    // let customer = thread::spawn(move || {
    //     let customer_send = send.clone();
    //     let customer_recv = recv.clone();
    //     println!("Starting the customer!");
    //     thread::spawn(move || {
    //         let agency_send = send.clone();
    //         let agency_recv = recv.clone();
    //         println!("Starting the agency!");
    //         let mut received_message: Option<Message>;
    //         loop {
    //             received_message = agency_recv.recv();
    //             match received_message {
    //                 None => continue,
    //                 Some(rm) => match rm.journey_preference {
    //                     Some(jrnp) => agency_send.send(Message {
    //                         journey_preference: None,
    //                         journey_date: None,
    //                         customer_address: None,
    //                         journey_price: Some(*HASHMAP.get(&jrnp.to_owned()).unwrap()),
    //                         decision: None,
    //                     }),
    //                     None => break,
    //                 },
    //             }
    //         }
    //         println!("Closing the agency!");
    //     });

    //     let mut in_loop: bool = true;
    //     let mut price: f64 = 0.0;

    //     while in_loop {
    //         customer_send.send(Message {
    //             journey_preference: Some(journey_pref.clone()),
    //             journey_date: None,
    //             customer_address: None,
    //             journey_price: None,
    //             decision: None,
    //         });

    //         let price_message = customer_recv.recv();
    //         match price_message {
    //             None => continue,
    //             Some(pm) => match pm.journey_price {
    //                 Some(p) => price = p,
    //                 None => continue,
    //             },
    //         }
    //         println!("PriceOffer: {}", price);
    //         in_loop = eval_offer(&journey_pref, price);
    //     }
    //     if price <= max_price {
    //         customer_send.send(Message {
    //             journey_preference: None,
    //             journey_date: None,
    //             customer_address: None,
    //             journey_price: None,
    //             decision: Some(String::from("ACCEPT")),
    //         });
    //         customer_send.send(Message {
    //             journey_preference: None,
    //             journey_date: None,
    //             customer_address: Some(addr),
    //             journey_price: None,
    //             decision: None,
    //         });
    //         let date_message = customer_recv.recv();
    //         match date_message {
    //             None => (),
    //             Some(dm) => match dm.journey_date {
    //                 Some(date) => println!(
    //                     "Flight date: {} {} {} {}",
    //                     date.weekday(),
    //                     date.day(),
    //                     date.month(),
    //                     date.year()
    //                 ),
    //                 None => (),
    //             },
    //         }
    //     } else {
    //         customer_send.send(Message {
    //             journey_preference: None,
    //             journey_date: None,
    //             customer_address: None,
    //             journey_price: None,
    //             decision: Some(String::from("REJECT")),
    //         });
    //     }
    //     println!("Closing the customer!");
    // });

    // let _ = customer.join();
}
