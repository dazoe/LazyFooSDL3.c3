module lazyfoosdl3;

import sdl;

struct IntroState (GameState)
{
	LTexture background;
	LTexture message;
}

// Singleton?
IntroState sIntroState;

fn bool IntroState.enter(&self) @dynamic
{
	// Result flag
	bool success = true;

	// Load background texture
	if (self.background.load_from_file("resources/intro-bg.png") == false)
	{
		sdl::log_("Unable to load intro background. SDL error: %s\n", sdl::get_error());
		success = false;
	}
	// Render intro text
	SDLColor textColor = {0x00, 0x00, 0x00, 0xFF};
	if (self.message.load_from_rendered_text("Lazy Foo' Productions Presents...\npress return", textColor) == false)
	{
		sdl::log_("Unable to load text for intro. SDL error: %s\n", sdl::get_error());
		success = false;
	}

	return success;
}

fn bool IntroState.exit(&self) @dynamic
{
	// Clean up our textures.
	self.background.destroy();
	self.message.destroy();

	return true;
}

fn void IntroState.handle_event(&self, SDLEvent* event) @dynamic
{
	// If keypress is return key
	if (event.type == SDLEventType.KEY_DOWN && event.key.key == sdl::K_RETURN)
	{
		// Goto title state
		set_next_state(&sTitleState);
	}
}

fn void IntroState.update(&self) @dynamic
{
}

fn void IntroState.render(&self) @dynamic
{
	// Show the background
	self.background.render(0,0);

	// Show the message on the center of the screen.
	self.message.render(
		(float)(SCREEN_WIDTH - self.message.get_width()) / 2f,
		(float)(SCREEN_HEIGHT - self.message.get_height()) / 2f);
}