//
//  SPPPadle.m
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import "SPPPadle.h"
#import "SPPGraphicsUtilities.h"
#import "SPPMultiplayerLayeredCharacterScene.h"


#define kPaddleAttackFrames 10
#define kPaddleGetHitFrames 18
#define kPaddleDeathFrames 42
#define kPaddleProjectileSpeed 8.0

@implementation SPPPadle

#pragma mark - Initialization
- (id)initAtPosition:(CGPoint)position withPlayer:(SPPPlayer *)player {
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Paddle_Idle"];//@"Warrior_Idle"
    SKTexture *texture = [atlas textureNamed:@"paddle_idle_0001.png"];//@"warrior_idle_0001.png"
    
    return [super initWithTexture:texture atPosition:position withPlayer:player];
}

#pragma mark - Shared Assets
+ (void)loadSharedAssets {
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedProjectile = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(2.0, 24.0)];
        sSharedProjectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kProjectileCollisionRadius];
        sSharedProjectile.name = @"Projectile";
        sSharedProjectile.physicsBody.categoryBitMask = SPPColliderTypeProjectile;
        sSharedProjectile.physicsBody.collisionBitMask = SPPColliderTypeWall;
        sSharedProjectile.physicsBody.contactTestBitMask = sSharedProjectile.physicsBody.collisionBitMask;
        
        sSharedProjectileEmitter = [SKEmitterNode spp_emitterNodeWithEmitterNamed:@"PaddleProjectile"];
        sSharedIdleAnimationFrames = SPPLoadFramesFromAtlas(@"Paddle_Idle", @"Paddle_idle_", kDefaultNumberOfIdleFrames);
        sSharedWalkAnimationFrames = SPPLoadFramesFromAtlas(@"Paddle_Walk", @"Paddle_walk_", kDefaultNumberOfWalkFrames);
        sharedAttackAnimationFrames = SPPLoadFramesFromAtlas(@"Paddle_Attack", @"Paddle_attack_", kPaddleAttackFrames);
        sharedGetHitAnimationFrames = SPPLoadFramesFromAtlas(@"Paddle_GetHit", @"Paddle_getHit_", kPaddleGetHitFrames);
        sharedDeathAnimationFrames = SPPLoadFramesFromAtlas(@"Paddle_Death", @"Paddle_death_", kPaddleDeathFrames);
        sSharedDamageAction = [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:10.0 duration:0.0],
                                                   [SKAction waitForDuration:0.75],
                                                   [SKAction colorizeWithColorBlendFactor:0.0 duration:0.25]
                                                   ]];
    });
}

static SKSpriteNode *sSharedProjectile = nil;
- (SKSpriteNode *)projectile {
    return sSharedProjectile;
}

static SKEmitterNode *sSharedProjectileEmitter = nil;
- (SKEmitterNode *)projectileEmitter {
    return sSharedProjectileEmitter;
}

static NSArray *sSharedIdleAnimationFrames = nil;
- (NSArray *)idleAnimationFrames {
    return sSharedIdleAnimationFrames;
}

static NSArray *sSharedWalkAnimationFrames = nil;
- (NSArray *)walkAnimationFrames {
    return sSharedWalkAnimationFrames;
}

static NSArray *sharedAttackAnimationFrames = nil;
- (NSArray *)attackAnimationFrames {
    return sharedAttackAnimationFrames;
}

static NSArray *sharedGetHitAnimationFrames = nil;
- (NSArray *)getHitAnimationFrames {
    return sharedGetHitAnimationFrames;
}

static NSArray *sharedDeathAnimationFrames = nil;
- (NSArray *)deathAnimationFrames {
    return sharedDeathAnimationFrames;
}

static SKAction *sSharedDamageAction = nil;
- (SKAction *)damageAction {
    return sSharedDamageAction;
}

@end
