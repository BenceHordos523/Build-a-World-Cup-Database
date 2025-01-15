#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# truncate everything before inserting
echo $($PSQL "TRUNCATE games, teams")

function get_team_id {
  # $1 --> team name
  TEAM_ID=$($PSQL "select team_id from teams where name='$1'")

  if [[ -z $TEAM_ID ]]
  then
    INSERT_TEAM=$($PSQL "insert into teams(name) VALUES('$1')")
    if [[ $INSERT_TEAM == "INSERT 0 1" ]]
    then
      TEAM_ID=$($PSQL "select team_id from teams where name='$1'")
      echo $TEAM_ID
    fi
  else
    echo $TEAM_ID
  fi
}

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get teams id for winner
    WINNER_ID=$(get_team_id "$WINNER")

    # get teams id for opponent
    OPPONENT_ID=$(get_team_id "$OPPONENT")

    # insert games
    INSERT_GAMES=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAMES == "INSERT 0 1" ]]
    then
      echo Inserted into games
    fi
  fi

done