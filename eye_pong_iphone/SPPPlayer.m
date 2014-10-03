//
//  SPPPlayer.m
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import "SPPPlayer.h"

@implementation SPPPlayer

#pragma mark - Initialization
- (id)init {
    
    self = [super init];
    
    if (self) {
        _livesLeft = kStartLives;
        /* Make a Custom USER-Modded Class */
        _heroClass = NSClassFromString(@"SPPPadle");
    }
    return self;
}

@end
