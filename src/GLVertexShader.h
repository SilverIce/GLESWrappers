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
*/

@interface GLVertexShader : GLObject

// way to identify shader?
@property (nonatomic, copy)     NSString    *name;

- (BOOL)compileSource:(NSString *)source;

- (NSString *)compileLog;

+ (id)object;

@end
