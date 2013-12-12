//
//  IDPVertexArray.m
//  Wrapper
//
//  Created by Denis Halabuzar on 9/19/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import "GLVertexArray.h"
#import "GLContext+Private.h"

@interface GLBufferObject ()
@property (nonatomic, assign)   GLsizei         dataSize;
@property (nonatomic, assign)   GLBufferUsage   usage;
@property (nonatomic, assign)   GLenum          glTarget;
@end

@implementation GLBufferObject

#pragma mark -
#pragma mark Initialization and Deallocation

- (void)dealloc {
    glDeleteBuffers(1, &_uId);
    GLassertStateValid();
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        glGenBuffers(1, &_uId);
        GLassertStateValid();
        self.usage = GLBufferUsageStaticDraw;
    }
    return self;
}

#pragma mark -
#pragma mark GLObject

- (GLObjectType)glType {
    return self.glTarget;
}

- (void)internalBind:(BOOL)bind {
    glBindBuffer(self.glTarget, bind ? self.uId : 0);
    GLassertStateValid();
}

#pragma mark -
#pragma mark Public

- (void)modifyData:(const GLvoid *)data
          withSize:(GLsizei)size
          atOffset:(GLintptr)offset
{
    [self bind];
    assert(offset + size < self.dataSize);
    assertBound(self);
    glBufferSubData(self.glTarget, offset, size, data);
    GLassertStateValid();
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
    glBufferData(self.glTarget, size, data, usage);
    GLassertStateValid();
    [self unbind];
}

+ (id)objectAsIndiceBufer {
    GLBufferObject *me = [[self new] autorelease];
    if (me) {
        me.glTarget = GL_ELEMENT_ARRAY_BUFFER;
    }
    
    return me;
}

+ (id)objectAsVertexBufer {
    GLBufferObject *me = [[self new] autorelease];
    if (me) {
        me.glTarget = GL_ARRAY_BUFFER;
    }
    
    return me;
}

@end

@interface GLVertexArray ()
@property (nonatomic, retain)   GLBufferObject          *buffer;
@property (nonatomic, assign)   NSUInteger              elementSize;

@property (nonatomic, retain)   NSMutableDictionary     *index2Storage;
@end

@implementation GLVertexArray

- (void)dealloc {
    self.buffer = nil;
    glDeleteVertexArraysOES(1, &_uId);
    GLassertStateValid();
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        glGenVertexArraysOES(1, &_uId);
        GLassertStateValid();
        self.index2Storage = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)describeStructures:(const GLVertexArrayStructDescription *)descriptors
                     count:(NSUInteger)count
                  inBuffer:(GLBufferObject *)buffer
{
    assert(descriptors);
    assert(buffer);
    
    for (NSUInteger i = 0; i < count; ++i) {
        const GLVertexArrayStructDescription *descr = &descriptors[i];
        
//        self.index2Storage[descr->attribIndex] = 
    }
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
        
        me.buffer = [GLBufferObject objectAsVertexBufer];
        [me.buffer setData:data withSize:dataSize withUsage:usage];
    }
    
    return me;
}

- (NSUInteger)vertexCount {
    return self.buffer.dataSize / self.elementSize;
}

- (void)describeStructures:(const GLVertexArrayStructDescription *)descriptors
               structCount:(NSUInteger)count
{
    [self bind];
    assertBound(self);
    [self.buffer bind];
    for (NSUInteger i = 0; i < count; ++i) {
        const GLVertexArrayStructDescription *descr = &descriptors[i];
        glEnableVertexAttribArray(descr->attribIndex);
        glVertexAttribPointer(descr->attribIndex,
                              descr->elementCount,
                              descr->elementType,
                              descr->normalized,
                              self.elementSize,
                              (GLvoid *)descr->ptrOffset);
        GLassertStateValid();
    }
    [self.buffer unbind];
    [self unbind];
}

#pragma mark -
#pragma mark Attribute setters

#define IMPL_ATTRIB(argCount, type, GLtype) \
    DECL_ATTRIB(argCount, type, GLtype) { \
        [self bind]; \
        glVertexAttrib##argCount##type(attribute, UNIFORM_CALL_ARGS_##argCount); \
        [self unbind]; \
    }   \
    DECL_ATTRIB_V(argCount, type, GLtype) { \
        [self bind]; \
        glVertexAttrib##argCount##type##v(attribute, v); \
        [self unbind]; \
    }

#define UNIFORM_CALL_ARGS_1 x
#define UNIFORM_CALL_ARGS_2 UNIFORM_CALL_ARGS_1, y
#define UNIFORM_CALL_ARGS_3 UNIFORM_CALL_ARGS_2, z
#define UNIFORM_CALL_ARGS_4 UNIFORM_CALL_ARGS_3, w

DECL_FOUR_METHODS(GLfloat, f, IMPL_ATTRIB);

#pragma mark -
#pragma mark GLObject

- (void)internalBind:(BOOL)bind {
    glBindVertexArrayOES(bind ? self.uId : 0);
    GLassertStateValid();
}

+ (GLObjectType)glType {
    return GLObjectTypeVertexArray;
}

#pragma mark -
#pragma mark Drawing

- (void)drawTriangleStrip {
    [self bind];
    assertBound(self);
    glDrawArrays(GLPrimitiveTriangleStrip, 0, self.vertexCount);
    GLassertStateValid();
    [self unbind];
}

- (void)draw:(GLPrimitive)mode {
    [self bind];
    assertBound(self);
    glDrawArrays(mode, 0, self.buffer.dataSize / self.elementSize);
    GLassertStateValid();
    [self unbind];
}

- (void)draw:(GLPrimitive)mode from:(NSUInteger)from count:(NSUInteger)count {
    assert(from + count <= self.vertexCount);
    [self bind];
    assertBound(self);
    glDrawArrays(mode, from, count);
    GLassertStateValid();
    [self unbind];
}

@end

















