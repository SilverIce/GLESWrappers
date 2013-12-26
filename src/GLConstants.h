//
//  GLConstants.h
//  Wrapper
//
//  Created by Denis Halabuzar on 12/6/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import <GLKit/GLKit.h>

typedef NS_ENUM(GLenum, GLInternalFormat) {
    GLInternalFormatRGBA            = GL_RGBA,
    GLInternalFormatRGB             = GL_RGB,
    GLInternalFormatLuminance       = GL_LUMINANCE,
    GLInternalFormatLuminanceAlpha  = GL_LUMINANCE_ALPHA,
};

typedef NS_ENUM(GLenum, GLData) {
    GLDataByte      = GL_BYTE,
    GLDataUByte     = GL_UNSIGNED_BYTE,
    GLDataShort     = GL_SHORT,
    GLDataUShort    = GL_UNSIGNED_SHORT,
    GLDataFloat     = GL_FLOAT,
};

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

static BOOL GLintIsPowerOfTwo(GLint x) {
    return (x & (x - 1)) == 0;
}

static BOOL GLSizeIsPowerOfTwo(GLSize size) {
    return GLintIsPowerOfTwo(size.width) && GLintIsPowerOfTwo(size.height);
}

#define GLAssert(expression, ...) \
    if (!(expression)) { \
        NSLog(@"assertion '%s' failed. %@", #expression, [NSString stringWithFormat: __VA_ARGS__ ]); \
        assert(false); \
    }

#define GLCall(...)     __VA_ARGS__; GLassertStateValid();
#define GLCallR(...)     ({typeof(__VA_ARGS__) res = (__VA_ARGS__); GLassertStateValid(); res;})

extern void GLassertStateValid();
