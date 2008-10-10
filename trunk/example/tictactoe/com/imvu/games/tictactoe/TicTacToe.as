/*
IMVU Flash Widget API, Copyright 2007 IMVU
    
This file is part of the IMVU Flash Widget API.

The IMVU Flash Widget API is free software: you can redistribute it 
and/or modify it under the terms of the GNU General Public License 
as published by the Free Software Foundation, either version 3 of 
the License, or (at your option) any later version.

The IMVU Flash Widget API is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with the IMVU Flash Widget API. If not, see <http://www.gnu.org/licenses/>.
*/
package com.imvu.games.tictactoe {
	import com.imvu.widget.*;
	import com.imvu.events.*;
	import flash.text.TextField;
	import flash.events.*;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import com.interactiveAlchemy.utils.Debug;
	import flash.net.URLRequest;
	import flash.display.Loader;
	
	public class TicTacToe extends ClientWidget {
		
		/**
		 * A simple array representation of the current game board
		 */
		public var board:Array;
		
		/**
		 * The player number (1 or 2) of the current user
		 */
		public var myPlayerNumber:Number = 1;
		
		/**
		 * The player number (1 or 2) of the opponent
		 */
		public var theirPlayerNumber:Number = 2;
		
		/**
		 * A boolean indicating whether it is the current player's turn
		 */
		public var isMyTurn:Boolean = false;
		
		/**
		 * An array of references to the X/O markers on the game board.
		 * @see com.imvu.games.tictactoe.Space Space
		 */
		public var markers:Array = new Array(9);
		
		/**
		 * The text field used to display status messages at the bottom of the game board
		 */
		public var txtStatus:TextField;
		
		/**
		 * A blank mask used to cover the game board from being clicked during an
		 * opponent's turn
		 */
		public var cover:MovieClip;
		
		/**
		 * The button that appears prompting the user to play again when the game has ended.
		 */
		public var btnPlayAgain:SimpleButton;
		
		/**
		 * The top-left game board marker.
		 */
		public var marker0:Space;
		
		/**
		 * The top-center game board marker.
		 */
		public var marker1:Space;
		
		/**
		 * The top-right game board marker.
		 */		
		public var marker2:Space;
		
		/**
		 * The middle-left game board marker.
		 */		
		public var marker3:Space;

		/**
		 * The absolute center game board marker.
		 */			
		public var marker4:Space;
		
		/**
		 * The middle-right game board marker.
		 */			
		public var marker5:Space;
		
		/**
		 * The bottom-left game board marker.
		 */			
		public var marker6:Space;
		
		/**
		 * The bottom-center game board marker.
		 */			
		public var marker7:Space;
		
		/**
		 * The bottom-right game board marker.
		 */			
		public var marker8:Space;

		/**
		 * The movie clip representing the actual game board UI.
		 */
		public var gameboard:MovieClip;

		/**
		 * Initializes the game, wires the event listeners, loads the skin, and sets the game
		 * into its default "waiting for opponent" state
		 */		
		public function initWidget():void {
			this.widgetName = "Tic-Tac-Toe";
			this.loadSkin();
			this.markers = [marker0,marker1,marker2,marker3,marker4,marker5,marker6,marker7,marker8];
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			this.addEventListener(WidgetSpace.WIDGET_UNLOADED, this.reset);
			this.addEventListener("joinWidget", this.opponentJoined);
			this.addEventListener("confirmJoin", this.confirmJoin);
			this.addEventListener("opponentMove", this.opponentMove);
			this.addEventListener("youLose", this.lose);
			this.addEventListener("win", this.win);
			this.addEventListener("tie", this.tie);
			this.addEventListener("playAgain", this.reset);
			
			btnPlayAgain.addEventListener(MouseEvent.CLICK, this.playAgain);
			
			this.reset();
			this.txtStatus.text = "Waiting for opponent...";
			this.focus();
		}
		
		private function mouseDown(e:MouseEvent):void {
			this.startDrag();
		}
		
		private function mouseUp(e:MouseEvent):void {
			this.stopDrag();
		}
		/**
		 * Loads the skin for the background and grid portions of the game
		 */
		public function loadSkin():void {
			gameboard.background.load(this.path + "background.png");
			gameboard.grid.load(this.path + "grid.png");
		}
		
		/**
		 * Called when the user chooses to play the game again
		 */
		public function playAgain(e:Event=null) {
			this.fireRemoteEvent("playAgain");
			this.reset();
		}
		
		/**
		 * Event handler executed when an opponent joins the game
		 */
		public function opponentJoined(e:WidgetEvent):void {
			// Someone else joined, which means that you're the master
			var data:WidgetEventData = e.data;
			this.fireRemoteEvent("confirmJoin"); // Let the remote client know that you saw them and you're ready to play
			addMarkerListeners();
			this.myTurn();
		}
		
		/**
		 * Event handler executed when the current user joins the game and receives confirmation
		 * that another player has already taken control of the game.
		 */
		public function confirmJoin(e:WidgetEvent):void {
			// Someone else is already using the tic-tac-toe game, so you become player 2
			var data:WidgetEventData = e.data;
			this.theirPlayerNumber = 1;
			this.myPlayerNumber = 2;
			addMarkerListeners();
			this.theirTurn();
		}
		
		/**
		 * Event handler executed when the opponent takes a turn.
		 */
		public function opponentMove(e:WidgetEvent):void {
			Debug.write("Opponent took a turn", this.space.avatarName);
			var args:Object = e.data.args;
			board[args.square] = theirPlayerNumber;
			markers[args.square].markForPlayer(theirPlayerNumber);
			this.myTurn();
		}
		
		/**
		 * Sets the state of the game to indicate that it is the current local user's turn.
		 */
		public function myTurn():void {
			this.isMyTurn = true;
			cover.visible = false;
			switch (myPlayerNumber) {
				case 1:
					txtStatus.text = "X: ";
					break;
				case 2:
					txtStatus.text = "O: ";
					break;
			}
			txtStatus.appendText("It's your turn!");
		}
		
		/**
		 * Sets the state of the game to indicate that it is the remote user's turn.
		 */
		public function theirTurn():void {
			this.isMyTurn = false;
			cover.visible = true;
			switch (myPlayerNumber) {
				case 1:
					txtStatus.text = "X: It's O's turn!";
					break;
				case 2:
					txtStatus.text = "O: It's X's turn!";
					break;
			}
		}
		
		/**
		 * Marks a space for a particular player and checks to see if the move resulted
		 * in a win, loss, or tie.
		 * @param index The index of the space (0-8) to mark.
		 */
		public function markSpace(index:Number):void {
			Debug.write("Player " + myPlayerNumber + ": trying to mark space " + index);
			if (! board[index] && isMyTurn) {
				board[index] = myPlayerNumber;
				markers[index].markForPlayer(myPlayerNumber);
				markers[index].disableClick();
				this.fireRemoteEvent("opponentMove", { square: index });
				if (checkWin()) {
					this.fireRemoteEvent("youLose");
					this.dispatchEvent(new Event("win"));
				} else if (checkTie()) {
					this.fireRemoteEvent("tie");
					this.dispatchEvent(new Event("tie"));
				} else {
					this.theirTurn();
				}
			}
		}
		
		/**
		 * Adds event listeners to the markers on the board, making them clickable during
		 * the game.
		 */
		public function addMarkerListeners():void {
			var me = this;
			for (var i:Number=0;i<9;i++) {
				var marker:Space = markers[i];
				marker.index = i;
				marker.clickHandler = function(e:MouseEvent) {
					Debug.write("Player " + me.myPlayerNumber + " is trying to select " + e.currentTarget.name);
					me.markSpace(e.currentTarget.index);
				}
				marker.enableClick();
			}
		}
		
		/**
		 * Checks to see if the current game is a tie.
		 */
		public function checkTie():Boolean {
			for (var i:Number=0;i<9;i++) {
				if (! board[i]) {
					return false;
				}
			}
			return true;
		}
		
		/**
		 * Checks to see if the current game is a win.
		 */
		public function checkWin():Boolean {
			// Check for horizontal win
			if (
				(board[0] == myPlayerNumber && board[1] == myPlayerNumber && board[2] == myPlayerNumber) ||
				(board[3] == myPlayerNumber && board[4] == myPlayerNumber && board[5] == myPlayerNumber) ||
				(board[6] == myPlayerNumber && board[7] == myPlayerNumber && board[8] == myPlayerNumber)
			) {
				return true;
			}
			
			// Check for vertical win
			if (
				(board[0] == myPlayerNumber && board[3] == myPlayerNumber && board[6] == myPlayerNumber) ||
				(board[1] == myPlayerNumber && board[4] == myPlayerNumber && board[7] == myPlayerNumber) ||
				(board[2] == myPlayerNumber && board[5] == myPlayerNumber && board[8] == myPlayerNumber)
			) {
				return true;
			}
			
			// Check for diagonal win
			if (
				(board[0] == myPlayerNumber && board[4] == myPlayerNumber && board[8] == myPlayerNumber) ||
				(board[2] == myPlayerNumber && board[4] == myPlayerNumber && board[6] == myPlayerNumber)
			) {
				return true;
			}
			return false;
		}
		
		/**
		 * Event handler executed when the local player wins the game.
		 */
		public function win(e:Event) {
			txtStatus.text = "You Win!";
			this.cover.visible = true;
			this.gameOver();
		}
		
		/**
		 * Event handler executed when the remote player wins the game.
		 */
		public function lose(e:Event) {
			txtStatus.text = "You Lose!";
			this.cover.visible = true;
			this.gameOver();
		}
		
		/**
		 * Event handler executed in the event of a tie.
		 */
		public function tie(e:Event) {
			txtStatus.text = "Tie!";
			this.cover.visible = true;
			this.gameOver();
		}
		
		/**
		 * Indicates that the game has ended and displays the "Play Again" button.
		 */
		public function gameOver():void {
			btnPlayAgain.visible = true;
		}
		
		/**
		 * Resets the the game to its initial state.
		 */
		public function reset(e:Event=null):void {
			btnPlayAgain.visible = false;
			this.board = new Array(9);
			for (var i:Number=0;i<9;i++) {
				var marker:Space = this.markers[i];
				marker.clear();
				marker.enableClick();
			}
			this.cover.visible = false;
			switch (myPlayerNumber) {
				case 1:
					this.myTurn();
					break;
				case 2:
					this.theirTurn();
					break;
			}
		}
	}
}