//
//  Gameplay.m
//  KitchenNinja
//
//  Created by Sohil on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Knife.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#define CONVEYER_SCLAE 1.56

@implementation Gameplay {
    CCLabelTTF *_toxicityLabel;
    CCLabelTTF *_completenessLabel;
    CCLabelTTF *_timerLabel;
    CCNode *_conveyer1;
    CCNode *_conveyer2;
    CCSprite *_knife;
    id _rotate, _sequence;
    NSArray *_conveyers;
    int _speed;
    int _force;
    int _toxicity;
    int _completeness;
    int _timer;
    CCPhysicsNode *_physicsNode;
    NSTimeInterval _timeInterval;
    NSMutableArray *_allIngredients;
    NSArray *_ingredientList;
    NSArray *_toxicIngredientList;
    CGSize _screenSize;
    SEL _incrementSelector;
}

- (void)didLoadFromCCB {
    _timer = 10;
    _speed = 3;
    _force = 20000;
    _timeInterval = 0.0f;
    _toxicity = 0;
    _completeness = 0;
    _conveyers = @[_conveyer1, _conveyer2];
    self.userInteractionEnabled = TRUE;
    _allIngredients = [[NSMutableArray alloc] init];
    _ingredientList = [[NSArray alloc] initWithObjects:@"Banana", @"Strawberry", @"Pineapple", nil];
    _toxicIngredientList = [[NSArray alloc] initWithObjects:@"Shoe", @"Sock", nil];
    _rotate = [CCActionRotateBy actionWithDuration:0.05f angle:-45];
    _sequence = [CCActionSequence actionWithArray:@[_rotate, [[_rotate copy] reverse]]];
    [_physicsNode setCollisionDelegate:self];
    _incrementSelector = @selector(increment);
    [self schedule:_incrementSelector interval:1.0];
    _screenSize = [[CCDirector sharedDirector] viewSize];
    [_timerLabel setString:[NSString stringWithFormat:@"%d", _timer]];
}

- (void)increment {
    [_timerLabel setString:[NSString stringWithFormat:@"%d", _timer--]];
}

- (void)update:(CCTime)delta {
    static int flag = 1;
    _timeInterval += delta;

    if (_timer == 0 && flag == 1) {
        [_timerLabel setString:[NSString stringWithFormat:@"%d", _timer]];
        [self unschedule:_incrementSelector];
        flag = 0;
        [self setPaused:TRUE];
    }

    if (_timeInterval > 0.5f) {
        [_allIngredients addObject:[self launchIngredient]];
        _timeInterval = 0.0f;
    }

    NSMutableArray *escapedIngredients = [[NSMutableArray alloc] init];
    for (CCNode *ingredient in _allIngredients) {
        if (ingredient.position.x > _screenSize.width || ingredient.position.y > _screenSize.height ||
            ingredient.position.x < 0 || ingredient.position.y < 0) {
            [ingredient removeFromParent];
            [escapedIngredients addObject:ingredient];
        }
    }

    for (CCNode *ingredient in escapedIngredients) {
        [_allIngredients removeObject:ingredient];
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

- (CCNode *)launchIngredient {
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
    return ingredient;
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair toxic:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    if ([nodeB class] == [Knife class]) {
        [[_physicsNode space] addPostStepBlock:^{
            [nodeA removeFromParent];
            [_toxicityLabel setString:[NSString stringWithFormat:@"%d", ++_toxicity]];
        } key:nodeA];
    }
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair nonToxic:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    if ([nodeB class] == [Knife class]) {
        [[_physicsNode space] addPostStepBlock:^{
            [nodeA removeFromParent];
            [_completenessLabel setString:[NSString stringWithFormat:@"%d", ++_completeness]];
        } key:nodeA];
    }
}

@end
