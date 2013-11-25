//
//  GLTexture.h
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

// use cases:

// bind & put something into texture
// bind onto less active slot & do somthing & restore previous

// bind -> make it current texture -

// TODO:
// sometimes we'll have a huge texture and we'll want to free memory as fast as possible

@interface GLTexture : GLObject

- (void)bind;
- (void)unbind;

@end

@interface GLTexture ()
// private api:
@property (nonatomic, assign)   GLuint              useCount;
@property (nonatomic, assign)   GLActiveObjects     *slot;

@end
