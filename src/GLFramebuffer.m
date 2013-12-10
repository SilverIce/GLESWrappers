//
//  GLFramebuffer.m
//  openGLES Wrappers
//
//  Created by denis on 11/15/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLFramebuffer.h"
#import "EAGLContext+GLContext.h"

@interface GLFramebuffer ()
@property (nonatomic, retain)   GLTextureFaceRef    *colorTexturePtr;
@property (nonatomic, retain)   GLTextureFaceRef    *depthTexturePtr;
@property (nonatomic, retain)   GLTextureFaceRef    *stencilTexturePtr;
@end

@implementation GLFramebuffer

@dynamic colorTexture;
@dynamic depthTexture;
@dynamic stencilTexture;

+ (id)objectWithColorAttachment:(GLTextureFaceRef *)colorFace {
    GLFramebuffer *me = [self object];
    me.colorTexture = colorFace;
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

static void _GLFramebufferAttachTexture(GLFramebuffer *me, GLTextureFaceRef **field,
                                        GLTextureFaceRef *face, GLFramebufferAttachment point)
{
    if (*field != face) {
        [*field release];
        *field = [face retain];
        
        [me bind];
        
        if (face) {
            glFramebufferTexture2D(GL_FRAMEBUFFER,
                                   point,
                                   face.face,
                                   face.texture.uId,
                                   face.level);
        } else {
            glFramebufferTexture2D(GL_FRAMEBUFFER,
                                   point,
                                   0,
                                   0,
                                   0);
        }
        
        [me unbind];
    }
}

- (GLTextureFaceRef *)colorTexture {
    return _colorTexturePtr;
}

- (GLTextureFaceRef *)depthTexture {
    return _depthTexturePtr;
}

- (GLTextureFaceRef *)stencilTexture {
    return _stencilTexturePtr;
}

- (void)setColorTexture:(GLTextureFaceRef *)colorTexture {
    _GLFramebufferAttachTexture(self, &_colorTexturePtr, colorTexture, GLFramebufferAttachmentColor);
}

- (void)setDepthTexture:(GLTextureFaceRef *)depthTexture {
    _GLFramebufferAttachTexture(self, &_depthTexturePtr, depthTexture, GLFramebufferAttachmentDepth);
}

- (void)setStencilTexture:(GLTextureFaceRef *)stencilTexture {
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
