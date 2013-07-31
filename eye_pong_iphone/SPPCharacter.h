//
//  SPPCharacter.h
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPParallaxSprite.h"
/* Used by the move: method to move a character in a given direction. */
typedef enum : uint8_t {
    SPPMoveDirectionForward = 0,
    SPPMoveDirectionLeft,
    SPPMoveDirectionRight,
    SPPMoveDirectionBack,
} SPPMoveDirection;

/* The different animation states of an animated character. */
typedef enum : uint8_t {
    SPPAnimationStateIdle = 0,
    SPPAnimationStateWalk,
    SPPAnimationStateAttack,
    SPPAnimationStateGetHit,
    SPPAnimationStateDeath,
    kAnimationStateCount
} SPPAnimationState;

/* Bitmask for the different entities with physics bodies. */
/* NOTE: This needs custom defining here */
typedef enum : uint8_t {
    SPPColliderTypeHero             = 1,
    SPPColliderTypeGoblinOrBoss     = 2,
    SPPColliderTypeProjectile       = 4,
    SPPColliderTypeWall             = 8,
    SPPColliderTypeCave             = 16
} SPPColliderType;

#define kMovementSpeed 200.0
#define kRotationSpeed 0.06

#define kCharacterCollisionRadius   40
#define kProjectileCollisionRadius  15

#define kDefaultNumberOfWalkFrames 28
#define kDefaultNumberOfIdleFrames 28

@class SPPMultiplayerLayeredCharacterScene;
#import "SPPParallaxSprite.h"

@interface SPPCharacter : SPPParallaxSprite

@property (nonatomic, getter=isDying) BOOL dying;
@property (nonatomic, getter=isAttacking) BOOL attacking;
@property (nonatomic) CGFloat health;
@property (nonatomic, getter=isAnimated) BOOL animated;
@property (nonatomic) CGFloat animationSpeed;
@property (nonatomic) CGFloat movementSpeed;

@property (nonatomic) NSString *activeAnimationKey;
@property (nonatomic) SPPAnimationState requestedAnimation;

/* Preload shared animation frames, emitters, etc. */
+ (void)loadSharedAssets;

/* Initialize a standard sprite. */
- (id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position;

/* Initialize a parallax sprite. */
- (id)initWithSprites:(NSArray *)sprites atPosition:(CGPoint)position usingOffset:(CGFloat)offset;

/* Reset a character for reuse. */
- (void)reset;

/* Loop Update - called once per frame. */
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval;

/* Applying Damage - i.e., decrease health. */
- (BOOL)applyDamage:(CGFloat)damage;
// use projectile alpha to determine potency
- (BOOL)applyDamage:(CGFloat)damage fromProjectile:(SKNode *)projectile;

/* Orientation, Movement, and Attacking. */
- (void)move:(SPPMoveDirection)direction withTimeInterval:(NSTimeInterval)timeInterval;
- (CGFloat)faceTo:(CGPoint)position;
- (void)moveTowards:(CGPoint)position withTimeInterval:(NSTimeInterval)timeInterval;
- (void)moveInDirection:(CGPoint)direction withTimeInterval:(NSTimeInterval)timeInterval;
- (void)performAttackAction;


/* Scenes. */
- (void)addToScene:(SPPMultiplayerLayeredCharacterScene *)scene; // also adds the shadow blob
- (SPPMultiplayerLayeredCharacterScene *)characterScene; // returns the MultiplayerLayeredCharacterScene this character is in

/* Animation. */
- (void)fadeIn:(CGFloat)duration;
@end
