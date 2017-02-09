//
//  PBJCoreImageView.h
//  Vision
//
//  Created by Josh Benjamin on 2/10/17.
//  Copyright © 2017 Patrick Piemonte. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PBJCoreImageView : GLKView
@property (nonatomic) CIImage *image;

- (void)setImage:(CIImage *)image withDimensions:(CMVideoDimensions)dimensions;
@end
