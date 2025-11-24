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

// Global audio devices
SDLAudioDeviceID gMusicDevice;
SDLAudioDeviceID gEffectsDevice;

// Music
Sound gMusic;
Sound[4] gSounds;

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

	// Open default audio playback device.
	gMusicDevice = sdl::open_audio_device(sdl::AUDIO_DEVICE_DEFAULT_PLAYBACK, null);
	if (gMusicDevice == 0)
	{
		sdl::log_("Could not open default playback device. SDL error: %s\n", sdl::get_error());
		return INIT_AUDIO?;
	}
	gEffectsDevice = sdl::open_audio_device(sdl::AUDIO_DEVICE_DEFAULT_PLAYBACK, null);
	if (gEffectsDevice == 0)
	{
		sdl::log_("Could not open default playback device. SDL error: %s\n", sdl::get_error());
		return INIT_AUDIO?;
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

	// Set gTextTexture to a static string
	gTextTexture.load_from_rendered_text(
		"Press <space> to play / pause music\n"
		"Press 0 to stop music\n"
		"Change music volume with Q and W\n"
		"Press 1,2,3,4 to play a sound effect.",
		{0x00, 0x00, 0x00, 0xFF});

	// Load music wav
	if (gMusic.load_from_file(gMusicDevice, "resources/Ove - Earth Is All We Have.wav") == false) {
		sdl::log_("Could not load music. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}
	if (gSounds[0].load_from_file(gEffectsDevice, "resources/FX/pepSound1.mp3.wav") == false) {
		sdl::log_("Could not load pepSound1.mp3.wav. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}
	if (gSounds[1].load_from_file(gEffectsDevice, "resources/FX/phaseJump1.mp3.wav") == false) {
		sdl::log_("Could not load phaseJump.mp3.wav. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}
	if (gSounds[2].load_from_file(gEffectsDevice, "resources/FX/phaserDown1.mp3.wav") == false) {
		sdl::log_("Could not load phaserDown1.mp3.wav. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}
	if (gSounds[3].load_from_file(gEffectsDevice, "resources/FX/phaserUp1.mp3.wav") == false) {
		sdl::log_("Could not load phaserUp1.mp3.wav. SDL error: %s\n", sdl::get_error());
		err = LOAD_ERROR;
	}

	return err?;
}

fn void close()
{
	// Clean up sounds
	gMusic.destroy();
	gSounds[0].destroy();
	gSounds[1].destroy();
	gSounds[2].destroy();
	gSounds[3].destroy();

	// Close audio devices.
	gEffectsDevice.close();
	gEffectsDevice = 0;
	gMusicDevice.close();
	gMusicDevice = 0;

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

	// String
	DString timeText;

	// The main loop
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
				switch (event.key.key)
				{
					// Pause / resume music
					case sdl::K_SPACE:
						if (gMusicDevice.paused())
						{
							gMusicDevice.resume();
						}
						else
						{
							gMusicDevice.pause();
						}
					// Stop music, ie: pause and clear the audio stream buffer
					case sdl::K_0:
						gMusicDevice.pause();
						gMusic.stop();
					case sdl::K_1:
						gSounds[0].play();
					case sdl::K_2:
						gSounds[1].play();
					case sdl::K_3:
						gSounds[2].play();
					case sdl::K_4:
						gSounds[3].play();

					// Adjust music volume using q and w
					case sdl::K_Q:
						float gain = gMusicDevice.get_gain() - 0.1f;
						// Clamp to silent.
						if (gain < 0) {
							gain = 0;
						}
						gMusicDevice.set_gain(gain);
						io::printfn("Music gain: %f", gain);
					case sdl::K_W:
						float gain = gMusicDevice.get_gain() + 0.1f;
						// Clamp to +5 over amplifacation.
						if (gain > 5) {
							gain = 5;
						}
						gMusicDevice.set_gain(gain);
						io::printfn("Music gain: %f", gain);
				}
			}
		}

		// always call music play to keep music buffer filled.
		gMusic.play();

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
