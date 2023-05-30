//
//  joypad_handler.m
//  Ballz
//
//  Created by Trent Gamblin on 11-09-28.
//  Copyright 2011 Nooskewl. All rights reserved.
//

#import "joypad_handler.h"
#import "JoypadSDK.h"
#include "../cursor.h"

@implementation joypad_handler

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

-(void)start
{
	finding = false;
	joypadManager = [[JoypadManager alloc] init];
	[joypadManager setDelegate:self];
	[joypadManager usePreInstalledLayout:kJoyControllerSNES];
	//[joypadManager setMaxPlayerCount:1];

	connected = left = right = up = down = ba = bb = bx = by = bl = br = false;
}

-(void)find_devices
{
	finding = true;
	if (connected) return;
	[joypadManager stopFindingDevices];
	[joypadManager startFindingDevices];
}

-(void)stop_finding_devices
{
	finding = false;
	[joypadManager stopFindingDevices];
}

-(void)joypadManager:(JoypadManager *)manager didFindDevice:(JoypadDevice *)device previouslyConnected:(BOOL)prev
{
	[manager stopFindingDevices];
	[manager connectToDevice:device asPlayer:1];
}

-(void)joypadManager:(JoypadManager *)manager didLoseDevice:(JoypadDevice *)device;
{
}

-(void)joypadManager:(JoypadManager *)manager deviceDidConnect:(JoypadDevice *)device player:(unsigned int)player
{
	[device setDelegate:self];  // Use self to have the same delegate object as the joypad manager.
	connected = true;
}

-(void)joypadManager:(JoypadManager *)manager deviceDidDisconnect:(JoypadDevice *)device player:(unsigned int)player
{
	connected = false;
	left = right = up = down = ba = bb = bx = by = bl = br = false;
	if (finding) [self find_devices];
}

-(void)joypadDevice:(JoypadDevice *)device didAccelerate:(JoypadAcceleration)accel
{
}

-(void)joypadDevice:(JoypadDevice *)device dPad:(JoyInputIdentifier)dpad buttonUp:(JoyDpadButton)dpadButton
{
	if (dpadButton == kJoyDpadButtonUp)
	{
		up = false;
		cursor_up(false);
	}
	else if (dpadButton == kJoyDpadButtonDown)
	{
		down = false;
		cursor_down(false);
	}
	else if (dpadButton == kJoyDpadButtonLeft)
	{
		left = false;
		cursor_left(false);
	}
	else if (dpadButton == kJoyDpadButtonRight)
	{
		right = false;
		cursor_right(false);
	}
}

-(void)joypadDevice:(JoypadDevice *)device dPad:(JoyInputIdentifier)dpad buttonDown:(JoyDpadButton)dpadButton
{
	if (dpadButton == kJoyDpadButtonUp)
	{
		up = true;
		cursor_up(true);
	}
	else if (dpadButton == kJoyDpadButtonDown)
	{
		down = true;
		cursor_down(true);
	}
	else if (dpadButton == kJoyDpadButtonLeft)
	{
		left = true;
		cursor_left(true);
	}
	else if (dpadButton == kJoyDpadButtonRight)
	{
		right = true;
		cursor_right(true);
	}
}

-(void)joypadDevice:(JoypadDevice *)device buttonUp:(JoyInputIdentifier)button
{
	if (button == kJoyInputAButton)
	{
		ba = false;
		cursor_enter(false);
	}
	else if (button == kJoyInputBButton)
	{
		bb = false;
	}
	else if (button == kJoyInputXButton)
	{
		bx = false;
	}
	else if (button == kJoyInputYButton)
	{
		by = false;
	}
	else if (button == kJoyInputLButton)
	{
		bl = false;
	}
	else if (button == kJoyInputRButton)
	{
		br = false;
	}
}

-(void)joypadDevice:(JoypadDevice *)device buttonDown:(JoyInputIdentifier)button
{
	if (button == kJoyInputAButton)
	{
		ba = true;
		cursor_enter(true);
	}
	else if (button == kJoyInputBButton)
	{
		bb = true;
	}
	else if (button == kJoyInputXButton)
	{
		bx = true;
	}
	else if (button == kJoyInputYButton)
	{
		by = true;
	}
	else if (button == kJoyInputLButton)
	{
		bl = true;
	}
	else if (button == kJoyInputRButton)
	{
		br = true;
	}
}

-(void)joypadDevice:(JoypadDevice *)device analogStick:(JoyInputIdentifier)stick didMove:(JoypadStickPosition)newPosition
{
}

@end
