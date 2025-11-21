module lazyfoosdl3;
import std::io;
import sdl;

const CInt SCREEN_WIDTH = 800;
const CInt SCREEN_HEIGHT = 600;

SDLWindow* gWindow;
SDLSurface* gScreenSurface;
SDLSurface* gHelloWorld;

faultdef INIT_VIDEO, INIT_WINDOW, INIT_SURFACE;

fn void? init()
{
	if (sdl::init(SDLInitFlags.VIDEO) == false)
	{
		sdl::log_("SDL could not initialize! SDL error: %s\n", sdl::get_error());
		return INIT_VIDEO?;
	}
	gWindow = sdl::create_window("LazyFoo SDL3 tutorial in C3", SCREEN_WIDTH, SCREEN_HEIGHT, 0);
	if (gWindow == null)
	{
		sdl::log_("Window could not be created! SDL error: %s\n", sdl::get_error());
		return INIT_WINDOW?;
	}
	gScreenSurface = gWindow.get_surface();
	if (gScreenSurface == null)
	{
		sdl::log_("Unable to get window surface! SDL error: %s\n", sdl::get_error());
		gWindow.destroy();
		return INIT_SURFACE?;
	}
}

faultdef LOAD_ERROR;

fn void? load_media()
{
	ZString image_path = "resources/HelloWorld.bmp";
	gHelloWorld = sdl::load_bmp(image_path);
	if (gHelloWorld == null) {
		sdl::log_("Unable to get window surface! SDL error: %s\n", sdl::get_error());
		return LOAD_ERROR?;
	}
}

fn void close()
{
	gHelloWorld.destroy();
	gHelloWorld = null;

	gWindow.destroy();
	gScreenSurface = null;
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

	bool quit;
	SDLEvent event;
	while(quit == false)
	{
		while(sdl::poll_event(&event) == true)
		{
			if (event.type == SDLEventType.QUIT)
			{
				quit = true;
			}
		}

		gScreenSurface.fill_rect(null, gScreenSurface.map_rbg(0xFF, 0xFF, 0xFF));
		gHelloWorld.blit(null, gScreenSurface, null);
		gWindow.update_surface();
	}

	close();

	return 0;
}
