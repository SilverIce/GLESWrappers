//
//  GLWeakReference.m
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLWeakReference.h"
#import <objc/runtime.h>

static const char __kGLWeakRef__;

@implementation GLWeakReference

@synthesize target  = _target;

static void _IDPDeallocMethod(id _self, SEL _cmd) {
    GLWeakReference *ref = [GLWeakReference getReferenceFor:_self];
    if (ref) {
        ref.target = nil;
    }
    
    IMP superIMP = [[_self superclass] instanceMethodForSelector:@selector(dealloc)];
    superIMP(_self, _cmd);
}

static Class _IDPGetSubclass(Class class) {
    const char *cName = [[NSStringFromClass(class) stringByAppendingString:@"_GLWeakArrayRef"] cStringUsingEncoding:NSASCIIStringEncoding];
    
    Class subClass = objc_getClass(cName);
    if (subClass) {
        return subClass;
    }
    
    subClass = objc_allocateClassPair(class, cName, 0);
    
    Method deallocMethod = class_getInstanceMethod([NSObject class], @selector(dealloc));
    const char *types = method_getTypeEncoding(deallocMethod);
    class_addMethod(subClass, @selector(dealloc), (IMP)_IDPDeallocMethod, types);
    
    objc_registerClassPair(subClass);
    
    return subClass;
}

+ (id)getReferenceFor:(id)object {
    GLWeakReference *ref = objc_getAssociatedObject(object, &__kGLWeakRef__);
    return ref;
}

+ (id)referenceFor:(id)object {
    GLWeakReference *ref = [self getReferenceFor:object];
    
    if (nil == ref) {
        ref = [[self new] autorelease];
        ref.target = object;
        objc_setAssociatedObject(object, &__kGLWeakRef__, ref, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        object_setClass(object, _IDPGetSubclass([object class]));
    }
    
    return ref;
}

- (void)setTarget:(id)target {
    assert(!target || !_target);
    _target = target;
}

- (void)dealloc {
    if (self.target) {
        objc_setAssociatedObject(self.target, &__kGLWeakRef__, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.target = nil;
    }
    
    [super dealloc];
}

@end