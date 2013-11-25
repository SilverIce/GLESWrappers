//
//  GLVertexShader.m
//  openGLES Wrappers
//
//  Created by denis on 11/19/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLShader.h"

@interface GLShader ()
@property (nonatomic, assign)   GLuint      uId;
@property (nonatomic, assign)   GLuint      shaderType;
@end

@implementation GLShader

+ (id)object {
    assert(false);
    return nil;
}

+ (id)objectAsVertexShader {
    return [[[self alloc] initWithType:GL_VERTEX_SHADER] autorelease];
}

+ (id)objectAsFragmentShader {
    return [[[self alloc] initWithType:GL_FRAGMENT_SHADER] autorelease];
}

#pragma mark -
#pragma mark Initialization and Deallocation

- (void)dealloc {
    glDeleteShader(self.uId);
    [super dealloc];
}

- (id)initWithType:(GLuint)shaderType {
    self = [super init];
    if (self) {
        self.shaderType = shaderType;
        self.uId = glCreateShader(shaderType);
    }
    return self;
}

#pragma mark -
#pragma mark Overridden Methods

#pragma mark -
#pragma mark Public Methods

- (BOOL)compileSource:(NSString *)source {
    assert(source);
    
    typedef const char * GLConstStr;
    GLConstStr strings[1] = {source.UTF8String};
    glShaderSource(self.uId, 1, strings, NULL);
    
    glCompileShader(self.uId);
    
    GLint status = 0;
    glGetShaderiv(self.uId, GL_COMPILE_STATUS, &status);
    
    return status == GL_TRUE;
}

- (NSString *)compileLog {
    GLint logLength = 0;
    glGetShaderiv(self.uId, GL_INFO_LOG_LENGTH, &logLength);
    
    if (logLength == 0) {
        return nil;
    }
    
    GLchar *log = calloc(logLength + 1, 1);
    GLsizei length = 0;
    glGetShaderInfoLog(self.uId, logLength + 1, &length, log);
    
    NSString *string = [NSString stringWithUTF8String:log];
    free(log);
    
    return string;
}

#pragma mark -
#pragma mark Private Methods

@end
