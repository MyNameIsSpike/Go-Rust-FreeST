use crate::agency;
use crate::message::Decision;
use crate::message::Message;
use chan::Receiver;
use chan::Sender;
use chrono::prelude::*;
use rand::prelude::*;
use std::thread;

//Customer Address
pub struct Address {
    country: String,
    city: String,
    street: String,
}

impl Address {
    pub fn new(country: String, city: String, street: String) -> Address {
        return Address {
            country,
            city,
            street,
        };
    }

    pub fn country(&self) -> String {
        return self.country.clone();
    }
    pub fn city(&self) -> String {
        return self.city.clone();
    }
    pub fn street(&self) -> String {
        return self.street.clone();
    }
}

pub fn order(
    send: Sender<Message>,
    recv: Receiver<Message>,
    max_price: f64,
    addr: Address,
    journey_pref: String,
) {
    let customer = thread::spawn(move || {
        let customer_send = send.clone();
        let customer_recv = recv.clone();
        println!("Starting the customer!");
        let _ = thread::spawn(move || {
            agency::sell(send, recv);
        });
        let mut price: f64;
        loop {
            let journey_pref_message = Message::JourneyPreference(journey_pref.clone());

            customer_send.send(journey_pref_message);
            let received: Message = customer_recv.recv().unwrap();
            match received {
                Message::JourneyPrice(p) => {
                    price = p;
                    println!("Price Offer: {}", price);
                    if eval_offer(&journey_pref, &price) {
                        break;
                    }
                }
                _ => (),
            }
        }

        let customer_decision: Message;
        if price < max_price {
            customer_decision = Message::CustomerDecision(Decision::ACCEPT);
            customer_send.send(customer_decision);
            let address_message = Message::CustomerAddress(addr);
            customer_send.send(address_message);
            let received = customer_recv.recv().unwrap();
            match received {
                Message::JourneyDate(d) => {
                    println!(
                        "Flight date: {}, {}/{}/{}",
                        d.weekday(),
                        d.day(),
                        d.month(),
                        d.year()
                    );
                }
                _ => (),
            }
        } else {
            customer_decision = Message::CustomerDecision(Decision::REJECT);
            customer_send.send(customer_decision);
        }
        println!("Closing the customer!");
    });

    let _ = customer.join();
}

fn eval_offer(_journey_pref: &String, _price: &f64) -> bool {
    let mut rng = rand::thread_rng();
    return rng.gen::<f64>() < 0.5;
}
