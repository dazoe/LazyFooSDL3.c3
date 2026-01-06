module lazyfoosdl3;
import std::io;
import sdl;
import sdl::ttf;

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 600;

/* Global variables */
// The main sdl window.
SDLWindow* gWindow;

// The renderer we will be using
SDLRenderer* gRenderer;

// Global font
TTFFont* gFont;

// Our global textures
LTexture gDotTexture;

// Global Objects
Dot gDot;

// Gamestate management
GameState gCurrentState;
GameState gNextState;


faultdef INIT_VIDEO, INIT_WINDOW, INIT_VSYNC, INIT_AUDIO, INIT_TTF;

fn void? init()
{
	// Initialize SDL
	if (sdl::init({.video, .audio}) == false)
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

	// Load global font
	gFont = ttf::open_font("resources/HandDrawnShapes.ttf", 28);
	if (gFont == null)
	{
		sdl::log_("Could not load ttf font. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}

	// Load our dot texture.
	if (gDotTexture.load_from_file("resources/dot.png") == false)
	{
		sdl::log_("Unsable to load dot texture. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}

	return err?;
}

fn void close()
{
	// Clean up texture(s)
	gDotTexture.destroy();

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

fn void set_next_state(GameState nextState)
{
	// If the user doesn't want to exit
	if (gNextState.type != ExitState.typeid)
	{
		gNextState = nextState;
	}
}

fn bool change_state()
{
	bool success = true;

	// If the state needs to be changed
	if (gNextState != null)
	{
		success = gCurrentState.exit() && success;
		success = gNextState.enter() && success;

		// change the current state and clear next state
		gCurrentState = gNextState;
		gNextState = null;
	}

	return success;
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

	// Event data
	SDLEvent event;

	// Initilize the dot we will be moving
	gDot.init(20);

	// Set initial gamestate
	gCurrentState = &sIntroState;
	if (gCurrentState.enter() == false)
	{
		gCurrentState.exit();
		gCurrentState = &sExitState;
	}

	// The main loop
	while(gCurrentState.type != ExitState.typeid)
	{
		// Set this to true to update the text texture.
		bool updateTextTexture = false;

		// Process events
		while(sdl::poll_event(&event) == true)
		{
			// if quit event set quit flag
			if (event.type == SDLEventType.QUIT)
			{
				set_next_state(&sExitState);
			}
			// if escape is pressed
			if (event.type == SDLEventType.KEY_DOWN && event.key.key == sdl::K_ESCAPE)
			{
				set_next_state(&sExitState);
			}

			// Pass events to current state
			gCurrentState.handle_event(&event);
		}

		// Update current state
		gCurrentState.update();

		// Change state if needed
		if (change_state() == false)
		{
			// exit if failed to change state
			gCurrentState.exit();
			gCurrentState = &sExitState;
		}

		// Fill the background (white)
		gRenderer.set_draw_color(0xFF, 0xFF, 0xFF, 0xFF);
		gRenderer.clear();

		// Render the current state
		gCurrentState.render();

		// Update screen
		gRenderer.present();
	}

	close();

	return 0;
}
