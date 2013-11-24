//
//  GLWeakReference.h
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLWeakReference : NSObject
@property (nonatomic, assign, readonly)   id target;

+ (id)getReferenceFor:(id)object;
+ (id)referenceFor:(id)object;

@end

@interface NSObject (GLWeakReference)
- (GLWeakReference *)weakReference;
- (GLWeakReference *)getWeakReference;

@end
