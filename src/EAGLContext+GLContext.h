//
//  EAGLContext+GLContext.h
//  Wrapper
//
//  Created by Denis Halabuzar on 11/26/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import <GLKit/GLKit.h>

@class GLContext;

@interface EAGLContext (GLContext)
- (GLContext *)context;

@end
