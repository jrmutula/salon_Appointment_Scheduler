#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
# show available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

# if there is no service available
  if [[ -z $SERVICES ]]
  then
    echo -e "\nSorry, we don't offer any services at the moment."

# if services exist
  else
    echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

# get customer choice
  read SERVICE_ID_SELECTED

# if the choice is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then

# send to main menu
  MAIN_MENU "Sorry, that is not a valid service number! Try again."
  else
  AVAILABLE_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# if it is a number but not one of the available options
  if [[ -z $AVAILABLE_SERVICE ]]
  then

# send to main menu
  MAIN_MENU "I could not find that service. Is there any other service you would be interested in today?"
  else

# get customer phone number
  echo -e "\nWhat's your phone number?\n"
    read CUSTOMER_PHONE

# check if is a new customer or not
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# if is a new customer
  if [[ -z $CUSTOMER_NAME ]]
  then

# get the name, phone and add to the appointment table
  echo -e "\nI don't have a record for that phone number, what's your name?\n"
    read CUSTOMER_NAME
  NEW_CUSTOMER_INFO_=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# get the appointment time
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?\n"
    read SERVICE_TIME

# update the appointment table 
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  APPOINTMENT_SET=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g').\n"

# in the case of a returning customer
  else

# get the service name and ask for the time the customer wants to appoint
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?\n"
    read SERVICE_TIME

# update the appointment table 
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  APPOINTMENT_SET=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g').\n"
  fi
  fi
  fi
  fi
}

MAIN_MENU
