//
//  GLFramebuffer.h
//  openGLES Wrappers
//
//  Created by denis on 11/15/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"
#import "GLTexture.h"

@interface GLFramebuffer : GLNestedObject

// read RGBA UNSIGNED_BYTE pixels
- (void)readRGBAUBytePixels:(GLvoid *)pixels fromRect:(GLRect)rect;

@end
