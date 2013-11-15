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

@interface GLContext : NSObject

- (GLFramebuffer *)framebuffer;

- (GLProgram *)program;

// texture at current active slot
- (GLTexture *)texture;
// current active texture slot
- (NSUInteger)textureSlot;

- (void)attachTexture:(GLTexture *)texture ontoSlot:(NSUInteger)slot;
- (GLTexture *)textureInSlot:(NSUInteger)slot;

// internals:
@property (nonatomic, retain)   GLActiveObjects     *objectSet;

@end

// internal class:
@interface GLActiveObjects : NSObject
- (GLObject *)activeObjectOfClass:(Class)theClass;
- (GLObject *)activeObjectOfObject:(GLObject *)object;
- (void)setActiveObject:(GLObject *)object;

@end

@interface GLObject : NSObject

- (GLContext *)context;

// type identifier. can be overridden
+ (Class)glType;

- (void)bind;
- (void)unbind;

- (void)nestedBind;
- (void)nestedUnbind;

// should be overridden
- (void)internalBind:(BOOL)bind;

- (BOOL)isBound;

// private api:

@property (nonatomic, assign)   GLuint      uId;
// we should definitely retain prev object as context no more owns it
@property (nonatomic, retain)   GLObject    *prevBound;
@property (nonatomic, assign)   BOOL        nestedBound;

@end

