module lazyfoosdl3;
import std::io;
import sdl;

const CInt SCREEN_WIDTH = 800;
const CInt SCREEN_HEIGHT = 600;
const float SPRITESIZE = 100;

SDLWindow* gWindow;
SDLRenderer* gRenderer;
LTexture gArrowTexture;

faultdef INIT_VIDEO, INIT_WINDOW;

fn void? init()
{
	if (sdl::init(SDLInitFlags.VIDEO) == false)
	{
		sdl::log_("SDL could not initialize! SDL error: %s\n", sdl::get_error());
		return INIT_VIDEO?;
	}
	if (sdl::create_window_and_renderer("LazyFoo SDL3 tutorial in C3", SCREEN_WIDTH, SCREEN_HEIGHT, 0, &gWindow, &gRenderer) == false)
	{
		sdl::log_("Window could not be created! SDL error: %s\n", sdl::get_error());
		return INIT_WINDOW?;
	}
}

faultdef LOAD_ERROR;

fn void? load_media()
{
	fault err;

	// load sprite sheet
	if (gArrowTexture.load_from_file("resources/arrow.png") == false)
	{
		sdl::log_("Unable to load Up texture! SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}

	return err?;
}

fn void close()
{
	gArrowTexture.destroy();

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

	// Rotation degrees
	double degrees = 0.0;

	// Flip mode
	SDLFlipMode flipMode = SDLFlipMode.NONE;

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
			else if (event.type == SDLEventType.KEY_DOWN)
			{
				switch (event.key.key)
				{
					// Rotate on left/right key press
					case sdl::K_LEFT:
						degrees -= 36;
					case sdl::K_RIGHT:
						degrees += 36;

					// Set flip mode based on 1/2/3 press
					case sdl::K_1:
						flipMode = SDLFlipMode.HORIZONTAL;
					case sdl::K_2:
						flipMode = SDLFlipMode.NONE;
					case sdl::K_3:
						flipMode = SDLFlipMode.VERTICAL;
				}
			}
		}

		// Fill the background with white
		gRenderer.set_draw_color(0xFF, 0xFF, 0xFF, 0xFF);
		gRenderer.clear();

		// Define center from the corner of the arrow
		SDLFPoint center = {gArrowTexture.get_width() / 2f, gArrowTexture.get_height() / 2f};

		// Draw texture rotated and or flipped
		gArrowTexture.render(((float)SCREEN_WIDTH - gArrowTexture.get_width()) / 2f, ((float)SCREEN_HEIGHT - gArrowTexture.get_height()) / 2f, null, ORIGINAL_SIZE, ORIGINAL_SIZE, degrees, &center, flipMode);

		// Update screen
		gRenderer.present();
	}

	close();

	return 0;
}
