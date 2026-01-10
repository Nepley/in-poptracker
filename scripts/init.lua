ENABLE_DEBUG_LOG = true

ScriptHost:LoadScript("scripts/logic.lua")
Tracker:AddItems("items/items.json")
Tracker:AddMaps("maps/maps.json")

Tracker:AddLocations("locations/teamNoDifficulty.json")
Tracker:AddLocations("locations/teamHasDifficulty.json")
Tracker:AddLocations("locations/teamSpellPractice.json")
Tracker:AddLocations("locations/soloNoDifficulty.json")
Tracker:AddLocations("locations/soloHasDifficulty.json")
Tracker:AddLocations("locations/soloSpellPractice.json")

Tracker:AddLayouts("layouts/resources.json")
Tracker:AddLayouts("layouts/settings.json")
Tracker:AddLayouts("layouts/spellcards.json")
Tracker:AddLayouts("layouts/maps.json")

Tracker:AddLayouts("layouts/tracker.json")

if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end