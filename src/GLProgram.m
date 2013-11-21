//
//  GLProgram.m
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/20/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLProgram.h"
#import "GLVertexShader.h"

@implementation GLProgram

- (void)dealloc {
    self.vertShader = nil;
    glDeleteProgram(self.uId);
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.uId = glCreateProgram();
        
        [self setUniform:@"titt" to4f:0 :1 :0 :0];
    }
    return self;
}

- (void)internalBind:(BOOL)bind {
    glUseProgram(bind ? self.uId : 0);
}

#pragma mark -
#pragma mark Uniform setters

#define IMPL_UNIFORM(argCount, type, GLtype) \
    DECL_UNIFORM(argCount, type, GLtype) { glUniform##argCount##type([self uniformLocation:uniform], UNIFORM_CALL_ARGS_##argCount); }   \
    DECL_UNIFORM_V(argCount, type, GLtype) { glUniform##argCount##type##v([self uniformLocation:uniform], count, v); }

#define UNIFORM_CALL_ARGS_1 x
#define UNIFORM_CALL_ARGS_2 UNIFORM_CALL_ARGS_1, y
#define UNIFORM_CALL_ARGS_3 UNIFORM_CALL_ARGS_2, z
#define UNIFORM_CALL_ARGS_4 UNIFORM_CALL_ARGS_3, w

DECL_FOUR_METHODS(GLint, i, IMPL_UNIFORM);
DECL_FOUR_METHODS(GLfloat, f, IMPL_UNIFORM);

#pragma mark -
#pragma mark Attribute setters

#define IMPL_ATTRIB(argCount, type, GLtype) \
    DECL_ATTRIB(argCount, type, GLtype) { glVertexAttrib##argCount##type([self attribLocation:attribute], UNIFORM_CALL_ARGS_##argCount); }   \
    DECL_ATTRIB_V(argCount, type, GLtype) { glVertexAttrib##argCount##type##v([self attribLocation:attribute], v); }

DECL_FOUR_METHODS(GLfloat, f, IMPL_ATTRIB);

#pragma mark -
#pragma mark Etc

- (BOOL)link {
    glLinkProgram(self.uId);
    
    return [self linkStatus];
}

- (BOOL)linkStatus {
    GLint status = 0;
    glGetProgramiv(self.uId, GL_LINK_STATUS, &status);
    return status == GL_TRUE;
}

- (BOOL)validate {
    glValidateProgram(self.uId);
    GLint status = 0;
    glGetProgramiv(self.uId, GL_VALIDATE_STATUS, &status);
    return status == GL_TRUE;
}

- (GLint)attribLocation:(NSString *)attribute {
    assert(attribute);
    return glGetAttribLocation(self.uId, attribute.UTF8String);
}

- (void)setAttrib:(NSString *)attribute location:(GLuint)location {
    assert(attribute);
    glBindAttribLocation(self.uId, location, attribute.UTF8String);
}

- (GLint)uniformLocation:(NSString *)uniform {
    return glGetUniformLocation(self.uId, uniform.UTF8String);
}

- (NSString *)infoLog {
    GLint length = 0;
    glGetProgramiv(self.uId, GL_INFO_LOG_LENGTH, &length);
    if (length == 0) {
        return nil;
    }
    
    GLchar *buffer = calloc(length, sizeof(GLchar));
    glGetProgramInfoLog(self.uId, length, &length, buffer);
    
    return [NSString stringWithUTF8String:buffer];
}

- (void)setVertShader:(GLVertexShader *)vertShader {
    if (vertShader != _vertShader) {
        if (_vertShader) {
            glDetachShader(self.uId, _vertShader.uId);
        }
        
        if (vertShader) {
            glAttachShader(self.uId, vertShader.uId);
        }
        
        [_vertShader release];
        _vertShader = [vertShader retain];
    }
}

@end
