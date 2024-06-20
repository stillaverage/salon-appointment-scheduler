#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ SALON ~~~\n"

DISPLAY_OPTIONS() {
  SERVICES=$($PSQL "SELECT * FROM services;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

GET_CUSTOMER_PHONE() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
}

GET_CUSTOMER_NAME_AND_ID() {
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nYou are a new customer. What's your name?"
    read CUSTOMER_NAME
    ADD_NEW_CUSTOMER
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
}

ADD_NEW_CUSTOMER() {
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  if [[ $INSERT_CUSTOMER_RESULT = "INSERT 0 1" ]]
  then
    echo "\nSuccessfully entered customer name and number.\n"
  else
    MAIN_MENU "\nThere was an error with customer name and number. What can I help you with?\n"
  fi
}

GET_SERVICE_TIME() {
  echo -e "\nWhat time would you like your $(echo "$SERVICE_SELECTED" | sed -E 's/^ *| *$//g'), $(echo "$CUSTOMER_NAME" | sed -E 's/^ *| *$//g')?"
  read SERVICE_TIME
}

ADD_APPOINTMENT() {
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  if [[ $INSERT_APPOINTMENT_RESULT = "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $(echo "$SERVICE_SELECTED" | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo "$CUSTOMER_NAME" | sed -E 's/^ *| *$//g')."
  else
    MAIN_MENU "\nThere was an error with appointment scheduler. What can I help you with?\n"
  fi
}

SCHEDULE_SERVICE() {
  GET_CUSTOMER_PHONE
  GET_CUSTOMER_NAME_AND_ID
  GET_SERVICE_TIME
  ADD_APPOINTMENT
}

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e $1
  fi

  DISPLAY_OPTIONS

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "\nPlease enter a number.\n"
  else
    SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_SELECTED ]]
    then
      MAIN_MENU "\nThat service is not available. What would you like today?\n"
    else
      SCHEDULE_SERVICE
    fi
  fi
}

MAIN_MENU "Welcome to the Salon. How can I help you?\n"
