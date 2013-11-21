//
//  IDPVertexArray.m
//  Wrapper
//
//  Created by Denis Halabuzar on 9/19/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import "GLVertexArray.h"

@interface GLBufferObject ()
@property (nonatomic, assign)   GLsizei dataSize;
@end

@implementation GLBufferObject

- (void)dealloc {
    glDeleteBuffers(1, &_uId);
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        glGenBuffers(1, &_uId);
    }
    return self;
}

- (void)internalBind:(BOOL)bind {
    glBindBuffer(GL_ARRAY_BUFFER, bind ? self.uId : 0);
}

- (void)modifyData:(const GLvoid *)data
          withSize:(GLsizei)size
          atOffset:(GLintptr)offset
{
    assert(offset + size < self.dataSize);
    glBufferSubData(GL_ARRAY_BUFFER, offset, size, data);
}

- (void)setData:(const GLvoid *)data
       withSize:(GLsizei)size
      withUsage:(GLenum)usage
{
    self.dataSize = size;
    glBufferData(GL_ARRAY_BUFFER, size, data, usage);
}

+ (id)objectWithUsage:(GLenum)usage
                 data:(const GLvoid *)data
                 size:(GLsizei)size
{
    GLBufferObject *me = [[self new] autorelease];
    if (me) {
        [me bind];
        me.dataSize = size;
        glBufferData(GL_ARRAY_BUFFER, size, data, usage);
        [me unbind];
    }

    return me;
}

@end

@interface GLVertexArray ()
@property (nonatomic, retain)  GLBufferObject *buffer;
@property (nonatomic, assign)  NSUInteger      elementSize;
@end

@implementation GLVertexArray

- (void)dealloc {
    self.buffer = nil;
    glDeleteVertexArraysOES(1, &_uId);
    [super dealloc];
}

+ (id)objectWithUsage:(GLenum)usage
                 data:(const GLvoid *)data
             dataSize:(GLsizei)dataSize
          elementSize:(GLsizei)elementSize
{
    assert((dataSize % elementSize) == 0);
    assert(elementSize > 0);
    assert(dataSize > 0);
    //assert(data); // it's ok when no data
    
    GLVertexArray *me = [[self new] autorelease];
    if (me) {
        me.elementSize = elementSize;
        //me.dataSize = dataSize;
        
        glGenVertexArraysOES(1, &me->_uId);
        
        [me nestedBind];
        me.buffer = [GLBufferObject objectWithUsage:usage data:data size:dataSize];
        [me.buffer nestedBind];
        [me nestedBind];
        
        [me.buffer nestedUnbind];
    }
    
    return me;
}

- (NSUInteger)vertexCount {
    return self.buffer.dataSize / self.elementSize;
}

- (void)describeStructures:(const IDPVertexArrayStructDescription*)descriptors
               structCount:(NSUInteger)count
{
    for (NSUInteger i = 0; i < count; ++i) {
        const IDPVertexArrayStructDescription *descr = &descriptors[i];
        glEnableVertexAttribArray(descr->identifier);
        glVertexAttribPointer(descr->identifier,
                              descr->elementCount,
                              descr->elementType,
                              descr->normalized,
                              self.elementSize,
                              (GLvoid *)descr->ptrOffset);
    }
}

- (void)describeStructWithIdentifier:(GLint)attribute
                        elementCount:(GLsizei)size
                         elementType:(GLenum)type
                          normalized:(GLboolean)normalized
                           ptrOffset:(GLsizei)ptrOffset
{
    glEnableVertexAttribArray(attribute);
    glVertexAttribPointer(attribute, size, type, normalized, self.elementSize, (GLvoid *)ptrOffset);
}

- (void)internalBind:(BOOL)bind {
    glBindVertexArrayOES(bind ? self.uId : 0);
}

- (void)drawTriangleStrip {
    glDrawArrays(GL_TRIANGLE_STRIP, 0, self.vertexCount);
}

- (void)draw:(GLenum)mode {
    glDrawArrays(mode, 0, self.buffer.dataSize / self.elementSize);
}

- (void)draw:(GLenum)mode from:(NSUInteger)from count:(NSUInteger)count {
    assert(from + count <= self.vertexCount);
    glDrawArrays(mode, from, count);
}

@end

















