//
//  GLTexture.h
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"
#import "GLFramebuffer.h"

// TODO:
// sometimes we'll have a huge texture and we'll want to free memory as fast as possible

typedef struct {
    GLSize              size;
    GLInternalFormat    format;
    GLvoid              *data;
    GLData              dataType;
} GLPixelData;

typedef NS_ENUM(GLenum, GLTextureMinFilter) {
    GLTextureMinFilterNearest               = GL_NEAREST,
    GLTextureMinFilterLinear                = GL_LINEAR,
    // requires use of mipmap:
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


GLPixelData * GLPixelDataCreateFromImageAtPath(NSString *filePath);
void GLPixelDataFree(GLPixelData *pixelData);

@class GLTextureFaceRef;

// Base class that implements bind, unbind behaviour.
@interface GLTexture : GLObject

// per texture (not per texture face) paramenters
@property (nonatomic, assign)   GLTextureMinFilter      minFilter;
@property (nonatomic, assign)   GLTextureMagFilter      magFilter;
@property (nonatomic, assign)   GLTextureWrap           wrapS;
@property (nonatomic, assign)   GLTextureWrap           wrapT;

- (GLInternalFormat)format;
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

// fill specified texture area with pixels
- (void)putSubImageAtFace:(GLTextureFace)face
                 withRect:(GLRect)rect
                 dataType:(GLData)dataType
                   pixels:(const GLvoid *)pixels;

+ (id)objectAs2DTextureWithSize:(GLSize)size
                 internalFormat:(GLInternalFormat)internalFormat   //
                       dataType:(GLData)dataType
                         pixels:(const GLvoid *)pixels;            // can be NULL

/**
 *  Creates 2D texture containing bundled image at given path
 *
 *  @param path bundled image path
 *
 *  @return texture
 */
+ (id)objectWithImageAtPath:(NSString *)path;

@end

// 6-faced cubemap texture
@interface GLTextureCube : GLTexture
@end

// Strong texture reference
// References specific texture face & level
@interface GLTextureFaceRef : NSObject <GLFramebufferRenderTarget>
- (GLTexture *)texture;
- (GLTextureFace)face;
- (GLint)level;

+ (id)objectWithTexture:(GLTexture *)texture
                   face:(GLTextureFace)face
                  level:(GLint)level;

@end
