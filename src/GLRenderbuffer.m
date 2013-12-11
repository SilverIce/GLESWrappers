//
//  GLRenderbuffer.m
//  Wrapper
//
//  Created by Denis Halabuzar on 12/11/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import "GLRenderbuffer.h"

@interface GLRenderbuffer ()
@property (nonatomic, assign)   GLInternalFormat    format;
@property (nonatomic, assign)   GLSize              size;
@end

@implementation GLRenderbuffer

+ (id)objectWithInternalFormat:(GLInternalFormat)format
                          size:(GLSize)size
{
    GLRenderbuffer *me = [[self new] autorelease];
    if (me) {
        glGenRenderbuffers(1, &me->_uId);
        [me setFormat:format size:size];
    }
    
    return me;
}

+ (id)object {
    assert(false);
    return nil;
}

#pragma mark -
#pragma mark Initialization and Deallocation

- (void)dealloc {
    glDeleteRenderbuffers(1, &_uId);
    [super dealloc];
}

#pragma mark -
#pragma mark Public

- (void)setFormat:(GLInternalFormat)format
             size:(GLSize)size
{
    [self bind];
    self.format = format;
    self.size = size;
    glRenderbufferStorage(GL_RENDERBUFFER, format, size.width, size.height);
    [self unbind];
}

#pragma mark -
#pragma mark GLObject

- (void)internalBind:(BOOL)bind {
    glBindRenderbuffer(GL_RENDERBUFFER, bind ? _uId : 0);
}

+ (GLObjectType)glType {
    return GLObjectTypeRenderbuffer;
}

#pragma mark -
#pragma mark GLFramebufferRenderTarget

- (void)internalAttach:(BOOL)attach
           framebuffer:(GLFramebuffer *)framebuffer
               toPoint:(GLFramebufferAttachment)attachmentPoint
{
    if (attach) {
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, attachmentPoint, GL_RENDERBUFFER, self.uId);
    } else {
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, attachmentPoint, 0, 0);
    }
}

@end
