//
//  GLContext.h
//  GLWrarring
//
//  Created by denis on 10/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "GLConstants.h"
#import "GLWeakReference.h"

@class GLProgram;
@class GLFramebuffer;
@class GLTexture;
@class GLObject;
@class GLActiveObjects;
@class GLSlot;

typedef NS_ENUM(GLenum, GLObjectType) {
    GLObjectTypeFramebuffer,
    GLObjectTypeBuffer,
    GLObjectTypeProgram,
    GLObjectTypeVertexArray,
    GLObjectTypeTexture2D,
    GLObjectTypeTextureCubemap,
};

/*
gl context issues:
context is too imperative for me
 
1. the shared state is much harder to maintain
2. everything changes state, need keep in mind how each function changes that state


 
hard to maintain state
*/

@interface GLContext : NSObject

- (GLFramebuffer *)framebuffer;

//- (GLProgram *)program;

@end

@interface GLContext (GLTextureManagement)
- (GLSlot *)activeSlot;

// trying to find less active textures & bind onto slots occupied by them
// it assumes that we are trying activate textures of same type
// Important: method clears texture object stack
- (void)activateTextures:(NSArray *)array;
// ensures that texture is in slot. may not activate slot
// Important: method clears texture object stack
- (void)activateTexture:(GLTexture *)texture;

// find less active slot (& put texture into slot if it's not in slot yet), activate slot
- (void)_bindTexture:(GLTexture *)texture;

- (void)setupSlots;
- (void)deallocSlots;

@end

// internals:
@interface GLContext ()
@property (nonatomic, retain)   GLActiveObjects     *objectSet;
@end


// internal class.
// Associative key(GLObjectType)-values array(GLObject*) container.
// does not retain values
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

@interface GLObject : NSObject

- (GLContext *)context;

// gl object type identifier. can be overridden
// objects should always have equal identifiers if they behave in same way
// initially set to object class
- (GLObjectType)glType;
+ (GLObjectType)glType;

// should be overridden
- (void)bind;
- (void)unbind;
- (BOOL)isBound;

// should we really pass&store context everywhere or just query current EAGLConext context?
+ (id)objectWithContext:(GLContext *)context;

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

@interface GLNestedObject : GLObject

@end

@interface GLNestedObject ()

@end

