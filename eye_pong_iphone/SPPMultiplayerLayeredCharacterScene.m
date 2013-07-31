//
//  SPPMultiplayerLayeredCharacterScene.m
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import "SPPMultiplayerLayeredCharacterScene.h"
#import "SPPPlayer.h"
#import "SPPHeroCharacter.h"
#import "SPPGraphicsUtilities.h"
#import <GameController/GameController.h>

@interface SPPMultiplayerLayeredCharacterScene ()

@property (nonatomic) NSMutableArray *players;
@property (nonatomic) SPPPlayer *defaultPlayer;
@property (nonatomic) SKNode *world;
@property (nonatomic) NSMutableArray *layers;
@property (nonatomic, readwrite) NSMutableArray *heroes;

@property (nonatomic) NSArray *hudAvatars;
@property (nonatomic) NSArray *hudLabels;

@property (nonatomic) NSArray *hudScores;
@property (nonatomic) NSArray *hudLifeHeartArrays;

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end

@implementation SPPMultiplayerLayeredCharacterScene

#pragma mark - Initialization
- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        _players = [[NSMutableArray alloc] initWithCapacity:kNumPlayers];
        _defaultPlayer = [[SPPPlayer alloc] init];
        [(NSMutableArray *)_players addObject:_defaultPlayer];
        for (int i = 1; i < kNumPlayers; i++) {
            [(NSMutableArray *)_players addObject:[NSNull null]];
        }
        
        _world = [[SKNode alloc] init];
        [_world setName:@"world"];
        _layers = [NSMutableArray arrayWithCapacity:kWorldLayerCount];
        for (int i = 0; i < kWorldLayerCount; i++) {
            SKNode *layer = [[SKNode alloc] init];
            layer.zPosition = (CGFloat)kWorldLayerCount - i;
            [_world addChild:layer];
            [(NSMutableArray *)_layers addObject:layer];
        }
        
        [self addChild:_world];
        
        [self buildHUD];
        [self updateHUDForPlayer:_defaultPlayer forState:SPPHUDStateLocal withMessage:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GCControllerDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GCControllerDidDisconnectNotification object:nil];
}

#pragma mark - Shared Assets
+ (void)loadSceneAssetsWithCompletionHandler:(SPPAssetLoadCompletionHandler)handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Load the shared assets in the background.
        [self loadSceneAssets];
        
        if (!handler) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Call the completion handler back on the main queue.
            handler();
        });
    });
}

+ (void)loadSceneAssets {
    // Overridden by subclasses.
}

+ (void)releaseSceneAssets {
    // Overridden by subclasses.
}

- (SKEmitterNode *)sharedSpawnEmitter {
    // Overridden by subclasses.
    return nil;
}

#pragma mark - HUD and Scores
- (void)buildHUD {
    NSString *iconNames[] = { @"iconWarrior_blue", @"iconWarrior_green", @"iconWarrior_pink", @"iconWarrior_red" };
    NSArray *colors = @[ [SKColor greenColor], [SKColor blueColor], [SKColor yellowColor], [SKColor redColor] ];
    CGFloat hudX = 30;
    CGFloat hudY = self.frame.size.height - 30;
    CGFloat hudD = self.frame.size.width / kNumPlayers;
    
    _hudAvatars = [NSMutableArray arrayWithCapacity:kNumPlayers];
    _hudLabels = [NSMutableArray arrayWithCapacity:kNumPlayers];
    _hudScores = [NSMutableArray arrayWithCapacity:kNumPlayers];
    _hudLifeHeartArrays = [NSMutableArray arrayWithCapacity:kNumPlayers];
    SKNode *hud = [[SKNode alloc] init];
    
    for (int i = 0; i < kNumPlayers; i++) {
        SKSpriteNode *avatar = [SKSpriteNode spriteNodeWithImageNamed:iconNames[i]];
        avatar.scale = 0.5;
        avatar.alpha = 0.5;
        avatar.position = CGPointMake(hudX + i * hudD + (avatar.size.width * 0.5), self.frame.size.height - avatar.size.height * 0.5 - 8 );
        [(NSMutableArray *)_hudAvatars addObject:avatar];
        [hud addChild:avatar];
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Copperplate"];
        label.text = @"NO PLAYER";
        label.fontColor = colors[i];
        label.fontSize = 16;
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        label.position = CGPointMake(hudX + i * hudD + (avatar.size.width * 1.0), hudY + 10 );
        [(NSMutableArray *)_hudLabels addObject:label];
        [hud addChild:label];
        
        SKLabelNode *score = [SKLabelNode labelNodeWithFontNamed:@"Copperplate"];
        score.text = @"SCORE: 0";
        score.fontColor = colors[i];
        score.fontSize = 16;
        score.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        score.position = CGPointMake(hudX + i * hudD + (avatar.size.width * 1.0), hudY - 40 );
        [(NSMutableArray *)_hudScores addObject:score];
        [hud addChild:score];
        
        [(NSMutableArray *)_hudLifeHeartArrays addObject:[NSMutableArray arrayWithCapacity:kStartLives]];
        for (int j = 0; j < kStartLives; j++) {
            SKSpriteNode *heart = [SKSpriteNode spriteNodeWithImageNamed:@"lives.png"];
            heart.scale = 0.4;
            heart.position = CGPointMake(hudX + i * hudD + (avatar.size.width * 1.0) + 18 + ((heart.size.width + 5) * j), hudY - 10);
            heart.alpha = 0.1;
            [_hudLifeHeartArrays[i] addObject:heart];
            [hud addChild:heart];
        }
    }
    
    [self addChild:hud];
}

- (void)updateHUDForPlayer:(SPPPlayer *)player forState:(SPPHUDState)state withMessage:(NSString *)message {
    NSUInteger playerIndex = [self.players indexOfObject:player];
    
    SKSpriteNode *avatar = self.hudAvatars[playerIndex];
    [avatar runAction:[SKAction sequence: @[[SKAction fadeAlphaTo:1.0 duration:1.0], [SKAction fadeAlphaTo:0.2 duration:1.0], [SKAction fadeAlphaTo:1.0 duration:1.0]]]];
    
    SKLabelNode *label = self.hudLabels[playerIndex];
    CGFloat heartAlpha = 1.0;
    switch (state) {
        case SPPHUDStateLocal:;
            label.text = NSLocalizedString(@"ME", @"ME");
            break;
        case SPPHUDStateConnecting:
            heartAlpha = 0.25;
            if (message) {
                label.text = message;
            } else {
                label.text = NSLocalizedString(@"AVAILABLE", @"AVAILABLE");
            }
            break;
        case SPPHUDStateDisconnected:
            avatar.alpha = 0.5;
            heartAlpha = 0.1;
            label.text = NSLocalizedString(@"NO PLAYER", @"NO PLAYER");
            break;
        case SPPHUDStateConnected:
            if (message) {
                label.text = message;
            } else {
                label.text = NSLocalizedString(@"CONNECTED", @"CONNECTED");
            }
            break;
    }
    
    for (int i = 0; i < player.livesLeft; i++) {
        SKSpriteNode *heart = self.hudLifeHeartArrays[playerIndex][i];
        heart.alpha = heartAlpha;
    }
}

- (void)updateHUDForPlayer:(SPPPlayer *)player {
    NSUInteger playerIndex = [self.players indexOfObject:player];
    SKLabelNode *label = self.hudScores[playerIndex];
    NSString *scoreTxt = NSLocalizedString(@"SCORE:", @"SCORE:");
    label.text = [NSString stringWithFormat:@"%@ %d",scoreTxt, player.score];
}

- (void)updateHUDAfterHeroDeathForPlayer:(SPPPlayer *)player {
    NSUInteger playerIndex = [self.players indexOfObject:player];
    
    // Fade out the relevant heart - one-based livesLeft has already been decremented.
    NSUInteger heartNumber = player.livesLeft;
    
    NSArray *heartArray = self.hudLifeHeartArrays[playerIndex];
    SKSpriteNode *heart = heartArray[heartNumber];
    [heart runAction:[SKAction fadeAlphaTo:0.0 duration:3.0f]];
}

- (void)addToScore:(uint32_t)amount afterEnemyKillWithProjectile:(SKNode *)projectile {
    
    SPPPlayer *player = projectile.userData[kPlayer]; //kPlayer
    
    player.score += amount;
    
    [self updateHUDForPlayer:player];
}

#pragma mark - Loop Update
- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = kMinTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
        self.worldMovedForUpdate = YES;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
#if TARGET_OS_IPHONE
    SPPPlayer *defaultPlayer = self.defaultPlayer;
    SPPHeroCharacter *hero = nil;
    if ([self.heroes count] > 0) {
        hero = defaultPlayer.hero;
    }
    
    if (![hero isDying]) {
        if (!CGPointEqualToPoint(defaultPlayer.targetLocation, CGPointZero)) {
            if (defaultPlayer.fireAction) {
                [hero faceTo:defaultPlayer.targetLocation];
            }
            
            if (defaultPlayer.moveRequested) {
                if (!CGPointEqualToPoint(defaultPlayer.targetLocation, hero.position)) {
                    [hero moveTowards:defaultPlayer.targetLocation withTimeInterval:timeSinceLast];
                } else {
                    defaultPlayer.moveRequested = NO;
                }
            }
        }
    }
#endif
    
    for (SPPPlayer *player in self.players) {
        if ((id)player == [NSNull null]) {
            continue;
        }
        
        SPPHeroCharacter *hero = player.hero;
        if (!hero || [hero isDying]) {
            continue;
        }
        
        // heroMoveDirection is used by game controllers.
        CGPoint heroMoveDirection = player.heroMoveDirection;
        if (hypotf(heroMoveDirection.x, heroMoveDirection.y) > 0.0f) {
            [hero moveInDirection:heroMoveDirection withTimeInterval:timeSinceLast];
        }
        else {
            if (player.moveForward) {
                [hero move:SPPMoveDirectionForward withTimeInterval:timeSinceLast];
            } else if (player.moveBack) {
                [hero move:SPPMoveDirectionBack withTimeInterval:timeSinceLast];
            }
            
            if (player.moveLeft) {
                [hero move:SPPMoveDirectionLeft withTimeInterval:timeSinceLast];
            } else if (player.moveRight) {
                [hero move:SPPMoveDirectionRight withTimeInterval:timeSinceLast];
            }
        }
        
        if (player.fireAction) {
            [hero performAttackAction];
        }
    }
}

- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLast {
    // Overridden by subclasses.
}

- (void)didSimulatePhysics {
    SPPHeroCharacter *defaultHero = self.defaultPlayer.hero;
    
    // Move the world relative to the default player position.
    if (defaultHero) {
        CGPoint heroPosition = defaultHero.position;
        CGPoint worldPos = self.world.position;
        CGFloat yCoordinate = worldPos.y + heroPosition.y;
        if (yCoordinate < kMinHeroToEdgeDistance) {
            worldPos.y = worldPos.y - yCoordinate + kMinHeroToEdgeDistance;
            self.worldMovedForUpdate = YES;
        } else if (yCoordinate > (self.frame.size.height - kMinHeroToEdgeDistance)) {
            worldPos.y = worldPos.y + (self.frame.size.height - yCoordinate) - kMinHeroToEdgeDistance;
            self.worldMovedForUpdate = YES;
        }
        
        CGFloat xCoordinate = worldPos.x + heroPosition.x;
        if (xCoordinate < kMinHeroToEdgeDistance) {
            worldPos.x = worldPos.x - xCoordinate + kMinHeroToEdgeDistance;
            self.worldMovedForUpdate = YES;
        } else if (xCoordinate > (self.frame.size.width - kMinHeroToEdgeDistance)) {
            worldPos.x = worldPos.x + (self.frame.size.width - xCoordinate) - kMinHeroToEdgeDistance;
            self.worldMovedForUpdate = YES;
        }
        self.world.position = worldPos;
    }
    
    // Using performSelector:withObject:afterDelay: withg a delay of 0.0 means that the selector call occurs after
    // the current pass through the run loop.
    // This means the property will be cleared after the subclass implementation of didSimluatePhysics completes.
    [self performSelector:@selector(clearWorldMoved) withObject:nil afterDelay:0.0f];
}

- (void)clearWorldMoved {
    self.worldMovedForUpdate = NO;
}

#if TARGET_OS_IPHONE
#pragma mark - Event Handling - iOS
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *heroes = self.heroes;
    if ([heroes count] < 1) {
        return;
    }
    UITouch *touch = [touches anyObject];
    
    SPPPlayer *defaultPlayer = self.defaultPlayer;
    if (defaultPlayer.movementTouch) {
        return;
    }
    
    defaultPlayer.targetLocation = [touch locationInNode:defaultPlayer.hero.parent];
    
    BOOL wantsAttack = NO;
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    for (SKNode *node in nodes) {
        if (node.physicsBody.categoryBitMask & (SPPColliderTypeCave | SPPColliderTypeGoblinOrBoss)) {
            wantsAttack = YES;
        }
    }
    
    defaultPlayer.fireAction = wantsAttack;
    defaultPlayer.moveRequested = !wantsAttack;
    defaultPlayer.movementTouch = touch;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *heroes = self.heroes;
    if ([heroes count] < 1) {
        return;
    }
    SPPPlayer *defaultPlayer = self.defaultPlayer;
    UITouch *touch = defaultPlayer.movementTouch;
    if ([touches containsObject:touch]) {
        defaultPlayer.targetLocation = [touch locationInNode:defaultPlayer.hero.parent];
        if (!defaultPlayer.fireAction) {
            defaultPlayer.moveRequested = YES;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *heroes = self.heroes;
    if ([heroes count] < 1) {
        return;
    }
    SPPPlayer *defaultPlayer = self.defaultPlayer;
    UITouch *touch = defaultPlayer.movementTouch;
    
    if ([touches containsObject:touch]) {
        defaultPlayer.movementTouch = nil;
        defaultPlayer.fireAction = NO;
    }
}
#endif

@end
