module lazyfoosdl3;

import sdl;

// Square dimension
const SQUARE_SIZE = 20;
// Square max velocity
const SQUARE_VEL = 5;

struct Square
{
	// The collision box
	SDLRect collision_box;

	// The square's velocity
	CInt vel_x, vel_y;
}

fn void Square.init(&self)
{
	self.collision_box = {0,0,SQUARE_SIZE, SQUARE_SIZE};
}

fn void Square.handle_event(&self, SDLEvent* event)
{
	// If a key was pressed
	if (event.type == SDLEventType.KEY_DOWN && event.key.repeat == false)
	{
		// Adjust the velocity
		switch (event.key.key)
		{
			case sdl::K_UP: self.vel_y -= SQUARE_VEL;
			case sdl::K_DOWN: self.vel_y += SQUARE_VEL;
			case sdl::K_LEFT: self.vel_x -= SQUARE_VEL;
			case sdl::K_RIGHT: self.vel_x += SQUARE_VEL;
		}
	}
	// If a key was released
	else if (event.type == SDLEventType.KEY_UP && event.key.repeat == false)
	{
		// Adjust the velocity
		switch (event.key.key)
		{
			case sdl::K_UP: self.vel_y += SQUARE_VEL;
			case sdl::K_DOWN: self.vel_y -= SQUARE_VEL;
			case sdl::K_LEFT: self.vel_x += SQUARE_VEL;
			case sdl::K_RIGHT: self.vel_x -= SQUARE_VEL;
		}
	}
}

fn void Square.move(&self, SDLRect collider)
{
	// Move the square left/right
	self.collision_box.x += self.vel_x;

	// If the square went off screen or hit collider
	if ((self.collision_box.x < 0) || (self.collision_box.x + SQUARE_SIZE > SCREEN_WIDTH) || check_collision(self.collision_box, collider))
	{
		// Move back
		self.collision_box.x -= self.vel_x;
	}

	// Move the square up/down
	self.collision_box.y += self.vel_y;

	// If the square went off the screen or hit collider
	if ((self.collision_box.y < 0) || (self.collision_box.y + SQUARE_SIZE > SCREEN_HEIGHT) || check_collision(self.collision_box, collider))
	{
		// Move back
		self.collision_box.y -= self.vel_y;
	}
}

fn void Square.render(&self)
{
	// Show the square
	SDLFRect drawingRect = {(float)self.collision_box.x, (float)self.collision_box.y, SQUARE_SIZE, SQUARE_SIZE};
	gRenderer.set_draw_color(0x00, 0x00, 0x00, 0xff);
	gRenderer.rect(&drawingRect);
}