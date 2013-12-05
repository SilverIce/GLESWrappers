//
//  GLFramebuffer.m
//  openGLES Wrappers
//
//  Created by denis on 11/15/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLFramebuffer.h"

@interface GLFramebuffer ()
@property (nonatomic, retain)   GLTextureFaceRef    *colorTexture;
@property (nonatomic, retain)   GLTextureFaceRef    *depthTexture;
@property (nonatomic, retain)   GLTextureFaceRef    *stencilTexture;
@end

@implementation GLFramebuffer

#pragma mark -
#pragma mark Inialization and Deallocation

- (void)dealloc {
    self.colorTexture = nil;
    self.depthTexture = nil;
    self.stencilTexture = nil;
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
    glReadPixels(rect.x, rect.y, rect.width, rect.height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    [self unbind];
}

- (void)attachTextureFace:(GLTextureFaceRef *)face
                  toPoint:(GLFramebufferAttachment)point
{
    assert(face);
    
    [self bind];
    
    /*
     texture must name an existing cube map texture and textarget must be one of: TEXTURE_CUBE_MAP_POSITIVE_X, TEXTURE_CUBE_MAP_POSITIVE_Y,
     TEXTURE_CUBE_MAP_POSITIVE_Z, TEXTURE_CUBE_MAP_NEGATIVE_X, TEXTURE_CUBE_MAP_NEGATIVE_Y, or TEXTURE_CUBE_MAP_NEGATIVE_Z
     
     or
     
     If texture is not zero, then textarget must be one of TEXTURE_2D, TEXTURE_CUBE_MAP_POSITIVE_X, TEXTURE_CUBE_MAP_POSITIVE_Y,
     TEXTURE_CUBE_MAP_POSITIVE_Z, TEXTURE_CUBE_MAP_NEGATIVE_X, TEXTURE_CUBE_MAP_NEGATIVE_Y, or TEXTURE_CUBE_MAP_NEGATIVE_Z.
     */
    
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           point,
                           face.face,
                           face.texture.uId,
                           face.level);
    
    [self unbind];
}

- (void)detachTextureFromPoint:(GLFramebufferAttachment)point {
    [self bind];
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           point,
                           point,
                           0,
                           0);
    [self unbind];
}

@end
