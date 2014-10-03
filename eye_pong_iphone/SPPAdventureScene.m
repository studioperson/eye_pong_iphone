//
//  SPPAdventureScene.m
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import "SPPAdventureScene.h"
#import "SPPGraphicsUtilities.h"
#import "SPPCharacter.h"
#import "SPPPadle.h"//warrior or Archer type
                    //cave,boss, goblin
#import "SPPPlayer.h"

@interface SPPAdventureScene () <SKPhysicsContactDelegate>

@property (nonatomic) NSMutableArray *players; //array of player obj or NSNull for no players
@property (nonatomic) SPPPlayer *defaultPlayer; //player 1 controlled by touch/controller

@property (nonatomic, readwrite) NSMutableArray *heroes; //our fearless players

@end

@implementation SPPAdventureScene

@synthesize heroes = _heroes;

-(id)initWithSize:(CGSize)size{
    self = [super initWithSize:size];
    if (self){
        _heroes = [[NSMutableArray alloc]init];
        
        [self buildWorld];
        
        //center the camera on hero spawn point
        CGPoint startPosition = self.defaultSpawnPoint;
        [self centerWorldOnPosition:startPosition];
    }
    return self;
}

-(void)dealloc{
    free(_levelMap);
    _levelMap = NULL;
}

#pragma mark - World Building
-(void)buildWorld{
#ifdef DEBUG
    NSLog(@"Building World");
#endif
    
    // Config Physics for the World.
    self.physicsWorld.gravity = CGPointZero; //no gravity!
    self.physicsWorld.contactDelegate = self;
    //load tiles, spawnpoints, trees(?), collision walls
    
    
}


- (void)addBackgroundTiles {
    // Tiles should already have been pre-loaded in +loadSceneAssets.
    for (SKNode *tileNode in [self backgroundTiles]) {
        [self addNode:tileNode atWorldLayer:SPPWorldLayerGround];
    }
}

#pragma mark - Level Start
- (void)startLevel {
    SPPHeroCharacter *hero = [self addHeroForPlayer:self.defaultPlayer];
    
#ifdef MOVE_NEAR_TO_BOSS
    CGPoint bossPosition = self.levelBoss.position; // set earlier from buildWorld in addSpawnPoints
    bossPosition.x += 128;
    bossPosition.y += 512;
    hero.position = bossPosition;
#endif
    
    [self centerWorldOnCharacter:hero];
}

#pragma mark - Heroes
- (void)setDefaultPlayerHeroType:(SPPHeroType)heroType {
    switch (heroType) {
        case SPPHeroTypePaddle:
            self.defaultPlayer.heroClass = [SPPPaddle class];
            break;
            
        case SPPHeroTypeCustomPaddle:
            self.defaultPlayer.heroClass = [SPPCustomPaddle class];
            break;
    }
}

- (void)heroWasKilled:(SPPHeroCharacter *)hero {
    for (APACave *cave in self.goblinCaves) {
        [cave stopGoblinsFromTargettingHero:hero];
    }
    
    [super heroWasKilled:hero];
}

#pragma mark - Shared Assets
+ (void)loadSceneAssets {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Environment"];
    
    // Load archived emitters and create copyable sprites.
    sSharedProjectileSparkEmitter = [SKEmitterNode apa_emitterNodeWithEmitterNamed:@"ProjectileSplat"];
    sSharedSpawnEmitter = [SKEmitterNode apa_emitterNodeWithEmitterNamed:@"Spawn"];
    
    sSharedSmallTree = [[APATree alloc] initWithSprites:@[
                                                          [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"small_tree_base.png"]],
                                                          [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"small_tree_middle.png"]],
                                                          [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"small_tree_top.png"]]] usingOffset:25.0f];
    sSharedBigTree = [[APATree alloc] initWithSprites:@[
                                                        [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"big_tree_base.png"]],
                                                        [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"big_tree_middle.png"]],
                                                        [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"big_tree_top.png"]]] usingOffset:150.0f];
    sSharedBigTree.fadeAlpha = YES;
    sSharedLeafEmitterA = [SKEmitterNode apa_emitterNodeWithEmitterNamed:@"Leaves_01"];
    sSharedLeafEmitterB = [SKEmitterNode apa_emitterNodeWithEmitterNamed:@"Leaves_02"];
    
    // Load the tiles that make up the ground layer.
    [self loadWorldTiles];
    
    // Load assets for all the sprites within this scene.
    [APACave loadSharedAssets];
    [APAArcher loadSharedAssets];
    [APAWarrior loadSharedAssets];
    [APAGoblin loadSharedAssets];
    [APABoss loadSharedAssets];
}

+ (void)loadWorldTiles {
    NSLog(@"Loading world tiles");
    NSDate *startDate = [NSDate date];
    
    SKTextureAtlas *tileAtlas = [SKTextureAtlas atlasNamed:@"Tiles"];
    
    sBackgroundTiles = [[NSMutableArray alloc] initWithCapacity:1024];
    for (int y = 0; y < kWorldTileDivisor; y++) {
        for (int x = 0; x < kWorldTileDivisor; x++) {
            int tileNumber = (y * kWorldTileDivisor) + x;
            SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithTexture:[tileAtlas textureNamed:[NSString stringWithFormat:@"tile%d.png", tileNumber]]];
            CGPoint position = CGPointMake((x * kWorldTileSize) - kWorldCenter,
                                           (kWorldSize - (y * kWorldTileSize)) - kWorldCenter);
            tileNode.position = position;
            tileNode.zPosition = 1.0f;
            tileNode.blendMode = SKBlendModeReplace;
            [(NSMutableArray *)sBackgroundTiles addObject:tileNode];
        }
    }
    NSLog(@"Loaded all world tiles in %f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
}

+ (void)releaseSceneAssets {
    // Get rid of everything unique to this scene (but not the characters, which might appear in other scenes).
    sBackgroundTiles = nil;
    sSharedProjectileSparkEmitter = nil;
    sSharedSpawnEmitter = nil;
    sSharedLeafEmitterA = nil;
    sSharedLeafEmitterB = nil;
}

static SKEmitterNode *sSharedProjectileSparkEmitter = nil;
- (SKEmitterNode *)sharedProjectileSparkEmitter {
    return sSharedProjectileSparkEmitter;
}

static SKEmitterNode *sSharedSpawnEmitter = nil;
- (SKEmitterNode *)sharedSpawnEmitter {
    return sSharedSpawnEmitter;
}

static APATree *sSharedSmallTree = nil;
- (APATree *)sharedSmallTree {
    return sSharedSmallTree;
}

static APATree *sSharedBigTree = nil;
- (APATree *)sharedBigTree {
    return sSharedBigTree;
}

static SKEmitterNode *sSharedLeafEmitterA = nil;
- (SKEmitterNode *)sharedLeafEmitterA {
    return sSharedLeafEmitterA;
}

static SKEmitterNode *sSharedLeafEmitterB = nil;
- (SKEmitterNode *)sharedLeafEmitterB {
    return sSharedLeafEmitterB;
}

static NSArray *sBackgroundTiles = nil;
- (NSArray *)backgroundTiles {
    return sBackgroundTiles;
}

@end
