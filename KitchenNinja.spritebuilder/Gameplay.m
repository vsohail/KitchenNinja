//
//  Gameplay.m
//  KitchenNinja
//
//  Created by Sohil on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Knife.h"
#import "WinPopup.h"
#import "LossPopup.h"
#import "TutorialPopup.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "Time.h"
#import "Fury.h"
#import "Antidote.h"
#import "Ingredient.h"
#import "ToxicIngredient.h"
#import "PowerUp.h"
#import "Level.h"
#define CONVEYER_SCLAE 1.56

static NSMutableArray *levelArray;
static int levelNumber = 0;
static int totalLevels;

static int tutorialBasicNonToxic = 0;
static int tutorialBasicToxic = 0;
static int tutorialPowerUpFury = 0;
static int tutorialPowerUpTimer = 0;
static int tutorialPowerUpAntidote = 0;

static NSString *tutorialBasicNonToxicTip;
static NSString *tutorialBasicToxicTip;
static NSString *tutorialPowerUpFuryTip;
static NSString *tutorialPowerUpTimerTip;
static NSString *tutorialPowerUpAntidoteTip;

@implementation Gameplay {
    CCLabelTTF *_toxicityLabel;
    CCLabelTTF *_completenessLabel;
    CCLabelTTF *_timerLabel;
    CCLabelTTF *_levelNumberLabel;
    CCLabelTTF *_multiplierLabel;
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
    int _fury;
    int _completenessDelta;
    int _toxicityDelta;
    int _multiplier;
    CCPhysicsNode *_physicsNode;
    NSTimeInterval _timeInterval;
    NSTimeInterval _itemFrequency;
    NSMutableArray *_allIngredients;
    NSArray *_ingredientList;
    NSArray *_toxicIngredientList;
    NSMutableArray *_powerUpList;
    CGSize _screenSize;
    SEL _incrementSelector;
    SEL _furySelector;
    Level *_currLevel;
    TutorialPopup *_tutorialPopup;
}

- (id)init
{
    self = [super init];
    if (self) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            tutorialBasicNonToxicTip = [NSString stringWithFormat:@"%@\n%@", @"Chop Non-Toxic ingredients", @"to increase completeness to 100%"];
            tutorialBasicToxicTip = [NSString stringWithFormat:@"%@\n%@", @"Avoid chopping Toxic ingredients as", @"this increases toxicity"];
            tutorialPowerUpFuryTip = [NSString stringWithFormat:@"%@\n%@", @"Fury: Toxicity doesnt increase", @"for the next 5 seconds"];
            tutorialPowerUpTimerTip = @"Timer: Get a time boost";
            tutorialPowerUpAntidoteTip = @"Antidote: Decreases Toxicity";

            Level *level;
            levelArray = [[NSMutableArray alloc] init];
            // Level 1
            level = [[Level alloc] init];
            [level setSpeed:1];
            [level setTimer:120];
            [level setCompletenessDelta:20];
            [level setToxicityDelta:5];
            [level setForce:10000];
            [level setItemFrequency:1];
            [levelArray addObject:level];

            // Level 2
            level = [[Level alloc] init];
            [level setSpeed:3];
            [level setTimer:90];
            [level setCompletenessDelta:15];
            [level setToxicityDelta:10];
            [level setForce:20000];
            [level setItemFrequency:0.6];
            [levelArray addObject:level];

            // Level 3
            level = [[Level alloc] init];
            [level setSpeed:5];
            [level setTimer:60];
            [level setCompletenessDelta:10];
            [level setToxicityDelta:15];
            [level setForce:30000];
            [level setItemFrequency:0.4];
            [levelArray addObject:level];

            // Level 4
            level = [[Level alloc] init];
            [level setSpeed:8];
            [level setTimer:15];
            [level setCompletenessDelta:5];
            [level setToxicityDelta:20];
            [level setForce:50000];
            [level setItemFrequency:0.2];
            [levelArray addObject:level];

            totalLevels = (int) [levelArray count];
        });
    }

    return self;
}

- (void)didLoadFromCCB {
    _currLevel = [levelArray objectAtIndex:levelNumber];
    _timer = [_currLevel timer];
    _speed = [_currLevel speed];
    _force = [_currLevel force];
    _itemFrequency = [_currLevel itemFrequency];
    _completenessDelta = [_currLevel completenessDelta];
    _toxicityDelta = [_currLevel toxicityDelta];
    _toxicity = 0;
    _completeness = 0;
    _multiplier = 0;
    _timeInterval = 0.0f;
    _conveyers = @[_conveyer1, _conveyer2];
    self.userInteractionEnabled = TRUE;
    _allIngredients = [[NSMutableArray alloc] init];
    _ingredientList = [[NSArray alloc] initWithObjects:@"Banana", @"Strawberry", @"Pineapple", @"Onion", @"Tomato", @"Spinach", @"Pepper", @"Meat", @"Garlic", @"Cauliflower", @"Avocado", nil];
    _toxicIngredientList = [[NSArray alloc] initWithObjects:@"Shoe", @"Sock", nil];
    _powerUpList = [[NSMutableArray alloc] initWithObjects:@"Time", @"Fury", @"Antidote", nil];
    _rotate = [CCActionRotateBy actionWithDuration:0.05f angle:-45];
    _sequence = [CCActionSequence actionWithArray:@[_rotate, [[_rotate copy] reverse]]];
    [_physicsNode setCollisionDelegate:self];
    _incrementSelector = @selector(increment);
    _furySelector = @selector(fury:);
    [self schedule:_incrementSelector interval:1.0];
    _screenSize = [[CCDirector sharedDirector] viewSize];
    [_timerLabel setString:[NSString stringWithFormat:@"%d", _timer]];
    [_levelNumberLabel setString:[NSString stringWithFormat:@"%d", (levelNumber + 1)]];
    _tutorialPopup = (TutorialPopup *)[CCBReader load:@"TutorialPopup" owner:self];
}

- (void)increment {
    [_timerLabel setString:[NSString stringWithFormat:@"%d", _timer--]];
}

- (void) fury:(CCTime)delta {
    [_powerUpList addObject:@"Fury"];
}

- (void)gameOver:(BOOL)isWin {
    [self setPaused:TRUE];
    CCNode *popup;
    if (isWin) {
        popup = (WinPopup *)[CCBReader load:@"WinPopup" owner:self];
        [(WinPopup *)popup setScore:[self calculateScore]];
    } else {
        popup = (LossPopup *)[CCBReader load:@"LossPopup" owner:self];
        if (_toxicity >= 100) {
            [(LossPopup *)popup setReason:@"Too Toxic!"];
        } else {
            [(LossPopup *)popup setReason:@"Time is Up!"];
        }
    }
    popup.positionType = CCPositionTypeNormalized;
    popup.position = ccp(0.45, 0.5);
    [self addChild:popup];
}

- (void)showTutorialWithTip:(NSString *)tip {
    [self setPaused:TRUE];

    [_tutorialPopup setTutorialMessage:tip];
    _tutorialPopup.positionType = CCPositionTypeNormalized;
    _tutorialPopup.position = ccp(0.3, 0.3);
    [self addChild:_tutorialPopup];
}

- (void) continueLevel {
    [self setPaused:FALSE];
    [self removeChild:_tutorialPopup];
}

- (int) calculateScore {
    int score = 0;
    score = (100 - _toxicity);
    if (score < 50) {
        return score * (_multiplier / 2);
    }
    else {
        return score * (_multiplier);
    }
}

- (void)restartLevel {
    CCScene *restartScene = [CCBReader loadAsScene:@"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
}

- (void)loadNextLevel {
    levelNumber++;
    CCScene *nextScene = nil;

    if (levelNumber + 1 <= totalLevels) {
        nextScene = [CCBReader loadAsScene:@"Gameplay"];
    } else {
        levelNumber = 0;
        nextScene = [CCBReader loadAsScene:@"MainScene"];
    }

    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:nextScene withTransition:transition];
}

- (void)update:(CCTime)delta {
    static int flag = 1;
    _timeInterval += delta;

    if (_timer == 0 && flag == 1) {
        [_timerLabel setString:[NSString stringWithFormat:@"%d", _timer]];
        [self unschedule:_incrementSelector];
        flag = 0;
        [self gameOver:FALSE];
    }

    if (_timeInterval > _itemFrequency) {
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
    int powerUp = arc4random() % 10;
    int toxic = arc4random() % 3;
    CCNode* ingredient;
    if (powerUp > 2) {
        if (toxic == 2) {
            ingredient = [CCBReader load:_toxicIngredientList[arc4random() % [_toxicIngredientList count]]];
        } else {
            ingredient = [CCBReader load:_ingredientList[arc4random() % [_ingredientList count]]];
        }
    } else {
        ingredient = [CCBReader load:_powerUpList[arc4random() % [_powerUpList count]]];
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
        // load particle effect
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"ChopEffect"];
        // make the particle effect clean itself up, once it is completed
        explosion.autoRemoveOnFinish = TRUE;
        // place the particle effect on the seals position
        explosion.position = nodeA.position;
        // add the particle effect to the same node the seal is on
        [nodeA.parent addChild:explosion];
        if ([_powerUpList containsObject:@"Fury"] == NO) {
            [nodeA removeFromParent];
            if (!tutorialBasicToxic) {
                tutorialBasicToxic = 1;
                [self showTutorialWithTip:tutorialBasicToxicTip];
            }
            return;
        }
        [[_physicsNode space] addPostStepBlock:^{
            [nodeA removeFromParent];
            _toxicity += _toxicityDelta;
            _multiplier = 0;
            if (_toxicity > 100) {
                _toxicity = 100;
            }
            [_toxicityLabel setString:[NSString stringWithFormat:@"%d", _toxicity]];
            [_multiplierLabel setString:[NSString stringWithFormat:@"%d", _multiplier]];
            if (!tutorialBasicToxic) {
                tutorialBasicToxic = 1;
                [self showTutorialWithTip:tutorialBasicToxicTip];
            }
            if (_toxicity >= 100) {
                [self gameOver:FALSE];
            }
        } key:nodeA];
    }
    else if ([[nodeB class] isSubclassOfClass:[Ingredient class]] ||
             [[nodeB class] isSubclassOfClass:[ToxicIngredient class]] ||
             [[nodeB class] isSubclassOfClass:[PowerUp class]]) {
        [nodeA removeFromParent];
        [nodeB removeFromParent];
    }
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair nonToxic:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    if ([nodeB class] == [Knife class]) {
        // load particle effect
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"ChopEffect"];
        // make the particle effect clean itself up, once it is completed
        explosion.autoRemoveOnFinish = TRUE;
        // place the particle effect on the seals position
        explosion.position = nodeA.position;
        // add the particle effect to the same node the seal is on
        [nodeA.parent addChild:explosion];
        [[_physicsNode space] addPostStepBlock:^{
            [nodeA removeFromParent];
            _completeness += _completenessDelta;
            _multiplier ++;
            if (_completeness > 100) {
                _completeness = 100;
            }
            [_completenessLabel setString:[NSString stringWithFormat:@"%d", _completeness]];
            [_multiplierLabel setString:[NSString stringWithFormat:@"%d", _multiplier]];
            if (!tutorialBasicNonToxic) {
                tutorialBasicNonToxic = 1;
                [self showTutorialWithTip:tutorialBasicNonToxicTip];
            }
            if (_completeness >= 100) {
                [self gameOver:TRUE];
            }
        } key:nodeA];
    }
    else if ([[nodeB class] isSubclassOfClass:[Ingredient class]] ||
             [[nodeB class] isSubclassOfClass:[PowerUp class]]) {
        [nodeA removeFromParent];
        [nodeB removeFromParent];
    }
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair powerUp:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    if ([nodeB class] == [Knife class]) {
        [[_physicsNode space] addPostStepBlock:^{
            if ([nodeA class] == [Fury class]) {
                if (!tutorialPowerUpFury) {
                    tutorialPowerUpFury = 1;
                    [self showTutorialWithTip:tutorialPowerUpFuryTip];
                }
                [self furyPowerUpAction];
            } else if ([nodeA class] == [Antidote class]) {
                if (!tutorialPowerUpAntidote) {
                    tutorialPowerUpAntidote = 1;
                    [self showTutorialWithTip:tutorialPowerUpAntidoteTip];
                }
                [self antidotePowerUpAction];
            } else if ([nodeA class] == [Time class]) {
                if (!tutorialPowerUpTimer) {
                    tutorialPowerUpTimer = 1;
                    [self showTutorialWithTip:tutorialPowerUpTimerTip];
                }
                [self timePowerUpAction];
            }
            [nodeA removeFromParent];
        } key:nodeA];
    }
    else if ([[nodeB class] isSubclassOfClass:[PowerUp class]]) {
        [nodeA removeFromParent];
        [nodeB removeFromParent];
    }
}

-(void)furyPowerUpAction {
    [_powerUpList removeObject:@"Fury"];
    [self scheduleOnce:_furySelector delay:5.0];
}

-(void)antidotePowerUpAction {
    if (_toxicity != 0) {
        // Antidote effectiveness decreases with level advancement
        _toxicity -= _completenessDelta;
        if (_toxicity < 0) {
            _toxicity = 0;
        }
        [_toxicityLabel setString:[NSString stringWithFormat:@"%d", _toxicity]];
    }

}

-(void)timePowerUpAction {
    int time = (arc4random() % 4) + 1;
    _timer += time;
}

@end
