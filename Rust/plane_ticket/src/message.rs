/**
* Authors: Jorge Martins && Diogo Lopes
* This example is from Vasconcelos, V.T. (and several others):
* "Behavioral Types in Programming Languages" (figures 2.4, 2.5 and 2.6)
*/
//Messages to be traded
use crate::customer;
use chrono::prelude::*;
use std::fmt::{self, Display, Formatter};

pub enum Decision {
    ACCEPT,
    REJECT,
}

//simple function to print the Decision type
impl Display for Decision {
    // `f` is a buffer, and this method must write the formatted string into it
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        match self {
            Decision::ACCEPT => write!(f, "ACCEPT"),
            Decision::REJECT => write!(f, "REJECT"),
        }
    }
}

pub enum Message {
    JourneyPreference(String),
    JourneyDate(Date<Utc>),
    JourneyPrice(f64),
    CustomerAddress(customer::Address),
    CustomerDecision(Decision),
}
