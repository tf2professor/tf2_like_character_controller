# TF2-like character controller for Godot Game Engine
FPS character controller that tries to imitate the movement style and mechanics of the popular game Team Fortress 2. 

Originally made on Godot 3.5

## Controls
* WASD: move
* CTRL: crouch
* Spacebar: jump
* Mouse: look
* P: change perspective (first person or third person)

## Features
1. Air control similar to how it works on TF2:
	* Pressing W or S impedes air strafing;
	* To air strafe, press A or D and smoothly move the mouse towards the direction you are strafing to;
	* Moving the mouse too abruptly cancels an air strafe;
	* Pressing a movement key opposite to the direction you are moving will stop the motion;
	* If jumping from a stand still, pressing the movement keys will grant you a small boost in the air, to help with climbing obstacles.
2. Intelligent crouch system:
	* If there's an obstacle above, the character remains crouched until the space above is free;
	* Can't jump while fully crouched;
	* Crouching while jumping helps clear some taller obstacles (crouch jumping).
3. Speed change depending on state:
	* Different speed penalties while moving backwards (90% of full speed) and while crouching (33% of full speed).
4. Climbing/Step up mechanics:
	* You can climb/step up small obstacles by walking over them;
	* It is recommended to use actual ramps for smoother movement, but you can actually walk up stairs as well.
5. Walking on ramps without sliding down:
	* Movement on ramps is just as on flat ground.
6. Jumping again before fully hitting the ground:
	* You can "hop" by pressing jump right before hitting the ground;
	* There's a small penalty on vertical velocity for doing so. A jump from a fully grounded position is a bit higher;
	* Horizontal velocity is only updated after fully hitting the ground.

## Caveats and Limitations

I'm not sure if surfing is supported by this system, because I didn't get around to testing it. If it isn't currently supported, I imagine someone could implement it. I'm not interested on doing so, as surfing is more of a niche aspect of TF2, almost a different game mode, much like bunny hopping.

The code isn't the most elegant and I know a lot of stuff could be bunched together and/or optimized. I wanted to make the code as understandable as possible, even for novices, so I decided to write it in sections, which are focused on a single feature or mechanic. That way, it is easy to modify and customize to one's liking.

There's currently a bug in Godot's physics system. If you press yourself against the inside of a corner and then let go of the movement keys, the character you jitter a bit until it stops. This only happens when the corner is composed of a single collision shape (i.e. on the orange boxes). From what I've found, that's an issue on Godot's Bullet Physics system. It is a very localized issue and doesn't really interfere with important functionality.