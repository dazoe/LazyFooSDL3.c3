module lazyfoosdl3;
import std::io;
import sdl;

const CInt SCREEN_WIDTH = 800;
const CInt SCREEN_HEIGHT = 600;
const float SPRITESIZE = 100;
// Set color constants
const int COLOR_MAGNITUDE_COUNT = 3;
const char[COLOR_MAGNITUDE_COUNT] COLOR_MAGNITUDES = {0x00, 0x7F, 0xFF};

SDLWindow* gWindow;
SDLRenderer* gRenderer;
LTexture gColorsTexture;


enum ColorChannel : const inline int
{
	TEXTURE_RED,
	TEXTURE_GREEN,
	TEXTURE_BLUE,
	TEXTURE_ALPHA,

	BACKGROUND_RED,
	BACKGROUND_GREEN,
	BACKGROUND_BLUE,

	TOTAL,
	UNKNOWN,
}


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
	if (gColorsTexture.load_from_file("resources/rgb.png") == false)
	{
		sdl::log_("Unable to load Up texture! SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}

	return err?;
}

fn void close()
{
	gColorsTexture.destroy();

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

	// Initialize colors
	char[ColorChannel.TOTAL] colorChannelIndices;
	colorChannelIndices[ColorChannel.TEXTURE_RED] = 2;
	colorChannelIndices[ColorChannel.TEXTURE_GREEN] = 2;
	colorChannelIndices[ColorChannel.TEXTURE_BLUE] = 2;
	colorChannelIndices[ColorChannel.TEXTURE_ALPHA] = 2;

	colorChannelIndices[ColorChannel.BACKGROUND_RED] = 2;
	colorChannelIndices[ColorChannel.BACKGROUND_GREEN] = 2;
	colorChannelIndices[ColorChannel.BACKGROUND_BLUE] = 2;

	// Initialize blending
	gColorsTexture.set_blending(sdl::BLENDMODE_BLEND);

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
			else if (event.type == SDLEventType.KEY_DOWN)
			{
				// Check for channel key
				ColorChannel channelToUpdate = ColorChannel.UNKNOWN;
				switch (event.key.key)
				{
					// Update texture color channel
					case sdl::K_A:
						channelToUpdate = ColorChannel.TEXTURE_RED;
					case sdl::K_S:
						channelToUpdate = ColorChannel.TEXTURE_GREEN;
					case sdl::K_D:
						channelToUpdate = ColorChannel.TEXTURE_BLUE;
					case sdl::K_F:
						channelToUpdate = ColorChannel.TEXTURE_ALPHA;

					// Update background color channel
					case sdl::K_Q:
						channelToUpdate = ColorChannel.BACKGROUND_RED;
					case sdl::K_W:
						channelToUpdate = ColorChannel.BACKGROUND_GREEN;
					case sdl::K_E:
						channelToUpdate = ColorChannel.BACKGROUND_BLUE;
				}
				if (channelToUpdate != ColorChannel.UNKNOWN)
				{
					// Cycle through channel values
					colorChannelIndices[channelToUpdate]++;
					if (colorChannelIndices[channelToUpdate] >= COLOR_MAGNITUDE_COUNT)
					{
						colorChannelIndices[channelToUpdate] = 0;
					}

					// Write color values to console.
					sdl::log_("Texture - R:%3d G:%3d B:%3d A:%3d | Background - R:%3d G:%3d B:%3d",
						COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.TEXTURE_RED]],
						COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.TEXTURE_GREEN]],
						COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.TEXTURE_BLUE]],
						COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.TEXTURE_ALPHA]],
						COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.BACKGROUND_RED]],
						COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.BACKGROUND_GREEN]],
						COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.BACKGROUND_BLUE]],
					);
				}
			}
		}

		// Fill the background
		gRenderer.set_draw_color(
			COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.BACKGROUND_RED]],
			COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.BACKGROUND_GREEN]],
			COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.BACKGROUND_BLUE]],
			0xFF);
		gRenderer.clear();

		// Set textrure color and render
		gColorsTexture.set_color(
			COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.TEXTURE_RED]],
			COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.TEXTURE_GREEN]],
			COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.TEXTURE_BLUE]],
		);
		gColorsTexture.set_alpha(
			COLOR_MAGNITUDES[colorChannelIndices[ColorChannel.TEXTURE_ALPHA]],
		);
		gColorsTexture.render(
			((float)SCREEN_WIDTH - gColorsTexture.get_width()) / 2.0f, ((float)SCREEN_HEIGHT - gColorsTexture.get_height()) / 2.0f);

		// Update screen
		gRenderer.present();
	}

	close();

	return 0;
}
