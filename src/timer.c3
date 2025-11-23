module lazyfoosdl3;

import sdl;

struct LTimer
{
	ulong startTicks;
	ulong pausedTicks;
	bool paused;
	bool started;
}

fn void LTimer.start(&self)
{
	// Start the timer
	self.started = true;
	// Unpause the timer
	self.paused = false;

	// Get current clock time
	self.startTicks = sdl::get_ticks_ns();
	self.pausedTicks = 0;
}
fn void LTimer.stop(&self)
{
	// Stop the timer
	self.started = false;
	// Unpause the timer
	self.paused = false;

	// Clear tick variables
	self.startTicks = 0;
	self.pausedTicks = 0;
	
}
fn void LTimer.pause(&self)
{
	// If the timer is running and isn't paused
	if (self.started && !self.paused)
	{
		// Pause the timer
		self.paused = true;

		// Calculate the paused ticks
		self.pausedTicks = sdl::get_ticks_ns() - self.startTicks;
		self.startTicks = 0;
	}
}
fn void LTimer.unpause(&self)
{
	// If the timer is running and paused
	if (self.started && self.paused)
	{
		// Unpause the timer
		self.paused = false;

		// Reset the starting ticks
		self.startTicks = sdl::get_ticks_ns() - self.pausedTicks;

		// Clear the paused ticks
		self.pausedTicks = 0;
	}
}
fn ulong LTimer.getTicksNS(&self)
{
	// The actual timer time
	ulong time;

	// If the timer is running
	if (self.started)
	{
		// if the timer is paused
		if (self.paused)
		{
			// Return the number of ticks when the timer was paused
			time = self.pausedTicks;
		}
		else
		{
			// Return the current time minus the start time
			time = sdl::get_ticks_ns() - self.startTicks;
		}
	}
	return time;
}
fn bool LTimer.isStarted(&self)
{
	return self.started;
}
fn bool LTimer.isPaused(&self)
{
	return self.paused;
}
