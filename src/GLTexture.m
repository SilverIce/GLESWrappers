//
//  GLTexture.m
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLTexture.h"

@implementation GLTexture

- (void)bind {
    [self.context bindTexture:self];
}

- (void)unbind {
    // nothing to do
}

- (BOOL)isBound {
    return self.slot && self.slot == self.context.activeSlot;
}

@end
