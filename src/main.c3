module lazyfoosdl3;
import std::io;
import sdl;

const CInt SCREEN_WIDTH = 800;
const CInt SCREEN_HEIGHT = 600;

SDLWindow* gWindow;
SDLRenderer* gRenderer;
LTexture gBackgroundTexture, gStickyTexture;

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

	// load scene images
	if (gBackgroundTexture.load_from_file("resources/background.png") == false)
	{
		sdl::log_("Unable to load Up texture! SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}
	if (gStickyTexture.load_from_file("resources/sticky.png") == false)
	{
		sdl::log_("Unable to load Down texture! SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}

	return err?;
}

fn void close()
{
	gBackgroundTexture.destroy();
	gStickyTexture.destroy();

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
		}

		// Fill the background with white
		gRenderer.set_draw_color(0xFF, 0xFF, 0xFF, 0xFF);
		gRenderer.clear();

		// Render the images on the screen
		gBackgroundTexture.render(0f, 0f);
		gStickyTexture.render(240f, 150f);

		// Update screen
		gRenderer.present();
	}

	close();

	return 0;
}
