module lazyfoosdl3;
import std::io;
import sdl;

const CInt SCREEN_WIDTH = 800;
const CInt SCREEN_HEIGHT = 600;

SDLWindow* gWindow;
SDLRenderer* gRenderer;
LTexture gUpTexture, gDownTexture, gLeftTexture, gRightTexture;

faultdef INIT_VIDEO, INIT_WINDOW;

fn void? init()
{
	if (sdl::init({.video}) == false)
	{
		sdl::log_("SDL could not initialize! SDL error: %s\n", sdl::get_error());
		return INIT_VIDEO?;
	}
	if (sdl::create_window_and_renderer("LazyFoo SDL3 tutorial in C3", SCREEN_WIDTH, SCREEN_HEIGHT, {}, &gWindow, &gRenderer) == false)
	{
		sdl::log_("Window could not be created! SDL error: %s\n", sdl::get_error());
		return INIT_WINDOW?;
	}
}

faultdef LOAD_ERROR;

fn void? load_media()
{
	fault err;
	if (gUpTexture.load_from_file("resources/Up.png") == false)
	{
		sdl::log_("Unable to load Up texture! SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}
	if (gDownTexture.load_from_file("resources/Down.png") == false)
	{
		sdl::log_("Unable to load Down texture! SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}
	if (gLeftTexture.load_from_file("resources/Left.png") == false)
	{
		sdl::log_("Unable to load Left texture! SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}
	if (gRightTexture.load_from_file("resources/Right.png") == false)
	{
		sdl::log_("Unable to load Right texture! SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}
	return err?;
}

fn void close()
{
	gUpTexture.destroy();
	gDownTexture.destroy();
	gLeftTexture.destroy();
	gRightTexture.destroy();

	gRenderer.destroy();
	gRenderer = null;
	gWindow.destroy();
	gWindow = null;

	sdl::quit();
}

fn int main(String[] args)
{
	if (catch err = init())
	{
		io::printfn("init returned fault: %s", err);
		return 1;
	}
	if (catch err = load_media())
	{
		io::printfn("load_media returned fault: %s", err);
		return 2;
	}

	// The quit flag
	bool quit;

	// Event data
	SDLEvent event;

	// Currently rendered texture
	LTexture* currentTexture = &gUpTexture;

	// Default background color
	SDLColor bgColor = {0xFF, 0xFF, 0xFF, 0xFF};
	while(quit == false)
	{
		// Process events
		while(sdl::poll_event(&event) == true)
		{
			// if quit event set quit flag
			if (event.type == SDLEventType.QUIT)
			{
				quit = true;
			}
			// on keypress
			else if (event.type == SDLEventType.KEY_DOWN)
			{
				// Set texture
				if (event.key.key == sdl::K_UP)
				{
					currentTexture = &gUpTexture;
				}
				if (event.key.key == sdl::K_DOWN)
				{
					currentTexture = &gDownTexture;
				}
				if (event.key.key == sdl::K_LEFT)
				{
					currentTexture = &gLeftTexture;
				}
				if (event.key.key == sdl::K_RIGHT)
				{
					currentTexture = &gRightTexture;
				}
			}
		}

		// Reset bgColor to white
		bgColor = {0xFF, 0xFF, 0xFF, 0xFF};

		bool* keyStates = sdl::get_keyboard_state(null);
		if (keyStates[SDLScancode.UP] == true)
		{
			// Red
			bgColor.r = 0xff;
			bgColor.g = 0x00;
			bgColor.b = 0x00;
		}
		else if (keyStates[SDLScancode.DOWN] == true)
		{
			// Green
			bgColor.r = 0x00;
			bgColor.g = 0xff;
			bgColor.b = 0x00;
		}
		else if (keyStates[SDLScancode.LEFT] == true)
		{
			// Yellow
			bgColor.r = 0xff;
			bgColor.g = 0xff;
			bgColor.b = 0x00;
		}
		else if (keyStates[SDLScancode.RIGHT] == true)
		{
			// Blue
			bgColor.r = 0x00;
			bgColor.g = 0x00;
			bgColor.b = 0xff;
		}

		// Fill the background with white
		gRenderer.set_draw_color(...bgColor);
		gRenderer.clear();

		// Render the image on the screen
		currentTexture.render(((float)SCREEN_WIDTH - currentTexture.get_width()) / 2.0f, ((float)SCREEN_HEIGHT - currentTexture.get_height()) / 2.0f);

		// Update screen
		gRenderer.present();
	}

	close();

	return 0;
}
