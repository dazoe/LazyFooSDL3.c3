module lazyfoosdl3;

import sdl;

const DOT_MAX_VELOCITY = 5;

struct Dot
{
	CInt[<2>] velocity;
	SDLRect bounds;
}

fn void Dot.init(&self, CInt size)
{
	self.bounds = {0, 0, size, size};
}

fn void Dot.set_position(&self, CInt x, CInt y)
{
	self.bounds.x = x;
	self.bounds.y = y;
}

fn void Dot.handle_event(&self, SDLEvent* event)
{
	// If the event is a key press
	if (event.type == SDLEventType.KEY_DOWN && event.key.repeat == false)
	{
		switch (event.key.key)
		{
			case sdl::K_UP:
				self.velocity.y -= DOT_MAX_VELOCITY;
			case sdl::K_DOWN:
				self.velocity.y += DOT_MAX_VELOCITY;
			case sdl::K_LEFT:
				self.velocity.x -= DOT_MAX_VELOCITY;
			case sdl::K_RIGHT:
				self.velocity.x += DOT_MAX_VELOCITY;
		}
	}
	// If the event is a key release
	if (event.type == SDLEventType.KEY_UP && event.key.repeat == false)
	{
		switch (event.key.key)
		{
			case sdl::K_UP:
				self.velocity.y += DOT_MAX_VELOCITY;
			case sdl::K_DOWN:
				self.velocity.y -= DOT_MAX_VELOCITY;
			case sdl::K_LEFT:
				self.velocity.x += DOT_MAX_VELOCITY;
			case sdl::K_RIGHT:
				self.velocity.x -= DOT_MAX_VELOCITY;
		}
	}
}

fn void Dot.move(&self, CInt level_width, CInt level_height)
{
	// Move left/right
	self.bounds.x += self.velocity.x;

	// If the dot went to far left or right
	if ((self.bounds.x < 0) || (self.bounds.x + self.bounds.w) > level_width)
	{
		// Move back
		self.bounds.x -= self.velocity.x;
	}

	// Move up/down
	self.bounds.y += self.velocity.y;
	// If the dot went to far up or down
	if ((self.bounds.y < 0) || (self.bounds.y + self.bounds.h) > level_height)
	{
		// Move back
		self.bounds.y -= self.velocity.y;
	}
}

fn void Dot.render(&self, SDLRect camera)
{
	// Show the dot
	gDotTexture.render((float)(self.bounds.x - camera.x), (float)(self.bounds.y - camera.y));
}

fn SDLRect Dot.get_collider(&self)
{
	return self.bounds;
}
