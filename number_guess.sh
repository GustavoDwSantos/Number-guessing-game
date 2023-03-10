#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 +1 ))

echo -e "\n~~~~Number Guessing Game~~~~\n"

echo "Enter your username:"
read INSERT_USERNAME

USERNAME=$($PSQL "select username from player where username = '$INSERT_USERNAME'")

if [[ -z $USERNAME ]]
then 

  INSERT_USERNAME_RESULT=$($PSQL "insert into player(username) values('$INSERT_USERNAME')")
  echo -e "\nWelcome, $INSERT_USERNAME! It looks like this is your first time here."

else

  GAMES_PLAYED=$($PSQL "select count(game_id) from games full join player using(player_id) where username = '$INSERT_USERNAME'")
  BEST_GAME=$($PSQL "select min(score) from games full join player using(player_id) where username = '$INSERT_USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  
fi

echo -e "\nGuess the secret number between 1 and 1000:"

RESPONSE=0
SCORE=0
while [[ $RESPONSE != $NUMBER ]]
do 
  read RESPONSE
  
  if [[ ! $RESPONSE =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  else
    if (( $NUMBER < $RESPONSE ))
    then 
      echo -e "\nIt's lower than that, guess again:"
    elif (( $NUMBER > $RESPONSE ))
    then
      echo -e "\nIt's higher than that, guess again:"
    fi
  fi

  SCORE=$(($SCORE + 1))
done

PLAYER_ID=$($PSQL "select player_id from player where username = '$INSERT_USERNAME'")
INSERT_GAME_RESULT=$($PSQL "insert into games(player_id, score) values('$PLAYER_ID','$SCORE')")
echo -e "\nYou guessed it in $SCORE tries. The secret number was $NUMBER. Nice job!"