## KitchenNinja
### Objective
Chop all the right ingredients in each level. Levels will feature a recipe shown at the start of the level and will involve good reflexes and memory, while encouraging the player to chop the right ingredients as they move on a conveyer belt and penalizing them otherwise. Earlier levels will emphasize more on gameplay mechanics then on reflexes and memory.


### Gameplay Mechanics
The player will be a chef centered on the screen with two machetes. Tapping on the left half of the screen triggers the left machete and and the right side triggers the right one. The machetes lands on a fixed spot on a conveyer belt on which ingredients move from left to right or right to left. Whatever is chopped goes into the recipe pot, which will be visible with an animation. There will be a toxicity meter on the screen which will increase if people start chopping distinctly toxic elements like a shoe, a sock, or like rat poison. If toxicity hits 100%, its game over. The stars achieved for a level depend on how close you are to the recipe shown at the start and also how low the toxicity level is. A perfect level gets you 5 stars. The belt gets faster and more unpredictable as the levels increase. Also the recipes get more and more complex.


### Level Design
The different levels have a lot in common, as what changes is only the complexity of the recipe and the speed/ randomness of the conveyer belt. Later levels may feature newer ingredients, both good and bad. Future levels may also change the kitchen background to a better restaurant to show the chef going up the ranks because of his success.


## Technical
### Scenes
* Main Menu
* Level Select
* Gameplay

### Controls/Input
* Tap based controls
 * Left half of screen is left machete
 * Right half of screen is right machete
 * Pause button
 * Restart button


## Classes/CCBs
### Scenes
* Main Menu
* Level Select
* Gameplay

### Nodes/Sprites
* Chef
* Machete Right
* Machete Left
* CookingPot
* Conveyer Belt
* Ingredients
* Non-Toxic
* Toxic


## MVP Milestones (Tentative)
* Week 1
 * Implement Menus and Scenes
 * Start working on player(Chef)
* Week 2
 * Complete player(Chef)
 * machete controls with sound
 * Start working on Conveyer belt mechanics
 * (PM notes by Harshit) Fix conveyer belt animation nit for faster levels
* Week 3
 * Design Ingredient sprite.
 * Start working on game logic
 * (PM notes by Harshit) When knife hits an object partially, results in multiple objects being sent off track. Needs a fix of some sort
* Week 4
 * Start working on initial level
 * Tune controls of machete with respect to ingredients
 * (PM notes by Harshit) Create some timing mechanism in game instead of inifinte levels
* Week 5 (TODO) PM suggestion
 * Design extra levels
 * Work on level select screen
 * Create a better scoring model
 * (PM notes by Harshit) Create some kind of power ups, or other kind of items to make gameplay more interesting
 * (PM notes by Harshit) Could add some animations for combos etc
* Week 6
 * Test and tune the game
 * Stretch Goal: Add different backgrounds for the kitchen
 * (PM notes by Harshit) Prepare for poster, add a way to navigate between levels and better animation for sprites

## Background Art Credits
http://fernandojl.deviantart.com/art/Background-Kitchen-308233091
