//Contains the messages to be traded between threads
use crate::customer;
use chrono::prelude::*;
use std::fmt::{self, Display, Formatter};

pub enum Decision {
    ACCEPT,
    REJECT,
}

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
