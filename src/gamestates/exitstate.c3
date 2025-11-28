module lazyfoosdl3;

import sdl;

struct ExitState (GameState)
{
	void* empty;
}

// Singleton?
ExitState sExitState;

fn bool ExitState.enter(&self) @dynamic
{
	return true;
}

fn bool ExitState.exit(&self) @dynamic
{
	return true;
}

fn void ExitState.handle_event(&self, SDLEvent* event) @dynamic
{
}

fn void ExitState.update(&self) @dynamic
{
}

fn void ExitState.render(&self) @dynamic
{
}