#!/bin/bash

PSQL="psql -t --username=freecodecamp --dbname=salon -c"

CREATE_APPOINTMENT()
{
	# Get service ID
	SERVICE_ID=$1
	# Get service name
	SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")
	# Get phone number
	echo -e "\nWhat's your phone number?"
	read CUSTOMER_PHONE
	# Check for the customer's phone in customers table
	CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
	# if not exists
	if [[ -z $CUSTOMER_NAME ]]
	then
		# get customer name
		echo -e "\nI don't have a record for that phone number, what's your name?"
		read CUSTOMER_NAME 
		# insert in customer table
		RESULT_INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
	fi
	# get customer id from customers table
	CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
	# ask for time
	echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
	read SERVICE_TIME
	# Insert into the appointments table
	RESULT_INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
	# echo bye message
	echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."


}


MAIN_MENU()
{
	echo -e "\n~~~~~ MY SALON ~~~~~\n"
	if [[ -z $1 ]]
	then 
		echo -e "\nWelcome to My Salon, how can I help you?\n"
	else
		echo -e "$1"
	fi
	# obtain the services
	SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")
	# print the menu
	echo "$SERVICES" | while  read -r SERVICE_ID BAR SERVICE_NAME
	do
		echo "$SERVICE_ID) $SERVICE_NAME"
	done 
	# read the user input
	read SERVICE_ID_SELECTED

	case $SERVICE_ID_SELECTED in
		1) CREATE_APPOINTMENT $SERVICE_ID_SELECTED ;;
		2) CREATE_APPOINTMENT $SERVICE_ID_SELECTED ;;
		3) CREATE_APPOINTMENT $SERVICE_ID_SELECTED ;;
		4) CREATE_APPOINTMENT $SERVICE_ID_SELECTED ;;
		5) CREATE_APPOINTMENT $SERVICE_ID_SELECTED ;;
		*) MAIN_MENU "I could not find that service. What would you like today?";;
	esac 

}

MAIN_MENU

