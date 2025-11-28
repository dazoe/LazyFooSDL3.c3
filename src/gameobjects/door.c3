module lazyfoosdl3;

import sdl;

const DOOR_WIDTH = 20;
const DOOR_HEIGHT = 40;

struct Door
{
	SDLRect bounds;
	LTexture* texture;
}

fn void Door.init(&self, CInt x, CInt y)
{
	self.bounds = {x, y, DOOR_WIDTH, DOOR_HEIGHT};
}

fn void Door.render(&self)
{
	// Show the Door
	gRenderer.set_draw_color(0x00, 0x00, 0x00, 0xFF);
	SDLFRect renderRect = {...self.bounds};
	gRenderer.rect(&renderRect);
}

fn SDLRect Door.get_collider(&self)
{
	return self.bounds;
}
