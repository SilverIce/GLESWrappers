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

@property (nonatomic, retain)   GLTextureFaceRef    *colorTexture;
@property (nonatomic, retain)   GLTextureFaceRef    *depthTexture;
@property (nonatomic, retain)   GLTextureFaceRef    *stencilTexture;

// read RGBA UNSIGNED_BYTE pixels
- (void)readRGBAUBytePixels:(GLvoid *)pixels fromRect:(GLRect)rect;

+ (id)objectWithColorAttachment:(GLTextureFaceRef *)colorFace;

@end

// Wraps current bound framebuffer that was created out of our gl wrapper system.
// Useful when pure gl code co-works with wrapped one.
// Unsafe since it does not own framebuffer.
// Returns nil if no framebuffer bound.
@interface GLExternalFramebuffer : GLNestedObject

+ (id)object;

@end
