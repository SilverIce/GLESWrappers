//
//  GLUtils.c
//  Scrip2
//
//  Created by Denis Halabuzar on 12/11/13.
//  Copyright (c) 2013 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

void GLassertStateValid() {
#warning TODO: remove that definition in future as it may reduce performance
#define GLES_DEBUG
    
#ifdef GLES_DEBUG
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"gl error: 0x%x", error);
        assert(false);
    }
#endif
}
