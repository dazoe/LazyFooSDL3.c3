module lazyfoosdl3;

import sdl;

const LBUTTON_WIDTH = 300;
const LBUTTON_HEIGHT = 200;

enum LButtonSprite
{
    MOUSE_OUT,
    MOUSE_OVER_MOTION,
    MOUSE_DOWN,
    MOUSE_UP,
}

struct LButton
{
    SDLFPoint position;
    LButtonSprite current_sprite;
}

fn void LButton.set_position(&self, float x, float y)
{
    self.position = {x, y};
}

fn void LButton.handle_event(&self, SDLEvent event)
{
    // if mouse event happened
    if (event.type == SDLEventType.MOUSE_MOTION ||
        event.type == SDLEventType.MOUSE_BUTTON_DOWN ||
        event.type == SDLEventType.MOUSE_BUTTON_UP)
    {
        // Get mouse position
        float x = -1f;
        float y = -1f;
        sdl::get_mouse_state(&x, &y);

        // Check if mouse is inside button
        bool inside = true;

        // Mouse is left of button
        if (x < self.position.x)
        {
            inside = false;
        }
        // Mouse is right of button
        else if (x > self.position.x + LBUTTON_WIDTH)
        {
            inside = false;
        }
        // Mouse is above the button
        else if (y < self.position.y)
        {
            inside = false;
        }
        // Mouse is below the button
        else if (y > self.position.y + LBUTTON_HEIGHT)
        {
            inside = false;
        }
        // Mouse is outside the button
        if (!inside) {
            self.current_sprite = LButtonSprite.MOUSE_OUT;
        }
        // Mouse is inside the button
        else
        {
            // set mouse over sprite
            switch (event.type) {
                case MOUSE_MOTION:
                    self.current_sprite = LButtonSprite.MOUSE_OVER_MOTION;
                case MOUSE_BUTTON_DOWN:
                    self.current_sprite = LButtonSprite.MOUSE_DOWN;
                case MOUSE_BUTTON_UP:
                    self.current_sprite = LButtonSprite.MOUSE_UP;
            }
        }
    }
}

fn void LButton.render(&self)
{
    // define sprite clip regions
    SDLFRect[] spriteClips = {
        {0f, 0 * LBUTTON_HEIGHT, LBUTTON_WIDTH, LBUTTON_HEIGHT},
        {0f, 1 * LBUTTON_HEIGHT, LBUTTON_WIDTH, LBUTTON_HEIGHT},
        {0f, 2 * LBUTTON_HEIGHT, LBUTTON_WIDTH, LBUTTON_HEIGHT},
        {0f, 3 * LBUTTON_HEIGHT, LBUTTON_WIDTH, LBUTTON_HEIGHT},
    };

    // Show current button sprite
    gButtonSpriteTexture.render(self.position.x, self.position.y, &spriteClips[(int)self.current_sprite]);


}
