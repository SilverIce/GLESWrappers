//
//  GLFramebuffer.m
//  openGLES Wrappers
//
//  Created by denis on 11/15/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLFramebuffer.h"

@implementation GLFramebuffer

- (void)dealloc {
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

- (void)attachTexture:(GLTexture *)texture {
    assert(texture);
    
    [self bind];
    
    /*
     texture must name an existing cube map texture and textarget must be one of: TEXTURE_CUBE_MAP_POSITIVE_X, TEXTURE_CUBE_MAP_POSITIVE_Y,
     TEXTURE_CUBE_MAP_POSITIVE_Z, TEXTURE_CUBE_MAP_NEGATIVE_X, TEXTURE_CUBE_MAP_NEGATIVE_Y, or TEXTURE_CUBE_MAP_NEGATIVE_Z
     
     or
     
     If texture is not zero, then textarget must be one of TEXTURE_2D, TEXTURE_CUBE_MAP_POSITIVE_X, TEXTURE_CUBE_MAP_POSITIVE_Y,
     TEXTURE_CUBE_MAP_POSITIVE_Z, TEXTURE_CUBE_MAP_NEGATIVE_X, TEXTURE_CUBE_MAP_NEGATIVE_Y, or TEXTURE_CUBE_MAP_NEGATIVE_Z.
     */
    
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           texture.textureType,
                           texture.uId,
                           )
    
    [self unbind];
}

@end
