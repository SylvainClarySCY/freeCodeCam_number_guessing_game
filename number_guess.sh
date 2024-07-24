#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

echo Enter your username:
read USERNAME

IFS='|' read GAMES_PLAYED BEST_GAME <<< "$($PSQL "SELECT games_played, best_game FROM players WHERE username='$USERNAME';")"

if [[ -z $GAMES_PLAYED ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER_TO_GUESS=$((1 + $RANDOM % 1000))

echo Guess the secret number between 1 and 1000:
read GUESS

NUMBER_OF_GUESSES=1

while [[ GUESS -ne NUMBER_TO_GUESS ]]
do
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt NUMBER_TO_GUESS ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
    else
      echo "It's higher than that, guess again:"
      read GUESS
    fi
  else
    echo "That is not an integer, guess again:"
    read GUESS
  fi
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
done

echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!

if [[ -z $GAMES_PLAYED ]]
then
  INSERT_RESULT=$($PSQL "INSERT INTO players(username, games_played, best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESSES);")
else
  if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
    UPDATE_RESULT=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED+1, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME';")
  else
    UPDATE_RESULT=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED+1 WHERE username='$USERNAME';")
  fi
fi
