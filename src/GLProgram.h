//
//  GLProgram.h
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/20/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

@class GLVertexShader;

// holds per program uniform data

@interface GLProgram : GLObject

@property (nonatomic, retain)   GLVertexShader  *vertShader;

- (BOOL)link;

// will check for all the conditions that could lead to an INVALID_OPERATION error when rendering commands are issued
// information log of program is overwritten with information on the results of the validation
- (BOOL)validate;

// gets filled after program being lined or validated
- (NSString *)infoLog;

- (GLint)attribLocation:(NSString *)attribute;

// must be used before program will be linked.
// may be issued before any vertex shader objects are attached to a program object.
- (void)setAttrib:(NSString *)attribute
         location:(GLuint)location;

- (GLint)uniformLocation:(NSString *)uniform;

/// Uniform setters:

#define DECL_FOUR_METHODS(GLtype, type, method) \
    method(1, type, GLtype)   \
    method(2, type, GLtype)   \
    method(3, type, GLtype)   \
    method(4, type, GLtype)

#define DECL_UNIFORM_PAIR(argCount, type, GLtype)   \
    DECL_UNIFORM(argCount, type, GLtype);    DECL_UNIFORM_V(argCount, type, GLtype);

#define DECL_UNIFORM(argCount, type, GLtype)  \
    - (void)setUniform:(NSString *)uniform to##argCount##type UNIFORM_ARGS_##argCount(GLtype)

#define DECL_UNIFORM_V(argCount, type, GLtype)  \
    - (void)setUniform:(NSString *)uniform to##argCount##type##v :(const GLtype *)v count:(GLsizei)count

#define UNIFORM_ARGS_1(GLtype) :(GLtype)x
#define UNIFORM_ARGS_2(GLtype) UNIFORM_ARGS_1(GLtype) :(GLtype)y
#define UNIFORM_ARGS_3(GLtype) UNIFORM_ARGS_2(GLtype) :(GLtype)z
#define UNIFORM_ARGS_4(GLtype) UNIFORM_ARGS_3(GLtype) :(GLtype)w

DECL_FOUR_METHODS(GLint, i, DECL_UNIFORM_PAIR);
DECL_FOUR_METHODS(GLfloat, f, DECL_UNIFORM_PAIR);

/// Attribute setters:

#define DECL_ATTRIB_PAIR(argCount, type, GLtype)    DECL_ATTRIB(argCount, type, GLtype); DECL_ATTRIB_V(argCount, type, GLtype);

#define DECL_ATTRIB(argCount, type, GLtype) \
    - (void)setAttrib:(NSString *)attribute to##argCount##type UNIFORM_ARGS_##argCount(GLtype)

#define DECL_ATTRIB_V(argCount, type, GLtype) \
    - (void)setAttrib:(NSString *)attribute to##argCount##type##v :(const GLtype *)v

DECL_FOUR_METHODS(GLfloat, f, DECL_ATTRIB_PAIR);

@end
