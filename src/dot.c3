module lazyfoosdl3;

import sdl;
import std::io;

// The dot size
const DOT_WIDTH = 20;
const DOT_HEIGHT = 20;

// The dot's max velocity
const DOT_MAX_VEL = 10;

struct Dot
{
	// The position of the Dot
	int pos_x, pos_y;

	// The velocity of the Dot
	int vel_x, vel_y;
}

fn void Dot.handle_event(&self, SDLEvent event)
{
	// If a key was pressed
	if (event.type == SDLEventType.KEY_DOWN && event.key.repeat == false)
	{
		// Adjust the volocity
		switch (event.key.key)
		{
			case sdl::K_UP:
				self.vel_y -= DOT_MAX_VEL;
			case sdl::K_DOWN:
				self.vel_y += DOT_MAX_VEL;
			case sdl::K_LEFT:
				self.vel_x -= DOT_MAX_VEL;
			case sdl::K_RIGHT:
				self.vel_x += DOT_MAX_VEL;
		}
	}
	// If a key was released
	if (event.type == SDLEventType.KEY_UP && event.key.repeat == false)
	{
		// Adjust the volocity
		switch (event.key.key)
		{
			case sdl::K_UP:
				self.vel_y += DOT_MAX_VEL;
			case sdl::K_DOWN:
				self.vel_y -= DOT_MAX_VEL;
			case sdl::K_LEFT:
				self.vel_x += DOT_MAX_VEL;
			case sdl::K_RIGHT:
				self.vel_x -= DOT_MAX_VEL;
		}
	}
}

fn void Dot.move(&self)
{
	// move dot left/right
	self.pos_x += self.vel_x;

	// if the dot went too far, flip x velocity
	if ((self.pos_x < 0) || (self.pos_x + DOT_WIDTH) > SCREEN_WIDTH)
	{
		// self.pos_x -= self.vel_x;
		self.vel_x *= -1;
	}

	// move dot up/down
	self.pos_y += self.vel_y;

	// if the dot when too far, flip y velocity
	if ((self.pos_y < 0) || (self.pos_y + DOT_HEIGHT) > SCREEN_HEIGHT)
	{
		// self.pos_y -= self.vel_y;
		self.vel_y *= -1;
	}

}

fn void Dot.render(&self)
{
	// Show the dot
	gDotTexture.render(self.pos_x, self.pos_y);
}
