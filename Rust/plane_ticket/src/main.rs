/**
* Authors: Jorge Martins && Diogo Lopes
* This example is from Vasconcelos, V.T. (and several others):
* "Behavioral Types in Programming Languages" (figures 2.4, 2.5 and 2.6)
*/
use crate::customer::*;
use std::thread;

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

    //start the customer
    let customer = thread::spawn(move || {
        customer::order(send, recv, max_price, addr, journey_pref);
    });
    let _ = customer.join();
}
