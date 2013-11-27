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

typedef enum {
    kGLRGBA            = GL_RGBA,
    kGLRGB             = GL_RGB,
    kGLLuminance       = GL_LUMINANCE,
    kGLLuminanceAlpha  = GL_LUMINANCE_ALPHA,
} GLInternalFormat;

// Base class that implements bind, unbind behaviour.
// Useless by itself.
@interface GLTexture : GLObject

@property (nonatomic, assign)   GLuint      minFilter;
@property (nonatomic, assign)   GLuint      magFilter;

- (GLuint)width;
- (GLuint)height;
- (GLSizeI)size;

- (void)bind;
- (void)unbind;
// ensures that texture is belongs to some slot
- (void)ensureActive;

+ (id)objectAs2DTextureWithSize:(GLSizeI)size
                 internalFormat:(GLInternalFormat)internalFormat   //
                           type:(GLenum)type
                         pixels:(const GLvoid *)pixels;            // can be NULL

@end

@interface GLTexture ()
// private api:
@property (nonatomic, assign)   GLuint              useCount;
@property (nonatomic, assign)   GLActiveObjects     *slot;
@end


