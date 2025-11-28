module lazyfoosdl3;

import sdl;

struct TitleState (GameState)
{
	LTexture background;
	LTexture message;
}

TitleState sTitleState;

fn bool TitleState.enter(&self) @dynamic
{
	// Result flag
	bool success = true;

	// Load background texture
	if (self.background.load_from_file("resources/title-bg.png") == false)
	{
		sdl::log_("Unable to load title background. SDL error: %s\n", sdl::get_error());
		success = false;
	}
	// Render title text
	SDLColor textColor = {0x00, 0x00, 0x00, 0xFF};
	if (self.message.load_from_rendered_text("A State Machine Demo", textColor) == false)
	{
		sdl::log_("Unable to load text for title. SDL error: %s\n", sdl::get_error());
		success = false;
	}

	return success;
}

fn bool TitleState.exit(&self) @dynamic
{
	// Clean up our textures.
	self.background.destroy();
	self.message.destroy();

	return true;
}

fn void TitleState.handle_event(&self, SDLEvent* event) @dynamic
{
	// If keypress is return key
	if (event.type == SDLEventType.KEY_DOWN && event.key.key == sdl::K_RETURN)
	{
		// Goto over world state
		set_next_state(&sOverWorldState);
	}
}

fn void TitleState.update(&self) @dynamic
{
}

fn void TitleState.render(&self) @dynamic
{
	// Show the background
	self.background.render(0,0);

	// Show the message on the center of the screen.
	self.message.render(
		(float)(SCREEN_WIDTH - self.message.get_width()) / 2f,
		(float)(SCREEN_HEIGHT - self.message.get_height()) / 2f);
}
