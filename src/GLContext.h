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
    GLObjectTypeRenderbuffer,
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

- (GLObject *)framebuffer;

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

@interface GLObject : NSObject

- (GLContext *)context;

// gl object type identifier. can be overridden
// objects should always have equal identifiers if they behave in same way
- (GLObjectType)glType;
+ (GLObjectType)glType;

// should be overridden
- (void)bind;
- (void)unbind;
- (BOOL)isBound;

@end

// Implements nested binding behaviour - each bind call remembers previous bound object
// each unbind call restores pre
@interface GLNestedObject : GLObject
@end
