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

typedef Class GLObjectType;

@interface GLContext : NSObject

- (GLFramebuffer *)framebuffer;

- (GLProgram *)program;

@end

// internals:
@interface GLContext ()
@property (nonatomic, retain)   GLActiveObjects     *objectSet;

- (GLActiveObjects *)activeSlot;

// trying to find less active textures & bind onto slots occupied by them
// it assumes that we are trying activate textures of same type
- (void)activateTextures:(NSArray *)array;
- (void)activateTexture:(GLTexture *)texture;

// find less active slot (put texture innto slot if it's not in slot yet), activate slot
- (void)bindTexture:(GLTexture *)texture;
@end

// internal class:
@interface GLActiveObjects : NSObject
@property (nonatomic, assign)   GLuint      slotIdx;

- (GLObject *)activeObjectOfClass:(GLObjectType)theClass;
- (GLObject *)activeObjectOfObject:(GLObject *)object;
- (void)setActiveObject:(GLObject *)object;
- (void)resetActiveObject:(GLObject *)object;

@end

@interface GLObject : NSObject

- (GLContext *)context;

// type identifier. can be overridden
+ (GLObjectType)glType;
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

// private api:
@interface GLObject () {
@protected
    GLuint  _uId;
}

@property (nonatomic, assign)   GLuint              uId;
@property (nonatomic, assign)   GLContext           *context;

@end

@interface GLNestedObject : GLObject
- (void)bindNested;
- (void)unbindNested;

@end

@interface GLNestedObject ()
// we should definitely retain prev object as context no more owns it
@property (nonatomic, retain)   GLObject    *prevBound;
@property (nonatomic, assign)   BOOL        nestedBound;

@end

