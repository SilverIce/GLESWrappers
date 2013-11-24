//
//  GLContext+GLTextureManagement.m
//  openGLES Wrappers
//
//  Created by Denis Halabuzar on 11/22/13.
//  Copyright (c) 2013 denis. All rights reserved.
//

#import "GLContext+GLTextureManagement.h"
#import "GLTexture.h"

@interface GLContext () {
    GLActiveObjects     *_activeSlot;
}

// array of GLActiveObjects instances
@property (nonatomic, retain)   NSArray             *slots;
@property (nonatomic, assign)   GLActiveObjects     *activeSlot;

@end

@implementation GLContext (GLTextureManagement)

- (void)setupSlots {
    GLint slotCount = 0;
    glGetIntegerv(GL_MAX_TEXTURE_UNITS, &slotCount);
    NSMutableArray *slots = [NSMutableArray arrayWithCapacity:slotCount];
    for (GLint i = 0; i < slotCount; ++i) {
        GLActiveObjects *objects = [[GLActiveObjects new] autorelease];
        objects.slotIdx = i;
        [slots addObject:objects];
    }
    
    self.slots = [[slots copy] autorelease];
    
    GLint textureSlot;
    glGetIntegerv(GL_ACTIVE_TEXTURE, &textureSlot);
    self.activeSlot = [self slotWithIndex:textureSlot - GL_TEXTURE0];
}

- (GLActiveObjects *)slotWithIndex:(GLuint)index {
    for (GLActiveObjects *slotTmp in self.slots) {
        if (slotTmp.slotIdx == index) {
            return slotTmp;
        }
    }
    
    assert(false);
    return nil;
}

- (void)setActiveSlot:(GLActiveObjects *)activeSlot {
    assert(activeSlot);
    
    if (activeSlot != _activeSlot) {
        _activeSlot = activeSlot;
        glActiveTexture(GL_TEXTURE0 + activeSlot.slotIdx);
    }
}

- (void)activateTextures:(NSArray *)textures {
    assert(textures);
    assert(textures.count <= self.slots.count);
    
    // trying to find less active textures & bind onto slots occupied by them
    
    GLObjectType textureType = [textures.lastObject glType];
    NSArray *sortedSlots = nil;
    
    for (GLTexture *texture in textures) {
        // it assumes that we are trying activate textures of same type
        assert(textureType == texture.glType);
        
        ++texture.useCount;
        
        if (texture.slot) {
            continue;
        }
        
        if (!sortedSlots) {
            sortedSlots = [self sortSlotsByUse:textureType];
        }
        
        GLActiveObjects *slot = nil;
        for (GLActiveObjects *slotTmp in sortedSlots) {
            if ([textures containsObject:[slotTmp activeObjectOfClass:textureType]] == NO) {
                slot = slotTmp;
                break;
            }
        }
        
        assert(slot);
        
        [self putTexture:texture ontoSlot:slot];
    }
}

- (void)bindTexture:(GLTexture *)texture {
    assert(texture);
    
    if (texture.slot) {
        self.activeSlot = texture.slot;
    } else {
        GLActiveObjects *lessActive = [[self sortSlotsByUse:texture.glType] objectAtIndex:0];
        [self putTexture:texture ontoSlot:lessActive];
    }
    
    ++texture.useCount;
}

- (NSArray *)sortSlotsByUse:(GLObjectType)glType {
    NSArray *sortedSlots = [self.slots sortedArrayUsingComparator:^NSComparisonResult(GLActiveObjects *obj1, GLActiveObjects *obj2) {
        GLuint useCount1 = [(GLTexture *)[obj1 activeObjectOfClass:glType] useCount];
        GLuint useCount2 = [(GLTexture *)[obj2 activeObjectOfClass:glType] useCount];
        
        if (useCount1 < useCount2) {
            return NSOrderedDescending;
        }
        else if (useCount2 > useCount1) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
    
    assert(sortedSlots.count > 0);
    
    return sortedSlots;
}

// activate slot & put it into slot
- (void)putTexture:(GLTexture *)texture ontoSlot:(GLActiveObjects *)slot {
    assert(texture);
    assert(slot);
    assert(texture.slot == nil);
    
    GLTexture *prevTexture = (GLTexture *)[slot activeObjectOfObject:texture];
    assert(prevTexture != texture);
    if (prevTexture) {
        prevTexture.useCount = 0;
        prevTexture.slot = nil;
    }
    
    self.activeSlot = slot;
    [texture internalBind:YES];
    texture.slot = slot;
}

@end
