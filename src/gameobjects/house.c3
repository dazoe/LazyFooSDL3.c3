module lazyfoosdl3;

import sdl;

const HOUSE_SIZE = 40;

struct House
{
	SDLRect bounds;
	LTexture* texture;
}

fn void House.init(&self, CInt x, CInt y, LTexture* houseTexture)
{
	self.bounds = {x, y, HOUSE_SIZE, HOUSE_SIZE};
	self.texture = houseTexture;
}

fn void House.render(&self, SDLRect camera)
{
	// Show the House
	self.texture.render((float)(self.bounds.x - camera.x), (float)(self.bounds.y - camera.y));
}

fn SDLRect House.get_collider(&self)
{
	return self.bounds;
}
