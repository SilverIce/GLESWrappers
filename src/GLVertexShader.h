//
//  GLVertexShader.h
//  openGLES Wrappers
//
//  Created by denis on 11/19/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

/*
use cases:
get compile log
reuse vshader
 
gets retained by shader programm in opengl, so must be retained here as well
 
*/

@interface GLVertexShader : NSObject

// way to identify shader? to identify it in from some shader cache?
@property (nonatomic, copy)     NSString    *name;

- (GLuint)uId;

- (BOOL)compileSource:(NSString *)source;

- (NSString *)compileLog;

@end
