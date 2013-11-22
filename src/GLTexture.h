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

// bind -> make it be current texture -

@interface GLTexture : GLObject

- (void)bind;
- (void)unbind;

@end

@interface GLTexture ()
// private api:
@property (nonatomic, assign)   GLuint              uId;
@property (nonatomic, assign)   GLuint              useCount;
@property (nonatomic, assign)   GLActiveObjects     *slot;

@end