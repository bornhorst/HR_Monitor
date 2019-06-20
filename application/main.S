/*
 *	Authors: Andrew Capatina, Ryan Bentz, Alex Olsen, Ryan Bornhorst
 *	Class: ECE540
 *  Date: 3/21/2019
 *
 *  Description:
 *			This file is the software for the heart rate monitor. This program will
 *		read from all of the various hardware addresses contained on AHB-Lite.
 *		The job of this program is to fetch data gathered from hardware and calculate
 *		beats per minute. The results are sent to the user interfaces which is the
 *      wifi peripheral and seven segment display. The pushbuttons are used to select
 *		which heart rate statistics are shown on the seven segment display.
 *
 *
 *
 */

# Masks for Pushbuttons
BTN_R_MASK 				= 0x2
BTN_C_MASK 				= 0x10
BTN_L_MASK 				= 0x8
BTN_D_MASK 				= 0x1
BTN_U_MASK 				= 0x4
PUSHBUTTON_MASK			= 0x1F

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

// Naming convention for below addresses is confusing, read the comments.
// These addresses are used to control/read the status of six second timer.
PORT_TIM_RDY		= 0xbfa00004		# (o) Address indicating that the CPU has processed timer overflow.
PORT_TIM_ACK		= 0xbfa00000		# (o) Address indicating containing value that the timer has overflowed.

PORT_HR_DATA		= 0xbf900000		# (o) Address containing heart rate data.
PORT_HR_RDY			= 0xbf900004		# (o) Address containing value indicating data is ready to read.
PORT_HR_ACK			= 0xbf900008		# (o) Address containing value letting HW know that data has been processed.

PORT_WIFI			= 0xbfb00000		# (o) Address for writing to the wifi peripheral.

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

# bit mask for LEDs
MSK_LEDS_LO = 0xFF		# Mask for rightmost 8 LEDs on the Nexy4
MSK_LEDS_HI = 0xFF00	# Mask for the lefmost 8 LEDs on the Nexy4


# bit mask for display character codes and decimal points
MSK_CCODE 		= 0x1F		# Character codes are in lower 5 bits
MSK_DECPTS 		= 0x0F		# Decimal points 3 - 0 are in bits 3 to 0
MSK_DECPTS_HI 	= 0xF0		# Decimal points 7-4 are in bits 3 to 0
MSK_HEXDIGIT 	= 0x0F		# Hex digits only take 4 bits

# =============================
# === Useful Data Constants ===
# =============================

#  Constants for True, False, Null and INT_ACK
FALSE 	= 0x00
TRUE 	= 0x01
NULL 	= 0x00
INT_ACK = 0x01

#-------------------------------------------------------
# Values for lighting different segments of display.
#-------------------------------------------------------
SEVENSEG_EN_BPM_STATE	= 0x30			# Shuts off 5th and 6th segment of display.
SEVENSEG_EN_INFO_STATE	= 0x00			# Turns on all segments of display.

SEVENSEG_BLANK		= 0x00000000		# Value for setting a blank value for display.
SEVENSEG_ALL_G		= 0x16161616		# Lights half of display with G segments.

SEVENSEG_HR		= 0x171B0000			# Writes characters "Hr" to display.
SEVENSEG_HR_LOW	= 0x171B1800			# Writes character "HRL0" to display.
SEVENSEG_HR_HIGH= 0x171B1717			# Writes characters "HRHH" to display.

#-------------------------------------------------------
# Sevenseg State Constants
#-------------------------------------------------------
SEVENSEG_INIT_STATE= 0x0				# Init state for sevensegment display.
SEVENSEG_BPM_STATE = 0x1				# Used to indicate that we are writing average BPM to display.
SEVENSEG_MAX_STATE = 0x2				# Used to indicate that we are writing maximum BPM to display.
SEVENSEG_MIN_STATE = 0x3				# Used to indicate that we are writing minimum BPM to display.

# Different variables for lookup table, BotInfo register, LOCx_REG, LOCy_REG, Old_Heading register,
# 7 segment displays, and other variables required. All are byte wides except SP_TEMP which is word
# wide.
	.data
	.align 2    # Put next label on a word boundary

MIN_HRT_RATE:		.word 0x00		// Address containing the current minimum heart rate.
MAX_HRT_RATE:		.word 0x00		// Address containing the current maximum heart rate.
AVG_HRT_RATE:		.word 0x00		// Address containing the current average heart rate.

LST_HRT_RATE:		.word 0x00		// Address containing last known heart rate.
SVN_SEG_LST:		.word 0x00		// Value containing last written value to seven segment display.

BEAT_FLAG:			.word 0x00		// Indicates that a pulse is detected.
BEAT_COUNT:			.word 0x00		// Used as count when gathering number of pulses for 6 seconds.
HIGH_VAL:			.word 0x00		// Used for keeping track of the current highest value from ADC readings of pulses.
									// Helpful for tracking the peak of waveform.
.text

.globl main
main:
main_INIT:
		li		$t1, PORT_TIM_RDY		// Reset the timer on init.
		li		$t0, INT_ACK
		sw		$t0, 0($t1)
		la		$t0, (MIN_HRT_RATE)		// Load 55 to minimum heart rate. (test value)
		li		$t1, 55
		sw		$t1,  ($t0)
		la		$t0, (MAX_HRT_RATE)		// Load 171 to maximum heart rate. (test value)
		li		$t1, 171
		sw		$t1,  ($t0)
		la		$t0, (AVG_HRT_RATE)		// Load 72 to average heart rate. (test value)
		li		$t1, 72
		sw		$t1,  ($t0)

		lui   	$12, 0xbf80    				// $12 = address of LEDs (0xbf800000)
		li		$15, PORT_SEVENSEG_DP		// Load sevenseg decimal points register.
		li		$14, 0xB7					// Activate 3rd and 5th decimal points.
		sw		$14, 0($15)					// Write to DP enable register.
		li		$20, SEVENSEG_INIT_STATE	// STATE REGISTER FOR SEVENSEG DISPLAY
		// Add delay loop or use the system call to get time.
		li		$s1, DELAY_6_SECOND // Load value for 6 second delay.

# ==================
# *** Main  Loop ***
# ==================

/* ----------------------------------------------------------
 *	This is where execution will constantly loop.
 *  The timer will be checked if we are overflo
 * ----------------------------------------------------------
 */
Main_L0:
//	Check if the six second interval has passed
	li		$t1, PORT_TIM_ACK		// Load address for checking timer overflow.
	li		$t0, NULL				// Reset $t0
	lw		$t0, 0($t1)				// load the timer value
	li		$t2, 0x0				// Load 0 to $t2 for comparison.
	beq		$s7, $t2, TIMER_OVF		// check if timer has overflowed.
	b		CHECK_HEART_DATA		// otherwise check if there is heart rate data
	b		Main_L0

// If there was a timer overflow, then we need to
TIMER_OVF:
	li		$t1, INT_ACK			// Write a 1 to clear the acknowledge
	li		$t2, PORT_TIM_RDY		// Load address for writing acknowledge to CPU.
	sw		$t1, ($t2)				// Send acknowledge to the timer that flag was received
	jal		CALCULATE_BPM			// Calculate BPM

	b		Main_L0

/* -----------------------------------------------------------------------------------
 * Module for checking if a set of samples are ready.
 *
 * -----------------------------------------------------------------------------------
 */
CHECK_HEART_DATA:
	//	2. Check if new data has come in on the heart rate peripheral
	// Forward the data to the ESP8266 for storing in the database (TBD)
	li		$t1, PORT_HR_RDY		// Load address
	lw		$t0, 0($t1)				// read the HEART RATE DATA READY PORT
	bne		$t0, $0, DATA_READY		// if flag is 1, there is data
	b		Main_L0

DATA_READY:
	// Handshake to clear the perip	heral
	li      $t2, PORT_HR_ACK		// address for acknowledge
	li      $t1, INT_ACK			// acknowledge flag
	sb      $t1, ($t2)				// send 1 = give me the data

	li      $t1, PORT_HR_DATA		// adress for HR data
	lw      $t0,($t1)				// read the data
	sb      $0, ($t2)				// i got some

	jal		BEAT_DETECTION			// calculate BPMs
	jal		TRANSFER_DATA			// send data to the ESP8266
	b		Main_L0

TRANSFER_DATA:
	sw		$t0, (PORT_WIFI)		// Send result to wifi peripheral.
	b		Main_L0


/* -----------------------------------------------------------------------------------
 *	Module for beat detection compares a read value with current known highest value.
 *	If read value > highest value, we are on rising edge of beat slope so keep setting
 *	the current highest value. When the value < highest, we reach a peak and count a beat.
 * -----------------------------------------------------------------------------------
 */
BEAT_DETECTION:
//	1. 	Get the new data from the peripheral
	// $a0 has the value
	addi	$t1, $0, 0				// t1 = shift amount, shift by multiples of 8

//	2.	Loop through each byte and compare with current highest value
//		to check if we have found a peak
	addi	$s0, $0, 4
READ_LOOP:
//	Extract a byte and analyze it. Shift each byte to the LSB on each successive read
	srl 	$t0, $t0, $t1			// multiple of 8 for each pass: 0, 8, 16, 24
	andi	$t0, $t0, 0xFF

//	Compare the current read byte with the current highest value
	lw		$t2, (HIGH_VAL)
	bltu	$t2, $t0, HIGHER		// READ_VAL > HIGH_VAL

//	READ_VAL <= HIGH_VAL - The byte is less than or equal to the HIGH_VAL
	lw		$t3, (BEAT_FLAG)
	beq		$t3, $0, BEAT_DETECT	// IF Flag not set THEN beat detected

// Otherwise, READ_VAL <= HIGH_VAL but flag is set
// Set the "HIGH_VAL" as decreasing values so that we can detect upward transition
	sw		$t0, (HIGH_VAL)

	addi	$s0, $s0, -1
	addi	$t1, $t1, 8					// decrement the counter
	bne		$s0, $0, READ_LOOP				// go back to loop
	jr		$ra						// return to main

// READ_VAL > HIGH_VAL
HIGHER:
	// update with the new higher value
	sw		$t0, (HIGH_VAL)				// update new higher value

	// if flag is set, this is the first rising edge, so reset for next peak
	addi	$t4, $0, 0
	addi	$t5, $0, 1
	lw		$t6, (BEAT_FLAG)
	movz	$t3, $t5, $t6
	movn	$t3, $t4, $t6
	sw		$t3, (BEAT_FLAG)
	b		READ_LOOP

//	5.	We detected a beat with the values that were read (transition from high to low)
BEAT_DETECT:
	addi 	$t8, $0, 1				// set the beat flag to ignore all the values on
	sw		$t8, (BEAT_FLAG)		// on the downward transition

	lw		$t3, (BEAT_COUNT)		// increment beat counter
	addi	$t3, $t3, 1
	sw		$t3, (BEAT_COUNT)		// save the new incremented value
	b		READ_LOOP



CALCULATE_BPM:
	//jal		DISP_INFO_OPTION
// To calculate the BPM, multiple # of beats in 6 seconds by 10
	lw		$t8, (BEAT_COUNT)
	addi	$t7, $0, 10
	mul		$t8, $t8, $t7

// Store the calculated BPM
	sw		$t8, (AVG_HRT_RATE)

// Clear the BEAT COUNT
	addi	$t6, $0, 0
	sw		$t6, (BEAT_COUNT)

// Check if we have a new MIN
	lw		$t7, (MIN_HRT_RATE)
	blt		$t8, $t7, SET_MIN		// t8 < t7 = new MIN
	b		CHECK_MAX				// otherwise check MAX

SET_MIN:
	sw		$t8, (MIN_HRT_RATE)		// set new minimum HR
	b		DISP_INFO_OPTION

CHECK_MAX:
	lw		$t7, (MIN_HRT_RATE)
	blt		$t8, $t8, SET_MAX
	b		DISP_INFO_OPTION					// neither MAX nor min so return

SET_MAX:
	sw		$t8, (MAX_HRT_RATE) 	// set new max HR

	b		DISP_INFO_OPTION

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
			li		$t1, 0x0000FFFF							// Lights LEDs.
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
 * 	heart data to display. Updates $20 based off the button
 *  presses. Lets us know which value to write to sevensegment
 *  display.
 * ----------------------------------------------------------
 */
DISP_INFO_OPTION:
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
