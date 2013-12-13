//
//  GLDrawingContext.m
//  Wrapper
//
//  Created by Denis Halabuzar on 12/12/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import "GLDrawingContext.h"

#import "EAGLContext+GLContext.h"

#import "GLProgram.h"
#import "GLTexture.h"
#import "GLVertexArray.h"

@interface GLDrawingContext ()
@property (retain)  NSArray                 *attributes;
@property (retain)  NSMutableDictionary     *sampler2Texture;

@property (retain)  GLProgram               *program;
@property (retain)  GLVertexArray           *vertArray;

@end

typedef struct {
    const GLchar    *attribName;
    GLuint          attribIndex;     // attribute index
    GLsizei         elementCount;
    GLData          elementType;
    GLboolean       normalized;
    GLsizei         ptrOffset;
} GLStructDescription;

@implementation GLDrawingContext

- (void)setupProgram {
    GLuint attrIndex = 0;
    for (NSString *attr in self.attributes) {
        [self.program setAttrib:attr location:attrIndex];
        ++attrIndex;
    }
}

- (void)describeStructures:(const GLStructDescription *)descriptors
                     count:(NSUInteger)count
{
    for (NSUInteger i = 0; i < count; ++i) {
        const GLStructDescription *descr = &descriptors[i];
        
        NSUInteger attribIndex = [self.attributes indexOfObject:[NSString stringWithUTF8String:descr->attribName]];
        assert(attribIndex != NSNotFound);
        
        
    }
}

- (void)activateTextures {
    [[[EAGLContext currentContext] context] activateTextures:self.sampler2Texture.allValues];
    
    for (NSString *sampler in self.sampler2Texture.allValues) {
        [self.program setUniform:sampler
                            to1i:[(GLTexture *)self.sampler2Texture[sampler] slotIndex]];
    }
}

@end
