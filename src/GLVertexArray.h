//
//  IDPVertexArray.h
//  Wrapper
//
//  Created by Denis Halabuzar on 9/19/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import "GLContext.h"

typedef NS_ENUM(GLenum, GLBufferUsage) {
    GLBufferUsageStaticDraw     = GL_STATIC_DRAW,
    GLBufferUsageDynamicDraw    = GL_DYNAMIC_DRAW,
    GLBufferUsageStreamDraw     = GL_STREAM_DRAW,
};

// Wraps data buffer stored in GPU memory.
// create it with object* methods
@interface GLBufferObject : GLNestedObject

- (GLsizei)dataSize;
- (GLBufferUsage)usage;

- (void)modifyData:(const GLvoid *)data
          withSize:(GLsizei)size
          atOffset:(GLintptr)offset;

- (void)setData:(const GLvoid *)data
       withSize:(GLsizei)size
      withUsage:(GLBufferUsage)usage;

+ (id)objectAsIndiceBufer;
+ (id)objectAsVertexBufer;

@end

#define DECL_FOUR_METHODS(GLtype, type, method) \
    method(1, type, GLtype)   \
    method(2, type, GLtype)   \
    method(3, type, GLtype)   \
    method(4, type, GLtype)

#define UNIFORM_ARGS_1(GLtype) :(GLtype)x
#define UNIFORM_ARGS_2(GLtype) UNIFORM_ARGS_1(GLtype) :(GLtype)y
#define UNIFORM_ARGS_3(GLtype) UNIFORM_ARGS_2(GLtype) :(GLtype)z
#define UNIFORM_ARGS_4(GLtype) UNIFORM_ARGS_3(GLtype) :(GLtype)w

#define DECL_ATTRIB_PAIR(argCount, type, GLtype)    DECL_ATTRIB(argCount, type, GLtype); DECL_ATTRIB_V(argCount, type, GLtype);

#define DECL_ATTRIB(argCount, type, GLtype) \
    - (void)setAttrib:(GLuint)attribute to##argCount##type UNIFORM_ARGS_##argCount(GLtype)

#define DECL_ATTRIB_V(argCount, type, GLtype) \
    - (void)setAttrib:(GLuint)attribute to##argCount##type##v :(const GLtype *)v

#define countOf(array) (sizeof(array)/sizeof(array[0]))

typedef NS_ENUM(GLenum, GLPrimitive) {
    GLPrimitivePoints           = GL_POINTS,
    GLPrimitiveLines            = GL_LINES,
    GLPrimitiveLineLoop         = GL_LINE_LOOP,
    GLPrimitiveLineStrip        = GL_LINE_STRIP,
    GLPrimitiveTriangles        = GL_TRIANGLES,
    GLPrimitiveTriangleStrip    = GL_TRIANGLE_STRIP,
    GLPrimitiveTriangleFan      = GL_TRIANGLE_FAN,
};

// the data that gets passed into vertex shader
// vertex array with underlying Buffer object
@interface GLVertexArray : GLNestedObject

typedef struct {
    GLuint          attribIndex;     // attribute index
    GLsizei         elementCount;
    GLData          elementType;
    GLboolean       normalized;
    GLsizei         ptrOffset;
} GLVertexArrayStructDescription;

- (NSUInteger)vertexCount;
- (GLBufferObject *)buffer;

- (void)describeStructures:(const GLVertexArrayStructDescription *)descriptors
               structCount:(NSUInteger)count;

DECL_FOUR_METHODS(GLfloat, f, DECL_ATTRIB_PAIR);

- (void)drawTriangleStrip;
- (void)draw:(GLPrimitive)mode;
- (void)draw:(GLPrimitive)mode from:(NSUInteger)from count:(NSUInteger)count;

+ (id)objectWithUsage:(GLBufferUsage)usage
                 data:(const GLvoid *)data
             dataSize:(GLsizei)dataSize
          elementSize:(GLsizei)elementSize;

@end
