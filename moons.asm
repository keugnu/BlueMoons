# Final Project - Blue Moons
# TE 3340.002
# Programmer: Stephen-Micheal Brooks

.data
	seasonArray:	.space	16
	moonsArray:	.space	52
	compMonths:	.space	52
	seasonCounters:	.space	16
	seasonRef:	.word	79,1126,172,759,266,262,355,1369
	months: 	.asciiz "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"
	daysofmonth: 	.word 31,28,31,30,31,30,31,31,30,31,30,31
	askyear:	.asciiz "Please enter year greater than 1969 (yyyy): "
	bluemoon:	.asciiz " -Blue Moon"
	seasonalblue:	.asciiz " -Seasonal Blue Moon"
	title:		.asciiz "Full moons occur on:"
.text
	li $s1, 0		# begin index counter for moonsArray
	li $s2, 0		# begin index counter for seasonArray
	la $a0, askyear		# loads string to ask user for input into $a0
ask:	li $v0, 4		# prepare to print string
	syscall			# print the string in $a0
	li $v0, 5		# prepare for user input
	syscall			# take the input from the user
	move $s0, $v0		# move user input to $s0
	blt $s0, 1970, ask	# ask again if user typed a year lower than 1970
	li $a1, 32456		# store reference date and time to $a1
	move $a0, $s0		# move user input to $a0
	jal mooncycle		# call fucntion mooncycle
	move $t0, $v0		# move time from mooncycle into $t0
moons:	bge $t0, 525949, season	# if time of most recent moon is greater than minutes in a year, jump to season
	sw $t0, moonsArray($s1)	# store moon into moonsArray
	addi $s1, $s1, 4	# shift index for moonsArray by 1
	addi $t0, $t0, 42482	# add time to next moon to $t0
	j moons			# loop to moons
season: la $s1, seasonRef	# load address of seasonRef array into $s1	
	li $a0, 2015		# load reference year into $a0
	move $a1, $s0		# copy user input into $a1
	li $a0, 2015		# load reference year into $a0
	jal deltayear		# call dealtayear function
	move $a0, $v0		# copy deltayear into $a0
	jal leapcount		# call leapcount function
	addi $sp, $sp, -8	# move stack pointer by 8 bytes
	sw $v0, 4($sp)		# store number of leapyears in range to stack
	sw $v1, 0($sp)		# store number of non-leapyear onto stack
nextseason:
	lw $a0, 4($sp)		# load number of leapyears into $a0
	lw $a1, 0($sp)		# load number of non-leapyears into $s1
	lw $a2, 0($s1)		# set $a2 to current position in seasonRef array
	jal findday		# call findday function
	move $a1, $v1		# $a0 contains total minutes for range of years
	move $a0, $v0		# $s0 contains julian day when season changes
	lw $a2, 4($s1)		# load reference time (in minutes) into $a2
	jal determinejdate	# call determinejdate function
	mul $t0, $v0, 1440	# convert day to minutes
	add $t0, $t0, $v1	# add time of day to converted date
	sw $t0, seasonArray($s2)# store result to seasonArray
	addi $s2, $s2, 4	# shift index of seasonArray by 1
	addi $s1, $s1, 8	# move seasonRef index by 2 positions
	beq $s2, 16, dataisdone	# when 4 seasons are found jump to dataisdone
	j nextseason		# continue season loop
dataisdone:			# at this point, the dates (in minutes) for each full moon and for the start of each season are in arrays
	addi $sp, $sp, 8	# reposition stack pointer to orginal value
	la $a0, title		# load address of title string into $a0
	li $v0, 4		# prepare to print string
	syscall			# print
	li $s0, 0		# set $s0 to zero
	la $s2, seasonArray	# load address of seasonArray into $s2
	lw $t9, 12($s2)		# load time winter begins into $t9
	lw $t8, 8($s2)		# load time fall begins into $t8
	lw $t7, 4($s2)		# load time summer begins into $t7
	lw $t6, 0($s2)		# load time spring begins into $t6
checkseason:
	lw $t5, moonsArray($s0)	# load time of current moon into $t1
	beq $t5, $zero, end	# end program when last moon has been reached
	bge $t5, $t9, winter	# check if moon is in winter
	bge $t5, $t8, fall	# check if moon is in fall
	bge $t5, $t7, summer	# check if moon is in summer
	bge $t5, $t6, spring	# check if moon is in spring
	j winter		# moon begins in winter
moonOut:
	li $a0, '\n'		# load char '\n' into $a0
	li $v0, 11		# prepare to print char
	syscall			# print
	div $a0, $t5, 1440	# convert minutes to days
	mfhi $t0		# move remaining minutes to $t0
	div $t0, $t0, 60	# divide remaining minutes by 60 to get hours
	blt $t0, 10, printzeroH	# if hours are less than 10, print a zero
printedzeroH:
	move $a0, $t0		# move contents of $t0 to $a0
	li $v0, 1		# prepare to print integer
	syscall			# print
	li $a0, ':'		# load char ':' into $a0
	li $v0, 11		# prepare to print char
	syscall			# print
	mfhi $t0		# move final minutes into $t0
	blt $t0, 10, printzeroM	# print zero if minutes are less than 10
printedzeroM:
	move $a0, $t0		# move contents of $t0 to $a0
	li $v0, 1		# prepare to print int
	syscall			# print
	li $a0, ' '		# load char ' ' into $a0
	li $v0, 11		# prepare to print char
	syscall			# print
	div $a0, $t5, 1440	# convert minutes to days
	jal dateloop		# call dateloop function
	move $a0, $v0		# move gregorian day for full moon into $t0
	sw $v1, compMonths($s0)	# store gregorian month index to compMonths array
	move $t1, $v1		# move gregorian month index to $t1
	li $v0, 1		# prepare to print int
	syscall			# print
	li $a0, ' '		# load char ' ' into $a0
	li $v0, 11		# prepare to print char
	syscall			# print
	la $t2, months		# load address months array into $t2
	sll $t1, $t1, 2		# mult index of months array by 4
	add $t2, $t2, $t1	# load address of needed position in months array into $t2
	la $a0, ($t2)		# load address of month string into $a0
	li $v0, 4		# prepare to print string
	syscall			# print
	addi $s0, $s0, 4	# add 4 to $s0
	ble $s0, 4, checkseason # if first full moon continue loop
	addi $t0, $s0, -4	# subtract 4 from current moon's month index and store into $t0
	lw $t0, compMonths($t0)	# load current moon's month index to $t0
	addi $t1, $s0, -8	# subtract 8 from $t0 and store into $t1
	lw $t1, compMonths($t1)	# load previous moon's month index to $t1
	beq $t0, $t1, bluemoonoccured	# if month index is the same, blue moon has occured
	j checkseason		# continue loop
printzeroH:
	li $a0, '0'	# load char '0' into $a0
	li $v0, 11	# prepare to print char
	syscall		# print
	j printedzeroH
printzeroM:
	li $a0, '0'	# load char '0' into $a0
	li $v0, 11	# prepare to print char
	syscall		# print
	j printedzeroM
bluemoonoccured:
	la $a0, bluemoon	# load address of bluemoon string into $a0
	li $v0, 4		# prepare to print string
	syscall			# print
	j checkseason		# continue loop	
end:	li $v0, 10	# prepare to exit
	syscall		# exit	
winter:	la $t0, seasonCounters	# load address of seasonCounters into $t0
	lw $t1, 12($t0)		# load contents of index 3 into $t1
	addi $t1, $t1, 1	# increment $t1
	beq $t1, 4, seasonalblueoccured	# a seasonal blue has occured
	sw $t1, 12($t0)		# restore contents of $t1 into seasonCounter index 3
	j moonOut
fall:	la $t0, seasonCounters	# load address of seasonCounters into $t0
	lw $t1, 8($t0)		# load contents of index 2 into $t1
	addi $t1, $t1, 1	# increment $t1
	beq $t1, 4, seasonalblueoccured	# a seasonal blue has occured
	sw $t1, 8($t0)		# restore contents of $t1 into seasonCounter index 2
	j moonOut
summer: la $t0, seasonCounters	# load address of seasonCounters into $t0
	lw $t1, 4($t0)		# load contents of index 1 into $t1
	addi $t1, $t1, 1	# increment $t1
	beq $t1, 4, seasonalblueoccured	# a seasonal blue has occured
	sw $t1, 4($t0)		# restore contents of $t1 into seasonCounter index 1
	j moonOut
spring: la $t0, seasonCounters	# load address of seasonCounters into $t0
	lw $t1, 0($t0)		# load contents of index 0 into $t1
	addi $t1, $t1, 1	# increment $t1
	beq $t1, 4, seasonalblueoccured	# a seasonal blue has occured
	sw $t1, 0($t0)		# restore contents of $t1 into seasonCounter index 0
	j moonOut
seasonalblueoccured:
	la $a0, seasonalblue	# load address of seasonalblue string into $a0
	li $v0, 4		# prepare to print string
	syscall			# print
	j moonOut		# jump back to loop
	
#	Function: mooncycle determines the date and time (in minutes) that the first full moon occurs in the requested year
#
# Inputs:	$a0 contains user input
#		$a1 contains reference time
#		
# Outputs:	$v0 returns the time and date of the next full moon in the requested year

mooncycle:	move $t0, $a0		# load user input into $t0
		move $t1, $a1		# load reference time into $t1
		
mooncyclecont:	div $t2, $t1, 1440		# divide time by 1440 minutes to get number of days
		bge $t2, 365, decrementyear	# if number of days is greater than 365 then decrement year
		beq $t0, 1970, mooncyclereturn	# target year has been reached, prepare to return
		addi $t1, $t1, 42482		# add time for next moon
		j mooncyclecont			# iterate
		
	mooncyclereturn:	move $v0, $t1 	# move time to $v0 for return
				jr $ra		# return	
	
	decrementyear:	addi $t0, $t0, -1	# decrement year
			mfhi $t1		# save the remaining minutes from integer division to $t2
			subi $t3, $t2, 365	# extract number of days for the first moon of next year and store into $t3
			mul $t3, $t3, 1440	# convert days to minutes
			add $t1, $t3, $t1	# add remaining minutes to day of first full moon (in minutes)
			j mooncyclecont		# iterate

#	Function: deltayear determines the number of years between the reference date and user input
#
# Inputs:	$a0 holds reference year
#		$a1 holds user input year
#
# Outputs:	$v0 holds difference
	
deltayear:	sub $t0, $a0, $a1	# find range
		abs $v0, $t0		# make difference absolute value and store into return register $v0
		jr $ra			# return
		
#	Function: 	leapcount will determine how many leapyears exist between the user input and the reference year
#
# Inputs:	$a0 holds deltayear
#
# Outputs:	$v0 holds number of leapyears that exist between user input and reference year
#		$v1 hold number of non-leapyears

leapcount:	addi $sp, $sp, -4		# add 4 bytes to stack
		sw $ra, 0($sp)			# push $ra onto stack
		move $t0, $a0			# copy dealyear into $t0 for loop condition
		li $t1, 0			# load 0 into $t1 to serve as leapyear counter
contleapcount:	beqz $t0, leapcountfin		# if counter is zero, stop the loop
		jal leapyear			# call leapyear function
		beq $v0, 1, foundleapyear	# if leapyear function returns true
leapcount2:	addi $t0, $t0, -1		# decrement the loop condition
		li $t4, 2015			# set $t4 to reference year
		bgt $a1, $t4, yearisgreater	# check is reference year is less than input
		addi $a1, $a1, 1		# increment the year
		j contleapcount			# continue the leapcount function
		
	leapcountfin:	move $v0, $t1		# copy counter into return address $v0
			sub $v1, $a0, $t1	# $v1 holds number of non-leap years
			lw $ra, 0($sp)		# pop $ra off stack
			addi $sp, $sp, 4	# shrink stack by 4 bytes
			jr $ra			# return
	foundleapyear:	addi $t1, $t1, 1	# increment counter
			j leapcount2		# continue the leapcount function
	yearisgreater: addi $a1, $a1, -1	# decrement the year
			
#	Functions: findday find the julian day which the season changes on and also returns added time for range of years
#
# Inputs:	$a0 holds leapcount
#		$a1 hold number of normal years
#		$a2 holds reference day
#
# Output:	$v0 returns final julian day
#		$v1 returns minutes offset

findday:	li $t0, 365		# number of days in a normal year
		li $t1, 366		# number of days in a leap year
		add $t2, $a0, $a1	# total range
		li $t3, 350		# 350 minutes offset
		mult $t0, $t2		# multiply 365 by range
		mflo $t0		# move product to $t0
		add $t1, $t0, $a0	# add leap days
		mult $t2, $t3		# mult 350 by range
		mflo $t2		# copt product to $t2
		move $v1, $t2		# copy $t2 to $v1 for return
		div $t2, $t2, 60	# divide total minutes by 60 to get hours
		div $t2, $t2, 24	# div hours by 24 to get day(s)
		add $t0, $t0, $t2	# add extra day(s) non leap year total days
		add $t0, $t0, $a2	# add total non leap year days to reference day
		sub $v0, $t0, $t1	# (total non leap year days + reference day) - total leap year days
		jr $ra			# return
		
#	Function:	leapyear will check if the user input is a leapyear by a series of divisions.
#
# Inputs:	$a1 holds the user input
#		$t1 recieves the modulus of each division
#
# Outputs:	Output is boolean 0 or 1 for fales or true, respectively

leapyear:	div $t3, $a1, 400			# divide input by 400
		mfhi $t3				# save mod into $t1
		bne $t3, $zero, notfourhundred		# check if mod is 0, if not check more conditions
		li $v0, 1				# load 1 for true into return value
		jr $ra					# return to main

	notfourhundred:	div $t3, $a1, 4			# divide input by 4
			mfhi $t3			# load $t1 with mod
			bne $t3, $zero, notleapyear	# check if mod is 0, if not not leap year
			div $t3, $a1, 100		# divide input by 100
			mfhi $t3			# load $t1 with mod
			beq $t3, $zero, notleapyear	# check if mod is 0, if so not leap year
			li $v0, 1			# load 1 for true into return value
			jr $ra				# return to main
			
	notleapyear:	li $v0, 0	# load zero for false into return value
			jr $ra		# return
			
#	Function: determinejdate determines the julian date for the change of the season
#
# Inputs:	$a0 contains julian day
#		$a1 contains extra minutes needed per year
#		$a2 contains refence time for change of season (in minutes)
#
# Outputs:	$v0 contains finalized day of change
#		$v1 contains time of day (in minutes)

determinejdate:		add $t0, $a2, $a1	# add time from range and reference time
			div $t0, $t0, 60	# divide total time by 60 to obtain hours
			mfhi $t1		# move remaining minutes to $t1
contdeterminejdate:	bgt $t0, 24, addaday	# if hours is greater than 24, we must add a day
			move $v0, $a0		# move day into $v0 for return
			li $t2, 60		# load 60 for multiplication
			mult $t0, $t2		# convert remaining hours back to minutes
			mflo $t0		# move product to $t0
			add $t0, $t0, $t1	# add remaining minutes
			move $v1, $t0		# move time into $v1 for return
			jr $ra			# return
		
	addaday:	addi $a0, $a0, 1	# add a day
		 	subi $t0, $t0, 24	# subtract 24 hours from $t0
		 	j contdeterminejdate
		 	
#	Function: dateloop will convert julian day to month and day
#
# Inputs:	$a0 is julian day
#
# Outputs:	$v0 returns gregorian day
#		$v1 returns month

dateloop:	la $t2, daysofmonth	# load daysofmonth array into $t2
		lw $t0, 0($t2)		# load value from daysofmonth array into $t0
		li $t1, 0		# start index for months array
contdateloop:	lw $t0, 0($t2)		# load value from daysofmonth array into $t0
		ble  $a0, $t0, fin	# is julian day <= days in current month?
		addi $t2, $t2, 4	# move daysofmonth index up by 1
		sub  $a0, $a0, $t0	# subtract days of current month from julian day
		addi $t1, $t1, 1	# increment month by 1
		j contdateloop		# restart loop
	fin:	move $v0, $a0		# copy day of month into $v0 for return
		move $v1, $t1		# copy month index into $v1 for return
		jr $ra			# return