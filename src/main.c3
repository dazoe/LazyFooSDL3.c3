module lazyfoosdl3;
import std::io;
import sdl;
import sdl::ttf;

const CInt SCREEN_WIDTH = 800;
const CInt SCREEN_HEIGHT = 600;
const float SPRITESIZE = 100;
// Set color constants
const int COLOR_MAGNITUDE_COUNT = 3;
const char[COLOR_MAGNITUDE_COUNT] COLOR_MAGNITUDES = {0x00, 0x7F, 0xFF};

/* Global variables */
// The main sdl window.
SDLWindow* gWindow;

// The renderer we will be using
SDLRenderer* gRenderer;

// Global font
TTFFont* gFont;

// Our global textures
LTexture gTextTexture;

faultdef INIT_VIDEO, INIT_WINDOW, INIT_TTF;

fn void? init()
{
	// Initialize SDL
	if (sdl::init({.video}) == false)
	{
		sdl::log_("SDL could not initialize! SDL error: %s\n", sdl::get_error());
		return INIT_VIDEO?;
	}

	// Create window and renderer
	if (sdl::create_window_and_renderer("LazyFoo SDL3 tutorial in C3", SCREEN_WIDTH, SCREEN_HEIGHT, {}, &gWindow, &gRenderer) == false)
	{
		sdl::log_("Window could not be created! SDL error: %s\n", sdl::get_error());
		return INIT_WINDOW?;
	}

	// Initialize SDL_TTF
	if (ttf::init() == false)
	{
		sdl::log_("SDL_ttf could not initialize. SDL error: %s\n", sdl::get_error());
		return INIT_TTF?;
	}
}

faultdef LOAD_ERROR;

fn void? load_media()
{
	fault err;

	// Load global font
	gFont = ttf::open_font("resources/HandDrawnShapes.ttf", 28);
	if (gFont == null)
	{
		sdl::log_("Could not load ttf font. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}
	else
	{
		// Load text (black)
		SDLColor textColor = {0x00, 0x00, 0x00, 0xFF};
		if (gTextTexture.load_from_rendered_text("Press return to start timer!", textColor) == false)
		{
			sdl::log_("Could not load text texture. SDL error: %s\n", sdl::get_error());
			err = LOAD_ERROR;
		}
	}

	return err?;
}

fn void close()
{
	// Clean up texture(s)
	gTextTexture.destroy();

	// Clean up font
	gFont.close();
	gFont = null;

	// Clean up window and renderer
	gRenderer.destroy();
	gRenderer = null;
	gWindow.destroy();
	gWindow = null;

	// Quit SDL and SDL_TTF
	ttf::quit();
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

	// Application timer
	LTimer timer;

	// String
	DString timeText;

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

			// Check for key presses
			if (event.type == SDLEventType.KEY_DOWN)
			{
				// Start / Stop
				if (event.key.key == sdl::K_RETURN)
				{
					if (timer.isStarted())
					{
						timer.stop();
					}
					else
					{
						timer.start();
					}
				}
				
				// Pause / Unpause
				if (event.key.key == sdl::K_SPACE)
				{
					if (timer.isPaused())
					{
						timer.unpause();
					}
					else
					{
						timer.pause();
					}
				}
			}
		}

		// update text
		timeText.chop(0);
		io::fprintf(&timeText, "Milliseconds since start time %f", ((double)timer.getTicksNS() / 1000000))!!;
		SDLColor textColor = {0x00, 0x00, 0x00, 0xFF};
		gTextTexture.load_from_rendered_text(timeText.zstr_view(), textColor);

		// Fill the background
		gRenderer.set_draw_color(0xFF, 0xFF, 0xFF, 0xFF);
		gRenderer.clear();

		// Render text on screen
		gTextTexture.render(
			((float)SCREEN_WIDTH - gTextTexture.get_width()) / 2f,
			((float)SCREEN_HEIGHT - gTextTexture.get_height()) / 2f);

		// Update screen
		gRenderer.present();
	}

	close();

	return 0;
}
