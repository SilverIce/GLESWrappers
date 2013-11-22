//
//  GLTexture.m
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLTexture.h"
#import "GLContext+GLTextureManagement.h"

@implementation GLTexture

- (void)bind {
    [self.context activateTexture:self];
}

- (void)unbind {
    // nothing to do
}

@end
