//
//  SPPAdventureScene.m
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import "SPPAdventureScene.h"
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
        [self addNode:tileNode atWorldLayer:APAWorldLayerGround];
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

@end
