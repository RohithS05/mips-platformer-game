#########################################################################################
#
# CSCB58 Winter 2025 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Rohithkumar Sridharan, 1010409700, sridh133, rohithkumar.sridharan@mail.utoronto.ca
# # Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1-4 (all of them)
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 	1. Double Jump
# 	2. Different levels (3 levels)
# 	3. Pick-up effects (3 types of pickup effects)
#
# # Link to video demonstration for final submission:
# Youtube Link: https://youtu.be/9eYF6T4EQ9s
# MyMedia Link: https://play.library.utoronto.ca/watch/ce87e4c4768e472a3246c29746b5cd90
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
# # Are you OK with us sharing the video with people outside course staff? 
# - no
# # Any additional information that the TA needs to know:
# - (keyboard controls are: 
#	a for left movement, 
#	d for right movement
# 	w for vertical jump, 
#	q for left jump,
#	e for right jump,
#	z for quit game, and 
#	r for restart game.
#
# Win Condition: The goal of this game is to collect all coins in a given level, 
# 		 then you can move to the next level, once you finish 
#		 all 3 levels, you will win.
# Lose Condition: Each time your character touches the floor you lose 1 heart
#		 if you run out of hearts, you will lose.
#		 Additionally using 'q' to quit will also make you lose.
#
# Types of Pick-up efects:
#	1. Hearts can be picked up to restore 1 health if not at max health already
#	2. Red Mushrooms can be picked up to permanently increase Player height
#	3. Cyan Mushrooms can be picked up to permanently increase Player's jump power
#	   and also turn the Player colour into Cyan
#########################################################################################

.data
#Screen MACROS
.eqv BASE_ADDRESS     0x10008000
.eqv END_ADDRESS      0x10010000
.eqv UNIT_SIZE        4
.eqv UNITS_PER_ROW    64
.eqv DELAY_RATE	      60

#Colour MACROS
.eqv COLOUR_BLACK     0x00000000  # BLACK
.eqv PLATFORM_COLOUR  0x00FF7700  # ORANGE
.eqv COLOUR_BLUE      0x000000FF  # BLUE
.eqv COLOUR_YELLOW    0xFFFFFF00  # YELLOW
.eqv COLOUR_GREEN     0x0000FF00  # GREEN
.eqv COLOUR_RED       0x00FF0000  # RED
.eqv COLOUR_CYAN      0x0000FFFF  # CYAN
.eqv COLOUR_WHITE     0x00FFFFFF  # WHITE

#Keyboard
.eqv KEY_LEFT 0x61  # 'a'
.eqv KEY_RIGHT 0x64  # 'd'
.eqv KEY_JUMP 0x77  # 'w'
.eqv KEY_LEFT_JUMP 0x71  # 'q'
.eqv KEY_RIGHT_JUMP 0x65  # 'e'
.eqv KEY_RESTART  0x72  # 'r'
.eqv KEY_QUIT  0x7A  # 'z'
.eqv KEYBOARD_ADDRESS 0xffff0000

#Player Data (Starting)
.eqv STARTING_POS_X  2
.eqv STARTING_POS_Y  45
.eqv STARTING_WIDTH  3
.eqv STARTING_HEIGHT 5
.eqv STARTING_VEL_Y 0
.eqv STARTING_VEL_X 0
.eqv STARTING_JUMP_FORCE -5
.eqv STARTING_JUMP_FORCE_X 4
.eqv STARTING_HEALTH 3

#Respawn points for each level (x, y)
level_respawns:
	.word STARTING_POS_X, STARTING_POS_Y  # Level 0 (default)
	.word 50, 45  # Level 1
	.word 35, 45  # Level 2

#Player Data (Current)
player_x:      .word STARTING_POS_X  # X position (0-63)
player_y:      .word STARTING_POS_Y  # Y position (0-63)
player_width:  .word STARTING_WIDTH  # Width (units)
player_height: .word STARTING_HEIGHT  # Height (units)
player_colour: .word COLOUR_BLUE
player_vel_y:  .word STARTING_VEL_Y  # Vertical velocity
player_vel_x:   .word STARTING_VEL_X  # Horizontal velocity
gravity:       .word 1  # Gravity strength
jump_force:    .word STARTING_JUMP_FORCE  # Jump strength
jump_horiz_force: .word STARTING_JUMP_FORCE_X  # Horizontal push during diagonal jumps
single_jump: .word 0  # 0 = single jump can occur, 1 = single jump cannot occur
double_jump: .word 0  # 0 = double jump can occur, 1 = double jump cannot occur

#Health bar logic (fixed UI hearts)
health_bar_count:      .word   STARTING_HEALTH

#Level 1 pickups (original level)
level1_hearts_x:      .word 30
level1_hearts_y:      .word 50
level1_hearts_status: .word 1
level1_heart_count:   .word 1

level1_mushrooms_x:    .word 55
level1_mushrooms_y:    .word 20
	level1_mushroom_types: .word 0  # 0=red, 1=cyan
level1_mushroom_status: .word 1
level1_mushroom_count: .word 1

#Level 2 pickups
level2_hearts_x:      .word 5
level2_hearts_y:      .word 26
level2_hearts_status: .word 1
level2_heart_count:   .word 1

level2_mushrooms_x:    .word 25, 35
level2_mushrooms_y:    .word 55, 33
level2_mushroom_types: .word 1, 0
level2_mushroom_status: .word 1, 1
level2_mushroom_count: .word 2

#Level 3 pickups
level3_hearts_x:      .word 4
level3_hearts_y:      .word 35
level3_hearts_status: .word 1
level3_heart_count:   .word 1

level3_mushrooms_x:    .word 45, 20, 35
level3_mushrooms_y:    .word 10, 15, 30
level3_mushroom_types: .word 0, 1, 0
level3_mushroom_status: .word 1, 1, 1
level3_mushroom_count: .word 3

#Current pickup pointers
heart_x_array:         .word 0
heart_y_array:         .word 0
heart_status_array:    .word 0
heart_count:           .word 0

mushroom_x_array:      .word 0
mushroom_y_array:      .word 0
mushroom_type_array:   .word 0
mushroom_status_array: .word 0
mushroom_count:        .word 0

#Level 1 coins (5 coins)
level1_coins_x:    .word 49, 34, 10, 5, 49
level1_coins_y:    .word 47, 27, 10, 35, 7
level1_coins_status: .word 1, 1, 1, 1, 1
level1_coin_count: .word 5

#Level 2 coins (different configuration)
level2_coins_x:    .word 10, 25, 40, 55, 13, 35, 50
level2_coins_y:    .word 12, 30, 37, 45, 40, 20, 30
level2_coins_status: .word 1, 1, 1, 1, 1, 1, 1
level2_coin_count: .word 7

#Level 3 coins (most challenging)
level3_coins_x:    .word 5, 15, 25, 35, 45, 55, 10, 20, 30, 40, 50
level3_coins_y:    .word 55, 20, 30, 40, 18, 10, 20, 30, 40, 18, 10
level3_coins_status: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
level3_coin_count: .word 11

#Current coin pointers
coin_x_array:     .word 0
coin_y_array:     .word 0
coin_status_array: .word 0
coin_count:       .word 0
score:		.word 0

#Level 1 platforms (original level)
level1_platforms:
	.word 40, 25,  0, 45, 32  # x positions
	.word 10, 30, 50, 50, 60  # y positions
	.word 20, 20, 20, 10,  1  # widths
	.word  3,  3,  3,  3,  5  # heights
level1_count: .word 5

#Level 2 platforms
level2_platforms:
	.word 10, 30, 50, 20, 40  # x positions
	.word 15, 25, 35, 45, 55  # y positions
	.word 15, 10,  8, 12, 15  # widths
	.word  2,  2,  2,  2,  2  # heights
level2_count: .word 5

#Level 3 platforms
level3_platforms:
	.word  5, 25, 45, 15, 35,  0  # x positions
	.word 10, 20, 30, 40, 50,  0  # y positions
	.word  8,  8,  8,  8,  8,  0  # widths
	.word  2,  2,  2,  2,  2, 0  # heights
level3_count: .word 6

#Platform pointers
platform_x_array:    	 .word 0
platform_y_array:        .word 0
platform_width_array:    .word 0
platform_height_array:   .word 0
platform_count:          .word 0

#win and lose conditions
win_condition:	.word 0
lose_condition:	.word 0

#level handling logic
level:		.word 0
level_count:	.word 3

	.text
main:
	li $sp, 0x7ffffffc  # high stack address, aligned to 4
	jal clear_screen
	jal reset_player_stats
	jal reset_coins
	jal reset_health_bar
	jal reset_end_conditions
	jal reset_level
	jal reset_platforms

game_loop:
	jal handle_input
	jal draw_screen
	jal handle_win

	li $v0, 32
	li $a0, DELAY_RATE
	syscall

	j game_loop

#----------------------------
#draw_screen
#----------------------------
draw_screen:
	addi $sp, $sp, -4
	sw $ra, 0 ($sp)

	lw $s0, win_condition
	bnez $s0, draw_screen_win

	lw $s1, lose_condition
	bnez $s1, draw_screen_lose

	jal clear_screen
	jal update_player
	jal draw_platforms
	jal draw_coins
	jal draw_player
	jal draw_health_bar
	jal draw_hearts
	jal draw_mushrooms
	jal check_coin_collision
	jal check_heart_collision
	jal check_mushroom_collision
	j draw_screen_end

draw_screen_win:
	jal win_screen
	j draw_screen_end

draw_screen_lose:
	jal lose_screen
	j draw_screen_end

draw_screen_end:
	lw $ra, 0 ($sp)
	addi $sp, $sp, 4
	jr $ra

#----------------------------
#Player Functions
#----------------------------
respawn_player:
#Save return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

#Get current level
	lw $t0, level

#Calculate address offset for respawn point (8 bytes per level)
	sll $t1, $t0, 3  # level * 8
	la $t2, level_respawns
	add $t2, $t2, $t1  # address of current level's respawn point

#Load respawn coordinates
	lw $t3, 0($t2)  # x position
	lw $t4, 4($t2)  # y position

#Set respawn position
	sw $t3, player_x
	sw $t4, player_y

#Reset movement states (but keep other stats)
	li $t0, 0
	sw $t0, player_vel_y
	sw $t0, player_vel_x
	sw $t0, single_jump
	sw $t0, double_jump

#Restore return address
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

reset_player_stats:
#Reset X position
	li $t0, STARTING_POS_X  # Load starting X position
	sw $t0, player_x  # Store into current X position

#Reset Y position
	li $t0, STARTING_POS_Y  # Load starting Y position
	sw $t0, player_y  # Store into current Y position

#Reset width
	li $t0, STARTING_WIDTH  # Load starting width
	sw $t0, player_width  # Store into current width

#Reset height
	li $t0, STARTING_HEIGHT  # Load starting height
	sw $t0, player_height  # Store into current height

#Reset vertical velocity
	li $t0, STARTING_VEL_Y  # Load starting vertical velocity
	sw $t0, player_vel_y  # Store into current vertical velocity

#Reset horizontal velocity
	li $t0, STARTING_VEL_X  # Load starting horizontal velocity
	sw $t0, player_vel_x  # Store into current horizontal velocity

#Reset single jump flag
	li $t0, 0  # Single jump can occur (0)
	sw $t0, single_jump  # Store into single jump flag

#Reset double jump flag
	li $t0, 0  # Double jump can occur (0)
	sw $t0, double_jump  # Store into double jump flag

#Reset player colour
	li $t0, COLOUR_BLUE
	sw $t0, player_colour	

#Reset jump force
	li $t0, STARTING_JUMP_FORCE  # Load starting vertical velocity
	sw $t0, jump_force  # Jump strength

#Reset jump force x
	li $t0, STARTING_JUMP_FORCE_X  # Load starting horizontal velocity
	sw $t0, jump_horiz_force  # Store into current horizontal velocity

#Return from the function
	jr $ra

draw_player:
	lw $a0, player_x
	lw $a1, player_y
	lw $a2, player_width
	lw $a3, player_height
	lw $t0, player_colour

#Save return address
	sub $sp, $sp, 4
	sw $ra, 0($sp)

#Draw player rectangle
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	move $s4, $t0
	jal draw_rectangle

#Restore return address
	lw $ra, 0($sp)
	add $sp, $sp, 4
	jr $ra

update_player:
#Apply gravity
	lw $t0, player_vel_y
	lw $t1, gravity
	add $t0, $t0, $t1
	sw $t0, player_vel_y

#Update X position with velocity
	lw $t0, player_vel_x
	lw $t1, player_x
	add $t1, $t1, $t0

#Left boundary check
	bgez $t1, right_check
	li $t1, 0
right_check:
#Right boundary check
	lw $t2, player_width
	add $t3, $t1, $t2
	li $t4, 63
	ble $t3, $t4, store_x
	li $t1, 63
	sub $t1, $t1, $t2
store_x:
	sw $t1, player_x

#Update Y position with velocity
	lw $t0, player_vel_y
	lw $t1, player_y
	add $t1, $t1, $t0

#Ceiling collision (top of screen at Y=5)
	li $t2, 2
	bge $t1, $t2, check_platforms

#Player hit ceiling - bounce down
	li $t1, 3
	lw $t0, player_vel_y
	bgez $t0, check_platforms

#Reverse and reduce vertical velocity (bounce effect)
	neg $t0, $t0
	sra $t0, $t0, 1
	sw $t0, player_vel_y
	j check_platforms

check_platforms:
#Save registers before platform checks
	move $t9, $t1  # Save updated Y position

#Check if player is falling (vertical velocity > 0)
	lw $t0, player_vel_y
	blez $t0, floor_check  # If not falling, skip platform check

#Get player coordinates
	lw $t2, player_x  # Player left
	lw $t3, player_width  # Player width
	add $t4, $t2, $t3  # Player right
	lw $t5, player_height  # Player height
	add $t6, $t9, $t5  # Player bottom

#Initialize platform loop
	li $t0, 0  # Platform index
	lw $t1, platform_count

#Load platform array pointers
	lw $s5, platform_x_array  # Pointer to x positions
	lw $s6, platform_width_array  # Pointer to widths
	lw $s7, platform_y_array  # Pointer to y positions

platform_loop:
	beq $t0, $t1, floor_check  # If checked all platforms, continue to floor check

#Calculate offset
	sll $t7, $t0, 2  # offset = index * 4

#Load platform data using pointers
	add $t8, $s5, $t7  # platform_x_array + offset
	lw $s0, 0($t8)  # Platform left (x)

	add $t8, $s6, $t7  # platform_width_array + offset
	lw $s1, 0($t8)  # Platform width
	add $s2, $s0, $s1  # Platform right

	add $t8, $s7, $t7  # platform_y_array + offset
	lw $s3, 0($t8)  # Platform top (y)

#Check if player is horizontally aligned with platform
	bge $t2, $s2, next_platform  # If player left >= platform right, skip
	ble $t4, $s0, next_platform  # If player right <= platform left, skip

#Check if player's bottom is within platform top collision range
	sub $s4, $s3, 2  # Platform top - small margin (for landing detection)
	bgt $t9, $s3, next_platform  # If player top > platform top, skip (already below platform)
	bgt $s4, $t6, next_platform  # If platform top - margin > player bottom, skip (too high above)

#Collision detected - place player on top of platform
	sub $t9, $s3, $t5  # Set player Y to platform top - player height
	sw $zero, player_vel_y  # Stop vertical velocity
	sw $zero, single_jump  # Reset jump flag - player can jump again
	sw $zero, double_jump
	j store_updated_y

next_platform:
	addi $t0, $t0, 1  # Check next platform
	j platform_loop

floor_check:
#Floor collision (Y=60 is floor)
	lw $t5, player_height
	add $t6, $t9, $t5  # Player bottom
	li $t2, 65  # Floor Y position
	ble $t6, $t2, store_updated_y

#Player hit the floor - take damage, do NOT adjust anything else

#Save $ra before calling health_decrease
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal health_decrease  # Decrease health when hitting the floor

#Restore $ra after the call
	lw $ra, 0($sp)
	addi $sp, $sp, 4

#Skip storing player_y — it was already reset in reset_player_stats
	jr $ra

store_updated_y:
	sw $t9, player_y

#Apply friction to horizontal movement
	lw $t0, player_vel_x
	beqz $t0, no_friction
	blt $t0, 0, friction_neg
	addi $t0, $t0, -1  # Decelerate right
	bgez $t0, store_friction
	li $t0, 0
	j store_friction
friction_neg:
	addi $t0, $t0, 1  # Decelerate left
	blez $t0, store_friction
	li $t0, 0
store_friction:
	sw $t0, player_vel_x
no_friction:
	jr $ra

#----------------------------
#User Input Functions
#----------------------------

handle_input:
	li $t0, KEYBOARD_ADDRESS  # 0xffff0000
	lw $t1, 0($t0)  # Read ready bit
	beqz $t1, input_done  # If 0, no key pressed → exit

#Only process key if ready bit was 1
	lw $t2, 4($t0)  # Get key code

	beq $t2, KEY_LEFT, move_left  # 'a'
	beq $t2, KEY_RIGHT, move_right  # 'd'
	beq $t2, KEY_JUMP, jump  # "w"
	beq $t2, KEY_LEFT_JUMP, left_jump  # 'q'
	beq $t2, KEY_RIGHT_JUMP, right_jump  # 'e'
	beq $t2, KEY_RESTART, restart_game  # 'r'
	beq $t2, KEY_QUIT, quit_game  # 'z'

input_done:
	jr $ra
move_left:
	lw $t0, player_x
	li $t1, 1  # Left boundary
	ble $t0, $t1, no_move
	addi $t0, $t0, -3
	sw $t0, player_x
no_move:
	j input_done
move_right:
	lw $t0, player_x
	lw $t1, player_width
	li $t2, 63  # Right boundary
	add $t3, $t0, $t1
	bge $t3, $t2, no_move
	addi $t0, $t0, 3
	sw $t0, player_x
	j input_done

jump:
	lw $t0, single_jump
	beqz $t0, first_jump  # If single_jump == 0 → first jump allowed

	lw $t1, double_jump
	beqz $t1, second_jump  # If double_jump == 0 → second jump allowed

	j input_done  # Already used both jumps → skip

first_jump:
	lw $t2, jump_force
	sw $t2, player_vel_y
	li $t3, 1
	sw $t3, single_jump  # Mark first jump as used
	j input_done

second_jump:
	lw $t2, jump_force
	sw $t2, player_vel_y
	li $t3, 1
	sw $t3, double_jump  # Mark double jump as used
	j input_done


left_jump:
	lw $t0, single_jump
	beqz $t0, left_first_jump

	lw $t1, double_jump
	beqz $t1, left_second_jump

	j input_done

left_first_jump:
	lw $t2, jump_force
	sw $t2, player_vel_y

	lw $t2, jump_horiz_force
	neg $t2, $t2
	sw $t2, player_vel_x

	li $t3, 1
	sw $t3, single_jump
	j input_done

left_second_jump:
	lw $t2, jump_force
	sw $t2, player_vel_y

	lw $t2, jump_horiz_force
	neg $t2, $t2
	sw $t2, player_vel_x

	li $t3, 1
	sw $t3, double_jump
	j input_done

right_jump:
	lw $t0, single_jump
	beqz $t0, right_first_jump  # If single_jump == 0 → first jump allowed

	lw $t1, double_jump
	beqz $t1, right_second_jump  # If double_jump == 0 → second jump allowed

	j input_done  # Already used both jumps → no jump allowed

right_first_jump:
#Set vertical velocity
	lw $t2, jump_force
	sw $t2, player_vel_y

#Set horizontal velocity
	lw $t2, jump_horiz_force
	sw $t2, player_vel_x

	li $t3, 1
	sw $t3, single_jump  # Mark single jump as used
	j input_done

right_second_jump:
#Set vertical velocity
	lw $t2, jump_force
	sw $t2, player_vel_y

#Set horizontal velocity
	lw $t2, jump_horiz_force
	sw $t2, player_vel_x

	li $t3, 1
	sw $t3, double_jump  # Mark double jump as used
	j input_done

#----------------------------
#Restart and Quits Functions
#----------------------------
restart_game:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

#Reset all game state
	jal reset_player_stats
	jal reset_health_bar
	jal reset_end_conditions

#Reset level to 0
	sw $zero, level

#Reset all collectibles
	jal reset_coins
	jal reset_pickups

#Load level 0 data
	li $a0, 0
	jal load_level

#Respawn player
	jal respawn_player

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

quit_game:
	jal lose_screen
	li $v0, 10  # exit condition
	syscall

#----------------------------
#Platform functions
#----------------------------
reset_platforms:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $a0, 0  # Load level 0 by default
	jal load_level
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

draw_platforms:
#Save registers
	sub $sp, $sp, 4
	sw $ra, 0($sp)

#Initialize array pointers
	lw $t2, platform_x_array
	lw $t3, platform_y_array
	lw $t4, platform_width_array
	lw $t5, platform_height_array
	lw $t1, platform_count

	li $t0, 0  # index = 0

platform_loop_start:
	beq $t0, $t1, platform_loop_end

#Calculate offset
	sll $t7, $t0, 2  # offset = index * 4

#Load platform data using pointers
	add $t6, $t2, $t7
	lw $s0, 0($t6)  # x position

	add $t6, $t3, $t7
	lw $s1, 0($t6)  # y position

	add $t6, $t4, $t7
	lw $s2, 0($t6)  # width

	add $t6, $t5, $t7
	lw $s3, 0($t6)  # height

	li $s4, PLATFORM_COLOUR  # colour

	jal draw_rectangle

	addi $t0, $t0, 1
	j platform_loop_start

platform_loop_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#----------------------------
#draw_rectangle
#----------------------------
#Parameters:
#$s0 = x (unit-based)
#$s1 = y (unit-based)
#$s2 = width (units)
#$s3 = height (units)
#$s4 = colour
#----------------------------

draw_rectangle:
#Save all $t registers used
	sub $sp, $sp, 36  # Allocate space for 9 registers (9 * 4 bytes)
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $t8, 32($sp)

	li $t1, UNITS_PER_ROW  # units per row (64 for 256x256)
	move $t0, $s4  # Colour of the rectangle

	move $t2, $s1  # y_start
	add  $t3, $s1, $s3  # y_end = y + height
y_loop:
	bge $t2, $t3, end_draw_rect

	move $t4, $s0  # x_start
	add  $t5, $s0, $s2  # x_end = x + width
x_loop:
	bge $t4, $t5, end_x_loop

#offset = (y * 64 + x) * 4 (for 256x256 screen, 64 units per row)
	mult $t2, $t1
	mflo $t6
	add  $t6, $t6, $t4
	sll  $t6, $t6, 2  # word to byte offset
	li   $t7, BASE_ADDRESS
	add  $t6, $t6, $t7  # final address

#bounds check
	li   $t8, END_ADDRESS
	blt  $t6, BASE_ADDRESS, skip_pixel
	bge  $t6, $t8, skip_pixel

	sw   $t0, 0($t6)  # write color
skip_pixel:
	addi $t4, $t4, 1
	j x_loop
end_x_loop:
	addi $t2, $t2, 1
	j y_loop
end_draw_rect:
#Restore $t registers
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $t8, 32($sp)
	add $sp, $sp, 36  # Deallocate stack space

	jr $ra

#----------------------------
#Coin functions
#----------------------------
#Inputs:
#$a0 - x (unit-based)
#$a1 - y (unit-based)
#$a2 - status (1 = show coin, 0 = hide it with background)
#----------------------------
reset_coins:
#Save return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

#Reset score
	sw $zero, score

#Reset level 1 coins
	la $t0, level1_coins_status
	li $t1, 0
	li $t2, 5  # level1_coin_count = 5
reset_level1_coins:
	beq $t1, $t2, reset_level2_coins
	sw $1, 0($t0)  # Set status to 1
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	j reset_level1_coins

reset_level2_coins:
	la $t0, level2_coins_status
	li $t1, 0
	li $t2, 7  # level2_coin_count = 7
reset_level2_loop:
	beq $t1, $t2, reset_level3_coins
	sw $1, 0($t0)  # Set status to 1
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	j reset_level2_loop

reset_level3_coins:
	la $t0, level3_coins_status
	li $t1, 0
	li $t2, 11  # level3_coin_count = 11
reset_level3_loop:
	beq $t1, $t2, load_current_level_coins
	sw $1, 0($t0)  # Set status to 1
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	j reset_level3_loop

load_current_level_coins:
#Now load the current level's coin data
	lw $a0, level
	jal load_level

#Restore return address
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

draw_coins:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $t9, 0  # index = 0
	lw $t8, coin_count  # load coin_count
	lw $s0, coin_x_array  # load array pointers
	lw $s1, coin_y_array
	lw $s2, coin_status_array

coin_loop_start:
	beq $t9, $t8, coin_loop_end

	sll $t7, $t9, 2  # offset = index * 4

#Load coin data using pointers
	add $t6, $s0, $t7
	lw $a0, 0($t6)  # x position

	add $t6, $s1, $t7
	lw $a1, 0($t6)  # y position

	add $t6, $s2, $t7
	lw $a2, 0($t6)  # status

	jal draw_coin

	addi $t9, $t9, 1
	j coin_loop_start

coin_loop_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

draw_coin:
	sub $sp, $sp, 24  # Allocate space for 6 words (ra + s0-s4)
	sw $ra, 0($sp)  # Save return address
	sw $s0, 4($sp)  # Save s0
	sw $s1, 8($sp)  # Save s1
	sw $s2, 12($sp)  # Save s2
	sw $s3, 16($sp)  # Save s3
	sw $s4, 20($sp)  # Save s4

	li $t0, COLOUR_YELLOW  # Golden yellow
	li $t1, COLOUR_BLACK  # Background (hide)
	beqz $a2, draw_hidden  # If status == 0 → draw black
	move $t2, $t0  # Coin color
	j draw_it
draw_hidden:
	move $t2, $t1  # Background color
draw_it:
#Set up parameters for draw_rectangle:
	move $s0, $a0  # x (temporarily use s0)
	move $s1, $a1  # y (temporarily use s1)
	li   $s2, 1  # width (units)
	li   $s3, 1  # height (units)
	move $s4, $t2  # colour (coin or black)
	jal draw_rectangle

#Restore registers
	lw $ra, 0($sp)  # Restore return address
	lw $s0, 4($sp)  # Restore s0
	lw $s1, 8($sp)  # Restore s1
	lw $s2, 12($sp)  # Restore s2
	lw $s3, 16($sp)  # Restore s3
	lw $s4, 20($sp)  # Restore s4
	add $sp, $sp, 24  # Deallocate stack space
	jr $ra  # Return

#----------------------------
#Coin Collision Check
#----------------------------
check_coin_collision:
#Save registers
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	sw $t6, 28($sp)

	li $t0, 0  # coin index
	lw $t1, coin_count
	lw $t2, coin_x_array  # load array pointers
	lw $t3, coin_y_array
	lw $t4, coin_status_array

	lw $t5, player_x
	lw $t6, player_y
	lw $t7, player_width
	lw $t8, player_height

#Expand hitbox by 1 unit in all directions
	addi $t5, $t5, -1  # player_x - 1 (left buffer)
	addi $t7, $t7, 2  # width + 2 (1 buffer each side)
	addi $t6, $t6, -1  # player_y - 1 (top buffer)
	addi $t8, $t8, 2  # height + 2 (1 buffer each side)

check_coin_loop:
	beq $t0, $t1, end_coin_check

	sll $t9, $t0, 2  # offset = index * 4

#Load coin data using pointers
	add $a0, $t2, $t9
	lw $s0, 0($a0)  # coin_x

	add $a1, $t3, $t9
	lw $s1, 0($a1)  # coin_y

	add $a2, $t4, $t9
	lw $s2, 0($a2)  # coin_status

#Only check if coin is active
	beqz $s2, skip_coin

#Check if coin is inside player hitbox
	blt $s0, $t5, skip_coin  # coin_x < player_x → skip
	add $s3, $t5, $t7  # player_x + width
	bge $s0, $s3, skip_coin  # coin_x >= player_x + width → skip

	blt $s1, $t6, skip_coin  # coin_y < player_y → skip
	add $s4, $t6, $t8  # player_y + height
	bge $s1, $s4, skip_coin  # coin_y >= player_y + height → skip

#Collision detected: mark coin as collected
	sw $zero, 0($a2)

#Update score
	lw $s5, score
	addi $s5, $s5, 1
	sw $s5, score

skip_coin:
	addi $t0, $t0, 1
	j check_coin_loop

end_coin_check:
#Restore registers
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	lw $t6, 28($sp)
	addi $sp, $sp, 32
	jr $ra

#--------------------------------
#General Pickup Effect Functions
#--------------------------------

reset_pickups:
#Reset all hearts across all levels
	li $t1, 1

#Level 1 hearts (1 heart)
	sw $t1, level1_hearts_status

#Level 2 hearts (2 hearts)
	sw $t1, level2_hearts_status
	sw $t1, level2_hearts_status+4

#Level 3 hearts (3 hearts)
	sw $t1, level3_hearts_status
	sw $t1, level3_hearts_status+4
	sw $t1, level3_hearts_status+8

#Reset all mushrooms across all levels
#Level 1 mushrooms (2 mushrooms)
	sw $t1, level1_mushroom_status
	sw $t1, level1_mushroom_status+4

#Level 2 mushrooms (3 mushrooms)
	sw $t1, level2_mushroom_status
	sw $t1, level2_mushroom_status+4
	sw $t1, level2_mushroom_status+8

#Level 3 mushrooms (4 mushrooms)
	sw $t1, level3_mushroom_status
	sw $t1, level3_mushroom_status+4
	sw $t1, level3_mushroom_status+8
	sw $t1, level3_mushroom_status+12

	jr $ra

#----------------------------
#draw_heart
#----------------------------
#Parameters:
#$a0 - x (unit-based)
#$a1 - y (unit-based)
#$a2 - status
#1 = in-world heart (visible, collidable)
#0 = health bar heart (visible, not collidable)
#----------------------------
reset_health_bar:
	li $t9, STARTING_HEALTH
	sw $t9, health_bar_count
	jr $ra

health_increase:
	addi $sp, $sp, -4
	sw $t6, 4($sp)  # Save $t0

	lw $t6, health_bar_count
	addi $t6, $t6, 1
	sw $t6, health_bar_count

	lw $t6, 4($sp)  # Restore $t0
	addi $sp, $sp, 4

	jr $ra

health_decrease:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t0, health_bar_count
	addi $t0, $t0, -1

	blez $t0, player_death

	sw $t0, health_bar_count
	jal respawn_player

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
player_death:
	addi $t1, $zero, 1
	sw $t1, lose_condition

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

draw_health_bar:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $t0, 0  # index = 0
	lw $t1, health_bar_count  # array length
draw_health_bar_loop:
	beq $t0, $t1, draw_health_bar_end

	sll $t2, $t0, 3  # offset = index * 6
	addi $t2, $t2, 1

	move $a0, $t2  # x pos
	li $a1, 1  # y pos
	li $a2, 0  # status
	jal draw_heart

	addi $t0, $t0, 1
	j draw_health_bar_loop
draw_health_bar_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

draw_hearts:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $t0, 0  # index = 0
	lw $t1, heart_count  # array length
	lw $t2, heart_x_array
	lw $t3, heart_y_array
	lw $t4, heart_status_array
draw_hearts_loop_start:
	beq $t0, $t1, draw_hearts_loop_end

	sll $t5, $t0, 2  # offset = index * 4 (corrected from $0 to $t0)
	addi $t0, $t0, 1  # increment index

#Check heart status
	add $t6, $t4, $t5
	lw $a2, 0($t6)  # status
	beqz $a2, draw_hearts_loop_start

#Load heart coordinates
	add $t6, $t2, $t5
	lw $a0, 0($t6)  # x pos
	add $t6, $t3, $t5
	lw $a1, 0($t6)  # y pos

	jal draw_heart
	j draw_hearts_loop_start  # corrected jump target
draw_hearts_loop_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

draw_heart:
	addi $sp, $sp, -36  # Space for $ra and $t0-$t8
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	sw $t6, 28($sp)
	sw $t7, 32($sp)

	li $t0, COLOUR_GREEN  # Heart color (green)

#Row 0 - two top dots
	addi $s0, $a0, 1
	move  $s1, $a1
	li    $s2, 1
	li    $s3, 1
	move  $s4, $t0
	jal   draw_rectangle

	addi $s0, $a0, 3
	move  $s1, $a1
	li    $s2, 1
	li    $s3, 1
	move  $s4, $t0
	jal   draw_rectangle

#Row 1 - full width
	move  $s0, $a0
	addi  $s1, $a1, 1
	li    $s2, 5
	li    $s3, 1
	move  $s4, $t0
	jal   draw_rectangle

#Row 2 - full width
	move  $s0, $a0
	addi  $s1, $a1, 2
	li    $s2, 5
	li    $s3, 1
	move  $s4, $t0
	jal   draw_rectangle

#Row 3 - middle 3 units
	addi  $s0, $a0, 1
	addi  $s1, $a1, 3
	li    $s2, 3
	li    $s3, 1
	move  $s4, $t0
	jal   draw_rectangle

#Row 4 - bottom tip
	addi  $s0, $a0, 2
	addi  $s1, $a1, 4
	li    $s2, 1
	li    $s3, 1
	move  $s4, $t0
	jal   draw_rectangle

#Restore and return
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	lw $t6, 28($sp)
	lw $t7, 32($sp)
	addi $sp, $sp, 36
	jr $ra

#----------------------------
#Heart Collision Check
#----------------------------
check_heart_collision:
#Save registers (20 registers * 4 bytes = 80 bytes)
	sub $sp, $sp, 80
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $t8, 32($sp)
	sw $t9, 36($sp)
	sw $s0, 40($sp)
	sw $s1, 44($sp)
	sw $s2, 48($sp)
	sw $s3, 52($sp)
	sw $s4, 56($sp)
	sw $s5, 60($sp)
	sw $s6, 64($sp)
	sw $s7, 68($sp)
	sw $a0, 72($sp)
	sw $a1, 76($sp)
	sw $ra, -4($sp)  # push $ra before adjusting $sp if needed

	li $t0, 0  # heart index
	lw $t1, heart_count
	lw $t2, heart_x_array
	lw $t3, heart_y_array
	lw $t4, heart_status_array

	lw $t5, player_x
	lw $t6, player_y
	lw $t7, player_width
	lw $t8, player_height

#Expand hitbox by 1 unit in all directions
	addi $t5, $t5, -1  # player_x - 1 (left buffer)
	addi $t7, $t7, 2  # width + 2 (1 buffer each side)
	addi $t6, $t6, -1  # player_y - 1 (top buffer)
	addi $t8, $t8, 2  # height + 2 (1 buffer each side)

check_heart_loop:
	beq $t0, $t1, end_heart_check

	sll $t9, $t0, 2  # offset for word arrays (x, y)

#Load heart X and Y
	add $a0, $t2, $t9
	lw  $s0, 0($a0)  # heart_x

	add $a1, $t3, $t9
	lw  $s1, 0($a1)  # heart_y

#Load heart status using byte addressing
	add $a2, $t4, $t0  # 1 byte per heart
	lb  $s2, 0($a2)  # heart_status

	beqz $s2, skip_heart  # if status == 0, skip

#heart size
	li $s3, 5
	li $s4, 5

	add $s5, $s0, $s3  # heart right
	add $s6, $s1, $s4  # heart bottom

	add $s7, $t5, $t7  # player right
	add $t9, $t6, $t8  # player bottom (reuse $t9)

#Collision detection (AABB)
	blt $s5, $t5, skip_heart  # heart_right < player_left
	blt $s7, $s0, skip_heart  # player_right < heart_left
	blt $s6, $t6, skip_heart  # heart_bottom < player_top
	blt $t9, $s1, skip_heart  # player_bottom < heart_top

#Collision confirmed
	sb $zero, 0($a2)  # Set status = 0 (collected)
	jal health_increase  # Increase health

skip_heart:
	addi $t0, $t0, 1
	j check_heart_loop

end_heart_check:
#Restore registers
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $t8, 32($sp)
	lw $t9, 36($sp)
	lw $s0, 40($sp)
	lw $s1, 44($sp)
	lw $s2, 48($sp)
	lw $s3, 52($sp)
	lw $s4, 56($sp)
	lw $s5, 60($sp)
	lw $s6, 64($sp)
	lw $s7, 68($sp)
	lw $a0, 72($sp)
	lw $a1, 76($sp)
	lw $ra, -4($sp)  # Restore return address
	addi $sp, $sp, 80
	jr $ra

#----------------------------
#draw_mushroom
#----------------------------
#Inputs:
#$a0 = x
#$a1 = y
#$a2 = type (0 = red, 1 = cyan)
#$a3 = status (0 = skip, 1 = draw)
#----------------------------
draw_mushrooms:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $t0, 0  # index = 0
	lw $t1, mushroom_count  # array length
	lw $t2, mushroom_x_array
	lw $t3, mushroom_y_array
	lw $t4, mushroom_type_array
	lw $t5, mushroom_status_array

draw_mushrooms_loop_start:
	beq $t0, $t1, draw_mushrooms_loop_end

	sll $t6, $t0, 2  # Offset = Index * 4
	addi $t0, $t0, 1  # increment index early

#Check heart status
	add $t7, $t5, $t6
	lw $a3, 0($t7)  # status
	beqz $a3, draw_mushrooms_loop_start

#Load heart coordinates
	add $t7, $t2, $t6
	lw $a0, 0($t7)  # x pos
	add $t7, $t3, $t6
	lw $a1, 0($t7)  # y pos

#Load type
	add $t7, $t4, $t6
	lw $a2, 0($t7)  # xtype

	jal draw_mushroom
	j draw_mushrooms_loop_start

draw_mushrooms_loop_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

draw_mushroom:
#Save used registers
	sub $sp, $sp, 20
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)

	move $t0, $a0  # x
	move $t1, $a1  # y
	move $t2, $a2  # type

#Choose colour for cap
	li $t3, COLOUR_RED
	beqz $t2, set_colour
	li $t3, COLOUR_CYAN
set_colour:
#Draw cap top: (x, y)
	move $s0, $t0  # x
	move $s1, $t1  # y
	li   $s2, 1  # width
	li   $s3, 1  # height
	move $s4, $t3  # colour
	jal draw_rectangle

#Draw cap middle row: (x-1, y+1), (x, y+1), (x+1, y+1)
	addi $s1, $t1, 1  # y + 1
	li   $s2, 1  # width
	li   $s3, 1  # height
	move $s4, $t3

	addi $s0, $t0, -1  # x - 1
	jal draw_rectangle

	move $s0, $t0  # x
	jal draw_rectangle

	addi $s0, $t0, 1  # x + 1
	jal draw_rectangle

#Draw stem: white, at (x, y+2), (x, y+3)
	li   $s4, COLOUR_WHITE
	move $s0, $t0  # x
	li   $s2, 1  # width
	li   $s3, 1  # height

	addi $s1, $t1, 2
	jal draw_rectangle

	addi $s1, $t1, 3
	jal draw_rectangle

#Restore and return
	lw $ra, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

#----------------------------
#Mushroom Collision Check
#----------------------------
check_mushroom_collision:
#Save used registers including $ra
	sub $sp, $sp, 40
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $t8, 32($sp)
	sw $ra, 36($sp)

	li $t0, 0  # mushroom index
	lw $t1, mushroom_count
	lw $t2, mushroom_x_array
	lw $t3, mushroom_y_array
	lw $t4, mushroom_status_array
	lw $t5, mushroom_type_array

	lw $t6, player_x  # player_left
	lw $t7, player_y  # player_top
	lw $t8, player_width  # player_right = player_x + width
	add $t8, $t6, $t8
	lw $t9, player_height  # player_bottom = player_y + height
	add $t9, $t7, $t9

#Expand hitbox by 1 unit in all directions
	addi $t6, $t6, -1  # player_x - 1 (left buffer)
	addi $t8, $t8, 2  # width + 2 (1 buffer each side)
	addi $t7, $t7, -1  # player_y - 1 (top buffer)
	addi $t9, $t9, 2  # height + 2 (1 buffer each side)

mushroom_loop:
	beq $t0, $t1, end_mushroom_check

	sll $s0, $t0, 2  # offset = index * 4

	lw $s1, 0($t2)  # mushroom_x
	lw $s2, 0($t3)  # mushroom_y
	lw $s3, 0($t4)  # mushroom_status
	lw $s4, 0($t5)  # mushroom_type

	beqz $s3, skip_mushroom  # if status == 0, skip

#Calculate mushroom hitbox (more generous collision area)
	addi $s5, $s1, -2  # mushroom_left = x - 2 (wider area)
	addi $s6, $s1, 2  # mushroom_right = x + 2 (wider area)
	addi $s7, $s2, 5  # mushroom_bottom = y + 5

#More forgiving collision check - any overlap counts
#Check if player is to the left of mushroom
	bge $t8, $s5, check_right  # player_right > mushroom_left
	j skip_mushroom  # else no collision

check_right:
#Check if player is to the right of mushroom
	blt $t6, $s6, check_top  # player_left < mushroom_right
	j skip_mushroom  # else no collision

check_top:
#Check if player is above mushroom
	bge $t9, $s2, check_bottom  # player_bottom > mushroom_top
	j skip_mushroom  # else no collision

check_bottom:
#Check if player is below mushroom (more generous for hitting from below)
	blt $t7, $s7, collision_detected  # player_top < mushroom_bottom
	j skip_mushroom  # else no collision

collision_detected:
#Collision detected
	sw $zero, 0($t4)  # status = 0

	beqz $s4, red_mushroom

#Cyan mushroom behavior
	lw $s7, jump_force
	addi $s7, $s7, -1  # increase jump power by 3
	sw $s7, jump_force
	li $s7, COLOUR_CYAN
	sw $s7, player_colour
	j skip_mushroom

red_mushroom:
#Red mushroom behavior
	lw $s7, player_height
	addi $s7, $s7, 1  # increase player height by 3
	sw $s7, player_height

	lw $s7, player_y
	addi $s7, $s7, -1  # adjust y position upward by 3
	sw $s7, player_y

skip_mushroom:
	addi $t0, $t0, 1
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	addi $t4, $t4, 4
	addi $t5, $t5, 4
	j mushroom_loop

end_mushroom_check:
#Restore registers including $ra
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $t8, 32($sp)
	lw $ra, 36($sp)
	addi $sp, $sp, 40
	jr $ra


#----------------------------
#clear_screen
#----------------------------
clear_screen:
	li $t0, BASE_ADDRESS
	li $t1, COLOUR_BLACK
	li $t2, END_ADDRESS
clear_loop:
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	blt $t0, $t2, clear_loop
	jr $ra

#----------------------------
#Level handling
#----------------------------
reset_level:
	sw $zero, level
	jr $ra

add_level:
	addi $sp, $sp, -4
	sw $t0, 0($sp)

	lw $t0, level
	addi, $t0, $t0, 1
	sw $t0, level

	lw $t0, 0($sp)
	addi $sp, $sp, 4

	jr $ra

load_level:
#Input: $a0 = level number (0-based)
	addi $sp, $sp, -4
	sw $ra, 0($sp)

#Load platform data
	beq $a0, 0, load_level0
	beq $a0, 1, load_level1
	beq $a0, 2, load_level2

load_level0:
#Platforms for level 0 (original level 1)
	la $t0, level1_platforms
	la $t1, level1_platforms+20
	la $t2, level1_platforms+40
	la $t3, level1_platforms+60
	lw $t4, level1_count

#Coins for level 0
	la $t5, level1_coins_x
	la $t6, level1_coins_y
	la $t7, level1_coins_status
	lw $t8, level1_coin_count

#Hearts for level 0
	la $s0, level1_hearts_x
	sw $s0, heart_x_array
	la $s0, level1_hearts_y
	sw $s0, heart_y_array
	la $s0, level1_hearts_status
	sw $s0, heart_status_array
	lw $s0, level1_heart_count
	sw $s0, heart_count

#Mushrooms for level 0
	la $s0, level1_mushrooms_x
	sw $s0, mushroom_x_array
	la $s0, level1_mushrooms_y
	sw $s0, mushroom_y_array
	la $s0, level1_mushroom_types
	sw $s0, mushroom_type_array
	la $s0, level1_mushroom_status
	sw $s0, mushroom_status_array
	lw $s0, level1_mushroom_count
	sw $s0, mushroom_count

	j store_level_data

load_level1:
#Platforms for level 1 (original level 2)
	la $t0, level2_platforms
	la $t1, level2_platforms+20
	la $t2, level2_platforms+40
	la $t3, level2_platforms+60
	lw $t4, level2_count

#Coins for level 1
	la $t5, level2_coins_x
	la $t6, level2_coins_y
	la $t7, level2_coins_status
	lw $t8, level2_coin_count

#Hearts for level 1
	la $s0, level2_hearts_x
	sw $s0, heart_x_array
	la $s0, level2_hearts_y
	sw $s0, heart_y_array
	la $s0, level2_hearts_status
	sw $s0, heart_status_array
	lw $s0, level2_heart_count
	sw $s0, heart_count

#Mushrooms for level 1
	la $s0, level2_mushrooms_x
	sw $s0, mushroom_x_array
	la $s0, level2_mushrooms_y
	sw $s0, mushroom_y_array
	la $s0, level2_mushroom_types
	sw $s0, mushroom_type_array
	la $s0, level2_mushroom_status
	sw $s0, mushroom_status_array
	lw $s0, level2_mushroom_count
	sw $s0, mushroom_count

	j store_level_data

load_level2:
#Platforms for level 2 (original level 3)
	la $t0, level3_platforms
	la $t1, level3_platforms+24
	la $t2, level3_platforms+48
	la $t3, level3_platforms+72
	lw $t4, level3_count

#Coins for level 2
	la $t5, level3_coins_x
	la $t6, level3_coins_y
	la $t7, level3_coins_status
	lw $t8, level3_coin_count

#Hearts for level 2
	la $s0, level3_hearts_x
	sw $s0, heart_x_array
	la $s0, level3_hearts_y
	sw $s0, heart_y_array
	la $s0, level3_hearts_status
	sw $s0, heart_status_array
	lw $s0, level3_heart_count
	sw $s0, heart_count

#Mushrooms for level 2
	la $s0, level3_mushrooms_x
	sw $s0, mushroom_x_array
	la $s0, level3_mushrooms_y
	sw $s0, mushroom_y_array
	la $s0, level3_mushroom_types
	sw $s0, mushroom_type_array
	la $s0, level3_mushroom_status
	sw $s0, mushroom_status_array
	lw $s0, level3_mushroom_count
	sw $s0, mushroom_count

store_level_data:
#Store platform pointers (unchanged)
	sw $t0, platform_x_array
	sw $t1, platform_y_array
	sw $t2, platform_width_array
	sw $t3, platform_height_array
	sw $t4, platform_count

#Store coin pointers (unchanged)
	sw $t5, coin_x_array
	sw $t6, coin_y_array
	sw $t7, coin_status_array
	sw $t8, coin_count

#Hearts and mushrooms pointers already stored during level loading

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#----------------------------
#Win Screen and Lose Screen
#---------------------------
reset_end_conditions:
	sw $zero, win_condition
	sw $zero, lose_condition

	jr $ra

handle_win:
#Save return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t0, score
	lw $t1, coin_count
	bne $t0, $t1, handle_win_end  # If not all coins collected, exit

	lw $t2, level
	lw $t3, level_count

#Check if last level
	addi $t4, $t3, -1
	bge $t2, $t4, game_complete

#Load next level
	addi $t2, $t2, 1
	sw $t2, level

#Reset game state for new level
	move $a0, $t2
	jal load_level

#Reset score and respawn player
	sw $zero, score
	jal respawn_player

	j handle_win_end
game_complete:
	li $t5, 1
	sw $t5, win_condition
handle_win_end:
#Restore return address
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

win_screen:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

#Clear the screen first
	jal clear_screen

#Set color for the WIN text (bright green)
	li $s4, COLOUR_GREEN  # Bright green color

#Draw "W"
#Left vertical line of W
	li $s0, 2  # X position
	li $s1, 20  # Y position
	li $s2, 5  # Width
	li $s3, 25  # Height
	jal draw_rectangle

#Right vertical line of W
	li $s0, 22  # X position
	li $s1, 20  # Y position
	li $s2, 5  # Width
	li $s3, 25  # Height
	jal draw_rectangle

#Bottom horizontal of W
	li $s0, 7  # X position
	li $s1, 40  # Y position
	li $s2, 15  # Width
	li $s3, 5  # Height
	jal draw_rectangle

#Middle vertical of W
	li $s0, 12  # X position
	li $s1, 30  # Y position
	li $s2, 5  # Width
	li $s3, 10  # Height
	jal draw_rectangle

#Draw "I"
#Vertical line of I
	li $s0, 32  # X position
	li $s1, 20  # Y position
	li $s2, 5  # Width
	li $s3, 25  # Height
	jal draw_rectangle

#Draw "N"
#Left vertical line of N
	li $s0, 42  # X position
	li $s1, 20  # Y position
	li $s2, 5  # Width
	li $s3, 25  # Height
	jal draw_rectangle

#Diagonal of N (using multiple rectangles)
	li $s0, 47  # X position
	li $s1, 20  # Y position
	li $s2, 5  # Width
	li $s3, 5  # Height
	jal draw_rectangle

	li $s0, 49  # X position
	li $s1, 25  # Y position
	li $s2, 5  # Width
	li $s3, 5  # Height
	jal draw_rectangle

	li $s0, 51  # X position
	li $s1, 30  # Y position
	li $s2, 5  # Width
	li $s3, 5  # Height
	jal draw_rectangle

	li $s0, 53  # X position
	li $s1, 35  # Y position
	li $s2, 5  # Width
	li $s3, 5  # Height
	jal draw_rectangle

#Right vertical line of N
	li $s0, 57  # X position
	li $s1, 20  # Y position
	li $s2, 5  # Width
	li $s3, 25  # Height
	jal draw_rectangle

	li $v0, 32  # syscall: sleep
	li $a0, 100
	syscall

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

lose_screen:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

#Clear the screen
	jal clear_screen

#Set color to bright red
	li $s4, COLOUR_RED  # Red color

#=== Draw "L" (adjusted) ===
#Vertical part (shorter)
	li $s0, 1
	li $s1, 22
	li $s2, 3
	li $s3, 17
	jal draw_rectangle

#Horizontal part
	li $s0, 1
	li $s1, 39
	li $s2, 12
	li $s3, 3
	jal draw_rectangle

#=== Draw "O" (shifted left) ===
#Left vertical
	li $s0, 16
	li $s1, 22
	li $s2, 3
	li $s3, 20
	jal draw_rectangle

#Right vertical
	li $s0, 29
	li $s1, 22
	li $s2, 3
	li $s3, 20
	jal draw_rectangle

#Top horizontal
	li $s0, 19
	li $s1, 22
	li $s2, 10
	li $s3, 3
	jal draw_rectangle

#Bottom horizontal
	li $s0, 19
	li $s1, 39
	li $s2, 10
	li $s3, 3
	jal draw_rectangle

#=== Draw "S" (shifted left) ===
#Top horizontal
	li $s0, 36
	li $s1, 22
	li $s2, 12
	li $s3, 3
	jal draw_rectangle

#Middle horizontal
	li $s0, 36
	li $s1, 30
	li $s2, 12
	li $s3, 3
	jal draw_rectangle

#Bottom horizontal
	li $s0, 36
	li $s1, 39
	li $s2, 12
	li $s3, 3
	jal draw_rectangle

#Left vertical (top half)
	li $s0, 36
	li $s1, 22
	li $s2, 3
	li $s3, 8
	jal draw_rectangle

#Right vertical (bottom half)
	li $s0, 45
	li $s1, 30
	li $s2, 3
	li $s3, 9
	jal draw_rectangle

#=== Draw "E" (shifted left) ===
#Vertical line
	li $s0, 51
	li $s1, 22
	li $s2, 3
	li $s3, 20
	jal draw_rectangle

#Top horizontal
	li $s0, 54
	li $s1, 22
	li $s2, 9
	li $s3, 3
	jal draw_rectangle

#Middle horizontal
	li $s0, 54
	li $s1, 30
	li $s2, 7
	li $s3, 3
	jal draw_rectangle

#Bottom horizontal
	li $s0, 54
	li $s1, 39
	li $s2, 9
	li $s3, 3
	jal draw_rectangle

	li $v0, 32
	li $a0, 100
	syscall

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra