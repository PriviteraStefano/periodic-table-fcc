#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Function to search the database based on different types of identifiers
search_database() {
  local identifier="$1"
  local query
  local result

  # Check if $1 is an integer (atomic number)
  if [[ "$identifier" =~ ^[0-9]+$ ]]; then
    query="SELECT 
      elements.atomic_number, 
      elements.symbol, 
      elements.name, 
      types.type AS type, 
      properties.atomic_mass, 
      properties.melting_point_celsius, 
      properties.boiling_point_celsius 
    FROM elements 
    JOIN properties USING(atomic_number) 
    JOIN types USING(type_id) 
    WHERE elements.atomic_number=$identifier;"

  # Check if $1 is a symbol (2 characters, alphabetic)
  elif [[ "$identifier" =~ ^[A-Za-z]{1,2}$ ]]; then
    query="SELECT 
      elements.atomic_number, 
      elements.symbol, 
      elements.name, 
      types.type AS type, 
      properties.atomic_mass, 
      properties.melting_point_celsius, 
      properties.boiling_point_celsius 
    FROM elements 
    JOIN properties USING(atomic_number) 
    JOIN types USING(type_id) 
    WHERE elements.symbol='$identifier';"

  # Assume $1 is a name (more than 2 characters)
  else
    query="SELECT 
      elements.atomic_number, 
      elements.symbol, 
      elements.name, 
      types.type AS type, 
      properties.atomic_mass, 
      properties.melting_point_celsius, 
      properties.boiling_point_celsius 
    FROM elements 
    JOIN properties USING(atomic_number) 
    JOIN types USING(type_id) 
    WHERE elements.name='$identifier';"
  fi

  # Execute the query
  result=$($PSQL "$query")

  # Check if the result is empty
  if [[ -z "$result" ]]; then
    echo "I could not find that element in the database."
  else
    # Parse the result using IFS (Internal Field Separator) to handle the fields
    IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS <<< "$result"

    # Trim extra spaces from each field
    ATOMIC_NUMBER=$(echo "$ATOMIC_NUMBER" | xargs)
    SYMBOL=$(echo "$SYMBOL" | xargs)
    NAME=$(echo "$NAME" | xargs)
    TYPE=$(echo "$TYPE" | xargs)
    ATOMIC_MASS=$(echo "$ATOMIC_MASS" | xargs)
    MELTING_POINT_CELSIUS=$(echo "$MELTING_POINT_CELSIUS" | xargs)
    BOILING_POINT_CELSIUS=$(echo "$BOILING_POINT_CELSIUS" | xargs)

    # Output the details of the element
    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
}

# Check if an argument was provided
if [[ -z "$1" ]] 
then
  echo "Please provide an element as an argument."
  else
  # Call the function with the provided argument
  search_database "$1"
fi
