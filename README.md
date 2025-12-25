# Apartments

A comprehensive apartment system with interior support, police raiding, and automatic management.

## Features

### Interior System
- Full interior support for apartment rooms
- Seamless entry/exit system
- Multiple apartment tiers and configurations

### Police Raiding
- Police officers can raid apartments
- Doors automatically unlock during raids
- Raid state is tracked and synced across all clients
- Doors automatically lock when the owner returns during a raid

### Auto-Assignment
- Automatically assigns an apartment to new characters on first spawn
- Ensures every new character gets a starter apartment
- Door access is automatically configured upon assignment

### Automatic Cleanup
- Apartments are automatically deleted after **30 days of inactivity**
- System checks character's `LastPlayed` timestamp
- Inactive apartments are released and made available for new assignments
- Prevents apartment pool from being exhausted by inactive players

## Technical Details

- Uses MongoDB for apartment assignments storage
- Integrates with the base doorlock system for access control
- Supports multiple apartment configurations via config files
- Real-time state synchronization via GlobalState

Uses the OX Doorlock bridge for mythic - not default mythic doorlocks - if you want to change this please PR this would be very nice as i didnt have no clue how to use it haha

Thanks for reading - Let me know any issues within the mythic discord. 