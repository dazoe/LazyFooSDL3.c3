module lazyfoosdl3;

import sdl;

const OVERWORLD_WIDTH = SCREEN_WIDTH * 2;
const OVERWORLD_HEIGHT = SCREEN_HEIGHT * 2;

struct OverWorldState (GameState)
{
	LTexture backgroundTexture;
	LTexture blueHouseTexture;
	LTexture redHouseTexture;

	House blueHouse;
	House redHouse;
}

// Singleton
OverWorldState sOverWorldState;

fn void OverWorldState.init(&self)
{
}

fn bool OverWorldState.enter(&self) @dynamic
{
	// result flag
	bool success = true;

	// Load background
	if (self.backgroundTexture.load_from_file("resources/overworld-bg.png") == false)
	{
		sdl::log_("Unable to load overworld background. SDL error: %s\n", sdl::get_error());
		success = false;
	}
	// Load texture for blue house
	if (self.blueHouseTexture.load_from_file("resources/blue-house.png") == false)
	{
		sdl::log_("Unable to load blue house texture. SDL error: %s\n", sdl::get_error());
		success = false;
	}
	// Load texture for red house
	if (self.redHouseTexture.load_from_file("resources/red-house.png") == false)
	{
		sdl::log_("Unable to load red house texture. SDL error: %s\n", sdl::get_error());
		success = false;
	}

	// position houses and set textures
	self.redHouse.init(0, 0, &self.redHouseTexture);
	self.blueHouse.init(OVERWORLD_WIDTH - HOUSE_SIZE, OVERWORLD_HEIGHT - HOUSE_SIZE, &self.blueHouseTexture);

	// Set the dot's posisiton
	// from the red room
	if (gCurrentState.type == RedRoomState.typeid)
	{
		// Posistion below the red house
		gDot.set_position(
			self.redHouse.get_collider().x + (HOUSE_SIZE - gDot.get_collider().w) / 2,
			self.redHouse.get_collider().y + self.redHouse.get_collider().h + gDot.get_collider().h
		);
	}
	// from the blue room
	else if (gCurrentState.type == BlueRoomState.typeid)
	{
		// Position above the blue house
		gDot.set_position(
			self.blueHouse.get_collider().x + (HOUSE_SIZE - gDot.get_collider().w) / 2,
			self.blueHouse.get_collider().y - gDot.get_collider().h * 2
		);
	}
	// from somewhere else
	else
	{
		// Posistion in the center of the world
		gDot.set_position(
			(OVERWORLD_WIDTH - gDot.get_collider().w) / 2,
			(OVERWORLD_HEIGHT - gDot.get_collider().h) / 2
		);
	}

	return success;
}

fn bool OverWorldState.exit(&self) @dynamic
{
	// Clean up our textures.
	self.redHouseTexture.destroy();
	self.blueHouseTexture.destroy();
	self.backgroundTexture.destroy();

	return true;
}

fn void OverWorldState.handle_event(&self, SDLEvent* event) @dynamic
{
	// Pass event to the dot
	gDot.handle_event(event);
}

fn void OverWorldState.update(&self) @dynamic
{
	// Move the dot
	gDot.move(OVERWORLD_WIDTH, OVERWORLD_HEIGHT);

	// Check for collisions, with the red house
	if (check_collision(gDot.get_collider(), self.redHouse.get_collider()) == true)
	{
		// Goto the red room
		set_next_state(&sRedRoomState);
	}
	// with the blue house
	if (check_collision(gDot.get_collider(), self.blueHouse.get_collider()) == true)
	{
		// Goto the blue room
		set_next_state(&sBlueRoomState);
	}
}

fn void OverWorldState.render(&self) @dynamic
{
	// Center the camera over the dot
	SDLRect camera = {
		(gDot.get_collider().x - gDot.get_collider().w / 2) - (SCREEN_WIDTH / 2),
		(gDot.get_collider().y - gDot.get_collider().h / 2) - (SCREEN_HEIGHT / 2),
		SCREEN_WIDTH, SCREEN_HEIGHT};
	
	// Clamp the camera to the level bounds
	if (camera.x < 0)
	{
		camera.x = 0;
	}
	else if (camera.x > OVERWORLD_WIDTH - camera.w)
	{
		camera.x = OVERWORLD_WIDTH - camera.w;
	}
	if (camera.y < 0)
	{
		camera.y = 0;
	}
	else if (camera.y > OVERWORLD_HEIGHT - camera.h)
	{
		camera.y = OVERWORLD_HEIGHT - camera.h;
	}

	// Render the background
	SDLFRect bgClip = {camera.x, camera.y, camera.w, camera.h};
	self.backgroundTexture.render(0, 0, &bgClip);

	// Render objects
	self.redHouse.render(camera);
	self.blueHouse.render(camera);
	gDot.render(camera);
}

fn void OverWorldState.destroy(&self) @dynamic
{

}
