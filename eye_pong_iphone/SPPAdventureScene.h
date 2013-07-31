//
//  SPPAdventureScene.h
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import "SPPMultiplayerLayeredCharacterScene.h"

#define kWorldTileDivisor 32  // number of tiles
#define kWorldSize 4096       // pixel size of world (square)
#define kWorldTileSize (kWorldSize / kWorldTileDivisor)

#define kWorldCenter 2048

#define kLevelMapSize 256    // pixel size of level map (square)
#define kLevelMapDivisor (kWorldSize / kLevelMapSize)

typedef enum : uint8_t {
    SPPHeroTypePaddle,
    SPPHeroTypeCustomPaddle
} SPPHeroType;

@class SPPHeroCharacter;

@interface SPPAdventureScene : SPPMultiplayerLayeredCharacterScene

- (void)startLevel;
- (void)setDefaultPlayerHeroType:(SPPHeroType)heroType;

@end
