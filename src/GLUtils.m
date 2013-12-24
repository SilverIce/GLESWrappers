//
//  GLUtils.c
//  Scrip2
//
//  Created by Denis Halabuzar on 12/11/13.
//  Copyright (c) 2013 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define GL_ERROR_CODE(code)     {(GLenum)(code), #code}

static const struct {
    GLenum          code;
    const GLchar    *codeString;
} GLErrorCodeInfo[] = {
    GL_ERROR_CODE(GL_INVALID_ENUM),
    GL_ERROR_CODE(GL_INVALID_VALUE),
    GL_ERROR_CODE(GL_INVALID_OPERATION),
    GL_ERROR_CODE(GL_STACK_OVERFLOW),
    GL_ERROR_CODE(GL_STACK_UNDERFLOW),
    GL_ERROR_CODE(GL_OUT_OF_MEMORY),
};

static const GLchar * GLErrorCodeString(GLenum code) {
    for (GLuint i = 0; sizeof(GLErrorCodeInfo)/sizeof(GLErrorCodeInfo[0]); ++i) {
        if (GLErrorCodeInfo[i].code == code) {
            return GLErrorCodeInfo[i].codeString;
        }
    }
    
    return "no error code related string";
}

void GLassertStateValid() {
#warning TODO: remove that definition in future as it may reduce performance
#define GLES_DEBUG
    
#ifdef GLES_DEBUG
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"gl error: 0x%x - %s", error, GLErrorCodeString(error));
        assert(false);
    }
#endif
}
