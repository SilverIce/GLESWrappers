//
//  GLFramebuffer.h
//  openGLES Wrappers
//
//  Created by denis on 11/15/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

#import "GLTexture.h"

typedef NS_ENUM(GLenum, GLFramebufferAttachment) {
    GLFramebufferAttachmentColor    = GL_COLOR_ATTACHMENT0,
    GLFramebufferAttachmentDepth    = GL_DEPTH_ATTACHMENT,
    GLFramebufferAttachmentStencil  = GL_STENCIL_ATTACHMENT,
};

@interface GLFramebuffer : GLNestedObject

// read RGBA UNSIGNED_BYTE pixels
- (void)readRGBAUBytePixels:(GLvoid *)pixels fromRect:(GLRect)rect;

- (void)attachTexture:(GLTexture *)texture;

@end
