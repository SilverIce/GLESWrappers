//
//  GLContext+Private.h
//  Scrip2
//
//  Created by Denis Halabuzar on 12/11/13.
//  Copyright (c) 2013 Alexander. All rights reserved.
//

#import "GLContext.h"

// internals:
@interface GLContext ()
@property (nonatomic, retain)   GLActiveObjects     *objectSet;
@end


// internal class.
// Associative key(GLObjectType)-values array(GLObject*) container.
// retains values
@interface GLActiveObjects : NSObject

- (GLObject *)activeObjectOfClass:(GLObjectType)theClass;
// push new active object. returns previous top object
- (GLObject *)setActiveObject:(GLObject *)object;
// pop object. returns new top object
- (GLObject *)resetActiveObject:(GLObject *)object;
- (void)removeAllObjectsOfClass:(GLObjectType)theClass;

@end

// internal class.
// Associative key(GLObjectType)-value(GLObject*) container.
// does not retain values
@interface GLSlot : NSObject
@property (nonatomic, assign)   GLuint      slotIdx;

- (GLObject *)activeObjectOfClass:(GLObjectType)theClass;
// put new active object.
- (void)setActiveObject:(GLObject *)object;
// remove active object
- (void)resetActiveObject:(GLObject *)object;

@end

void assertBound(GLObject *object);

// private api:
@interface GLObject () {
@protected
    GLuint  _uId;
}

@property (nonatomic, assign)   GLuint              uId;
@property (nonatomic, assign)   GLContext           *context;

// should be overridden
- (void)internalBind:(BOOL)bind;

@end
