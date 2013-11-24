//
//  GLContext+GLTextureManagement.h
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

@interface GLContext (GLTextureManagement)

- (GLActiveObjects *)activeSlot;

// trying to find less active textures & bind onto slots occupied by them
// it assumes that we are trying activate textures of same type
- (void)activateTextures:(NSArray *)array;

// find less active slot (if texture not in slot yet), activate slot
- (void)bindTexture:(GLTexture *)texture;

@end
