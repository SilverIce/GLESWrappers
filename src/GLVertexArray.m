//
//  IDPVertexArray.m
//  Wrapper
//
//  Created by Denis Halabuzar on 9/19/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import "GLVertexArray.h"

@interface GLBufferObject ()
@property (nonatomic, assign)   GLsizei         dataSize;
@property (nonatomic, assign)   GLBufferUsage   usage;
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

+ (GLObjectType)glType {
    return GLObjectTypeBuffer;
}

- (void)internalBind:(BOOL)bind {
    glBindBuffer(GL_ARRAY_BUFFER, bind ? self.uId : 0);
}

- (void)modifyData:(const GLvoid *)data
          withSize:(GLsizei)size
          atOffset:(GLintptr)offset
{
    [self bind];
    assert(offset + size < self.dataSize);
    assertBound(self);
    glBufferSubData(GL_ARRAY_BUFFER, offset, size, data);
    [self unbind];
}

- (void)setData:(const GLvoid *)data
       withSize:(GLsizei)size
      withUsage:(GLBufferUsage)usage
{
    [self bind];
    assertBound(self);
    self.dataSize = size;
    self.usage = usage;
    glBufferData(GL_ARRAY_BUFFER, size, data, usage);
    [self unbind];
}

+ (id)objectWithUsage:(GLBufferUsage)usage
                 data:(const GLvoid *)data
                 size:(GLsizei)size
{
    GLBufferObject *me = [[self new] autorelease];
    if (me) {
        [me bind];
        me.dataSize = size;
        me.usage = usage;
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

+ (id)objectWithUsage:(GLBufferUsage)usage
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
        
        me.buffer = [GLBufferObject objectWithUsage:usage data:data size:dataSize];
        
        // attach buffer
        [me bind];
        [me.buffer bind];
        [me unbind];
        
        [me.buffer unbind];
    }
    
    return me;
}

- (NSUInteger)vertexCount {
    return self.buffer.dataSize / self.elementSize;
}

- (void)describeStructures:(const GLVertexArrayStructDescription*)descriptors
               structCount:(NSUInteger)count
{
    [self bind];
    assertBound(self);
    for (NSUInteger i = 0; i < count; ++i) {
        const GLVertexArrayStructDescription *descr = &descriptors[i];
        glEnableVertexAttribArray(descr->attribIndex);
        glVertexAttribPointer(descr->attribIndex,
                              descr->elementCount,
                              descr->elementType,
                              descr->normalized,
                              self.elementSize,
                              (const GLvoid *)descr->ptrOffset);
    }
    [self unbind];
}

- (void)internalBind:(BOOL)bind {
    glBindVertexArrayOES(bind ? self.uId : 0);
}

+ (GLObjectType)glType {
    return GLObjectTypeVertexArray;
}

- (void)drawTriangleStrip {
    [self bind];
    assertBound(self);
    glDrawArrays(GLPrimitiveTriangleStrip, 0, self.vertexCount);
    [self unbind];
}

- (void)draw:(GLPrimitive)mode {
    [self bind];
    assertBound(self);
    glDrawArrays(mode, 0, self.buffer.dataSize / self.elementSize);
    [self unbind];
}

- (void)draw:(GLPrimitive)mode from:(NSUInteger)from count:(NSUInteger)count {
    assert(from + count <= self.vertexCount);
    [self bind];
    assertBound(self);
    glDrawArrays(mode, from, count);
    [self unbind];
}

@end

















