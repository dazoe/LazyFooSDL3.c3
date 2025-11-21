module lazyfoosdl3;

import sdl;
import sdl::img;

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
    SDLSurface* loadedSurface = img::load(path);
    if (loadedSurface == null) {
        sdl::log_("Unable to load image %s. SDL error: %s\n", path, sdl::get_error());
    }
    else
    {
        self.texture = gRenderer.create_texture_from_surface(loadedSurface);
        if (self.texture == null)
        {
            sdl::log_("Unable to create texture from surface(%s). SDL error: %s\n", path, sdl::get_error());
        }
        else
        {
            self.width = loadedSurface.w;
            self.height = loadedSurface.h;
        }

        // Clean up loaded surface
        loadedSurface.destroy();
    }

    // return success if texture was loaded
    return self.texture != null;
}

fn void LTexture.render(&self, float x, float y)
{
    SDLFRect dstRect = {x, y, (float)self.width, (float)self.height};
    gRenderer.texture(self.texture, null, &dstRect);
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