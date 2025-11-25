module lazyfoosdl3;

import sdl;

const DOT_WIDTH = 20;
const DOT_HEIGHT = 20;

const DOT_MAX_VELOCITY = 5;

struct Dot
{
	CInt[<2>] position;
	CInt[<2>] velocity;
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

fn void Dot.move(&self)
{
	// Move left/right and up/down
	self.position += self.velocity;

	// If the dot went to far left or right
	if ((self.position.x < 0) || (self.position.x + DOT_WIDTH) > LEVEL_WIDTH)
	{
		// Move back
		self.position.x -= self.velocity.x;
	}

	// If the dot went to far up or down
	if ((self.position.y < 0) || (self.position.y + DOT_HEIGHT) > LEVEL_HEIGHT)
	{
		// Move back
		self.position.y -= self.velocity.y;
	}
}

fn void Dot.render(&self, SDLFRect camera)
{
	// Show the dot
	gDotTexture.render((float)self.position.x - camera.x, (float)self.position.y - camera.y);
}

fn CInt Dot.get_pos_x(&self)
{
	return self.position.x;
}

fn CInt Dot.get_pos_y(&self)
{
	return self.position.y;
}