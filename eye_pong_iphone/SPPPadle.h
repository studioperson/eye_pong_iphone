//
//  SPPPadle.h
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import "SPPHeroCharacter.h"

@interface SPPPadle : SPPHeroCharacter

@property (nonatomic, weak) SPPPlayer *player;

- (id)initAtPosition:(CGPoint)position withPlayer:(SPPPlayer *)player;

@end
