//
//  EAGLContext+GLContext.m
//  Wrapper
//
//  Created by Denis Halabuzar on 11/26/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import "EAGLContext+GLContext.h"
#import "GLContext.h"
#import <objc/runtime.h>

@implementation EAGLContext (GLContext)

- (GLContext *)context {
    static char kGLContext;
    GLContext *context = objc_getAssociatedObject(self, &kGLContext);
    if (!context) {
        context = [GLContext object];
        objc_setAssociatedObject(self, &kGLContext, context, OBJC_ASSOCIATION_RETAIN);
    }
    
    return context;
}

@end
