module lazyfoosdl3;
import std::io;
import sdl;
import sdl::ttf;

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 600;
const LEVEL_WIDTH = 1280;
const LEVEL_HEIGHT = 960;

/* Global variables */
// The main sdl window.
SDLWindow* gWindow;

// The renderer we will be using
SDLRenderer* gRenderer;

// Global font
TTFFont* gFont;

// Our global textures
LTexture gTextTexture;
LTexture gDotTexture;
LTexture gBgTexture;

faultdef INIT_VIDEO, INIT_WINDOW, INIT_VSYNC, INIT_AUDIO, INIT_TTF;

fn void? init()
{
	// Initialize SDL
	if (sdl::init(SDLInitFlags.VIDEO | SDLInitFlags.AUDIO) == false)
	{
		sdl::log_("SDL could not initialize! SDL error: %s\n", sdl::get_error());
		return INIT_VIDEO?;
	}

	// Create window and renderer
	if (sdl::create_window_and_renderer("LazyFoo SDL3 tutorial in C3", SCREEN_WIDTH, SCREEN_HEIGHT, 0, &gWindow, &gRenderer) == false)
	{
		sdl::log_("Window could not be created! SDL error: %s\n", sdl::get_error());
		return INIT_WINDOW?;
	}

	// Enable VSync
	if (gRenderer.set_vsync(1) == false)
	{
		sdl::log_("Could not set vsync. SDL error: %s\n", sdl::get_error());
		return INIT_VSYNC?;
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

	// Set gTextTexture to a static string
	gTextTexture.load_from_rendered_text(
		"Move the dot around with <up>, <down>, <left> and <right>",
		{0xcc, 0x00, 0x00, 0xFF});

	// Load our dot texture.
	if (gDotTexture.load_from_file("resources/dot.png") == false)
	{
		sdl::log_("Unsable to load dot texture. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}

	// Load our background2 texture
	if (gBgTexture.load_from_file("resources/background2.png") == false)
	{
		sdl::log_("Unsable to load background texture. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}

	return err?;
}

fn void close()
{
	// Clean up texture(s)
	gTextTexture.destroy();
	gDotTexture.destroy();
	gBgTexture.destroy();

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

fn bool check_collision(SDLRect a, SDLRect b)
{
	// Calculate the sides of rect a
	CInt aMinX = a.x;
	CInt aMaxX = a.x + a.w;
	CInt aMinY = a.y;
	CInt aMaxY = a.y + a.h;

	// Calculate the sides of rect b
	CInt bMinX = b.x;
	CInt bMaxX = b.x + b.w;
	CInt bMinY = b.y;
	CInt bMaxY = b.y + b.h;
	
	// If the left side of a is to the right of b
	if (aMinX >= bMaxX)
	{
		return false;
	}
	// If the right side of a is to the left of b
	if (aMaxX <= bMinX)
	{
		return false;
	}

	// If the top of a is below b
	if (aMinY >= bMaxY)
	{
		return false;
	}
	// If the bottom of a is above b
	if (aMaxY <= bMinY)
	{
		return false;
	}

	// If none of the sides are outside b
	return true;
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

	// String
	DString textInput;

	// The dot we will be moving
	Dot dot;

	// Define the camera area
	SDLFRect camera = {0f, 0f, SCREEN_WIDTH, SCREEN_HEIGHT};

	// The main loop
	while(quit == false)
	{
		// Set this to true to update the text texture.
		bool updateTextTexture = false;

		// Process events
		while(sdl::poll_event(&event) == true)
		{
			// if quit event set quit flag
			if (event.type == SDLEventType.QUIT)
			{
				quit = true;
			}
			dot.handle_event(&event);
		}

		// Update dot
		dot.move();

		// Center camera over the dot
		camera.x = (float)(dot.get_pos_x() + DOT_WIDTH / 2 - SCREEN_WIDTH / 2);
		camera.y = (float)(dot.get_pos_y() + DOT_HEIGHT / 2 - SCREEN_HEIGHT / 2);

		// Bound the camera to the level area
		if (camera.x < 0)
		{
			camera.x = 0;
		}
		else if (camera.x + camera.w > LEVEL_WIDTH)
		{
			camera.x = LEVEL_WIDTH - camera.w;
		}
		if (camera.y < 0)
		{
			camera.y = 0;
		}
		else if (camera.y + camera.h > LEVEL_HEIGHT)
		{
			camera.y = LEVEL_HEIGHT - camera.h;
		}

		// Fill the background
		gRenderer.set_draw_color(0xFF, 0xFF, 0xFF, 0xFF);
		gRenderer.clear();

		// Show background
		gBgTexture.render(0f, 0f, &camera);

		// Render dot
		dot.render(camera);

		// Render text on screen
		gTextTexture.render(
			((float)SCREEN_WIDTH - gTextTexture.get_width()) / 2f, 0f);
			// ((float)SCREEN_HEIGHT - gTextTexture.get_height()) / 2f);

		// Update screen
		gRenderer.present();

	}

	close();

	return 0;
}
