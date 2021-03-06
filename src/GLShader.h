//
//  GLVertexShader.h
//  openGLES Wrappers
//
//  Created by denis on 11/19/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

typedef NS_ENUM(GLenum, GLShaderType) {
    GLShaderTypeVertex      = GL_VERTEX_SHADER,
    GLShaderTypeFragment    = GL_FRAGMENT_SHADER,
};

@interface GLShader : NSObject

// way to identify shader? to identify it in from some shader cache?
//@property (nonatomic, copy)     NSString    *name;

- (GLuint)uId;
- (GLShaderType)shaderType;
- (BOOL)isCompiled;

- (NSString *)compileLog;

// returns successfully compiled shader. otherwise assertion will fail
+ (id)objectAsFragmentShaderWithSource:(NSString *)source;
+ (id)objectAsVertexShaderWithSource:(NSString *)source;

@end

@interface GLShader ()
+ (id)objectAsFragmentShader;
+ (id)objectAsVertexShader;

- (BOOL)compileSource:(NSString *)source;

@end