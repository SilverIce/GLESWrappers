//
//  GLContext.m
//  GLWrarring
//
//  Created by denis on 10/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

#import "GLFramebuffer.h"
#import "GLWeakReference.h"

#import "EAGLContext+GLContext.h"

#import "GLContext+GLTextureManagement.m"

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

- (GLFramebuffer *)framebuffer {
    return (GLFramebuffer *)[self.objectSet activeObjectOfClass:[GLFramebuffer glType]];
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

- (GLObject *)activeObjectOfClass:(GLObjectType)theClass {
    NSNumber *key = @([theClass hash]);
    return [(GLWeakReference *)self.dict[key] target];
}

- (void)setActiveObject:(GLObject *)object {
    assert(object);
    NSNumber *key = @([[object glType] hash]);
    self.dict[key] = [object makeWeakReference];
}

- (void)resetActiveObject:(GLObject *)object {
    assert(object);
    NSNumber *key = @([[object glType] hash]);
    [self.dict removeObjectForKey:key];
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

- (id)init {
    self = [super init];
    if (self) {
        self.glType = [self class];
    }
    return self;
}

- (GLContext *)context {
    return [[EAGLContext currentContext] context];
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
    assert(self.isBound == NO);
    
    [self.context.objectSet setActiveObject:self];
    [self internalBind:YES];
}

- (void)unbind {
    [self.context.objectSet setActiveObject:nil];
    [self internalBind:NO];
}

- (void)bindNested {
    assert(self.isBound == NO);
    
    self.nestedBound = YES;
    self.prevBound = [self.context.objectSet activeObjectOfClass:self.glType];
    [self.context.objectSet setActiveObject:self];
    
    [self internalBind:YES];
}

- (void)unbindNested {
    assert(self.isBound && self.nestedBound == YES);
    
    // bind previous object
    
    GLObject *prev = self.prevBound;
    
    if (prev) {
        assert(prev.glType == self.glType);
        
        [self.context.objectSet setActiveObject:prev];
        [prev internalBind:YES];
    } else {
        [self.context.objectSet resetActiveObject:self];
        [self internalBind:NO];
    }
    
    self.nestedBound = NO;
    self.prevBound = nil;
}

@end
