//
//  Ingredient.m
//  KitchenNinja
//
//  Created by Sohil on 2/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Ingredient.h"

@implementation Ingredient

- (void)didLoadFromCCB {
    [[self physicsBody] setCollisionType:@"nonToxic"];
}

@end
