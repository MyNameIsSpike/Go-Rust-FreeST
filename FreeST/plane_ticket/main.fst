-----------------------DATATYPES-------------------------
-- It would be useful to have a separated module
--for defining datatypes that are going to be
--used in a lot of files (e.g. Strings)
data String = Nil | StringCons Char String

-- Address should be defined in a "customer" class
--but I wasn't able to import classes in Freest
-- For now we will have to do everything in the same file
data Address = AddressCons String String String

data JourneyPreference = JPrefCons String

data JourneyDate = JDCons String String String --day month year (maybe we should also create a Date datatype)

data JourneyPrice = JPrice Int Int -- euros cents (don't know how to write floats) (problem: cents has to be 0<=cents<=99)

data CustomerAddress = CACons Address

data Decision = Reject | Accept

data CustomerDecision = CDCons Decision

data Message = JourneyPreference
                | JourneyDate
                | JourneyPrice
                | CustomerAddress
                | CustomerDecision
---------------------------------------------------------

-- main is not supposed to return Int, this is just temporary
main : Int
main =
    -- some mock values
    let max_price = 1000 in
    -- There must be another way to write strings in Freest
    --For now this worked
    let country =  StringCons 'P' $ StringCons 'o' $ StringCons 'r'
        $ StringCons 't' $ StringCons 'u' $ StringCons 'g'
        $ StringCons 'a' $ StringCons 'l' Nil in
    let city =
        StringCons 'L' $ StringCons 'i' $ StringCons 's'
        $ StringCons 'b'$ StringCons 'o' $ StringCons 'n' Nil in
    let street =
        StringCons 'R' $ StringCons 'u' $ StringCons 'a'
        $ StringCons ' ' $ StringCons 'A' $ StringCons 'u'
        $ StringCons 'g' $ StringCons 'u' $ StringCons 's'
        $ StringCons 't' $ StringCons 'a' Nil in
    let addr = AddressCons country city street in
    let journey_pref =
        StringCons 'R' $ StringCons 'o' $ StringCons 'm'
        $ StringCons 'e' Nil in

    --channel that will be used in the communication

    max_price