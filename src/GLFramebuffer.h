//
//  GLFramebuffer.h
//  openGLES Wrappers
//
//  Created by denis on 11/15/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

typedef NS_ENUM(GLenum, GLFramebufferAttachment) {
    GLFramebufferAttachmentColor    = GL_COLOR_ATTACHMENT0,
    GLFramebufferAttachmentDepth    = GL_DEPTH_ATTACHMENT,
    GLFramebufferAttachmentStencil  = GL_STENCIL_ATTACHMENT,
};

@protocol GLFramebufferRenderTarget <NSObject>
@required
- (void)internalAttach:(BOOL)attach
         toFramebuffer:(GLFramebuffer *)framebuffer
                 point:(GLFramebufferAttachment)attachmentPoint;

@end

/**
 *  Redirects drawing output onto attached rendering targets
 */
@interface GLFramebuffer : GLNestedObject

@property (nonatomic, retain)   id<GLFramebufferRenderTarget>    colorTarget;
@property (nonatomic, retain)   id<GLFramebufferRenderTarget>    depthTarget;
@property (nonatomic, retain)   id<GLFramebufferRenderTarget>    stencilTarget;

// read RGBA UNSIGNED_BYTE pixels
- (void)readRGBAUBytePixels:(GLvoid *)pixels fromRect:(GLRect)rect;

+ (id)objectWithColorAttachment:(id<GLFramebufferRenderTarget>)colorFace;

@end

/**
 *  Wraps current bound framebuffer that was created out of our gl wrapper system.
 *  Useful when pure gl code co-works with wrapped one.
 *  Unsafe since it does not own framebuffer.
 *  Returns nil if no framebuffer bound.
 */
@interface GLExternalFramebuffer : GLNestedObject

+ (id)object;

@end
