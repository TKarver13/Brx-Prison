local Translations = {
    error = {
        ["missing_something"] = "It looks like you are missing something...",
        ["not_enough_police"] = "Not enough Police..",
        ["door_open"] = "The door is already open..",
        ["cancelled"] = "Process Canceled..",
        ["didnt_work"] = "It did not work..",
        ["emty_box"] = "The Box Is Empty..",
        ["injail"] = "You're in jail for %{Time} months..",
        ["item_missing"] = "You are missing an Item..",
        ["escaped"] = "You escaped... Get the hell out of here.!",
        ["do_some_work"] = "Do some work for sentence reduction, Your job: %{currentjob} ",
        ["security_activated"] = "Highest security level is active, stay with the cell blocks!"
    },
    success = {
        ["found_stashitem"] = "Something is stashed here..",
        ["found_stashitem_double"] = "Someone hid some things here..",
        ["time_cut"] = "You've worked some time off your sentence.",
        ["free_"] = "You're free! Enjoy it! :)",
        ["timesup"] = "Your time is up! Check yourself out at the visitors center",
    },
    info = {
        ["timeleft"] = "You still have ... %{JAILTIME} months",
        ["lost_job"] = "You're Unemployed",
        ["job_interaction"] = "[E] Electricity Work",
        ["job_interaction_target"] = "Do some work!",
        ["received_property"] = "You got your property back..",
        ["seized_property"] = "Your property has been seized, you'll get everything back when your time is up..",
        ["cells_blip"] = "Cells",
        ["freedom_blip"] = "Jail Front Desk",
        ["cafe_blip"] = "Cafeteria",
        ["medical_blip"] = "Medical",
        ["work_blip"] = "Prison Work",
        ["target_freedom_option"] = "Check Time",
        ["target_canteen_option"] = "Get Food",
        ["police_alert_title"] = "New Call",
        ["police_alert_description"] = "Prison Outbreak",
        ["connecting_device"] = "Connecting Device",
        ["working"] = "Fixing..."
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
