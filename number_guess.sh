#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GENERATE_RANDOM_NUMBER()
{
	echo $((1 + $RANDOM % 1000))
	
}

PRINT_MESSAGE()
{
	if [[ -z $1 ]]
	then
		echo "Enter your username:"
	else
		echo "$1"
	fi
}

GET_USERNAME()
{
	PRINT_MESSAGE
	read USERNAME
	# Query the user_id using the username
	USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
	# If username not in the database
	if [[ -z $USER_ID ]]
	then
		# Insert username into the users table 
		RESULT_INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
		# Get the user_id of the nwely created user 
		USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
		# Print welcome message: Welcome, <username>! It looks like this is your first time here.
		PRINT_MESSAGE "Welcome, $USERNAME! It looks like this is your first time here."

	else 
		# Get number of games played by the user 
		GAMES_PLAYED=$($PSQL "SELECT COUNT(1) FROM games WHERE user_id=$USER_ID")
		# get the min of guesses
		BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
		# Print welcome message: Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses.
		PRINT_MESSAGE "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
	fi
	return $USER_ID

}

GET_USER_GUESS()
{
	NUM_GUESSES=0
	SECRET_NUMBER=$(GENERATE_RANDOM_NUMBER)
	echo $SECRET_NUMBER
	PRINT_MESSAGE "Guess the secret number between 1 and 1000:"
	read USER_GUESS
	NUM_GUESSES=$(( NUM_GUESSES + 1 ))

	while [[ $USER_GUESS -ne $SECRET_NUMBER ]]
	do
		NUM_GUESSES=$(( NUM_GUESSES + 1 ))

		if [[ $USER_GUESS =~ ^[0-9]*$ ]]
		then 
			if [[ $USER_GUESS -gt $SECRET_NUMBER ]] 
			then 
				PRINT_MESSAGE "It's lower than that, guess again:" 
				read USER_GUESS 
			else 
				PRINT_MESSAGE "It's higher than that, guess again:" 
				read USER_GUESS 
			fi
	else
		PRINT_MESSAGE "That is not an integer, guess again:"
		read USER_GUESS
	fi

	done
	PRINT_MESSAGE "You guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

	# insert the game into the games table
	RESULT_INSERT_GAME=$($PSQL "INSERT INTO games (user_id, guesses) VALUES ($USER_ID,$NUM_GUESSES)")

}

GET_USERNAME
GET_USER_GUESS
