//
//  GLTexture.h
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext.h"

@interface GLTexture : GLObject

@end

@interface GLTexture ()
// private api:
@property (nonatomic, assign)   GLuint              uId;
@property (nonatomic, assign)   GLActiveObjects     *slot;
@property (nonatomic, assign)   GLuint              useCount;

@end
