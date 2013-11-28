//
//  GLWeakReference.h
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import <Foundation/Foundation.h>

// 
// Not threadsafe
@interface GLWeakReference : NSObject
@property (nonatomic, assign, readonly)   id target;

+ (id)referenceFor:(id)target;
+ (id)makeReferenceFor:(id)target;

@end

@interface NSObject (GLWeakReference)
// creates & returns weak reference if wasn't created before
- (GLWeakReference *)makeWeakReference;
// returns weak reference
- (GLWeakReference *)weakReference;

@end
