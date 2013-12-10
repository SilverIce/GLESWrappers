//
//  GLTexture.h
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

// TODO:
// sometimes we'll have a huge texture and we'll want to free memory as fast as possible

typedef struct {
    GLsizei width, height;
} GLSize;

typedef struct {
    GLint x, y;
} GLPoint;

typedef union {
    struct {
        GLPoint origin;
        GLSize size;
    };
    struct {
        GLint x, y;
        GLsizei width, height;
    };
} GLRect;

typedef struct {
    GLuint  width;
    GLuint  height;
    GLvoid  *data;
} GLPixelData;


typedef NS_ENUM(GLenum, GLTextureMinFilter) {
    GLTextureMinFilterNearest               = GL_NEAREST,
    GLTextureMinFilterLinear                = GL_LINEAR,
    GLTextureMinFilterNearestMipmapNearest  = GL_NEAREST_MIPMAP_NEAREST,
    GLTextureMinFilterNearestMipmapLinear   = GL_NEAREST_MIPMAP_LINEAR,
    GLTextureMinFilterLinearMipmapNearest   = GL_LINEAR_MIPMAP_NEAREST,
    GLTextureMinFilterLinearMipmapLinear    = GL_LINEAR_MIPMAP_LINEAR,
};

typedef NS_ENUM(GLenum, GLTextureType) {
    GLTextureType2D         = GL_TEXTURE_2D,
    GLTextureTypeCubemap    = GL_TEXTURE_CUBE_MAP,
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

typedef NS_ENUM(GLenum, GLTextureFace) {
    // A single 2d texture face
    GLTextureFace2D                 = GL_TEXTURE_2D,
    
    GLTextureFaceCubemapPositiveX   = GL_TEXTURE_CUBE_MAP_POSITIVE_X,
    GLTextureFaceCubemapPositiveY   = GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
    GLTextureFaceCubemapPositiveZ   = GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
    
    GLTextureFaceCubemapNegativeX   = GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
    GLTextureFaceCubemapNegativeY   = GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
    GLTextureFaceCubemapNegativeZ   = GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,
};

@class GLTextureFaceRef;

// Base class that implements bind, unbind behaviour.
@interface GLTexture : GLObject

// per texture (not per texture face) paramenters
@property (nonatomic, assign)   GLTextureMinFilter      minFilter;
@property (nonatomic, assign)   GLTextureMagFilter      magFilter;
@property (nonatomic, assign)   GLTextureWrap           wrapS;
@property (nonatomic, assign)   GLTextureWrap           wrapT;
@property (nonatomic, assign)   GLInternalFormat        format;

- (GLuint)width;
- (GLuint)height;
- (GLSize)size;
- (GLTextureType)textureType;

- (void)bind;
- (void)unbind;

// ensures that texture attached to slot
// Important: method clears texture object stack
- (void)ensureActive;
// returns -1 if not attached to slot
- (GLint)slotIndex;

// make new reference for specified face & level
- (GLTextureFaceRef *)referenceFace:(GLTextureFace)face
                              level:(GLint)level;

+ (id)objectAs2DTextureWithSize:(GLSize)size
                 internalFormat:(GLInternalFormat)internalFormat   //
                       dataType:(GLData)dataType
                         pixels:(const GLvoid *)pixels;            // can be NULL

// should not be here since method references coregraphics framework methods. just for testing
+ (id)objectWithImagePath:(NSString *)path;

@end

@interface GLTexture ()
// private api:
// a way to determine most used/active texture - how often it was activated
@property (nonatomic, assign)   GLuint              useCount;
@property (nonatomic, assign)   GLSlot              *slot;
@end

@interface GLTextureCube : GLTexture
@end

// Strong texture reference
// References specific texture face & level
@interface GLTextureFaceRef : NSObject
- (GLTexture *)texture;
- (GLTextureFace)face;
- (GLint)level;

+ (id)objectWithTexture:(GLTexture *)texture
                   face:(GLTextureFace)face
                  level:(GLint)level;

@end
