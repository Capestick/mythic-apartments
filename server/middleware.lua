function RegisterMiddleware()
    Middleware:Add("Characters:Creating", function(source, cData)
		
		
		local randomApt = GetRandomAvailableApartment()
		if randomApt then
			
			return {{
				Apartment = 0 
			}}
		end
		
		return {{
			Apartment = 0 
		}}
	end)

    Middleware:Add('Characters:Spawning', function(source)
        local player = exports['mythic-base']:FetchComponent('Fetch'):Source(source)
        local char = player:GetData('Character')
        if not char then
            return
        end
        
        local characterSID = char:GetData("SID")
        local aptId = char:GetData("Apartment") or 0
        
        
        if aptId > 0 then
            local assignedApt = GetCharacterApartment(characterSID)
            if not assignedApt or assignedApt ~= aptId then
                
                if not _assignedApartments then
                    _assignedApartments = {}
                end
                if not _apartmentAssignments then
                    _apartmentAssignments = {}
                end
                
                if not _assignedApartments[aptId] then
                    _assignedApartments[aptId] = {
                        characterSID = characterSID,
                        characterID = char:GetData("ID"),
                        assignedAt = os.time() * 1000
                    }
                    _apartmentAssignments[characterSID] = aptId
                    _apartmentAssignments[tostring(characterSID)] = aptId
                    if tonumber(characterSID) then
                        _apartmentAssignments[tonumber(characterSID)] = aptId
                    end
                    UpdateAvailableApartments()
                end
            end
        end
        
		GlobalState[string.format("Apartment:Interior:%s", characterSID)] = aptId
        
        
        local finalAptId = GetCharacterApartment(characterSID)
        if finalAptId and finalAptId > 0 then
            EnsureCharacterDoorAccess(characterSID, finalAptId)
        end
    end, 2)

	Middleware:Add("Characters:Logout", function(source)
		local char = Fetch:Source(source):GetData("Character")
		if char ~= nil then
			TriggerClientEvent("Apartment:Client:Cleanup", source, GlobalState[string.format("%s:Apartment", source)])
			GlobalState[string.format("%s:Apartment", source)] = nil
			GlobalState[string.format("Apartment:Interior:%s", char:GetData("SID"))] = char:GetData("Apartment")
		end
	end)

	Middleware:Add("Characters:GetSpawnPoints", function(source, charId, cData)
		print(string.format("^3[APARTMENTS DEBUG] Characters:GetSpawnPoints - source: %s, charId: %s, cData.SID: %s, cData.Apartment: %s^7", source, tostring(charId), tostring(cData.SID), tostring(cData.Apartment)))
		
		local spawns = {}
		
		
		local aptId = GetCharacterApartment(cData.SID)
		print(string.format("^3[APARTMENTS DEBUG] Characters:GetSpawnPoints - GetCharacterApartment returned: %s^7", tostring(aptId)))
		
		
		if not aptId or aptId == 0 then
			print(string.format("^1[APARTMENTS DEBUG] Characters:GetSpawnPoints - Character has NO apartment (aptId: %s), returning empty spawns^7", tostring(aptId)))
			return spawns
		end
		
		
			print(string.format("^3[APARTMENTS DEBUG] Characters:GetSpawnPoints - Character has apartment %s, fetching apartment data^7", tostring(aptId)))
			local apt = _aptData[aptId]
			if apt then
				
				if apt.interior and apt.interior.wakeup then
					local roomLabel = apt.roomLabel or aptId
					local buildingLabel = apt.buildingLabel or apt.buildingName or "Apartment"
					local label = string.format("%s - Room %s", buildingLabel, roomLabel)
					
					
					local wakeupX = apt.interior.wakeup.x
					local wakeupY = apt.interior.wakeup.y
					local wakeupZ = apt.interior.wakeup.z
					local wakeupH = apt.interior.wakeup.h or 0.0
					
					
					wakeupX = tonumber(wakeupX)
					wakeupY = tonumber(wakeupY)
					wakeupZ = tonumber(wakeupZ)
					wakeupH = tonumber(wakeupH) or 0.0
					
					
					if wakeupX and wakeupY and wakeupZ then
						print(string.format("^3[APARTMENTS DEBUG] Characters:GetSpawnPoints - Apartment found: %s, wakeup coords: %s, %s, %s^7", label, tostring(wakeupX), tostring(wakeupY), tostring(wakeupZ)))
						
						
						local locationData = {
							x = wakeupX,
							y = wakeupY,
							z = wakeupZ,
							h = wakeupH
						}
						
						table.insert(spawns, {
							id = string.format("APT:%s:%s", aptId, cData.SID),
							label = label,
							location = locationData,
							icon = "building",
							event = "Apartment:SpawnInside",
						})
						print(string.format("^2[APARTMENTS DEBUG] Characters:GetSpawnPoints - Added spawn point for apartment %s^7", tostring(aptId)))
					else
						print(string.format("^1[APARTMENTS DEBUG] Characters:GetSpawnPoints - Apartment %s wakeup coordinates are invalid (x: %s, y: %s, z: %s)!^7", tostring(aptId), tostring(wakeupX), tostring(wakeupY), tostring(wakeupZ)))
					end
				else
					if not apt.interior then
						print(string.format("^1[APARTMENTS DEBUG] Characters:GetSpawnPoints - Apartment %s has no interior data!^7", tostring(aptId)))
					elseif not apt.interior.wakeup then
						print(string.format("^1[APARTMENTS DEBUG] Characters:GetSpawnPoints - Apartment %s has no wakeup data!^7", tostring(aptId)))
					end
				end
			else
				print(string.format("^1[APARTMENTS DEBUG] Characters:GetSpawnPoints - Apartment %s not found in _aptData! Returning empty spawns^7", tostring(aptId)))
			end
		end
		
		
		print(string.format("^3[APARTMENTS DEBUG] Characters:GetSpawnPoints - Returning %d spawn points^7", #spawns))

		return spawns
	end, 2)
end
