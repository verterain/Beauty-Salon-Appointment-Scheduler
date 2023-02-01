#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"
echo -e "How may I help you?\n"

LIST_SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  OUR_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$OUR_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    LIST_SERVICES "That service doesn't exist. Could you please double-check the input?"
  else
    SERVICES_RESULT=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICES_RESULT ]]
  then 
    LIST_SERVICES "That service doesn't exist. Could you please double-check the input?"
  else 
    echo -e "\nPlease enter your phone number."
    read CUSTOMER_PHONE

    CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID_RESULT ]]
    then
      echo -e "\nYou must be a new client! What's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    echo -e "\nWhat time for the appointment fits you?, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME

    APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (time, service_id, customer_id) VALUES('$SERVICE_TIME', $SERVICE_ID_SELECTED, $CUSTOMER_ID)")
    SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    echo -e "\nI have put you down for a $(echo $SELECTED_SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
  fi
}

LIST_SERVICES
