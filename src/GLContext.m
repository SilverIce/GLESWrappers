//
//  GLContext.m
//  GLWrarring
//
//  Created by denis on 10/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"
#import "GLContext+Private.h"

#import "GLFramebuffer.h"
#import "GLWeakReference.h"

#import "EAGLContext+GLContext.h"

#import "GLContext+GLTextureManagement.hpp"

@interface GLContext ()

@end

@implementation GLContext

- (void)dealloc {
    [self deallocSlots];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.objectSet = [GLActiveObjects object];
        [self setupSlots];
    }
    return self;
}

- (GLObject *)framebuffer {
    return (GLObject *)[self.objectSet activeObjectOfClass:GLObjectTypeFramebuffer];
}

@end


@interface GLActiveObjects ()
@property (nonatomic, retain)   NSMutableDictionary *dict;
@end

@implementation GLActiveObjects

- (void)dealloc {
    self.dict = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)description {
    return self.dict.description;
}

- (GLObject *)activeObjectOfClass:(GLObjectType)theClass {
    NSNumber *key = @(theClass);
    NSMutableArray *stack = self.dict[key];
    return stack.lastObject;
}

- (GLObject *)setActiveObject:(GLObject *)object {
    assert(object);
    NSNumber *key = @([object glType]);
    
    NSMutableArray *stack = self.dict[key];
    if (!stack) {
        self.dict[key] = stack = [NSMutableArray array];
    }
    
    GLObject *prevWeak = stack.lastObject;
    //assert(prevWeak != newWeak); // it's ok to push object twice
    [stack addObject:object];
    
    assert(object == [self activeObjectOfClass:object.glType]);
    
    return prevWeak;
}

- (GLObject *)resetActiveObject:(GLObject *)object {
    assert(object);
    NSNumber *key = @([object glType]);
    
    NSMutableArray *stack = self.dict[key];
    assert(stack);
    assert(stack.lastObject == object);
    
    [stack removeLastObject];
    
    return stack.lastObject;
}

- (void)removeAllObjectsOfClass:(GLObjectType)theClass {
    NSMutableArray *stack = self.dict[@(theClass)];
    [stack removeAllObjects];
}

@end

@interface GLSlot ()
@property (nonatomic, retain)   NSMutableDictionary *dict;
@end

@implementation GLSlot

- (void)dealloc {
    self.dict = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"slot %u. textures = %@", self.slotIdx, self.dict];
}

- (GLObject *)activeObjectOfClass:(GLObjectType)theClass {
    NSNumber *key = @(theClass);
    return [(GLWeakReference *)self.dict[key] target];
}

- (void)setActiveObject:(GLObject *)object {
    assert(object);
    NSNumber *key = @([object glType]);
    self.dict[key] = [object makeWeakReference];
}

- (void)resetActiveObject:(GLObject *)object {
    assert(object);
    NSNumber *key = @([object glType]);
    assert(object == [(GLWeakReference *)self.dict[key] target]);
    [self.dict removeObjectForKey:key];
    assert(object == [self activeObjectOfClass:object.glType]);
}

@end

void assertBound(GLObject *object) {
    assert(object);
    assert([object isBound]);
}

@implementation GLObject

+ (id)objectWithContext:(GLContext *)context {
    GLObject *me = [[self new] autorelease];
    me.context = context;
    return me;
}

+ (GLObjectType)glType {
    assert(false);
    return -1;
}

- (void)dealloc {
    GLAssert(self.context == [[EAGLContext currentContext] gl_context],
        @"GL object must be deallocated inside his native context only. GL resource leak detected");
    [super dealloc];
}

- (GLObjectType)glType {
    return [[self class] glType];
}

- (GLContext *)context {
    if (!_context) {
        EAGLContext *context = [EAGLContext currentContext];
        assert(context && "there should be always context active during sending any messages to any GLObject instance");
        _context = [context gl_context];
    }
    return _context;
}

- (void)bind {
    assert(false);
}

- (void)unbind {
    assert(false);
}

- (void)internalBind:(BOOL)bind {
    assert(false);
}

- (BOOL)isBound {
    assert(NO);
    return NO;
}

@end

@implementation GLNestedObject

- (BOOL)isBound {
    return [self.context.objectSet activeObjectOfClass:self.glType] == self;
}

- (void)bind {
    //assert(self.isBound == NO); // it's ok to bind twice
    
    GLObject *prevActive = [self.context.objectSet setActiveObject:self];
    
    if (self != prevActive) {
        [self internalBind:YES];
    }
}

- (void)unbind {
    //assert(self.isBound && self.nestedBound == YES);
    
    // bind previous object
    
    GLObject *prev = [self.context.objectSet resetActiveObject:self];
    
    if (prev) {
        assert(prev.glType == self.glType);
        
        if (prev != self) {
            [prev internalBind:YES];
        }
    } else {
        [self internalBind:NO];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@. uId %u", super.description, self.uId];
}

@end
