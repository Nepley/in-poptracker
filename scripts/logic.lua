function canStage34()
	return Tracker:ProviderCountForCode('lives_3_4') <= Tracker:ProviderCountForCode('lives') and Tracker:ProviderCountForCode('bombs_3_4') <= Tracker:ProviderCountForCode('bombs') and Tracker:FindObjectForCode('lower_difficulty_3_4').CurrentStage <= Tracker:FindObjectForCode('lower_difficulty').CurrentStage
end

function canStage56()
	return Tracker:ProviderCountForCode('lives_5_6') <= Tracker:ProviderCountForCode('lives') and Tracker:ProviderCountForCode('bombs_5_6') <= Tracker:ProviderCountForCode('bombs') and Tracker:FindObjectForCode('lower_difficulty_5_6').CurrentStage <= Tracker:FindObjectForCode('lower_difficulty').CurrentStage
end

function canHard()
	return Tracker:FindObjectForCode('lower_difficulty').CurrentStage >= 1
end

function canNormal()
	return Tracker:FindObjectForCode('lower_difficulty').CurrentStage >= 2
end

function canEasy()
	return Tracker:FindObjectForCode('lower_difficulty').CurrentStage >= 3
end

function canExtra()
	return Tracker:ProviderCountForCode('lives_extra') <= Tracker:ProviderCountForCode('lives') and Tracker:ProviderCountForCode('bombs_extra') <= Tracker:ProviderCountForCode('bombs')
end

function canPhantasm()
	return Tracker:ProviderCountForCode('lives_phantasm') <= Tracker:ProviderCountForCode('lives') and Tracker:ProviderCountForCode('bombs_phantasm') <= Tracker:ProviderCountForCode('bombs')
end

function teamNoDifficulty()
	return not Tracker:FindObjectForCode('difficulty_check').Active
end

function teamHasDifficulty()
	return Tracker:FindObjectForCode('difficulty_check').Active
end

function soloNoDifficulty()
	return not Tracker:FindObjectForCode('difficulty_check').Active
end

function soloHasDifficulty()
	return Tracker:FindObjectForCode('difficulty_check').Active
end

function extraStage()
	return Tracker:FindObjectForCode('extra_stage_included').CurrentStage >= 1
end

function lastSpell()
	return Tracker:FindObjectForCode('include_last_spell').Active
end