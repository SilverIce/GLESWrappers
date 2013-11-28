//
//  GLTexture.m
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLTexture.h"

@interface GLTexture ()
@property (nonatomic, assign)   GLuint      textureType;
@property (nonatomic, assign)   GLSizeI     size;
@end

@implementation GLTexture


+ (id)objectWithImagePath:(NSString *)path {
    NSString *res = [[NSBundle mainBundle] pathForResource:path
                                                    ofType:nil];

    UIImage *img = [UIImage imageWithContentsOfFile:res];
    assert(img);
    CGImageRef image = img.CGImage;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), image);
    
    CGContextRelease(spriteContext);
    
    GLTexture *me = [self objectAs2DTextureWithSize:(GLSizeI){width, height}
                                     internalFormat:GLInternalFormatRGBA
                                               type:GL_UNSIGNED_BYTE
                                             pixels:spriteData];
    
    [me bind];
    me.minFilter = GLTextureMinFilterNearest;
    
    free(spriteData);
    
    return me;
}

+ (id)objectAs2DTextureWithSize:(GLSizeI)size
                 internalFormat:(GLInternalFormat)internalFormat
                           type:(GLenum)type
                         pixels:(const GLvoid *)pixels
{
    GLTexture *me = [[self new] autorelease];
    if (me) {
        me.size = size;
        me.textureType = GL_TEXTURE_2D;
        
        [me ensureActive];
        
        glTexImage2D(me.textureType,
                     0, // level
                     internalFormat,
                     size.width, size.height,
                     0, // border, not supported on GLES
                     internalFormat,
                     type,
                     pixels);
    }
    
    assert(me);
    return me;
}

- (void)dealloc {
    glDeleteTextures(1, &_uId);
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        glGenTextures(1, &_uId);
    }
    return self;
}

- (GLuint)width {
    return self.size.width;
}

- (GLuint)height {
    return self.size.height;
}

- (void)ensureActive {
    [self.context activateTexture:self];
}

- (GLint)slotIndex {
    if (self.slot) {
        return self.slot.slotIdx;
    }
    
    return -1;
}

#pragma mark -
#pragma mark Texture parameters

static void _GLTextureSetParam(GLTexture *texture, GLuint param, GLenum value, GLenum *field) {
    assertBound(texture);
    *field = value;
    glTexParameteri(texture.textureType, param, value);
}

- (void)setMinFilter:(GLTextureMinFilter)filter {
    _GLTextureSetParam(self, GL_TEXTURE_MIN_FILTER, filter, &_minFilter);
}

- (void)setMagFilter:(GLTextureMagFilter)magFilter {
    _GLTextureSetParam(self, GL_TEXTURE_MAG_FILTER, magFilter, &_magFilter);
}

- (void)setWrapS:(GLTextureWrap)wrapS {
    _GLTextureSetParam(self, GL_TEXTURE_WRAP_S, wrapS, &_wrapS);
}

- (void)setWrapT:(GLTextureWrap)wrapT {
    _GLTextureSetParam(self, GL_TEXTURE_WRAP_T, wrapT, &_wrapT);
}

#pragma mark -
#pragma mark GLObject

- (void)bind {
    [self.context bindTexture:self];
}

- (void)unbind {
    // nothing to do
}

- (BOOL)isBound {
    return self.slot && self.slot == self.context.activeSlot;
}

- (void)internalBind:(BOOL)bind {
    glBindTexture(self.textureType, bind ? self.uId : 0);
}

@end
