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

GLPixelData * GLPixelDataCreateFromImageAtPath(NSString *filePath) {
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    assert(img);
    CGImageRef image = img.CGImage;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    
    GLPixelData *spriteData = (GLPixelData *) calloc(sizeof(GLPixelData) + width * height * 4, 1);
    spriteData->size = (GLSize){width, height};
    spriteData->data = ((GLbyte *)spriteData + sizeof(GLPixelData));
    spriteData->format = GLInternalFormatRGBA;
    spriteData->dataType = GLDataUByte;
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData->data, width, height, 8, width * 4,
                                                       CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(spriteContext, 0, height);
    CGContextScaleCTM(spriteContext, 1.0, -1.0);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), image);
    
    CGContextRelease(spriteContext);
    
    return spriteData;
}

void GLPixelDataFree(GLPixelData *pixelData) {
    free(pixelData);
}

@interface GLTexture ()
@property (nonatomic, assign)   GLTextureType       textureType;
@property (nonatomic, assign)   GLSize              size;
@property (nonatomic, assign)   GLInternalFormat    format;
@end

@implementation GLTexture

#pragma mark -
#pragma mark Constructors

+ (id)objectWithImageAtPath:(NSString *)path {
    NSString *res = [[NSBundle mainBundle] pathForResource:path
                                                    ofType:nil];
    
    GLPixelData *data = GLPixelDataCreateFromImageAtPath(res);

    GLTexture *me = [self objectAs2DTextureWithSize:data->size
                                     internalFormat:data->format
                                           dataType:data->dataType
                                             pixels:data->data];
    
    GLPixelDataFree(data);
    
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
        
        [me bind];
        
        [me putImageAtFace:GLTextureFace2D
                  withSize:size
            internalFormat:internalFormat
                  dataType:dataType
                    pixels:pixels];
        
        me.minFilter = GLTextureMinFilterLinear;
        //self.magFilter = GLTextureMagFilterLinear;
        me.wrapS = GLTextureWrapClampToEdge;
        me.wrapT = GLTextureWrapClampToEdge;

        [me unbind];
    }
    
    assert(me);
    return me;
}

#pragma mark -
#pragma mark Inialization and Deallocation

- (void)dealloc {
    GLCall(glDeleteTextures(1, &_uId));
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        GLCall(glGenTextures(1, &_uId));
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
    
    if (!GLSizeIsPowerOfTwo(size)) {
        NSLog(@"warning: using non power-of-two texture. filter & wrap parameters limited");
    }
    
    glTexImage2D(self.textureType,
                 0, // level
                 internalFormat,
                 size.width, size.height,
                 0, // border, not supported by GLES
                 internalFormat,
                 dataType,
                 pixels);
    GLassertStateValid();
    
    [self unbind];
}

- (void)putSubImageAtFace:(GLTextureFace)face
                 withRect:(GLRect)rect
                 dataType:(GLData)dataType
                   pixels:(const GLvoid *)pixels
{
    _GLtextureValidateFace(self, face);
    
    [self bind];
    
    glTexSubImage2D(face,
                    0,  // level
                    rect.x, rect.y, rect.width, rect.height,
                    self.format,
                    dataType,
                    pixels);
    GLassertStateValid();
    
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

static void _GLTextureSetParam(GLTexture *texture, GLenum param, GLenum value, GLenum *field) {
    [texture bind];
    assertBound(texture);
    *field = value;
    GLCall(glTexParameteri(texture.textureType, param, value));
    [texture unbind];
}

- (void)setMinFilter:(GLTextureMinFilter)filter {
    GLAssert(GLSizeIsPowerOfTwo(self.size) ||
             (filter == GLTextureMinFilterNearest || filter == GLTextureMinFilterLinear),
             @"filter 0x%x not available for non power-of-two textres", filter);
    
    GLAssert((filter == GLTextureMinFilterNearest || filter == GLTextureMinFilterLinear),
             @"mipmapping & mipmap filters are not supported yet");
    
    _GLTextureSetParam(self, GL_TEXTURE_MIN_FILTER, filter, &_minFilter);
}

- (void)setMagFilter:(GLTextureMagFilter)magFilter {
    _GLTextureSetParam(self, GL_TEXTURE_MAG_FILTER, magFilter, &_magFilter);
}

- (void)setWrapS:(GLTextureWrap)wrapS {
    assert(GLSizeIsPowerOfTwo(self.size) || wrapS == GLTextureWrapClampToEdge);
    _GLTextureSetParam(self, GL_TEXTURE_WRAP_S, wrapS, &_wrapS);
}

- (void)setWrapT:(GLTextureWrap)wrapT {
    assert(GLSizeIsPowerOfTwo(self.size) || wrapT == GLTextureWrapClampToEdge);
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
    GLCall(glBindTexture(self.textureType, bind ? self.uId : 0));
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
         toFramebuffer:(GLFramebuffer *)framebuffer
                 point:(GLFramebufferAttachment)attachmentPoint
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
    
    GLassertStateValid();
}

@end
