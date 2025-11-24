module lazyfoosdl3;

import sdl;

struct Sound
{
	char* wav_data;
	uint wav_data_len;
	SDLAudioStream* stream;
}

fn bool Sound.load_from_file(&self, SDLAudioDeviceID playback_device, ZString filename)
{
	SDLAudioSpec spec;
	if (sdl::load_wav(filename, &spec, &self.wav_data, &self.wav_data_len) == false) {
		sdl::log_("Unable to load wav file. SDL error: %s\n", sdl::get_error());
		return false;
	}
	self.stream = sdl::create_audio_stream(&spec, null);
	if (self.stream == null) {
		sdl::log_("Unable to create audio stream. SDL error: %s\n", sdl::get_error());
		self.destroy();
		return false;
	}
	sdl::bind_audio_stream(playback_device, self.stream);
	return true;
}

fn void Sound.destroy(&self)
{
	self.stream.destroy();
	self.stream = null;
	if (self.wav_data != null) {
		sdl::free(self.wav_data);
		self.wav_data = null;
		self.wav_data_len = 0;
	}
}

fn void Sound.play(&self)
{
	// add more data if queued data is less than ...
	if (self.stream.get_queued() < (self.wav_data_len / 2))
	{
		if (self.stream.put_data(self.wav_data, self.wav_data_len) == false)
		{
			sdl::log_("Unable to put data into the audiostream. SDL error: %s\n", sdl::get_error());
		}
	}
}

fn void Sound.stop(&self)
{
	if (self.stream.clear() == false)
	{
		sdl::log_("Unable to clear the audiostream. SDL error: %s\n", sdl::get_error());
	}
}
