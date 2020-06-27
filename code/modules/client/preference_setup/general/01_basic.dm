datum/preferences
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/spawnpoint = "Aft Cryogenic Storage" 			//where this character will spawn
	var/real_name						//our character's name
//	var/real_first_name					//Eclipse Removal
	var/family_name						//Eclipse refactor: Used in some perks. Clan/family name.
	var/be_random_name = 0				//whether we are a random name every round

/datum/category_item/player_setup_item/physical/basic
	name = "Basic"
	sort_order = 1

/datum/category_item/player_setup_item/physical/basic/load_character(savefile/S)
	from_file(S["gender"],                pref.gender)
	from_file(S["age"],                   pref.age)
	from_file(S["spawnpoint"],            pref.spawnpoint)
//	from_file(S["real_first_name"],       pref.real_first_name)		//Eclipse Removal
	from_file(S["family_name"],           pref.family_name)		//Eclipse Edit
	from_file(S["real_name"],             pref.real_name)
	from_file(S["name_is_always_random"], pref.be_random_name)

/datum/category_item/player_setup_item/physical/basic/save_character(savefile/S)
	to_file(S["gender"],                  pref.gender)
	to_file(S["age"],                     pref.age)
	to_file(S["spawnpoint"],              pref.spawnpoint)
//	to_file(S["real_first_name"],         pref.real_first_name)		//Eclipse Removal
	to_file(S["family_name"],             pref.family_name)			//Eclipse Edit
	to_file(S["real_name"],               pref.real_name)
	to_file(S["name_is_always_random"],   pref.be_random_name)

/datum/category_item/player_setup_item/physical/basic/sanitize_character()
	var/datum/species/S = all_species[pref.species ? pref.species : SPECIES_HUMAN]
	if(!S) S = all_species[SPECIES_HUMAN]
	pref.age                = sanitize_integer(pref.age, S.min_age, S.max_age, initial(pref.age))
	pref.gender             = sanitize_inlist(pref.gender, S.genders, pick(S.genders))
	pref.spawnpoint         = sanitize_inlist(pref.spawnpoint, get_late_spawntypes(), initial(pref.spawnpoint))
	pref.be_random_name     = sanitize_integer(pref.be_random_name, 0, 1, initial(pref.be_random_name))

	// This is a bit noodly. If pref.cultural_info[TAG_CULTURE] is null, then we haven't finished loading/sanitizing, which means we might purge
	// numbers or w/e from someone's name by comparing them to the map default. So we just don't bother sanitizing at this point otherwise.
	/*
	if(pref.cultural_info[TAG_CULTURE])
		var/decl/cultural_info/check = SSculture.get_culture(pref.cultural_info[TAG_CULTURE])
		if(check)
			pref.real_name = check.sanitize_name(pref.real_name, pref.species)
			if(!pref.real_name)
				pref.real_name = random_name(pref.gender, pref.species)
	*/
/datum/category_item/player_setup_item/physical/basic/content()
	. = list()
	. += "<b>Character name:</b> "		//Begin eclipse edit
	. += "<a href='?src=\ref[src];rename=1'><b>[pref.real_name]</b></a><br>"
	. += "<b>Family/clan name:</b> "
	. += "<a href='?src=\ref[src];famname=1'><b>[pref.family_name]</b></a><br>"		//End eclipse edit
	. += "<a href='?src=\ref[src];random_name=1'>Randomize Name</A><br>"
	. += "<a href='?src=\ref[src];always_random_name=1'>Always Random Name: [pref.be_random_name ? "Yes" : "No"]</a>"
	. += "<hr>"
	. += "<b>Gender:</b> <a href='?src=\ref[src];gender=1'><b>[gender2text(pref.gender)]</b></a><br>"
	. += "<b>Age:</b> <a href='?src=\ref[src];age=1'>[pref.age]</a><br>"
	. += "<b>Spawn Point</b>: <a href='?src=\ref[src];spawnpoint=1'>[pref.spawnpoint]</a><br>"

	. = jointext(.,null)

/datum/category_item/player_setup_item/physical/basic/OnTopic(href, href_list, mob/user)
	var/datum/species/S = all_species[pref.species]

// // // BEGIN PARTIAL ECLIPSE REVERT // // //
	if(href_list["rename"])		//Eclipse Revert: Full name
		var/raw_name = input(user, "Choose your character's name:", "Character Name", pref.real_name)  as text|null
		if (!isnull(raw_name) && CanUseTopic(user))
			var/new_name = sanitize_name(raw_name, pref.species)
			if(new_name)
				pref.real_name = new_name
				return TOPIC_REFRESH
			else
				to_chat(user, SPAN_WARNING("Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and ."))
			return TOPIC_NOACTION

	if(href_list["famname"])		//Eclipse Rework: Family name
		log_debug("famname entered")
		var/last_name_max_length = 14
		var/raw_family_name = input(user, "Choose your character's family/clan name. (This is used in some perks for 'x family heirloom' items.)", "Character Family/Clan Name", pref.family_name)  as text|null
		if(CanUseTopic(user))
			log_debug("famname canusetopic true")
			if(isnull(raw_family_name) || raw_family_name == "")
				log_debug("famname is null")
				pref.family_name = null
				return TOPIC_REFRESH
			else
				log_debug("famname is [raw_family_name]")
				var/new_famname = sanitize_name(raw_family_name, pref.species, last_name_max_length)
				log_debug("sanitised famname is [new_famname]")
				if(new_famname)
					pref.family_name = new_famname
					return TOPIC_REFRESH
				else
					to_chat(user, SPAN_WARNING("Invalid family/clan name. Your name should be at least 2 and at most [last_name_max_length] characters long. It may only contain the characters A-Z, a-z, -, ' and ."))
					return TOPIC_NOACTION

	else if(href_list["random_name"])
		pref.real_name = random_name(pref.gender, pref.species)
		return TOPIC_REFRESH

// // // END PARTIAL ECLIPSE REVERT // // //

	else if(href_list["always_random_name"])
		pref.be_random_name = !pref.be_random_name
		return TOPIC_REFRESH

	else if(href_list["gender"])
		var/new_gender = input(user, "Choose your character's gender:", CHARACTER_PREFERENCE_INPUT_TITLE, pref.gender) as null|anything in S.genders
		S = all_species[pref.species]
		if(new_gender && CanUseTopic(user) && (new_gender in S.genders))
			pref.gender = new_gender
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["age"])
		var/new_age = input(user, "Choose your character's age:\n([S.min_age]-[S.max_age])", CHARACTER_PREFERENCE_INPUT_TITLE, pref.age) as num|null
		if(new_age && CanUseTopic(user))
			pref.age = max(min(round(text2num(new_age)), S.max_age), S.min_age)
			//pref.skills_allocated = pref.sanitize_skills(pref.skills_allocated)		// The age may invalidate skill loadouts
			return TOPIC_REFRESH

	else if(href_list["spawnpoint"])
		var/list/spawnkeys = list()
		for(var/spawntype in get_late_spawntypes())
			spawnkeys += spawntype
		var/choice = input(user, "Where would you like to spawn when late-joining?") as null|anything in spawnkeys
		if(!choice || !get_late_spawntypes()[choice] || !CanUseTopic(user))	return TOPIC_NOACTION
		pref.spawnpoint = choice
		return TOPIC_REFRESH

	return ..()