module lazyfoosdl3;
import std::io;
import sdl;
import sdl::ttf;

const CInt SCREEN_WIDTH = 800;
const CInt SCREEN_HEIGHT = 600;
const int SCREEN_FPS = 60;

/* Global variables */
// The main sdl window.
SDLWindow* gWindow;

// The renderer we will be using
SDLRenderer* gRenderer;

// Global font
TTFFont* gFont;

// Our global textures
LTexture gTextTexture;
LTexture gSpriteSheetTexture;

faultdef INIT_VIDEO, INIT_WINDOW, INIT_VSYNC, INIT_TTF;

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

	// Load the sprite sheet
	if (gSpriteSheetTexture.load_from_file("resources/green_idle_240x440.png") == false)
	{
		sdl::log_("Unable to load dot texture. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}

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
	gSpriteSheetTexture.destroy();

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

	// VSync toggle
	bool vsyncEnabled = true;

	// FSP cap toggle
	bool fpsCapEnabled = true;

	// Timer to cap frame rate
	LTimer capTimer;

	// Time spent rendering
	ulong nsRendering = 0;

	// String
	DString timeText;

	// Current frame
	int frame = -1;

	// Setup animation sprites
	const SPRITE_WIDTH = 240;
	const SPRITE_HEIGHT = 440;
	const int NUM_SPRITES = 3;
	const int FRAMES_PER_SPRITE = 10;
	SDLFRect[NUM_SPRITES] spriteClips = {
		{SPRITE_WIDTH * 0f, 0f, SPRITE_WIDTH, SPRITE_HEIGHT},
		{SPRITE_WIDTH * 1f, 0f, SPRITE_WIDTH, SPRITE_HEIGHT},
		{SPRITE_WIDTH * 2f, 0f, SPRITE_WIDTH, SPRITE_HEIGHT},
	};

	// The main loop
	while(quit == false)
	{
		// Start frame timer
		capTimer.start();

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
				// VSync toggle
				if (event.key.key == sdl::K_RETURN)
				{
					vsyncEnabled = !vsyncEnabled;
					gRenderer.set_vsync(vsyncEnabled ? 1 : sdl::RENDERER_VSYNC_DISABLED);
				}
				
				// FPS cap toggle
				if (event.key.key == sdl::K_SPACE)
				{
					fpsCapEnabled = !fpsCapEnabled;
				}
			}
		}

		// goto next frame
		frame++;
		
		// cycle animation
		if (frame / FRAMES_PER_SPRITE >= NUM_SPRITES)
		{
			frame = 0;
		}

		// update text
		if (nsRendering != 0)
		{
			double framesPerSecond = 1000000000.0 / (double)nsRendering;
			timeText.chop(0);
			io::fprintf(&timeText, "Frames per second %s %s %f",
				(vsyncEnabled ? "(VSync)" : "" ), (fpsCapEnabled ? "(Cap)" : ""),
				framesPerSecond)!!;
			SDLColor textColor = {0x00, 0x00, 0x00, 0xFF};
			gTextTexture.load_from_rendered_text(timeText.zstr_view(), textColor);
		}

		// Fill the background
		gRenderer.set_draw_color(0xFF, 0xFF, 0xFF, 0xFF);
		gRenderer.clear();

		// Render the sprite
		gSpriteSheetTexture.render(
			(SCREEN_WIDTH - SPRITE_WIDTH) / 2f,
			(SCREEN_HEIGHT - SPRITE_HEIGHT) / 2,
			&spriteClips[frame / FRAMES_PER_SPRITE]);

		// Render text on screen
		gTextTexture.render(
			((float)SCREEN_WIDTH - gTextTexture.get_width()) / 2f,
			((float)SCREEN_HEIGHT - gTextTexture.get_height()) / 2f);

		// Update screen
		gRenderer.present();

		// Get time to render frame
		nsRendering = capTimer.getTicksNS();

		// If time remaining in frame
		ulong nsPerFrame = 1000000000 / SCREEN_FPS;
		if (fpsCapEnabled && nsRendering < nsPerFrame)
		{
			// Sleep remaining time
			ulong sleepTime = nsPerFrame - nsRendering;
			sdl::delay_ns(sleepTime);

			// Get frame time + sleep time
			nsRendering = capTimer.getTicksNS();
		}
	}

	close();

	return 0;
}
