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
