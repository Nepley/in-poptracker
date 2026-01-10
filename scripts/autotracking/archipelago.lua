ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CURRENT_INDEX = -1

function onClear(slotData)
	CURRENT_INDEX = -1

	-- Reset Locations
	for _, layoutLocationPath in pairs(LOCATION_MAPPING) do
		if layoutLocationPath[1] then
			local layoutLocationObject = Tracker:FindObjectForCode(layoutLocationPath[1])

			if layoutLocationObject then
				if layoutLocationPath[1]:sub(1, 1) == "@" then
					layoutLocationObject.AvailableChestCount = layoutLocationObject.ChestCount
				else
					layoutLocationObject.Active = false
				end
			end
		end
	end

	-- Reset Items
	for _, item in pairs(ITEM_MAPPING) do
		for _, layoutItemData in pairs(item) do
			if layoutItemData[1] and layoutItemData[2] then
				local layoutItemObject = Tracker:FindObjectForCode(layoutItemData[1])

				if layoutItemObject then
					if layoutItemData[2] == "toggle" then
						layoutItemObject.Active = false
					elseif layoutItemData[2] == "progressive" then
						layoutItemObject.CurrentStage = 0
						layoutItemObject.Active = false
					elseif layoutItemData[2] == "consumable" then
						layoutItemObject.AcquiredCount = 0
					elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
						print(string.format("onClear: Unknown item type %s for code %s", layoutItemData[2], layoutItemData[1]))
					end
				elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
					print(string.format("onClear: Could not find object for code %s", layoutItemData[1]))
				end
			end
		end
	end

	local function in_array(val, array)
		for index, value in ipairs(array) do
			if value == val then
				return true
			end
		end

		return false
	end

	local spellGoal = 0
	if slotData['goal'] == 4 then
		spellGoal = 1
	elseif slotData['goal'] == 5 then
		spellGoal = 2
	end

	-- Reset Logic
	Tracker:FindObjectForCode("lives_3_4").AcquiredCount = slotData['number_life_mid']
	Tracker:FindObjectForCode("bombs_3_4").AcquiredCount = slotData['number_bomb_mid']
	Tracker:FindObjectForCode("lower_difficulty_3_4").CurrentStage = slotData['difficulty_mid']
	Tracker:FindObjectForCode("lives_5_6").AcquiredCount = slotData['number_life_end']
	Tracker:FindObjectForCode("bombs_5_6").AcquiredCount = slotData['number_bomb_end']
	Tracker:FindObjectForCode("lower_difficulty_5_6").CurrentStage = slotData['difficulty_end']
	Tracker:FindObjectForCode("lives_extra").AcquiredCount = slotData['number_life_extra']
	Tracker:FindObjectForCode("bombs_extra").AcquiredCount = slotData['number_bomb_extra']
	Tracker:FindObjectForCode("extra_stage_included").CurrentStage = slotData['extra_stage']
	Tracker:FindObjectForCode("difficulty_check").Active = slotData['difficulty_check']
	Tracker:FindObjectForCode("include_lunatic").Active = (slotData['exclude_lunatic'] == 0)
	Tracker:FindObjectForCode("both_stage_4").Active = slotData['both_stage_4']
	Tracker:FindObjectForCode("include_last_spell").Active = slotData['time_check']
	Tracker:FindObjectForCode("teams").Active = (slotData['characters'] == 0 or slotData['characters'] == 2)
	Tracker:FindObjectForCode("solo").Active = (slotData['characters'] == 1 or slotData['characters'] == 2)
	Tracker:FindObjectForCode("stages").Active = (slotData['mode'] ~= 1)
	Tracker:FindObjectForCode("spell_practice").Active = (slotData['mode'] ~= 0 and slotData['mode'] ~= 2)
	Tracker:FindObjectForCode("spell_card_goal").CurrentStage = spellGoal
	Tracker:FindObjectForCode("final_spell_card").AcquiredCount = slotData['treasure_final_spell_card']
	Tracker:FindObjectForCode("spell_practice_illusion_team").Active = in_array("Illusion Team", slotData['spell_cards_teams'])
	Tracker:FindObjectForCode("spell_practice_magic_team").Active = in_array("Magic Team", slotData['spell_cards_teams'])
	Tracker:FindObjectForCode("spell_practice_devil_team").Active = in_array("Devil Team", slotData['spell_cards_teams'])
	Tracker:FindObjectForCode("spell_practice_nether_team").Active = in_array("Nether Team", slotData['spell_cards_teams'])

	if not Tracker:FindObjectForCode("include_lunatic").Active then
		Tracker:FindObjectForCode("lower_difficulty").CurrentStage = 1
	end

	-- We check if solo character are on, and enable them if necessary
	local solo_active = Tracker:FindObjectForCode("solo").Active
	Tracker:FindObjectForCode("reimu").Active = solo_active
	Tracker:FindObjectForCode("yukari").Active = solo_active
	Tracker:FindObjectForCode("marisa").Active = solo_active
	Tracker:FindObjectForCode("alice").Active = solo_active
	Tracker:FindObjectForCode("sakuya").Active = solo_active
	Tracker:FindObjectForCode("remilia").Active = solo_active
	Tracker:FindObjectForCode("youmu").Active = solo_active
	Tracker:FindObjectForCode("yuyuko").Active = solo_active

	local time = 0
	if slotData['time'] == 0 then
		time = 1
	end

	Tracker:FindObjectForCode("time").Active = time
end

function onItem(index, itemId, itemName, playerNumber)
	if index <= CURRENT_INDEX then
		return
	end

	CURRENT_INDEX = index

	--- Special case for progressive stage unlocks
	if (itemId >= STARTING_ITEM_ID + 200 and itemId <= STARTING_ITEM_ID + 204) or (itemId >= STARTING_ITEM_ID + 245 and itemId <= STARTING_ITEM_ID + 252) then
		--- Global
		if(itemId == STARTING_ITEM_ID + 200) then
			if Tracker:FindObjectForCode("illusion_team_stage_6_b").Active and Tracker:FindObjectForCode("extra_stage_included").CurrentStage == 1 then
				itemId = STARTING_ITEM_ID + 205
			elseif Tracker:FindObjectForCode("illusion_team_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 216
			elseif Tracker:FindObjectForCode("illusion_team_stage_5").Active then
				itemId = STARTING_ITEM_ID + 215
			elseif Tracker:FindObjectForCode("illusion_team_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 214
			elseif Tracker:FindObjectForCode("illusion_team_stage_4_a").Active then
				itemId = STARTING_ITEM_ID + 213
			elseif Tracker:FindObjectForCode("illusion_team_stage_3").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 212
				else
					--- 200 has the stages when "both stage 4" are false
					itemId = STARTING_ITEM_ID + 200
				end
			elseif Tracker:FindObjectForCode("illusion_team_stage_2").Active then
				itemId = STARTING_ITEM_ID + 211
			else
				itemId = STARTING_ITEM_ID + 210
			end
		--- Illusion Team
		elseif(itemId == STARTING_ITEM_ID + 201) then
			if Tracker:FindObjectForCode("illusion_team_stage_6_b").Active and Tracker:FindObjectForCode("extra_stage_included").CurrentStage == 1 then
				itemId = STARTING_ITEM_ID + 206
			elseif Tracker:FindObjectForCode("illusion_team_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 223
			elseif Tracker:FindObjectForCode("illusion_team_stage_5").Active then
				itemId = STARTING_ITEM_ID + 222
			elseif Tracker:FindObjectForCode("illusion_team_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 221
			elseif Tracker:FindObjectForCode("illusion_team_stage_4_a").Active then
				itemId = STARTING_ITEM_ID + 220
			elseif Tracker:FindObjectForCode("illusion_team_stage_3").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 219
				else
					itemId = STARTING_ITEM_ID + 220
				end
			elseif Tracker:FindObjectForCode("illusion_team_stage_2").Active then
				itemId = STARTING_ITEM_ID + 218
			else
				itemId = STARTING_ITEM_ID + 217
			end
		--- Magic Team
		elseif(itemId == STARTING_ITEM_ID + 202) then
			if Tracker:FindObjectForCode("magic_team_stage_6_b").Active and Tracker:FindObjectForCode("extra_stage_included").CurrentStage == 1 then
				itemId = STARTING_ITEM_ID + 207
			elseif Tracker:FindObjectForCode("magic_team_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 230
			elseif Tracker:FindObjectForCode("magic_team_stage_5").Active then
				itemId = STARTING_ITEM_ID + 229
			elseif Tracker:FindObjectForCode("magic_team_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 228
			elseif Tracker:FindObjectForCode("magic_team_stage_4_a").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 227
				else
					itemId = STARTING_ITEM_ID + 228
				end
			elseif Tracker:FindObjectForCode("magic_team_stage_3").Active then
				itemId = STARTING_ITEM_ID + 226
			elseif Tracker:FindObjectForCode("magic_team_stage_2").Active then
				itemId = STARTING_ITEM_ID + 225
			else
				itemId = STARTING_ITEM_ID + 224
			end
		--- Devil Team
		elseif(itemId == STARTING_ITEM_ID + 203) then
			if Tracker:FindObjectForCode("devil_team_stage_6_b").Active and Tracker:FindObjectForCode("extra_stage_included").CurrentStage == 1 then
				itemId = STARTING_ITEM_ID + 208
			elseif Tracker:FindObjectForCode("devil_team_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 237
			elseif Tracker:FindObjectForCode("devil_team_stage_5").Active then
				itemId = STARTING_ITEM_ID + 236
			elseif Tracker:FindObjectForCode("devil_team_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 235
			elseif Tracker:FindObjectForCode("devil_team_stage_4_a").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 234
				else
					itemId = STARTING_ITEM_ID + 235
				end
			elseif Tracker:FindObjectForCode("devil_team_stage_3").Active then
				itemId = STARTING_ITEM_ID + 233
			elseif Tracker:FindObjectForCode("devil_team_stage_2").Active then
				itemId = STARTING_ITEM_ID + 232
			else
				itemId = STARTING_ITEM_ID + 231
			end
		--- Nether Team
		elseif(itemId == STARTING_ITEM_ID + 204) then
			if Tracker:FindObjectForCode("nether_team_stage_6_b").Active and Tracker:FindObjectForCode("extra_stage_included").CurrentStage == 1 then
				itemId = STARTING_ITEM_ID + 209
			elseif Tracker:FindObjectForCode("nether_team_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 244
			elseif Tracker:FindObjectForCode("nether_team_stage_5").Active then
				itemId = STARTING_ITEM_ID + 243
			elseif Tracker:FindObjectForCode("nether_team_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 242
			elseif Tracker:FindObjectForCode("nether_team_stage_4_a").Active then
				itemId = STARTING_ITEM_ID + 241
			elseif Tracker:FindObjectForCode("nether_team_stage_3").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 240
				else
					itemId = STARTING_ITEM_ID + 241
				end
			elseif Tracker:FindObjectForCode("nether_team_stage_2").Active then
				itemId = STARTING_ITEM_ID + 239
			else
				itemId = STARTING_ITEM_ID + 238
			end
		--- Reimu
		elseif(itemId == STARTING_ITEM_ID + 245) then
			if Tracker:FindObjectForCode("reimu_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 259
			elseif Tracker:FindObjectForCode("reimu_stage_5").Active then
				itemId = STARTING_ITEM_ID + 258
			elseif Tracker:FindObjectForCode("reimu_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 257
			elseif Tracker:FindObjectForCode("reimu_stage_4_a").Active then
				itemId = STARTING_ITEM_ID + 256
			elseif Tracker:FindObjectForCode("reimu_stage_3").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 255
				else
					itemId = STARTING_ITEM_ID + 256
				end
			elseif Tracker:FindObjectForCode("reimu_stage_2").Active then
				itemId = STARTING_ITEM_ID + 254
			else
				itemId = STARTING_ITEM_ID + 253
			end
		--- Yukari
		elseif(itemId == STARTING_ITEM_ID + 246) then
			if Tracker:FindObjectForCode("yukari_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 266
			elseif Tracker:FindObjectForCode("yukari_stage_5").Active then
				itemId = STARTING_ITEM_ID + 265
			elseif Tracker:FindObjectForCode("yukari_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 264
			elseif Tracker:FindObjectForCode("yukari_stage_4_a").Active then
				itemId = STARTING_ITEM_ID + 263
			elseif Tracker:FindObjectForCode("yukari_stage_3").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 262
				else
					itemId = STARTING_ITEM_ID + 263
				end
			elseif Tracker:FindObjectForCode("yukari_stage_2").Active then
				itemId = STARTING_ITEM_ID + 261
			else
				itemId = STARTING_ITEM_ID + 260
			end
		--- Marisa
		elseif(itemId == STARTING_ITEM_ID + 247) then
			if Tracker:FindObjectForCode("marisa_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 273
			elseif Tracker:FindObjectForCode("marisa_stage_5").Active then
				itemId = STARTING_ITEM_ID + 272
			elseif Tracker:FindObjectForCode("marisa_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 271
			elseif Tracker:FindObjectForCode("marisa_stage_4_a").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 270
				else
					itemId = STARTING_ITEM_ID + 271
				end
			elseif Tracker:FindObjectForCode("marisa_stage_3").Active then
					itemId = STARTING_ITEM_ID + 269
			elseif Tracker:FindObjectForCode("marisa_stage_2").Active then
				itemId = STARTING_ITEM_ID + 268
			else
				itemId = STARTING_ITEM_ID + 267
			end
		--- Alice
		elseif(itemId == STARTING_ITEM_ID + 248) then
			if Tracker:FindObjectForCode("alice_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 280
			elseif Tracker:FindObjectForCode("alice_stage_5").Active then
				itemId = STARTING_ITEM_ID + 279
			elseif Tracker:FindObjectForCode("alice_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 278
			elseif Tracker:FindObjectForCode("alice_stage_4_a").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 277
				else
					itemId = STARTING_ITEM_ID + 278
				end
			elseif Tracker:FindObjectForCode("alice_stage_3").Active then
				itemId = STARTING_ITEM_ID + 276
			elseif Tracker:FindObjectForCode("alice_stage_2").Active then
				itemId = STARTING_ITEM_ID + 275
			else
				itemId = STARTING_ITEM_ID + 274
			end
		--- Sakuya
		elseif(itemId == STARTING_ITEM_ID + 249) then
			if Tracker:FindObjectForCode("sakuya_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 287
			elseif Tracker:FindObjectForCode("sakuya_stage_5").Active then
				itemId = STARTING_ITEM_ID + 286
			elseif Tracker:FindObjectForCode("sakuya_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 285
			elseif Tracker:FindObjectForCode("sakuya_stage_4_a").Active then
				itemId = STARTING_ITEM_ID + 284
			elseif Tracker:FindObjectForCode("sakuya_stage_3").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 283
				else
					itemId = STARTING_ITEM_ID + 284
				end
			elseif Tracker:FindObjectForCode("sakuya_stage_2").Active then
				itemId = STARTING_ITEM_ID + 282
			else
				itemId = STARTING_ITEM_ID + 281
			end
		--- Remilia
		elseif(itemId == STARTING_ITEM_ID + 250) then
			if Tracker:FindObjectForCode("remilia_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 294
			elseif Tracker:FindObjectForCode("remilia_stage_5").Active then
				itemId = STARTING_ITEM_ID + 293
			elseif Tracker:FindObjectForCode("remilia_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 292
			elseif Tracker:FindObjectForCode("remilia_stage_4_a").Active then
				itemId = STARTING_ITEM_ID + 291
			elseif Tracker:FindObjectForCode("remilia_stage_3").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 290
				else
					itemId = STARTING_ITEM_ID + 291
				end
			elseif Tracker:FindObjectForCode("remilia_stage_2").Active then
				itemId = STARTING_ITEM_ID + 289
			else
				itemId = STARTING_ITEM_ID + 288
			end
		--- Youmu
		elseif(itemId == STARTING_ITEM_ID + 251) then
			if Tracker:FindObjectForCode("youmu_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 2101
			elseif Tracker:FindObjectForCode("youmu_stage_5").Active then
				itemId = STARTING_ITEM_ID + 2100
			elseif Tracker:FindObjectForCode("youmu_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 299
			elseif Tracker:FindObjectForCode("youmu_stage_4_a").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 298
				else
					itemId = STARTING_ITEM_ID + 299
				end
			elseif Tracker:FindObjectForCode("youmu_stage_3").Active then
				itemId = STARTING_ITEM_ID + 297
			elseif Tracker:FindObjectForCode("youmu_stage_2").Active then
				itemId = STARTING_ITEM_ID + 296
			else
				itemId = STARTING_ITEM_ID + 295
			end
		--- Yuyuko
		elseif(itemId == STARTING_ITEM_ID + 252) then
			if Tracker:FindObjectForCode("yuyuko_stage_6_a").Active then
				itemId = STARTING_ITEM_ID + 2108
			elseif Tracker:FindObjectForCode("yuyuko_stage_5").Active then
				itemId = STARTING_ITEM_ID + 2107
			elseif Tracker:FindObjectForCode("yuyuko_stage_4_b").Active then
				itemId = STARTING_ITEM_ID + 2106
			elseif Tracker:FindObjectForCode("yuyuko_stage_4_a").Active then
				if Tracker:FindObjectForCode("both_stage_4").Active then
					itemId = STARTING_ITEM_ID + 2105
				else
					itemId = STARTING_ITEM_ID + 2106
				end
			elseif Tracker:FindObjectForCode("yuyuko_stage_3").Active then
				itemId = STARTING_ITEM_ID + 2104
			elseif Tracker:FindObjectForCode("yuyuko_stage_2").Active then
				itemId = STARTING_ITEM_ID + 2103
			else
				itemId = STARTING_ITEM_ID + 2102
			end
		end
	end

	--- Final Spell Card Unlock
	if itemId >= STARTING_ITEM_ID + 312 and itemId <= STARTING_ITEM_ID + 316 and Tracker:FindObjectForCode("treasures").AcquiredCount >= 4 then
		local final_spell_id = tostring(Tracker:FindObjectForCode("final_spell_card").AcquiredCount)
		Tracker:FindObjectForCode("sc_" .. final_spell_id).Active = true
	end

	local itemObject = ITEM_MAPPING[itemId]

	if not itemObject or not itemObject[1] then
		return
	end

	for _, item in ipairs(itemObject) do
		local trackerItemObject = Tracker:FindObjectForCode(item[1])

		if trackerItemObject then
			if item[2] == "toggle" then
				trackerItemObject.Active = true
			elseif item[2] == "progressive" then
				trackerItemObject.CurrentStage = trackerItemObject.CurrentStage + 1
			elseif item[2] == "consumable" then
				trackerItemObject.AcquiredCount = trackerItemObject.AcquiredCount + item[3]
			elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
				print(string.format("onItem: Unknown item type %s for code %s", item[2], item[1]))
			end
		else
			print(string.format("onItem: Could not find object for code %s", item[1]))
		end
	end
end

function onLocation(locationId, locationName)
	local locationObject = LOCATION_MAPPING[locationId]

	if not locationObject or not locationObject[1] then
		return
	end

	for _, location in ipairs(locationObject) do
		local trackerLocationObject = Tracker:FindObjectForCode(location)

		if trackerLocationObject then
			if location:sub(1, 1) == "@" then
				trackerLocationObject.AvailableChestCount = trackerLocationObject.AvailableChestCount - 1
			else
				trackerLocationObject.Active = false
			end
		else
			print(string.format("onLocation: Could not find object for code %s", location))
		end
	end
end

Archipelago:AddClearHandler("Clear", onClear)
Archipelago:AddItemHandler("Item", onItem)
Archipelago:AddLocationHandler("Location", onLocation)