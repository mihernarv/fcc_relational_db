#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"
PRINT_MESSAGE()
{
	if [[ -z $1 ]]
	then
		echo -e "I could not find that element in the database."
	else
		echo "$1" | while read -r TYPE_ID BAR ATOMIC_NUMBER BAR SYMBOL BAR NAME BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE 
		do
			echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
		done 
	fi
}

QUERY_ATOMIC_NUMBER()
{
	RESULT_NUMBER=$($PSQL "SELECT  * FROM elements JOIN properties USING(atomic_number) JOIN TYPES USING(type_id) WHERE atomic_number = $1;")
	PRINT_MESSAGE "$RESULT_NUMBER"
}

QUERY_ATOMIC_SYMBOL()
{
	RESULT_SYMBOL=$($PSQL "SELECT  * FROM elements JOIN properties USING(atomic_number) JOIN TYPES USING(type_id) WHERE symbol= '$1';")
	PRINT_MESSAGE "$RESULT_SYMBOL"
}

QUERY_ELEMENT_NAME()
{
	RESULT_NAME=$($PSQL "SELECT  * FROM elements JOIN properties USING(atomic_number) JOIN TYPES USING(type_id) WHERE name = '$1';")
	PRINT_MESSAGE "$RESULT_NAME"
}

# If no argument is provided, then exit
if [[ -z $1 ]]
then
	echo Please provide an element as an argument.
	exit
fi

# If the input is a number
if [[ $1 =~ ^[0-9]+$ ]]
then
	QUERY_ATOMIC_NUMBER $1
	exit
fi

# if the input is a capital followed by a lower:
if [[ $1 =~ ^[A-Z][a-z]?$ ]]
then
	QUERY_ATOMIC_SYMBOL $1
else
	QUERY_ELEMENT_NAME $1
fi

