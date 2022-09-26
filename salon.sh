#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

LIST_SERVICES(){
  
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "select * from services")

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do 
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    LIST_SERVICES "I could not find that service. What would you like today?\n"
  else
    SERVICE_DISP_RESULT=$($PSQL "select * from services where service_id=$SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_DISP_RESULT ]]
    then
      LIST_SERVICES "I could not find that service. What would you like today?\n"
    else
      echo -e "\nOkay, what is your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_ID_RESULT=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_ID_RESULT ]] 
      then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER=$($PSQL "insert into customers (phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi
      
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

      echo -e "\nWhat time would you like your cut, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
      read SERVICE_TIME

      APPOINTMENT_CREATE_RESULT=$($PSQL "insert into appointments (time, service_id, customer_id) values('$SERVICE_TIME', $SERVICE_ID_SELECTED, $CUSTOMER_ID)")
      SELECTED_SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

      echo -e "\nI have put you down for a $(echo $SELECTED_SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
  fi
}

LIST_SERVICES