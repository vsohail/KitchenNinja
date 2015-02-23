//
//  Gameplay.m
//  KitchenNinja
//
//  Created by Sohil on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#define CONVEYER_SCLAE 1.56

@implementation Gameplay {
    CCNode *_conveyer1;
    CCNode *_conveyer2;
    NSArray *_conveyers;
    int _speed;
    CCPhysicsNode *_physicsNode;
    NSTimeInterval _timeInterval;
    NSArray *_ingredientList;
}

- (void)didLoadFromCCB {
    _speed = 1;
    _timeInterval = 0.0f;
    _conveyers = @[_conveyer1, _conveyer2];
    self.userInteractionEnabled = TRUE;
    _ingredientList = [[NSArray alloc] initWithObjects:@"Banana", @"Strawberry", @"Pineapple", nil];
}

- (void)update:(CCTime)delta {
    _timeInterval += delta;

    if (_timeInterval > 0.5f) {
        [self launchIngredient];
        _timeInterval = 0.0f;
    }

    for (CCNode *conveyer in _conveyers) {
        conveyer.position = ccp(conveyer.position.x - _speed, conveyer.position.y);

        // if the left corner is one complete width off the screen,
        // move it to the right
        if (conveyer.position.x <= (-1 * (conveyer.contentSize.width * CONVEYER_SCLAE))) {
            conveyer.position = ccp(conveyer.position.x +
                                 2 * (conveyer.contentSize.width * CONVEYER_SCLAE), conveyer.position.y);
        }
    }
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
}

- (void)launchIngredient {
    CCNode* ingredient = [CCBReader load:_ingredientList[arc4random() % [_ingredientList count]]];
    ingredient.position = ccpAdd(ccp(0, 72) ,ccp(0, 0));

    [_physicsNode addChild:ingredient];

    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 15000);
    [ingredient.physicsBody applyForce:force];
}

@end
