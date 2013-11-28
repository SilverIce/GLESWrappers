//
//  GLContext.h
//  GLWrarring
//
//  Created by denis on 10/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class GLProgram;
@class GLFramebuffer;
@class GLTexture;
@class GLObject;
@class GLActiveObjects;

typedef GLActiveObjects GLSlot;
typedef Class GLObjectType;

@interface GLContext : NSObject

- (GLFramebuffer *)framebuffer;

- (GLProgram *)program;

@end

@interface GLContext (GLTextureManagement)
- (GLSlot *)activeSlot;

// trying to find less active textures & bind onto slots occupied by them
// it assumes that we are trying activate textures of same type
- (void)activateTextures:(NSArray *)array;
// ensures that texture is in slot. may not activate slot
- (void)activateTexture:(GLTexture *)texture;

// find less active slot (& put texture into slot if it's not in slot yet), activate slot
- (void)bindTexture:(GLTexture *)texture;

@end

// internals:
@interface GLContext ()
@property (nonatomic, retain)   GLActiveObjects     *objectSet;
@end


// internal class.
// Associative key(GLObjectType)-value(GLObject*) container.
// does not retain values
@interface GLActiveObjects : NSObject
@property (nonatomic, assign)   GLuint      slotIdx;

- (GLObject *)activeObjectOfClass:(GLObjectType)theClass;
- (void)setActiveObject:(GLObject *)object;
- (void)resetActiveObject:(GLObject *)object;

@end

@interface GLObject : NSObject

- (GLContext *)context;

// gl object type identifier. can be overridden
// objects should always have equal identifiers if they acting in same way
// initially set to object class
- (GLObjectType)glType;

// should be overridden
- (void)bind;
- (void)unbind;
- (BOOL)isBound;

// should be overridden
- (void)internalBind:(BOOL)bind;

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
@property (nonatomic, assign)   GLObjectType        glType;
@end

@interface GLNestedObject : GLObject
- (void)bindNested;
- (void)unbindNested;

@end

@interface GLNestedObject ()
// we should definitely retain prev object as context no more owns it
// someone should need & retain them too however
// TODO: should i use weak reference?
@property (nonatomic, retain)   GLObject    *prevBound;
@property (nonatomic, assign)   BOOL        nestedBound;

@end

