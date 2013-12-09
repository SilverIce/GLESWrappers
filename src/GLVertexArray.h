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

// create it with init or objectWithUsage method
// data buffer stored in GPU memory
@interface GLBufferObject : GLNestedObject

- (GLsizei)dataSize;
- (GLBufferUsage)usage;

- (void)modifyData:(const GLvoid *)data
          withSize:(GLsizei)size
          atOffset:(GLintptr)offset;

- (void)setData:(const GLvoid *)data
       withSize:(GLsizei)size
      withUsage:(GLBufferUsage)usage;

+ (id)objectWithUsage:(GLBufferUsage)usage
                 data:(const GLvoid *)data
                 size:(GLsizei)size;

@end

#define countOf(array) (sizeof(array)/sizeof(array[0]))

// the data that gets passed into vertex shader
// vertex array with underlying Buffer object
@interface GLVertexArray : GLNestedObject

typedef struct {
    GLint           identifier;
    GLsizei         elementCount;
    GLData          elementType;
    GLboolean       normalized;
    GLsizei         ptrOffset;
} GLVertexArrayStructDescription;

- (NSUInteger)vertexCount;
- (GLBufferObject *)buffer;

- (void)describeStructures:(const GLVertexArrayStructDescription *)descriptors
               structCount:(NSUInteger)count;

- (void)describeStructWithIdentifier:(GLint)identifier
                        elementCount:(GLsizei)size
                         elementType:(GLData)type
                          normalized:(GLboolean)normalized
                           ptrOffset:(GLsizei)ptrOffset;

- (void)drawTriangleStrip;
// GL_POINTS, GL_TRIANGLE_STRIP and etc
- (void)draw:(GLenum)mode;
- (void)draw:(GLenum)mode from:(NSUInteger)from count:(NSUInteger)count;

+ (id)objectWithUsage:(GLenum)usage
                 data:(const GLvoid *)data
             dataSize:(GLsizei)dataSize
          elementSize:(GLsizei)elementSize;

@end
