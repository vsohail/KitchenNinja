//
//  PowerUp.m
//  KitchenNinja
//
//  Created by Sohil Veljee on 4/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PowerUp.h"

@implementation PowerUp

- (void)didLoadFromCCB {
    [[self physicsBody] setCollisionType:@"powerUp"];
}

@end
