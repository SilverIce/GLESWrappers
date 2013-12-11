//
//  GLTexture.m
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLTexture.h"
#import "GLTexture+Private.h"
#import "GLContext+Private.h"

@interface GLTexture ()
@property (nonatomic, assign)   GLTextureType       textureType;
@property (nonatomic, assign)   GLSize             size;
@end

@implementation GLTexture

#pragma mark -
#pragma mark Constructors

+ (id)objectWithImageAtPath:(NSString *)path {
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
    
    GLTexture *me = [self objectAs2DTextureWithSize:(GLSize){width, height}
                                     internalFormat:GLInternalFormatRGBA
                                           dataType:GLDataUByte
                                             pixels:spriteData];
    
    [me bind];
    me.minFilter = GLTextureMinFilterNearest;
    [me unbind];
    
    free(spriteData);
    
    return me;
}

+ (id)objectAs2DTextureWithSize:(GLSize)size
                 internalFormat:(GLInternalFormat)internalFormat
                       dataType:(GLData)dataType
                         pixels:(const GLvoid *)pixels
{
    GLTexture *me = [[self new] autorelease];
    if (me) {
        me.textureType = GL_TEXTURE_2D;
        
        [me putImageAtFace:GLTextureFace2D
                  withSize:size
            internalFormat:internalFormat
                  dataType:dataType
                    pixels:pixels];
    }
    
    assert(me);
    return me;
}

#pragma mark -
#pragma mark Inialization and Deallocation

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

#pragma mark -
#pragma mark Accessors

- (GLuint)width {
    return self.size.width;
}

- (GLuint)height {
    return self.size.height;
}

static void _GLtextureValidateFace(GLTexture *texture, GLTextureFace face) {
    assert((face == GLTextureFace2D && texture.textureType == GL_TEXTURE_2D) ||
           (face != GLTextureFace2D && texture.textureType == GL_TEXTURE_CUBE_MAP));
}

- (void)putImageAtFace:(GLTextureFace)face
              withSize:(GLSize)size
        internalFormat:(GLInternalFormat)internalFormat
              dataType:(GLData)dataType
                pixels:(const GLvoid *)pixels
{
    _GLtextureValidateFace(self, face);
    
    [self bind];
    
    self.size = size;
    self.format = internalFormat;
    
    glTexImage2D(self.textureType,
                 0, // level
                 internalFormat,
                 size.width, size.height,
                 0, // border, not supported on GLES
                 internalFormat,
                 dataType,
                 pixels);
    
    [self unbind];
}

- (void)putSubImageAtFace:(GLTextureFace)face
                 withRect:(GLRect)rect
           internalFormat:(GLInternalFormat)internalFormat
                 dataType:(GLData)dataType
                   pixels:(const GLvoid *)pixels
{
    _GLtextureValidateFace(self, face);
    
    [self bind];
    
    self.format = internalFormat;
    
    glTexSubImage2D(face,
                    0,  // level
                    rect.x, rect.y, rect.width, rect.height,
                    internalFormat, dataType,
                    pixels);
    
    [self unbind];
}

- (GLTextureFaceRef *)referenceFace:(GLTextureFace)face
                              level:(GLint)level
{
    return [GLTextureFaceRef objectWithTexture:self
                                          face:face
                                         level:level];
}

#pragma mark -
#pragma mark Texture parameters

static void _GLTextureSetParam(GLTexture *texture, GLuint param, GLenum value, GLenum *field) {
    [texture bind];
    assertBound(texture);
    *field = value;
    glTexParameteri(texture.textureType, param, value);
    [texture unbind];
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
#pragma mark GLObject & other

+ (GLObjectType)glType {
    return GLObjectTypeTexture2D;
}

- (BOOL)isBound {
    return [self.context.activeSlot activeObjectOfClass:self.glType] == self;
}

- (void)internalBind:(BOOL)bind {
    glBindTexture(self.textureType, bind ? self.uId : 0);
}

- (void)bind {
    //assert(self.isBound == NO);
    
    [self.context _bindTexture:self];
    [self.context.objectSet setActiveObject:self];
}

- (void)unbind {
    //assert(self.isBound && self.nestedBound == YES);
    
    // bind previous object
    
    GLTexture *prev = (GLTexture *)[self.context.objectSet resetActiveObject:self];
    
    // no need unbind current texture - context's activateTexture method does it if required
    
    if (prev) {
        assert(prev.glType == self.glType);
        
        [self.context _bindTexture:prev];
    } else {
        ;
    }
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

@end

@implementation GLTextureCube

+ (GLObjectType)glType {
    return GLObjectTypeTextureCubemap;
}

@end

@interface GLTextureFaceRef ()
@property (nonatomic, retain)   GLTexture           *texture;
@property (nonatomic, assign)   GLTextureFace       face;
@property (nonatomic, assign)   GLint               level;
@end

@implementation GLTextureFaceRef

+ (id)objectWithTexture:(GLTexture *)texture
                   face:(GLTextureFace)face
                  level:(GLint)level
{
    assert(texture);
    _GLtextureValidateFace(texture, face);
    
    GLTextureFaceRef *me = [[self new] autorelease];
    if (me) {
        me.texture = texture;
        me.face = face;
        me.level = level;
    }
    
    return me;
}

- (void)dealloc {
    self.texture = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark GLFramebufferRenderTarget

- (void)internalAttach:(BOOL)attach
           framebuffer:(GLFramebuffer *)framebuffer
               toPoint:(GLFramebufferAttachment)attachmentPoint
{
    if (attach) {
        glFramebufferTexture2D(GL_FRAMEBUFFER,
                               attachmentPoint,
                               self.face,
                               self.texture.uId,
                               self.level);
    } else {
        glFramebufferTexture2D(GL_FRAMEBUFFER,
                               attachmentPoint,
                               0,
                               0,
                               0);
    }
}

@end
