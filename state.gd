extends Node

enum Turns {PLAYER_TURN, ENEMY_TURN, NO_TURN}
enum Game_Mode {GOLF, BATTLE}

var turn: Turns = Turns.PLAYER_TURN
var game_mode: Game_Mode
