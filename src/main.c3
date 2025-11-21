module lazyfoosdl3;
import std::io;
import sdl;

const CInt SCREEN_WIDTH = 800;
const CInt SCREEN_HEIGHT = 600;

SDLWindow* gWindow;
SDLRenderer* gRenderer;
LTexture gPngTexture;

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
	ZString image_path = "resources/HelloPNG.png";
	if (gPngTexture.load_from_file(image_path) == false)
	{
		sdl::log_("Unable to load png texture! SDL error: %s\n", sdl::get_error());
		return LOAD_ERROR?;
	}
}

fn void close()
{
	gPngTexture.destroy();

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

		// Fill the background with white
		gRenderer.set_draw_color(0xFF, 0xFF, 0xFF, 0xFF);
		gRenderer.clear();

		// Render the image on the screen
		gPngTexture.render(0, 0);

		// Update screen
		gRenderer.present();
	}

	close();

	return 0;
}
