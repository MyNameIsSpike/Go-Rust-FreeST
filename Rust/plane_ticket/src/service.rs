/**
* Authors: Jorge Martins && Diogo Lopes
* This example is from Vasconcelos, V.T. (and several others):
* "Behavioral Types in Programming Languages" (figures 2.4, 2.5 and 2.6)
*/
use crate::message::Message;
use chan::Receiver;
use chan::Sender;
use chrono::prelude::*;
use rand::prelude::*;

pub fn order_delivery(send: Sender<Message>, recv: Receiver<Message>) {
    let service_send = send.clone();
    let service_recv = recv.clone();
    println!("Starting the service!");
    let customer_address_message = service_recv.recv().unwrap();
    match customer_address_message {
        Message::CustomerAddress(addr) => {
            println!(
                "Customer address: Country-> {}, City->{}, Street->{}",
                addr.country(),
                addr.city(),
                addr.street(),
            );
            let mut rng = rand::thread_rng();
            let month: u32 = rng.gen_range(1, 13);
            let day: u32 = rng.gen_range(1, 30);
            let date = Utc.ymd(2021, month, day);
            let flight_date = Message::JourneyDate(date);
            service_send.send(flight_date);
        }
        _ => (),
    }

    println!("Closing the service!");
}
