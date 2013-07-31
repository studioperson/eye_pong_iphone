//
//  SPPGraphicsUtilities.h
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

/* Generate a random float between 0.0f and 1.0f. */
#define SPP_RANDOM_0_1() (arc4random() / (float)(0xffffffffu))

/* The assets are all facing Y down, so offset by pi half to get into X right facing. */
#define SPP_POLAR_ADJUST(x) x + (M_PI * 0.5f)


/* Load an array of APADataMap or APATreeMap structures for the given map file name. */
void *SPPCreateDataMap(NSString *mapName);

/* Distance and coordinate utility functions. */
CGFloat SPPDistanceBetweenPoints(CGPoint first, CGPoint second);
CGFloat SPPRadiansBetweenPoints(CGPoint first, CGPoint second);
CGPoint SPPPointByAddingCGPoints(CGPoint first, CGPoint second);

/* Load the named frames in a texture atlas into an array of frames. */
NSArray *SPPLoadFramesFromAtlas(NSString *atlasName, NSString *baseFileName, int numberOfFrames);

/* Run the given emitter once, for duration. */
void SPPRunOneShotEmitter(SKEmitterNode *emitter, CGFloat duration);


/* Define structures that map exactly to 4 x 8-bit ARGB pixel data. */
#pragma pack(1)
typedef struct {
    uint8_t bossLocation, wall, goblinCaveLocation, heroSpawnLocation;
} SPPDataMap;

typedef struct {
    uint8_t unusedA, bigTreeLocation, smallTreeLocation, unusedB;
} APATreeMap;
#pragma pack()

typedef SPPDataMap *SPPDataMapRef;
typedef SPPTreeMap *SPPTreeMapRef;

/* Category on NSValue to make it easy to access the pointValue/CGPointValue from iOS and OS X. */
@interface NSValue (SPPAdventureAdditions)
- (CGPoint)spp_CGPointValue;
+ (instancetype)spp_valueWithCGPoint:(CGPoint)point;
@end

/* Category on SKEmitterNode to make it easy to load an emitter from a node file created by Xcode. */
@interface SKEmitterNode (SPPAdventureAdditions)
+ (instancetype)spp_emitterNodeWithEmitterNamed:(NSString *)emitterFileName;
@end
