//
//  PBJCoreImageView.m
//  Vision
//
//  Created by Josh Benjamin on 2/10/17.
//  Copyright © 2017 Patrick Piemonte. All rights reserved.
//

#import "PBJCoreImageView.h"
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PBJCoreImageView ()
{
    CIContext *_context;
    CMVideoDimensions _currentVideoDimensions;
}
@end

@implementation PBJCoreImageView
@synthesize image = _image;
- (void)setImage:(CIImage *)image withDimensions:(CMVideoDimensions)dimensions
{
    _image = image;
    _currentVideoDimensions = dimensions;
    [self display];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        return [self initWithFrame:frame context:eaglContext];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame context:(nonnull EAGLContext *)context
{
    self = [super initWithFrame:frame context:context];
    if (self) {
        _context = [CIContext contextWithEAGLContext:context];
        self.enableSetNeedsDisplay = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGRect sourceExtent = _image.extent;
    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    
    CGFloat previewAspect = self.bounds.size.width  / self.bounds.size.height;
    
    // To maintain the aspect radio of the screen size, we clip the video image
    CGRect drawRect = self.image.extent;
    if (sourceAspect > previewAspect) {
        // use full height of the video image, and center crop the width
        drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
        drawRect.size.width = drawRect.size.height * previewAspect;
    } else {
        // use full width of the video image, and center crop the height
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspect;
    }
    
    CGFloat scale = 1.0;
    if(self.window)
        scale = [[[self window] screen] scale];
    CGRect destRect = CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(scale, scale));
    // PERF: if filter feature is worth keeping, move more from CPU to GPU
    // Metal ran at 60% CPU, compared to GLKView at 130% https://github.com/minimoog/CoreImageHelpers
    // Alternatively, see WWDC '12 Session 511 Core Image Techniques at 40:00
    // in order to map the sample buffer to a GL texture, create CIImage from the texture
    // Sample Code: https://github.com/bdudney/Experiments/AVCoreImageIntegration
    // and see http://stackoverflow.com/questions/20975434/applying-cifilter-to-opengl-render-to-texture
    [_context drawImage:self.image inRect:destRect fromRect:drawRect];
}

@end
