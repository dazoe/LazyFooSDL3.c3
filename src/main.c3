module lazyfoosdl3;
import std::io;
import sdl;

const CInt SCREEN_WIDTH = 800;
const CInt SCREEN_HEIGHT = 600;
const float SPRITESIZE = 100;

SDLWindow* gWindow;
SDLRenderer* gRenderer;
LTexture gSpriteSheetTexture;

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
	if (gSpriteSheetTexture.load_from_file("resources/circles.png") == false)
	{
		sdl::log_("Unable to load Up texture! SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}

	return err?;
}

fn void close()
{
	gSpriteSheetTexture.destroy();

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

		// Init sprite clip
		SDLFRect spriteClip = {0f, 0f, SPRITESIZE, SPRITESIZE};

		// Init sprite size
		SDLFRect spriteSize = {0f, 0f, SPRITESIZE, SPRITESIZE};

		// Render the images on the screen

		// Use top left sprite
		spriteClip.x = 0f;
		spriteClip.y = 0f;

		// Set sprite size to original size
		spriteSize.w = SPRITESIZE;
		spriteSize.h = SPRITESIZE;

		// Draw original sized sprite
		gSpriteSheetTexture.render(0f, 0f, &spriteClip, spriteSize.w, spriteSize.h);

		// Use top right sprite
		spriteClip.x = SPRITESIZE;
		spriteClip.y = 0f;

		// Set sprite to half size
		spriteSize.w = SPRITESIZE * 0.5f;
		spriteSize.h = SPRITESIZE * 0.5f;

		// Draw half sized sprite
		gSpriteSheetTexture.render(SCREEN_WIDTH - spriteSize.w, 0f, &spriteClip, spriteSize.w, spriteSize.h);

		// Use bottom left sprite
		spriteClip.x = 0f;
		spriteClip.y = SPRITESIZE;

		// Set sprite to double size
		spriteSize.w = SPRITESIZE * 2f;
		spriteSize.h = SPRITESIZE * 2f;

		// Draw double sized sprite
		gSpriteSheetTexture.render(0f, SCREEN_HEIGHT - spriteSize.h, &spriteClip, spriteSize.w, spriteSize.h);

		// Use bottom right sprite
		spriteClip.x = SPRITESIZE;
		spriteClip.y = SPRITESIZE;

		// Squish vertically
		spriteSize.w = SPRITESIZE;
		spriteSize.h = SPRITESIZE * 0.5f;

		// Draw double sized sprite
		gSpriteSheetTexture.render(SCREEN_WIDTH - spriteSize.w, SCREEN_HEIGHT - spriteSize.h, &spriteClip, spriteSize.w, spriteSize.h);

		// Update screen
		gRenderer.present();
	}

	close();

	return 0;
}
