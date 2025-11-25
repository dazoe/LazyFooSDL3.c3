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
		"Enter Text:\n",
		{0x00, 0x00, 0x00, 0xFF});

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

	// Enable text input
	gWindow.start_text_input();

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
			// Special key input
			else if (event.type == SDLEventType.KEY_DOWN)
			{
				// Handle backspace
				if (event.key.key == sdl::K_BACKSPACE)
				{
					// remove last charater
					if (textInput.len() > 0)
					{
						textInput.chop(textInput.len()-1);
						updateTextTexture = true;
					}
				}
				// Handle return
				if (event.key.key == sdl::K_RETURN)
				{
					textInput.append('\n');
					updateTextTexture = true;
				}
				// Handle copy (ctrl+c)
				else if (event.key.key == sdl::K_C && sdl::get_mod_state() & sdl::KMOD_CTRL)
				{
					sdl::set_clipboard_text(textInput.zstr_view());
				}
				// Handle paste (ctrl+v)
				else if (event.key.key == sdl::K_V && sdl::get_mod_state() & sdl::KMOD_CTRL)
				{
					ZString clipboard_text = sdl::get_clipboard_text();
					if (clipboard_text != null)
					{
						textInput.append_chars(clipboard_text.str_view());
						sdl::free(clipboard_text);
						updateTextTexture = true;
					}
				}
			}
			// Special text input event
			else if (event.type == SDLEventType.TEXT_INPUT)
			{
				// If not ctrl or alt
				if (!(sdl::get_mod_state() & sdl::KMOD_ALT || sdl::get_mod_state() & sdl::KMOD_CTRL))
				{
					textInput.append_chars(event.text.text.str_view());
					updateTextTexture = true;
				}
			}
		}

		// Re-render text when requested.
		if (updateTextTexture)
		{
			@pool()
			{
				DString tmp;
				io::fprintf(&tmp, "Enter Text:\n%s", textInput.str_view())!!;
				// update gTextTexture to include our string
				gTextTexture.load_from_rendered_text(
					tmp.zstr_view(),
					{0x00, 0x00, 0x00, 0xFF});
			};
		}



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
