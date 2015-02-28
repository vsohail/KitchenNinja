//
//  ToxicIngredient.m
//  KitchenNinja
//
//  Created by Sohil on 2/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ToxicIngredient.h"

@implementation ToxicIngredient

- (void)didLoadFromCCB {
    [[self physicsBody] setCollisionType:@"toxic"];
}

@end
