//
//  SPPHeroCharacter.h
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import "SPPEnemyCharacter.h"

@class SPPPlayer;

@interface SPPHeroCharacter : SPPCharacter

@property (nonatomic, weak) SPPPlayer *player;

/* Designated Initializer. */
- (id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position withPlayer:(SPPPlayer *)player;

- (id)initAtPosition:(CGPoint)position withPlayer:(SPPPlayer *)player;

- (void)fireProjectile;
- (SKSpriteNode *)projectile;
- (SKEmitterNode *)projectileEmitter;

@end
