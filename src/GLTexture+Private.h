//
//  GLTexture+Private.h
//  Scrip2
//
//  Created by Denis Halabuzar on 12/11/13.
//  Copyright (c) 2013 Alexander. All rights reserved.
//

#import "GLTexture.h"

@interface GLTexture ()
// private api:
// a way to determine most used/active texture - how often it was activated
@property (nonatomic, assign)   GLuint              useCount;
@property (nonatomic, assign)   GLSlot              *slot;
@end
