module lazyfoosdl3;

import sdl;

interface GameState
{
	// Transitions
	fn bool enter();
	fn bool exit();

	// Main loop functions
	fn void handle_event(SDLEvent* event);
	fn void update();
	fn void render();
}
