//
//  SPPParallaxSprite.h
//  eye_pong_iphone
//
//  Created by Tony Person on 7/30/13.
//  Copyright (c) 2013 Tony Person. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SPPParallaxSprite : SKSpriteNode

@property (nonatomic) BOOL usesParallaxEffect;
@property (nonatomic) CGFloat virtualZRotation;

/* If initialized with this method, sprite is set up for parallax effect; otherwise, no parallax. */
- (id)initWithSprites:(NSArray *)sprites usingOffset:(CGFloat)offset;

- (void)updateOffset;

@end
