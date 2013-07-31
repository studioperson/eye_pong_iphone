//
//  SPPHeroCharacter.m
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import "SPPHeroCharacter.h"
#import "SPPMultiplayerLayeredCharacterScene.h"

@implementation SPPHeroCharacter

- (id)initAtPosition:(CGPoint)position withPlayer:(SPPPlayer *)player{
    return [self initWithTexture:nil atPosition:position withPlayer:player];
}

- (id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position withPlayer:(SPPPlayer *)player{
    self = [super initWithTexture:texture atPosition:position];
    if(self){
        _player = player;
        self.zPosition = 0.25;
        self.name = [NSString stringWithFormat:NSLocalizedString(@"Hero", @"Hero")];
    }
    return self;
}

#pragma mark - Overridden Methods
- (void)configurePhysicsBody {
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kCharacterCollisionRadius];
    
    // Our object type for collisions.
    self.physicsBody.categoryBitMask = SPPColliderTypeHero;
    
    // Collides with these objects.
    self.physicsBody.collisionBitMask = SPPColliderTypeGoblinOrBoss | SPPColliderTypeHero | SPPColliderTypeWall | SPPColliderTypeCave;
    
    // We want notifications for colliding with these objects.
    self.physicsBody.contactTestBitMask = SPPColliderTypeGoblinOrBoss;
}

- (void)collidedWith:(SKPhysicsBody *)other {
    if (other.categoryBitMask & SPPColliderTypeGoblinOrBoss) {
        SPPCharacter *enemy = (SPPCharacter *)other.node;
        if (!enemy.dying) {
            [self applyDamage:5.0f];
            self.requestedAnimation = SPPAnimationStateGetHit;
        }
    }
}

- (void)animationDidComplete:(SPPAnimationState)animationState {
    
    switch (animationState) {
            
        case SPPAnimationStateDeath:{
            SPPMultiplayerLayeredCharacterScene *scene = [self characterScene];
            
            SKEmitterNode *emitter = [[self deathEmitter] copy];
            emitter.zPosition = 0.8;
            [self addChild:emitter];
            SPPRunOneShotEmitter(emitter, 4.5f);
            
            [self runAction:[SKAction sequence:@[
                                                 [SKAction waitForDuration:4.0f],
                                                 [SKAction runBlock:^{
                [scene heroWasKilled:self];
            }],
                                                 [SKAction removeFromParent],
                                                 ]]];
            break;}
            
        case SPPAnimationStateAttack:
            [self fireProjectile];
            break;
            
        default:
            break;
    }
}

#pragma mark - Shared Assets
+ (void)loadSharedAssets {
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedProjectileSoundAction = [SKAction playSoundFileNamed:@"magicmissile.caf" waitForCompletion:NO];
        sSharedDeathEmitter = [SKEmitterNode spp_emitterNodeWithEmitterNamed:@"Death"];
        sSharedDamageEmitter = [SKEmitterNode spp_emitterNodeWithEmitterNamed:@"Damage"];
    });
}

static SKAction *sSharedProjectileSoundAction = nil;
- (SKAction *)projectileSoundAction {
    return sSharedProjectileSoundAction;
}

static SKEmitterNode *sSharedDeathEmitter = nil;
- (SKEmitterNode *)deathEmitter {
    return sSharedDeathEmitter;
}

static SKEmitterNode *sSharedDamageEmitter = nil;
- (SKEmitterNode *)damageEmitter {
    return sSharedDamageEmitter;
}

- (SKAction *)damageAction {
    return nil;
}

@end

NSString * const kPlayer = @"kPlayer";