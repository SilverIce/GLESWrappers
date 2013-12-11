//
//  GLContext+TextureManagement.c
//  Wrapper
//
//  Created by Denis Halabuzar on 11/28/13.
//  Copyright (c) 2013 IDAP Group. All rights reserved.
//

#import "GLContext.h"
#import "GLTexture+Private.h"

@interface GLContext () {
    GLSlot  *_activeSlot;
}
// array of GLActiveObjects instances
@property (nonatomic, retain)   NSArray     *slots;
@property (nonatomic, assign)   GLSlot      *activeSlot;

@end

//@interface GLContext (GLTextureManagement)
//- (void)setupSlots;
//
//@end

@implementation GLContext(GLTextureManagement)

- (void)deallocSlots {
    self.slots = nil;
}

- (void)setupSlots {
    GLint slotCount = 0;
    glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &slotCount);
    NSMutableArray *slots = [NSMutableArray arrayWithCapacity:slotCount];
    for (GLint i = 0; i < slotCount; ++i) {
        GLSlot *objects = [[GLSlot new] autorelease];
        objects.slotIdx = i;
        [slots addObject:objects];
    }
    
    self.slots = [[slots copy] autorelease];
    
    GLint textureSlot;
    glGetIntegerv(GL_ACTIVE_TEXTURE, &textureSlot);
    self.activeSlot = [self slotWithIndex:textureSlot - GL_TEXTURE0];
}

- (GLSlot *)slotWithIndex:(GLuint)index {
    for (GLSlot *slotTmp in self.slots) {
        if (slotTmp.slotIdx == index) {
            return slotTmp;
        }
    }
    
    assert(false);
    return nil;
}

- (GLSlot *)activeSlot {
    return _activeSlot;
}

- (void)setActiveSlot:(GLSlot *)activeSlot {
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
    
    [self.objectSet removeAllObjectsOfClass:textureType];
    
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
        
        GLSlot *slot = nil;
        for (GLSlot *slotTmp in sortedSlots) {
            if ([textures containsObject:[slotTmp activeObjectOfClass:textureType]] == NO) {
                slot = slotTmp;
                break;
            }
        }
        
        assert(slot);
        
        [self putTexture:texture ontoSlot:slot];
    }
}

- (void)activateTexture:(GLTexture *)texture {
    assert(texture);
    
    [self.objectSet removeAllObjectsOfClass:texture.glType];
    
    ++texture.useCount;
    
    if (texture.slot) {
        return;
    }
    
    GLSlot *lessActive = [self lessActiveSlotFor:texture.glType];
    [self putTexture:texture ontoSlot:lessActive];
}

- (void)_bindTexture:(GLTexture *)texture {
    assert(texture);
    
    if (texture.slot) {
        self.activeSlot = texture.slot;
    } else {
        GLSlot *lessActive = [self lessActiveSlotFor:texture.glType];
        [self putTexture:texture ontoSlot:lessActive];
    }
    
    ++texture.useCount;
    
    assert(texture.slot == self.activeSlot);
}

- (GLSlot *)lessActiveSlotFor:(GLObjectType)objType {
    GLSlot *lessActive = nil;
    GLuint useCountLast = 0;
    
    for (GLSlot *slot in self.slots) {
        GLuint useCountCurr = [(GLTexture *)[slot activeObjectOfClass:objType] useCount];
        if (useCountCurr < useCountLast || !lessActive) {
            lessActive = slot;
            useCountLast = useCountCurr;
        }
        
        if (useCountCurr == 0) {
            break;
        }
    }
    
    assert(lessActive);
    return lessActive;
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
- (void)putTexture:(GLTexture *)texture ontoSlot:(GLSlot *)slot {
    assert(texture);
    assert(slot);
    assert(texture.slot == nil);
    
    GLTexture *prevTexture = (GLTexture *)[slot activeObjectOfClass:texture.glType];
    assert(prevTexture != texture);
    if (prevTexture) {
        prevTexture.useCount = 0;
        prevTexture.slot = nil;
    }
    
    texture.slot = slot;
    [slot setActiveObject:texture];
    
    self.activeSlot = slot;
    [texture internalBind:YES];
}

@end
