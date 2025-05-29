extends Node


## customer:
## responses[personality][susbcription][dialogue_branch]
## each entry is an array of dictionaries:
## {
##     "text": string,         # customer's response to player's shenanigans
## }


## service agent (player):
## responses[personality][subscription][dialogue_branch]
## each entry is an array of dictionaries:
## {
##     "text": string,         # what the player can say
##     "mood_change": int      # how the response affects the customer's mood (positive or negative)
## }
