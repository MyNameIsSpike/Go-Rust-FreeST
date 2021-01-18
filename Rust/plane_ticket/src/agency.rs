/**
* Authors: Jorge Martins && Diogo Lopes
* This example is from Vasconcelos, V.T. (and several others):
* "Behavioral Types in Programming Languages" (figures 2.4, 2.5 and 2.6)
*/
use crate::message::Decision;
use crate::message::Message;
use crate::service;
use chan::Receiver;
use chan::Sender;
use std::collections::HashMap;
use std::thread;
//Agency sell code
pub fn sell(send: Sender<Message>, recv: Receiver<Message>) {
    let mut map: HashMap<String, f64> = HashMap::new();
    map.insert(String::from("Rome"), 289.65);
    map.insert(String::from("Paris"), 176.75);
    map.insert(String::from("Lisbon"), 196.46);
    map.insert(String::from("New York"), 456.67);
    map.insert(String::from("Kyoto"), 516.00);

    let agency_send = send.clone();
    let agency_recv = recv.clone();
    println!("Starting the agency!");
    let mut received: Message;
    loop {
        received = agency_recv.recv().unwrap();
        match received {
            Message::JourneyPreference(jp) => {
                println!("Journey Preference: {}", jp);
                let price_message = Message::JourneyPrice(map[&jp]);
                agency_send.send(price_message);
            }
            Message::CustomerDecision(d) => {
                println!("Received Decision: {}", d);
                match d {
                    Decision::ACCEPT => {
                        let _ = thread::spawn(move || {
                            service::order_delivery(send, recv);
                        });
                    }
                    Decision::REJECT => (),
                }
                break;
            }
            _ => (),
        }
    }
    println!("Closing the agency!");
}
