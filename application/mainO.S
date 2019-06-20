
# Masks for Pushbuttons
BTN_R_MASK 				= 0x2
BTN_C_MASK 				= 0x10
BTN_L_MASK 				= 0x8
BTN_D_MASK 				= 0x1
BTN_U_MASK 				= 0x4
PUSHBUTTON_MASK			= 0x1F

# Values to display specific segments on the display
DISPLAY_SEGMENT_A 		= 16
DISPLAY_SEGMENT_B 		= 17
DISPLAY_SEGMENT_C 		= 18
DISPLAY_SEGMENT_D 		= 19
DISPLAY_SEGMENT_E 		= 20
DISPLAY_SEGMENT_F 		= 21
DISPLAY_SEGMENT_G 		= 22
DISPLAY_SEGMENT_BLANK 	= 28

# ======================
# === Port Addresses ===
# ======================

# Nexys 4 board base I/O interface ports compatible with the Nexy$4 I/O interface
# Port Addresses
PORT_LEDS 			= 0xbf800000		# (o) LEDs
PORT_SLSWTCH		= 0xbf800004		# (i) slide switches
PORT_PBTNS 			= 0xbf800008		# (i) pushbuttons inputs

PORT_SEVENSEG_EN 	= 0xbf700000		# (o) 7 Segment enable
PORT_SEVENSEG_HGH	= 0xbf700004		# (o) 7 Segment Higher Display
PORT_SEVENSEG_LOW	= 0xbf700008		# (o) 7 Segment Lower Display
PORT_SEVENSEG_DP	= 0xbf70000c		# (o) 7 segment Decimal Point Display

# =====================================
# === Register bit mappings (masks) ===
# =====================================

#  bit masks for pushbuttons and switches for seven segment emulator
MSK_ALLBTNS		= 0x1F		# Buttons are in bits[5:0]
MSK_PBTNS 		= 0x0F		# Mask for 4 buttons to display on LED
MSK_BTN_CENTER 	= 0x10		# Pushbutton Center is bit 4
MSK_BTN_LEFT 	= 0x08		# Pushbutton Left is bit 3
MSK_BTN_UP 		= 0x04		# Pushbutton Up is bit 2
MSK_BTN_RIGHT 	= 0x02		# Pushbutton Right is bit 25
MSK_BTN_DOWN 	= 0x01		# Pushbutton Down is bit 0

MSK_SW7			= 0x80		# Slide switch 7 is bit 7
MSK_SW6 		= 0x40		# Slide switch 6 is bit 6
MSK_SW5 		= 0x20		# Slide switch 5 is bit 5
MSK_SW4 		= 0x10		# Slide switch 4 is bit 4
MSK_SW3 		= 0x08		# Slide switch 3 is bit 3
MSK_SW2 		= 0x04		# Slide switch 2 is bit 2
MSK_SW1 		= 0x02		# Slide switch 1 is bit 1
MSK_SW0 		= 0x01		# Slide switch 0 is bit 0

MSK_SW15 		= 0x80		# Slide switch 15 is bit 7
MSK_SW14 		= 0x40		# Slide switch 14 is bit 6
MSK_SW13 		= 0x20		# Slide switch 13 is bit 5
MSK_SW12 		= 0x10		# Slide switch 12 is bit 4
MSK_SW11 		= 0x08		# Slide switch 11 is bit 3
MSK_SW10 		= 0x04		# Slide switch 10 is bit 2
MSK_SW09 		= 0x02		# Slide switch 09 is bit 25
MSK_SW08 		= 0x01		# Slide switch 08 is bit 0


# bit mask for LEDs
MSK_LEDS_LO = 0xFF		# Mask for rightmost 8 LEDs on the Nexy4
MSK_LEDS_HI = 0xFF00	# Mask for the lefmost 8 LEDs on the Nexy4


# bit mask for display character codes and decimal points
MSK_CCODE 		= 0x1F		# Character codes are in lower 5 bits
MSK_DECPTS 		= 0x0F		# Decimal points 3 - 0 are in bits 3 to 0
MSK_DECPTS_HI 	= 0xF0		# Decimal points 7-4 are in bits 3 to 0
MSK_HEXDIGIT 	= 0x0F		# Hex digits only take 4 bits


# nibble masks
MSKLOWNIB 	= 0x0F		# Mask out high nibble of byte
MSKHIGHNIB 	= 0xF0		# Mask out low nibble of byte
INVLOWNIB 	= 0x0F		# Invert low nibble of byte

# =============================
# === Useful Data Constants ===
# =============================

#  Constants for True, False, Null and INT_ACK
FALSE 	= 0x00
TRUE 	= 0x01
NULL 	= 0x00
INT_ACK = 0x01

# Character code table for special characters
# Decimal digits 0 to 15 display '0'to 'F'
CC_BASE		= 0x10		# Base value for special characters
CC_SEGBASE	= 0x10		# Base value for segment display special characters
						#				 abcdefg
CC_SEGA 	= 0x10		# Segment A		[1000000]
CC_SEGB 	= 0x11		# Segment B		[0100000]
CC_SEGC 	= 0x12		# Segment C		[0010000]
CC_SEGD 	= 0x13		# Segment D		[0001000]
CC_SEGE 	= 0x14		# Segment E		[0000100]
CC_SEGF 	= 0x15		# Segment F		[0000010]
CC_SEGG 	= 0x16		# Segment G		[0000001]
CC_UCH 		= 0x17		# Upper Case H
CC_UCL 		= 0x18		# Upper Case L
CC_UCR 		= 0x19		# Upper Case R
CC_LCL 		= 0x1A		# Lower Case L
CC_LCR 		= 0x1B		# Lower Case R
CC_SPACE 	= 0x1C		# Space (blank)


#-------------------------------------------------------
# Values for lighting different segments of display.
#-------------------------------------------------------
SEVENSEG_EN_BPM_STATE	= 0x30		# Shuts off 5th and 6th segment of display.
SEVENSEG_EN_INFO_STATE	= 0x00		# Turns on all segments of display.

SEVENSEG_BLANK		= 0x00000000		# Value for setting a blank value for display.
SEVENSEG_A			= 0x10000000		# Value for lighting A segment of display.
SEVENSEG_B			= 0x11000000		# Value for lighting B segment of display.
SEVENSEG_C			= 0x12000000		# Value for lighting C segment of display.
SEVENSEG_D			= 0x13000000		# Value for lighting D segment of display.
SEVENSEG_E			= 0x14000000		# Value for lighting E segment of display.
SEVENSEG_F			= 0x15000000		# Value for lighting F segment of display.
SEVENSEG_G			= 0x16000000		# Value for lighting G segment of display.

SEVENSEG_ALL_G		= 0x16161616		// Lights half of display with G segments.

SEVENSEG_HR		= 0x171B0000
SEVENSEG_HR_LOW	= 0x171B1800
SEVENSEG_HR_HIGH= 0x171B1717

#-------------------------------------------------------
# Sevenseg State Constants
#-------------------------------------------------------
SEVENSEG_INIT_STATE= 0x0
SEVENSEG_BPM_STATE = 0x1
SEVENSEG_MAX_STATE = 0x2
SEVENSEG_MIN_STATE = 0x3

// NOT AN ACCURATE DELAY.
DELAY_6_SECOND		= 0x00A00000	// "12,500,000", used for six second delay.


# Different variables for lookup table, BotInfo register, LOCx_REG, LOCy_REG, Old_Heading register,
# 7 segment displays, and other variables required. All are byte wides except SP_TEMP which is word
# wide.
	.data
	.align 2    # Put next label on a word boundary

MIN_HRT_RATE:		.word 0x00
MAX_HRT_RATE:		.word 0x00
AVG_HRT_RATE:		.word 0x00

LST_HRT_RATE:		.word 0x00		// Address containing last known heart rate.
SVN_SEG_LST:		.word 0x00		// Value containing last written value to seven segment display.

.text

.globl main
main:
main_INIT:
			la		$t0, (MIN_HRT_RATE)				// INIT code.
			li		$t1, 55
			sw		$t1,  ($t0)
			la		$t0, (MAX_HRT_RATE)
			li		$t1, 171
			sw		$t1,  ($t0)
			la		$t0, (AVG_HRT_RATE)
			li		$t1, 72
			sw		$t1,  ($t0)

			lui   	$12, 0xbf80    					// $12 = address of LEDs (0xbf800000)
			li		$15, PORT_SEVENSEG_DP				// Load sevenseg decimal points register.
			li		$14, 0xB7							// Activate 3rd and 5th decimal points.
			sw		$14, 0($15)							// Write to DP enable register.
			li		$20, SEVENSEG_INIT_STATE			// STATE REGISTER FOR SEVENSEG DISPLAY
			// Add delay loop or use the system call to get time.
			li		$s1, DELAY_6_SECOND // Load value for 6 second delay.

# ==================
# *** Main  Loop ***
# ==================

/* ----------------------------------------------------------
 *	CURRENT ROUTINES IN LOOP:
 *		1.) Seven Segment Display Information
 *		2.) Calculate BPM (TO BE ADDED)
 *
 * ----------------------------------------------------------
 */
Main_L0:
#			jal		update_sevenseg						// Function to update display.
#			nop
		// Add function to wait for a pulse.
			//beq		$0, $0, wait_for_beat
			//nop
			jal     calculate_bpm		// this function must wait for pulse.
			nop
		// Once 6 seconds passes:
			//jal		$0, $0, average_results		// this function must wait for pulse
			//nop


			jal     disp_info_option
			nop
		// Write results
temp_rtn:
			beq		$0, $0, Main_L0
			nop

calculate_bpm:
			jal	 	disp_info_option
			nop
			// Add code to check for heart rate here.
			sub		$s1, $s1, 1				// Subtract 1 from delay counter.
			bne		$s1, 0x0, calculate_bpm	// Stay in loop until time passes.
			nop
// Calculate averages, return to main.
			li		$s1, DELAY_6_SECOND 	// Load value for 6 second delay.
			li		$t0, PORT_LEDS
			li		$t1, 0x0005555			// TEST CODE TO UPDATE RESULT
			sw		$t1, ($t0)
			beq		$0, $0, temp_rtn		// CHANGE THIS TO USE STACK POINTER LATER

/* ----------------------------------------------------------
 *	Module for updating lower half of the seven segment
 *  display based on the state.
 *
 * ----------------------------------------------------------
 */
update_sevenseg:
			la		$t6, LST_HRT_RATE						// Load address of last known heart rate.
			lw		$t7, ($t6)								// Load value from address.
			bne		$20, SEVENSEG_INIT_STATE, svsg_else_1	// If statement for initial state.
			nop												// Branch delay slot.
			li		$t0, PORT_SEVENSEG_LOW					// Load address for lower half of seven segment.
			li		$t1, SEVENSEG_ALL_G						// Write blank values to lower half for now.
			sw		$t1, 0($t0)
			li		$t0, PORT_LEDS
			li		$t1, 0x0000FFFF			// TEST CODE TO UPDATE RESULT
			sw		$t1, ($t0)
			sw		$t5, 0($t6)								// Store last known heart rate.
			jr		$31
			nop												// Branch delay slot.
svsg_else_1:
			bne		$20, SEVENSEG_BPM_STATE, svsg_else_2	// If statement for average heart rate state.
			nop
			la		$t5, (AVG_HRT_RATE)						// Branch delay slot.
			lw		$t5, ($t5)
			sw		$t5, 0($t6)								// Store last known heart rate.
			j		write_2_disp
			nop												// Branch delay slot.
svsg_else_2:
			bne		$20, SEVENSEG_MAX_STATE, svsg_else_3	// If statement for max heart rate state.
			nop												// Branch delay slot.
			// Load MAX heart rate value.
			la		$t5, (MAX_HRT_RATE)						// Branch delay slot.
			lw		$t5, ($t5)
			sw		$t5, 0($t6)								// Store last known heart rate.
			j		write_2_disp
			nop												// Branch delay slot.
svsg_else_3:												// Min heart rate final else
			// Load minimum heart rate value.
			la		$t5, (MIN_HRT_RATE)						// Branch delay slot.
			lw		$t5, ($t5)
			sw		$t5, 0($t6)								// Store last known heart rate.

write_2_disp:
			la		$s0, SVN_SEG_LST			// Load address of last known seven segment value.
			beq		$t7, $t5, skip_calculation	// IF statement for determining if we need to make calculation below.
			nop									// Branch delay slot.
			ADDI	$t1, $t5, 0			// Refresh value to be converted.
			DIV		$t1, 10				// Value to write mod 10.
			mfhi	$t2					// Save least significant digit.
			ADDI	$t1, $t5, 0			// Refresh value to be converted.
			DIV		$t1, 10				// Divide value by 10.
			mflo	$t1					// Store result of division.
			DIV		$t1, 10				// Value Mod 10.
			mfhi	$t3					// Save second digit.
			ADDI	$t1, $t5, 0			// Refresh value to be converted.
			DIV		$t1, 100			// Divide value by 100.
			mflo	$t1					// Store result of division.
			DIV		$t1, 10				// Value Mod 10.
			mfhi	$t4					// Save MSB digit.

			SLL		$t3, $t3, 8			// Shift value for second seven segment digit.
			SLL		$t4, $t4, 16		// Shift value for third seven segment digit.
			OR		$t2, $t2, $t3		// Combine results to one register.
			OR		$t2, $t2, $t4
			sw		$t2, 0($s0)			// Store result to SVN_SEG_LST.
skip_calculation:
			lw		$t2, 0($s0)			// Load word from SVN_SEG_LST.

			li		$t5, PORT_SEVENSEG_LOW	// Load address for lower half of seven segment.
			sw		$t2, 0($t5)			// Write heart rate value to seven segment.

			jr		$ra					// Return.
			nop


/* ----------------------------------------------------------
 *	Module for updating state variable indicating what
 * 	heart data to display.
 *
 * ----------------------------------------------------------
 */
disp_info_option:
			addi	$sp, $sp, -4						// Set space on stack.
			sw		$ra, 0($sp)							// Save return address on stack.
			li		$16, PORT_PBTNS						// $16 = address of push buttons.
			lw		$t0, 0($16)							// Load value of push buttons.
			bne     $t0, 0x8, else_max					// Branch to state for average bpm.
			nop											// Branch delay slot.
			jal		sevenseg_print_bpm
			nop
else_max:
			bne		$t0, 0x4, else_min					// Branch to state for max heart rate.
			nop											// Branch delay slot.
			jal		sevenseg_print_max
			nop
else_min:
			bne		$t0, 0x1, else_rtn					// Branch to state for min heart rate.
			nop											// Branch delay slot.
			jal		sevenseg_print_min
			nop
else_rtn:
			jal		update_sevenseg						// Function to update display.
			nop
			lw		$ra, 0($sp)							// Restore return address from stack.
			addi	$sp, $sp, 4							// Restore stack space.
			jr		$ra									// Return to main loop.

/* ----------------------------------------------------------
 *	Module for updating sevenseg with characters indicating
 *  average BPM displayed. Updates State Variable $16.
 *
 * ----------------------------------------------------------
 */
sevenseg_print_bpm:
			li	  	$t1, SEVENSEG_EN_BPM_STATE 	// Load enable value for sevensegment.
			li	  	$t2, PORT_SEVENSEG_EN		// Load seven segment enable address.
			sw		$t1, 0($t2)					// Enable digits.
			li		$t1, PORT_SEVENSEG_HGH		// Load address for upper half of seven segment.
			li		$t2, SEVENSEG_HR			// Write display information to upper half of display.
			sw		$t2, 0($t1)

			li		$20, SEVENSEG_BPM_STATE		// Update state register for type of information being displayed.
			jr		$31
			nop

/* ----------------------------------------------------------
 *	Module for updating sevenseg with characters indicating
 *  maximum BPM displayed. Updates State Variable $16.
 *
 * ----------------------------------------------------------
 */
sevenseg_print_max:
			li	  	$t1, SEVENSEG_EN_INFO_STATE // Load enable value for sevensegment.
			li	  	$t2, PORT_SEVENSEG_EN		// Load seven segment enable address.
			sw		$t1, 0($t2)					// Enable digits.
			li		$t1, PORT_SEVENSEG_HGH		// Load address for upper half of seven segment.
			li		$t2, SEVENSEG_HR_HIGH		// Write display information to upper half of display.
			sw		$t2, 0($t1)

			li		$20, SEVENSEG_MAX_STATE		// Update state register for type of information being displayed.
			jr		$31
			nop

/* ----------------------------------------------------------
 *	Module for updating sevenseg with characters indicating
 *  minimum BPM displayed. Updates State Variable $16.
 *
 * ----------------------------------------------------------
 */
sevenseg_print_min:
			li	  	$t1, SEVENSEG_EN_INFO_STATE	// Load enable value for sevensegment.
			li	  	$t2, PORT_SEVENSEG_EN		// Load seven segment enable address.
			sw		$t1, 0($t2)					// Enable digits.
			li		$t1, PORT_SEVENSEG_HGH		// Load address for upper half of seven segment.
			li		$t2, SEVENSEG_HR_LOW		// Write display information to upper half of display.
			sw		$t2, 0($t1)

			li		$20, SEVENSEG_MIN_STATE		// Update state register for type of information being displayed.
			jr		$31
nop