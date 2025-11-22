module lazyfoosdl3;

import sdl;
import sdl::img;

const ORIGINAL_SIZE = -1;

struct LTexture
{
	SDLTexture* texture;
	CInt width, height;
}

fn void LTexture.destroy(&self)
{
	self.texture.destroy();
	self.texture = null;
	self.width = 0;
	self.height = 0;
}

fn bool LTexture.load_from_file(&self, ZString path)
{
	// Clean up texture if it was already loaded.
	self.destroy();

	// Load given image to surface
	SDLSurface* loadedSurface = img::load(path);
	if (loadedSurface == null) {
		sdl::log_("Unable to load image %s. SDL error: %s\n", path, sdl::get_error());
	}
	else
	{
		// Set color key
		if (loadedSurface.set_color_key(true, loadedSurface.map_rbg(0x00, 0xFF, 0xFF)) == false)
		{
			sdl::log_("Unable to set color key on image surface. SDL error: %s", sdl::get_error());
		}
		else
		{
			// Create texture from surface
			self.texture = gRenderer.create_texture_from_surface(loadedSurface);
			if (self.texture == null)
			{
				sdl::log_("Unable to create texture from surface(%s). SDL error: %s\n", path, sdl::get_error());
			}
			else
			{
				// set texture dimisions
				self.width = loadedSurface.w;
				self.height = loadedSurface.h;
			}
		}

		// Clean up loaded surface
		loadedSurface.destroy();
	}

	// return success if texture was loaded
	return self.texture != null;
}

fn void LTexture.render(&self, float x, float y, SDLFRect* clip = null, float width = ORIGINAL_SIZE, float height = ORIGINAL_SIZE, double degrees = 0.0, SDLFPoint* center = null, SDLFlipMode flipmode = SDLFlipMode.NONE)
{
	// set texture position
	SDLFRect dstRect = {x, y, (float)self.width, (float)self.height};

	// If clipping, default to clip width and height
	if (clip != null)
	{
		dstRect.w = clip.w;
		dstRect.h = clip.h;
	}

	// Use dimensions if given
	if (width > 0)
	{
		dstRect.w = width;
	}
	if (height > 0)
	{
		dstRect.h = height;
	}

	// Render the texture
	gRenderer.texture_rotated(self.texture, clip, &dstRect, degrees, center, flipmode);
}

fn CInt LTexture.get_width(&self)
{
	return self.width;
}

fn CInt LTexture.get_height(&self)
{
	return self.height;
}

fn bool LTexture.is_loaded(&self)
{
	return self.texture == null;
}