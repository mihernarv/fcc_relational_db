#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#year,round,winner,opponent,winner_goals,opponent_goals

# bash function to get the TEAM_ID from the teams table
function get_team_id()
{
	TEAM=$1
	QUERY="SELECT team_id FROM teams WHERE name='$TEAM';"
	TEAM_ID=$($PSQL "$QUERY")
	return $TEAM_ID
}

function insert_team()
{
	TEAM=$1
	QUERY="INSERT INTO teams(name) VALUES('$TEAM');"
	RES=$($PSQL "$QUERY")
	echo $RES
}


FILE="games.csv"
while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
	if [[ $YEAR != year ]]  #Skip the first line of the fileZ
	then
		# Get the WINNER_ID from the teams table
		get_team_id "$WINNER"
		WINNER_ID=$?
		# If WINNER_ID is zero, then INSERT the winner in the teams table
		if [[ $WINNER_ID -gt 0 ]]
		then
			echo Team $WINNER already in the database
		else
			echo Inserting $WINNER into the database
			RES=$(insert_team "$WINNER")
			if [[ $RES == 'INSERT 0 1' ]]
			then
				echo Team $WINNER inserted into the database
			fi
			get_team_id "$WINNER"
			WINNER_ID=$?
		fi
		# Get the opponent_ID from the teams table
		get_team_id "$OPPONENT"
		OPPONENT_ID=$?

		# IF not OPPONENT_ID, then insert into the TEAMS table
		if [[ $OPPONENT_ID -gt 0 ]]
		then
			echo Team $OPPONENT already in the database
		else
			echo Inserting opponent team $OPPONENT into the database
			RES=$(insert_team "$OPPONENT")
                        if [[ $RES == 'INSERT 0 1' ]]
                        then
                                echo Team $OPPONENT inserted into the database
                        fi
			get_team_id "$OPPONENT"
			OPPONENT_ID=$?
		fi
		# Add the GAME to the games table 
		QUERY="INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"
		RES=$($PSQL "$QUERY")
		if [[ $RES == 'INSERT 0 1' ]]
		then
			echo "Game $WINNER vs $OPPONENT ($ROUND) has been inserted into the database"
		fi


	fi

done < $FILE
