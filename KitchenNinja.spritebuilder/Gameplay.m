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
    CCSprite *_knife;
    id _rotate, _sequence;
    NSArray *_conveyers;
    int _speed;
    int _force;
    CCPhysicsNode *_physicsNode;
    NSTimeInterval _timeInterval;
    NSArray *_ingredientList;
    NSArray *_toxicIngredientList;
}

- (void)didLoadFromCCB {
    _speed = 3;
    _force = 20000;
    _timeInterval = 0.0f;
    _conveyers = @[_conveyer1, _conveyer2];
    self.userInteractionEnabled = TRUE;
    _ingredientList = [[NSArray alloc] initWithObjects:@"Banana", @"Strawberry", @"Pineapple", nil];
    _toxicIngredientList = [[NSArray alloc] initWithObjects:@"Shoe", @"Sock", nil];
    _rotate = [CCActionRotateBy actionWithDuration:0.05f angle:-45];
    _sequence = [CCActionSequence actionWithArray:@[_rotate, [[_rotate copy] reverse]]];
}

- (void)update:(CCTime)delta {
    _timeInterval += delta;

    if (_timeInterval > 0.5f) {
        [self launchIngredient];
        _timeInterval = 0.0f;
    }

    for (CCNode *conveyer in _conveyers) {
        conveyer.position = ccp(conveyer.position.x + _speed, conveyer.position.y);

        // if the left corner is one complete width off the screen,
        // move it to the right
        if (conveyer.position.x >= (conveyer.contentSize.width * CONVEYER_SCLAE)) {
            conveyer.position = ccp(conveyer.position.x -
                                 2 * (conveyer.contentSize.width * CONVEYER_SCLAE), conveyer.position.y);
        }
    }
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    @try
    {
        [super touchBegan:touch withEvent:event];
        if([_knife numberOfRunningActions] == 0) {
            [_knife runAction:[_sequence copy]];
        }
    }
    @catch(NSException* ex)
    {
    }
}

- (void)launchIngredient {
    int toxic = arc4random() % 2;
    CCNode* ingredient;
    if (toxic) {
        ingredient = [CCBReader load:_toxicIngredientList[arc4random() % [_toxicIngredientList count]]];
    } else {
        ingredient = [CCBReader load:_ingredientList[arc4random() % [_ingredientList count]]];
    }

    ingredient.position = ccpAdd(ccp(0, _conveyer1.position.y) ,ccp(0, 0));

    [_physicsNode addChild:ingredient];

    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, _force);
    [ingredient.physicsBody applyForce:force];
}

@end
