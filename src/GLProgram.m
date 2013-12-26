//
//  GLProgram.m
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/20/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLProgram.h"
#import "GLShader.h"
#import "GLContext+Private.h"

@interface GLProgram ()
@property (nonatomic, retain)   NSMutableDictionary     *uniformCache;
@end

@implementation GLProgram

#pragma mark -
#pragma mark Construction

static NSString * GLShaderSource(NSString *fileName, NSString *extension) {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
    NSString *source = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
    assert(source);
    return source;
}

+ (id)objectWithVertShaderName:(NSString *)vertexShader
                  fragShader:(NSString *)fragmentShader
{
    GLShader *vShader = [GLShader objectAsVertexShaderWithSource:GLShaderSource(vertexShader, nil)];
    GLShader *fShader = [GLShader objectAsFragmentShaderWithSource:GLShaderSource(fragmentShader, nil)];

    GLProgram *me = [GLProgram object];
    
    me.vertShader = vShader;
    me.fragShader = fShader;
    
    assert(me);
    return me;
}

- (void)dealloc {
    // need detach shaders before program will became invalid after glDeleteProgram call
    self.vertShader = nil;
    self.fragShader = nil;
    
    self.uniformCache = nil;
    GLCall(glDeleteProgram(self.uId));
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.uId = GLCallR(glCreateProgram());
        self.uniformCache = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark -
#pragma mark GLObject

+ (GLObjectType)glType {
    return GLObjectTypeProgram;
}

- (void)internalBind:(BOOL)bind {
    GLCall(glUseProgram(bind ? self.uId : 0));
}

#pragma mark -
#pragma mark Uniform setters

#define IMPL_UNIFORM(argCount, type, GLtype) \
    DECL_UNIFORM(argCount, type, GLtype) {  \
        [self bind];    \
        GLint location = [self uniformLocation:uniform];    \
        assert(location != -1); \
        glUniform##argCount##type(location, UNIFORM_CALL_ARGS_##argCount);    \
        GLassertStateValid(); \
        [self unbind];  \
    }   \
    DECL_UNIFORM_V(argCount, type, GLtype) {    \
        [self bind];    \
        GLint location = [self uniformLocation:uniform];    \
        assert(location != -1); \
        glUniform##argCount##type##v(location, count, v); \
        GLassertStateValid(); \
        [self unbind];  \
    }

#define IMPL_UNIFORM_MATRIX(GLtype, type, argCount) \
    DECL_UNIFORM_MATRIX_V(GLtype, type, argCount) {  \
        [self bind];    \
        GLint location = [self uniformLocation:uniform];    \
        assert(location != -1); \
        glUniformMatrix##argCount##type##v(location, count, transpose, value); \
        GLassertStateValid(); \
        [self unbind];  \
    }

#define UNIFORM_CALL_ARGS_1 x
#define UNIFORM_CALL_ARGS_2 UNIFORM_CALL_ARGS_1, y
#define UNIFORM_CALL_ARGS_3 UNIFORM_CALL_ARGS_2, z
#define UNIFORM_CALL_ARGS_4 UNIFORM_CALL_ARGS_3, w

DECL_FOUR_METHODS(GLint, i, IMPL_UNIFORM);
DECL_FOUR_METHODS(GLfloat, f, IMPL_UNIFORM);

IMPL_UNIFORM_MATRIX(GLfloat, f, 2);
IMPL_UNIFORM_MATRIX(GLfloat, f, 3);
IMPL_UNIFORM_MATRIX(GLfloat, f, 4);

#pragma mark -
#pragma mark Etc

- (BOOL)link {
    assert(self.vertShader && [self.vertShader isCompiled]);
    assert(self.fragShader && [self.fragShader isCompiled]);
    
    GLCall(glLinkProgram(self.uId));
    [self.uniformCache removeAllObjects];
    
    return [self linkStatus];
}

- (BOOL)linkStatus {
    GLint status = 0;
    GLCall(glGetProgramiv(self.uId, GL_LINK_STATUS, &status));
    return status == GL_TRUE;
}

- (BOOL)validate {
    glValidateProgram(self.uId);
    GLint status = 0;
    glGetProgramiv(self.uId, GL_VALIDATE_STATUS, &status);
    GLassertStateValid();
    return status == GL_TRUE;
}

- (GLint)attribLocation:(NSString *)attribute {
    assert(attribute);
    return glGetAttribLocation(self.uId, attribute.UTF8String);
}

- (void)setAttrib:(NSString *)attribute location:(GLuint)location {
    assert(attribute);
    GLCall(glBindAttribLocation(self.uId, location, attribute.UTF8String));
}

- (void)associateAttributes:(const GLProgramAttrib2Loc *)associations
                      count:(NSUInteger)count
{
    assert(associations);
    for (NSUInteger i = 0; i < count; ++i) {
        const GLProgramAttrib2Loc *assoc = &associations[i];
        GLCall(glBindAttribLocation(self.uId, assoc->location, assoc->attrib));
    }
}

- (void)associateAttributes:(NSArray *)associations {
    assert(associations);
    assert((associations.count % 2) == 0);
    NSUInteger count = associations.count;
    for (NSUInteger i = 0; i < count; i += 2) {
        [self setAttrib:associations[i]
               location:[associations[i + 1] unsignedIntValue]];
    }
}

- (GLint)uniformLocation:(NSString *)uniform {
    GLint location = -1;
    NSNumber *locationNum = [self.uniformCache objectForKey:uniform];
    if (locationNum) {
        location = locationNum.integerValue;
    } else {
        location = glGetUniformLocation(self.uId, uniform.UTF8String);
        self.uniformCache[uniform] = @(location);
    }
    
    return location;
}

- (NSString *)infoLog {
    GLint length = 0;
    glGetProgramiv(self.uId, GL_INFO_LOG_LENGTH, &length);
    if (length == 0) {
        return nil;
    }
    
    GLchar *buffer = calloc(length, sizeof(GLchar));
    glGetProgramInfoLog(self.uId, length, &length, buffer);
    GLassertStateValid();
    
    NSString *log = [NSString stringWithUTF8String:buffer];
    free(buffer);
    return log;
}

- (void)setVertShader:(GLShader *)vertShader {
    if (vertShader != _vertShader) {
        if (_vertShader) {
            glDetachShader(self.uId, _vertShader.uId);
            GLassertStateValid();
        }
        
        if (vertShader) {
            GLAssert(vertShader.shaderType == GLShaderTypeVertex, @"wrong shader type");
            glAttachShader(self.uId, vertShader.uId);
            GLassertStateValid();
        }
        
        [_vertShader release];
        _vertShader = [vertShader retain];
    }
}

- (void)setFragShader:(GLShader *)fragShader {
    if (fragShader != _fragShader) {
        if (_fragShader) {
            glDetachShader(self.uId, _fragShader.uId);
            GLassertStateValid();
        }
        
        if (fragShader) {
            GLAssert(fragShader.shaderType == GLShaderTypeFragment, @"wrong shader type");
            glAttachShader(self.uId, fragShader.uId);
            GLassertStateValid();
        }
        
        [_fragShader release];
        _fragShader = [fragShader retain];
    }
}

@end

@implementation GLProgram (Construction)

+ (id)objectWithVertShaderName:(NSString *)vertexShader
                    fragShader:(NSString *)fragmentShader
          linkedWithAttributes:(NSArray *)attributes
{
    GLProgram *me = [self objectWithVertShaderName:vertexShader
                                        fragShader:fragmentShader];
    
    [me associateAttributes:attributes];
    
    GLAssert([me link], @"program link failed: %@", me.infoLog);
    
    return me;
}

@end
