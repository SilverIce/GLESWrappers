//
//  GLRenderbuffer.h
//  Wrapper
//
//  Created by Denis Halabuzar on 12/11/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import "GLContext.h"
#import "GLFramebuffer.h"

@interface GLRenderbuffer : GLNestedObject <GLFramebufferRenderTarget>
- (GLInternalFormat)format;
- (GLSize)size;

- (void)setFormat:(GLInternalFormat)format
             size:(GLSize)size;

+ (id)objectWithInternalFormat:(GLInternalFormat)format
                          size:(GLSize)size;

@end
