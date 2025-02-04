var/global/const/ANI_FREQ = 1363

/obj/machinery/telecomms/bus/preset_one/ministation
	id = "Bus"
	network = "tcommsat"
	freq_listening = list()
	autolinkers = list("processor1","server1","hub")

/obj/machinery/telecomms/processor/preset_one/ministation
	id = "Processor"
	network = "tcommsat"
	autolinkers = list("processor1","hub")

/obj/machinery/telecomms/server/presets/ministation
	id = "Server"
	freq_listening = list()
	channel_tags = list(
		list(MED_FREQ,  "Medical", COMMS_COLOR_MEDICAL),
		list(SUP_FREQ,  "Logistics", COMMS_COLOR_SUPPLY),
		list(SRV_FREQ,  "Service", COMMS_COLOR_SERVICE),
		list(ANI_FREQ,  "Animatronic Private", COMMS_COLOR_AI),
		list(ENT_FREQ,  "Entertainment", COMMS_COLOR_ENTERTAIN),
		list(COMM_FREQ, "Management", COMMS_COLOR_COMMAND),
		list(ENG_FREQ,  "Maintenance", COMMS_COLOR_ENGINEER),
		list(SEC_FREQ,  "Security", COMMS_COLOR_SECURITY)
		)
	autolinkers = list("server1","hub")

/obj/machinery/telecomms/hub/preset/ministation
	id = "Hub"
	network = "tcommsat"
	autolinkers = list("hub","receiverA", "broadcasterA")
