//
//  GLFramebuffer.m
//  openGLES Wrappers
//
//  Created by denis on 11/15/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLFramebuffer.h"
#import "GLContext+Private.h"
#import "EAGLContext+GLContext.h"

@interface GLFramebuffer ()
@property (nonatomic, retain)   id<GLFramebufferRenderTarget>    colorTexturePtr;
@property (nonatomic, retain)   id<GLFramebufferRenderTarget>    depthTexturePtr;
@property (nonatomic, retain)   id<GLFramebufferRenderTarget>    stencilTexturePtr;
@end

@implementation GLFramebuffer

@dynamic colorTarget;
@dynamic depthTarget;
@dynamic stencilTarget;

+ (id)objectWithColorAttachment:(id<GLFramebufferRenderTarget>)colorFace {
    GLFramebuffer *me = [self object];
    me.colorTarget = colorFace;
    return me;
}

#pragma mark -
#pragma mark Inialization and Deallocation

- (void)dealloc {
    // do not detach textures because it requires binding
    self.colorTexturePtr = nil;
    self.depthTexturePtr = nil;
    self.stencilTexturePtr = nil;
    
    glDeleteFramebuffers(1, &_uId);
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        glGenFramebuffers(1, &_uId);
    }
    return self;
}

#pragma mark -
#pragma mark GLObject

- (void)internalBind:(BOOL)bind {
    glBindFramebuffer(GL_FRAMEBUFFER, bind ? self.uId : 0);
}

+ (GLObjectType)glType {
    return GLObjectTypeFramebuffer;
}

#pragma mark -
#pragma mark Public

- (void)readRGBAUBytePixels:(GLvoid *)pixels fromRect:(GLRect)rect {
    [self bind];
    /*
     Only two combinations of format and type are accepted. The first is format RGBA and type UNSIGNED_BYTE.
     The second is an implementation-chosen format from among those defined in table 3.4, excluding formats LUMINANCE and LUMINANCE_ALPHA.
     The values of format and type for this format may be determined by calling GetIntegerv with the symbolic constants IMPLEMENTATION_COLOR_READ_FORMAT and IMPLEMENTATION_COLOR_READ_TYPE, respectively.
     */
    glReadPixels(rect.x, rect.y, rect.width, rect.height, GLInternalFormatRGBA, GLDataUByte, pixels);
    [self unbind];
}

static void _GLFramebufferAttachTexture(GLFramebuffer *me, id<GLFramebufferRenderTarget> *field,
                                        id<GLFramebufferRenderTarget> face, GLFramebufferAttachment point)
{
    if (*field != face) {
        [me bind];
        
        if (face) {
            [face internalAttach:YES
                     toFramebuffer:me
                           point:point];
        } else {
            [*field internalAttach:NO
                       toFramebuffer:me
                             point:point];
        }
        
        GLenum completeness = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (completeness != GL_FRAMEBUFFER_COMPLETE) {
            [NSException raise:NSInternalInconsistencyException
                        format:@"framebuffer incomplete status 0x%x", completeness];
        }
        
        [me unbind];
        
        [*field release];
        *field = [face retain];
    }
}

- (id<GLFramebufferRenderTarget>)colorTarget {
    return _colorTexturePtr;
}

- (id<GLFramebufferRenderTarget>)depthTarget {
    return _depthTexturePtr;
}

- (id<GLFramebufferRenderTarget>)stencilTarget {
    return _stencilTexturePtr;
}

- (void)setColorTarget:(id<GLFramebufferRenderTarget>)colorTexture {
    _GLFramebufferAttachTexture(self, &_colorTexturePtr, colorTexture, GLFramebufferAttachmentColor);
}

- (void)setDepthTarget:(id<GLFramebufferRenderTarget>)depthTexture {
    _GLFramebufferAttachTexture(self, &_depthTexturePtr, depthTexture, GLFramebufferAttachmentDepth);
}

- (void)setStencilTarget:(id<GLFramebufferRenderTarget>)stencilTexture {
    _GLFramebufferAttachTexture(self, &_stencilTexturePtr, stencilTexture, GLFramebufferAttachmentStencil);
}

@end

@implementation GLExternalFramebuffer

+ (id)object {
    GLint fboCurrent;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &fboCurrent);
    
    if (fboCurrent == 0) {
        return nil;
    }
    
    GLContext *context = [[EAGLContext currentContext] context];
    assert(!context.framebuffer || context.framebuffer.uId != fboCurrent);
    
    GLExternalFramebuffer *me = [[self new] autorelease];
    if (me) {
        me.uId = fboCurrent;
        [me bind];
    }
    
    return me;
}

- (void)internalBind:(BOOL)bind {
    glBindFramebuffer(GL_FRAMEBUFFER, bind ? self.uId : 0);
}

+ (GLObjectType)glType {
    return GLObjectTypeFramebuffer;
}

@end
