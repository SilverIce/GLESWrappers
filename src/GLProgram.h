//
//  GLProgram.h
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/20/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

@class GLShader;

// Private tools:

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

#define DECL_UNIFORM_MATRIX_V(GLtype, type, argCount)  \
    - (void)setUniform:(NSString *)uniform toMatrix##argCount##type##v  \
        :(GLsizei)count transpose:(GLboolean)transpose value:(const GLtype *)value

#define UNIFORM_ARGS_1(GLtype) :(GLtype)x
#define UNIFORM_ARGS_2(GLtype) UNIFORM_ARGS_1(GLtype) :(GLtype)y
#define UNIFORM_ARGS_3(GLtype) UNIFORM_ARGS_2(GLtype) :(GLtype)z
#define UNIFORM_ARGS_4(GLtype) UNIFORM_ARGS_3(GLtype) :(GLtype)w

// Private tools end

@interface GLProgram : GLNestedObject

- (GLint)attribLocation:(NSString *)attribute;

// must be used before program will be linked.
// may be issued before any vertex shader objects are attached to a program object.
- (void)setAttrib:(NSString *)attribute
         location:(GLuint)location;

typedef struct {
    const GLchar    *attrib;
    GLuint          location;
} GLProgramAttrib2Loc;

// associates attribute names with indices
// must be used before program will be linked.
// may be issued before any vertex shader objects are attached to a program object.
- (void)associateAttributes:(const GLProgramAttrib2Loc *)associations
                      count:(NSUInteger)count;

// associates attribute names with indices
// accepts array of NSString & NSNumber objects: e.g. @[@"attributeA", @1, @"attributeB", @2, ...]
- (void)associateAttributes:(NSArray *)associations;

// may return -1 if uniform is inactive (or no such at all)
- (GLint)uniformLocation:(NSString *)uniform;

// Uniform setters
// macroses generating lot of methods:
// - (void)setUniform:(NSString *)uniform to{1234}{if}{v}:[args,]:Targ1...:TargN [:args];
DECL_FOUR_METHODS(GLint, i, DECL_UNIFORM_PAIR);
DECL_FOUR_METHODS(GLfloat, f, DECL_UNIFORM_PAIR);

// macroses generating lot of methods:
// - (void)setUniform:(NSString *)uniform toMatrix{234}fv:(GLsizei)count transpose:(GLboolean)transpose value:(const GLtype *)value;
DECL_UNIFORM_MATRIX_V(GLfloat, f, 2);
DECL_UNIFORM_MATRIX_V(GLfloat, f, 3);
DECL_UNIFORM_MATRIX_V(GLfloat, f, 4);

+ (id)objectWithVertShaderName:(NSString *)vertexShader
                    fragShader:(NSString *)fragmentShader;

@end

@interface GLProgram (Construction)

// Creates linked program. otherwise assertion will fail
+ (id)objectWithVertShaderName:(NSString *)vertexShader
                    fragShader:(NSString *)fragmentShader
          linkedWithAttributes:(NSArray *)attributes;       // NSString (attribute) - NSNumber (attrib. index) array. You can pass nil here.
                                                            // See associateAttributes method for more info

@end

// advanced user api
@interface GLProgram ()
@property (nonatomic, retain)   GLShader  *vertShader;
@property (nonatomic, retain)   GLShader  *fragShader;

// both fragment and vertex shaders should be attached to link successfully.
// returns false in case of failure
- (BOOL)link;

// will check for all the conditions that could lead to an INVALID_OPERATION error when rendering commands are issued
// information log of program is overwritten with information on the results of the validation
- (BOOL)validate;

// gets filled after program being linked or validated
- (NSString *)infoLog;

@end
