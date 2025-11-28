module lazyfoosdl3;

import sdl;

struct BlueRoomState (GameState)
{
	LTexture background;
	Door exitDoor;
}

// Singleton?
BlueRoomState sBlueRoomState;

fn bool BlueRoomState.enter(&self) @dynamic
{
	// Result flag
	bool success = true;

	// Load background texture
	if (self.background.load_from_file("resources/blue-room.png") == false)
	{
		sdl::log_("Unable to load blue-room background. SDL error: %s\n", sdl::get_error());
		success = false;
	}

	// Place game objects
	self.exitDoor.init((SCREEN_WIDTH - DOOR_WIDTH) / 2, SCREEN_HEIGHT - DOOR_HEIGHT);
	gDot.set_position((SCREEN_WIDTH - gDot.bounds.w) / 2, SCREEN_HEIGHT - DOOR_HEIGHT - gDot.bounds.h * 2);

	return success;
}

fn bool BlueRoomState.exit(&self) @dynamic
{
	// Clean up our textures.
	self.background.destroy();

	return true;
}

fn void BlueRoomState.handle_event(&self, SDLEvent* event) @dynamic
{
	// Pass event to the dot.
	gDot.handle_event(event);
}

fn void BlueRoomState.update(&self) @dynamic
{
	// Move dot
	gDot.move(SCREEN_WIDTH, SCREEN_HEIGHT);

	// Check for collisions
	if (check_collision(gDot.get_collider(), self.exitDoor.get_collider()) == true)
	{
		// Go back to over world
		set_next_state(&sOverWorldState);
	}
}

fn void BlueRoomState.render(&self) @dynamic
{
	// Center the camera over the dot?
	SDLRect camera = {0, 0, SCREEN_WIDTH, SCREEN_HEIGHT};
	
	// Show the background
	self.background.render(0,0);

	// Render our objects
	self.exitDoor.render();
	gDot.render(camera);
}