//
//  GLTexture.m
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLTexture.h"

@implementation GLTexture

- (void)dealloc {
    glDeleteTextures(1, &_uId);
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        glGenTextures(1, &_uId);
    }
    return self;
}

- (void)internalBind:(BOOL)bind {
    glBindTexture(self.textureType, bind ? self.uId : 0);
}

- (void)bind {
    [self.context bindTexture:self];
}

- (void)unbind {
    // nothing to do
}

- (BOOL)isBound {
    return self.slot && self.slot == self.context.activeSlot;
}

- (void)setFilter:(GLuint)filter {
    assertBound(self);
    
    _filter = filter;
    glTexParameteri(self.textureType, GL_TEXTURE_MIN_FILTER, filter);
}

@end
