//
//  SPPPadle.m
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import "SPPPadle.h"
#import "SPPMultiplayerLayeredCharacterScene.h"

@implementation SPPPadle

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position withPlayer:(SPPPlayer *)player {
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Paddle_Idle"];//@"Warrior_Idle"
    SKTexture *texture = [atlas textureNamed:@"paddle_idle_0001.png"];//@"warrior_idle_0001.png"
    
    return [super initWithTexture:texture atPosition:position withPlayer:player];
}

@end
