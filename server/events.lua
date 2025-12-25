AddEventHandler("Apartment:Server:SpawnInside", function()
    
end)

RegisterNetEvent("Apartment:Server:LeavePoly", function()
    local src = source
    if _requestors[src] ~= nil then
        for k, v in ipairs(_requests) do
            if v == src then
                table.remove(_requests, k)
                return
            end
        end
    end
end)


AddEventHandler("Characters:Created", function(source, charData)
	print(string.format("^3[APARTMENTS DEBUG] Characters:Created event triggered - source: %s, SID: %s, ID: %s, Name: %s %s^7", source, tostring(charData.SID), tostring(charData.ID), charData.First or "Unknown", charData.Last or "Unknown"))
	if not _aptData or #_aptData == 0 then
		print(string.format("^1[APARTMENTS DEBUG] Characters:Created - _aptData is empty or nil!^7"))
		if Logger then
			Logger:Warn("Apartments", "Characters:Created called but _aptData is not loaded yet")
		end
		return
	end
	print(string.format("^3[APARTMENTS DEBUG] Characters:Created - Total apartments: %d, Available apartments: %d^7", #_aptData, _availableApartments and #_availableApartments or 0))
	local aptId = GetRandomAvailableApartment()
	print(string.format("^3[APARTMENTS DEBUG] Characters:Created - GetRandomAvailableApartment returned: %s^7", tostring(aptId)))
	
	if aptId then
		print(string.format("^3[APARTMENTS DEBUG] Characters:Created - Attempting to assign apartment %s to character %s (ID: %s)^7", tostring(aptId), tostring(charData.SID), tostring(charData.ID)))
		local assignResult = AssignApartmentToCharacter(aptId, charData.ID, charData.SID)
		print(string.format("^3[APARTMENTS DEBUG] Characters:Created - AssignApartmentToCharacter returned: %s^7", tostring(assignResult)))
		
		if assignResult then
			if Database then
				print(string.format("^3[APARTMENTS DEBUG] Characters:Created - Updating character %s in database with Apartment = %s^7", tostring(charData.ID), tostring(aptId)))
				Database.Game:updateOne({
					collection = "characters",
					query = {
						_id = charData.ID
					},
					update = {
						["$set"] = {
							Apartment = aptId
						}
					}
				}, function(success)
					print(string.format("^3[APARTMENTS DEBUG] Characters:Created - Database update result: %s^7", tostring(success)))
					if success then
						if EnsureCharacterDoorAccess then
							EnsureCharacterDoorAccess(charData.SID, aptId)
						end
						if source and source > 0 then
							if SendApartmentAssignmentEmail then
								SendApartmentAssignmentEmail(source, aptId, charData.SID)
							end
						end
						
						if Logger then
							Logger:Info("Apartments", string.format("Assigned apartment %s to new character %s (%s)", aptId, charData.SID, charData.First .. " " .. charData.Last))
						end
						print(string.format("^2[APARTMENTS DEBUG] Characters:Created - Successfully assigned apartment %s to character %s^7", tostring(aptId), tostring(charData.SID)))
					else
						print(string.format("^1[APARTMENTS DEBUG] Characters:Created - Database update FAILED for character %s^7", tostring(charData.ID)))
					end
				end)
			else
				print(string.format("^1[APARTMENTS DEBUG] Characters:Created - Database component is nil!^7"))
			end
		else
			print(string.format("^1[APARTMENTS DEBUG] Characters:Created - AssignApartmentToCharacter FAILED for apartment %s, character %s^7", tostring(aptId), tostring(charData.SID)))
		end
	else
		
		print(string.format("^1[APARTMENTS DEBUG] Characters:Created - No apartments available! Available count: %d^7", _availableApartments and #_availableApartments or 0))
		if Logger then
			Logger:Warn("Apartments", string.format("No apartments available for new character %s (%s) - character is homeless", charData.SID, charData.First .. " " .. charData.Last))
		end
	end
end)
