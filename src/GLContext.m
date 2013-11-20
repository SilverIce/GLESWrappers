//
//  GLContext.m
//  GLWrarring
//
//  Created by denis on 10/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

@implementation GLContext

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

- (GLObject *)activeObjectOfClass:(Class)theClass {
    NSNumber *key = @([[theClass glType] hash]);
    return self.dict[key];
}

- (GLObject *)activeObjectOfObject:(GLObject *)object {
    return [self activeObjectOfClass:object.class];
}

- (void)setActiveObject:(GLObject *)object {
    NSNumber *key = @([[object.class glType] hash]);
    self.dict[key] = object;
}

@end

@implementation GLObject

+ (Class)glType {
    return self;
}

- (void)bind {
    assert(self.isBound == NO);
    
    [self.context.objectSet setActiveObject:self];
    [self internalBind:YES];
}

- (void)unbind {
    assert(self.isBound && self.nestedBound == NO);
    
    [self.context.objectSet setActiveObject:nil];
    [self internalBind:NO];
}

- (void)nestedBind {
    assert(self.isBound == NO);
    
    self.nestedBound = YES;
    self.prevBound = [self.context.objectSet activeObjectOfObject:self];
    [self.context.objectSet setActiveObject:self];
    
    [self internalBind:YES];
}

- (void)nestedUnbind {
    assert(self.isBound && self.nestedBound == YES);
    
    // bind previous object
    
    GLObject *prev = self.prevBound;
    
    [self.context.objectSet setActiveObject:prev];
    if (prev) {
        [prev internalBind:YES];
    } else {
        [self internalBind:NO];
    }
    
    self.nestedBound = NO;
    self.prevBound = nil;
}

- (BOOL)isBound {
    return [self.context.objectSet activeObjectOfObject:self] == self;
}

@end
