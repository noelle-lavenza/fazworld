/obj/item/razorweb
	name = "razorweb wad"
	desc = "A wad of crystalline monofilament."
	icon = 'mods/species/ascent/icons/razorweb.dmi'
	icon_state = "wad"
	var/web_type = /obj/effect/razorweb

/obj/item/razorweb/throw_impact(var/atom/hit_atom)
	var/obj/effect/razorweb/web = new web_type(get_turf(hit_atom))
	..()
	if(isliving(hit_atom))
		web.buckle_mob(hit_atom)
		web.visible_message(SPAN_DANGER("\The [hit_atom] is tangled in \the [web]!"))
	web.entangle(hit_atom, TRUE)
	playsound(usr, 'mods/species/ascent/sounds/razorweb_twang.ogg', 50)
	qdel(src)

// Hey, did you ever see The Cube (1997) directed by Vincenzo Natali?
/obj/effect/razorweb
	name = "razorweb"
	desc = "A glimmering web of razor-sharp crystalline strands. Probably not something you want to sprint through."
	icon = 'mods/species/ascent/icons/razorweb.dmi'
	icon_state = "razorweb"
	anchored = TRUE
	z_flags = ZMM_MANGLE_PLANES

	var/mob/owner
	var/decays = TRUE
	var/break_chance = 100
	var/last_light
	var/image/gleam
	var/image/web
	var/static/species_immunity_list = list(
		SPECIES_MANTID_ALATE   = TRUE,
		SPECIES_MANTID_GYNE    = TRUE
	)

/obj/effect/razorweb/Destroy()
	if(owner)
		owner = null
	. = ..()

/obj/effect/razorweb/mapped
	decays = FALSE

/obj/effect/razorweb/tough
	name = "tough razorweb"
	break_chance = 33

/obj/effect/razorweb/Initialize(var/mapload)

	. = ..(mapload)

	for(var/obj/effect/razorweb/otherweb in loc)
		if(otherweb != src)
			return INITIALIZE_HINT_QDEL

	if(decays)
		addtimer(CALLBACK(src, /obj/effect/razorweb/proc/decay), 15 MINUTES)

	web = image(icon = icon, icon_state = "razorweb")
	gleam = emissive_overlay(icon = icon, icon_state = "razorweb-gleam")
	var/turf/T = get_turf(src)
	if(T) last_light = T.get_lumcount()
	icon_state = ""
	update_icon()
	START_PROCESSING(SSobj, src)

/obj/effect/razorweb/proc/decay()
	playsound(usr, 'mods/species/ascent/sounds/razorweb_break.ogg', 50)
	qdel_self()

/obj/effect/razorweb/attack_hand(mob/user)
	user.visible_message(SPAN_DANGER("\The [user] yanks on \the [src]!"))
	entangle(user, TRUE)
	qdel_self()

/obj/effect/razorweb/attackby(var/obj/item/thing, var/mob/user)

	var/destroy_self
	if(thing.force)
		visible_message(SPAN_DANGER("\The [user] breaks \the [src] with \the [thing]!"))
		destroy_self = TRUE

	if(prob(15) && user.unEquip(thing))
		visible_message(SPAN_DANGER("\The [thing] is sliced apart!"))
		qdel(thing)

	if(destroy_self)
		qdel(src)

/obj/effect/razorweb/on_update_icon()
	overlays.Cut()
	web.alpha = 255 * last_light
	overlays = list(web, gleam)

/obj/effect/razorweb/Process()
	var/turf/T = get_turf(src)
	if(T)
		var/current_light = T.get_lumcount()
		if(current_light != last_light)
			last_light = current_light
			update_icon()

/obj/effect/razorweb/user_unbuckle_mob(var/mob/user)
	var/mob/living/M = unbuckle_mob()
	if(M)
		if(M != user)
			visible_message(SPAN_NOTICE("\The [user] drags \the [M] free of \the [src]!"))
			entangle(user, silent = TRUE)
		else
			visible_message(SPAN_NOTICE("\The [M] writhes free of \the [src]!"))
		entangle(M, silent = TRUE)
		add_fingerprint(user)
	return M

/obj/effect/razorweb/Crossed(var/mob/living/L)
	. = ..()
	entangle(L)

/obj/effect/razorweb/proc/entangle(var/mob/living/L, var/silent)

	if(!istype(L) || !L.simulated || L.lying || (MOVING_DELIBERATELY(L) && prob(25)) || L.is_floating)
		return

	var/mob/living/carbon/human/H
	if(ishuman(L))
		H = L
		if(species_immunity_list[H.species.name])
			return

	if(!silent)
		visible_message(SPAN_DANGER("\The [L] blunders into \the [src]!"))

	var/severed = FALSE
	var/armour_prob = prob(100 * L.get_blocked_ratio(null, BRUTE, damage = ARMOR_MELEE_RESISTANT))
	if(H && prob(35))
		var/obj/item/organ/external/E
		var/list/limbs = H.get_external_organs()
		if(limbs)
			limbs = limbs.Copy()
		for(var/obj/item/organ/external/limb in shuffle(limbs))
			if(!istype(limb) || !(limb.limb_flags & ORGAN_FLAG_CAN_AMPUTATE))
				continue
			var/is_vital = FALSE
			for(var/obj/item/organ/internal/I in limb.internal_organs)
				if(H.species?.is_vital_organ(H, I))
					is_vital = TRUE
					break
			if(!is_vital)
				E = limb
				break
		if(E && !armour_prob)
			visible_message(SPAN_DANGER("The crystalline strands slice straight through \the [H]'s [E.amputation_point || E.name]!"))
			E.dismember()
			severed = TRUE

	if(!severed && !armour_prob)
		L.apply_damage(rand(25, 50), used_weapon = src)
		visible_message(SPAN_DANGER("The crystalline strands cut deeply into \the [L]!"))

	if(prob(break_chance))
		visible_message(SPAN_DANGER("\The [src] breaks apart!"))
		playsound(usr, 'mods/species/ascent/sounds/razorweb_break.ogg', 50)
		qdel(src)
	else
		playsound(usr, 'mods/species/ascent/sounds/razorweb_twang.ogg', 50)
		break_chance = min(break_chance+10, 100)