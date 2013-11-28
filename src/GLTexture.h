//
//  GLTexture.h
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

// use cases:

// bind & put something into texture
// bind onto less active slot & do somthing & restore previous

// bind -> make it current texture -

// TODO:
// sometimes we'll have a huge texture and we'll want to free memory as fast as possible

typedef struct {
    GLuint width, height;
} GLSizeI;

typedef struct {
    GLuint  width;
    GLuint  height;
    GLvoid  *data;
} GLPixelData;

typedef NS_ENUM(GLenum, GLInternalFormat) {
    GLInternalFormatRGBA            = GL_RGBA,
    GLInternalFormatRGB             = GL_RGB,
    GLInternalFormatLuminance       = GL_LUMINANCE,
    GLInternalFormatLuminanceAlpha  = GL_LUMINANCE_ALPHA,
};

typedef NS_ENUM(GLenum, GLTextureMinFilter) {
    GLTextureMinFilterNearest               = GL_NEAREST,
    GLTextureMinFilterLinear                = GL_LINEAR,
    GLTextureMinFilterNearestMipmapNearest  = GL_NEAREST_MIPMAP_NEAREST,
    GLTextureMinFilterNearestMipmapLinear   = GL_NEAREST_MIPMAP_LINEAR,
    GLTextureMinFilterLinearMipmapNearest   = GL_LINEAR_MIPMAP_NEAREST,
    GLTextureMinFilterLinearMipmapLinear    = GL_LINEAR_MIPMAP_LINEAR,
};

typedef NS_ENUM(GLenum, GLTextureMagFilter) {
    GLTextureMagFilterNearest   = GL_NEAREST,
    GLTextureMagFilterLinear    = GL_LINEAR,
};

typedef NS_ENUM(GLenum, GLTextureWrap) {
    GLTextureWrapClampToEdge    = GL_CLAMP_TO_EDGE,
    GLTextureWrapRepeat         = GL_REPEAT,
    GLTextureWrapMirroredRepeat = GL_MIRRORED_REPEAT,
};

// Base class that implements bind, unbind behaviour.
@interface GLTexture : GLObject

@property (nonatomic, assign)   GLTextureMinFilter      minFilter;
@property (nonatomic, assign)   GLTextureMagFilter      magFilter;

@property (nonatomic, assign)   GLTextureWrap           wrapS;
@property (nonatomic, assign)   GLTextureWrap           wrapT;

- (GLuint)width;
- (GLuint)height;
- (GLSizeI)size;

- (void)bind;
- (void)unbind;
// ensures that texture is belongs to some slot
- (void)ensureActive;
// returns -1 if inactive
- (GLint)slotIndex;

+ (id)objectAs2DTextureWithSize:(GLSizeI)size
                 internalFormat:(GLInternalFormat)internalFormat   //
                           type:(GLenum)type
                         pixels:(const GLvoid *)pixels;            // can be NULL

// should not be here as method references coregraphics framework methods. just for testing
+ (id)objectWithImagePath:(NSString *)path;

@end

@interface GLTexture ()
// private api:
@property (nonatomic, assign)   GLuint              useCount;
@property (nonatomic, assign)   GLSlot              *slot;
@end


