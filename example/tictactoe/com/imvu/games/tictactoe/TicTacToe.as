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
		
		public var board:Array;
		public var myPlayerNumber:Number = 1;
		public var theirPlayerNumber:Number = 2;
		public var isMyTurn:Boolean = false;
		public var markers:Array = new Array(9);
		
		public var txtStatus:TextField;
		public var cover:MovieClip;
		public var btnPlayAgain:SimpleButton;
		public var marker0:Space;
		public var marker1:Space;
		public var marker2:Space;
		public var marker3:Space;
		public var marker4:Space;
		public var marker5:Space;
		public var marker6:Space;
		public var marker7:Space;
		public var marker8:Space;
		public var gameboard:MovieClip;
		
		public function initWidget():void {
			this.widgetName = "Tic-Tac-Toe";
			this.loadSkin();
			this.markers = [marker0,marker1,marker2,marker3,marker4,marker5,marker6,marker7,marker8];
			
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
		}
		
		public function loadSkin():void {
			gameboard.background.load(this.path + "background.png");
			gameboard.grid.load(this.path + "grid.png");
		}
		
		public function playAgain(e:Event=null) {
			this.fireRemoteEvent("playAgain");
			this.reset();
		}
		
		public function opponentJoined(e:WidgetEvent):void {
			// Someone else joined, which means that you're the master
			var data:WidgetEventData = e.data;
			this.fireRemoteEvent("confirmJoin"); // Let the remote client know that you saw them and you're ready to play
			addMarkerListeners();
			this.myTurn();
		}
		
		public function confirmJoin(e:WidgetEvent):void {
			// Someone else is already using the tic-tac-toe game, so you become player 2
			var data:WidgetEventData = e.data;
			this.theirPlayerNumber = 1;
			this.myPlayerNumber = 2;
			addMarkerListeners();
			this.theirTurn();
		}
		
		public function opponentMove(e:WidgetEvent):void {
			Debug.write("Opponent took a turn", this.space.avatarName);
			var args:Object = e.data.args;
			board[args.square] = theirPlayerNumber;
			markers[args.square].markForPlayer(theirPlayerNumber);
			this.myTurn();
		}
		
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
		
		public function checkTie():Boolean {
			for (var i:Number=0;i<9;i++) {
				if (! board[i]) {
					return false;
				}
			}
			return true;
		}
		
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
		
		public function win(e:Event) {
			txtStatus.text = "You Win!";
			this.cover.visible = true;
			this.gameOver();
		}
		
		public function lose(e:Event) {
			txtStatus.text = "You Lose!";
			this.cover.visible = true;
			this.gameOver();
		}
		
		public function tie(e:Event) {
			txtStatus.text = "Tie!";
			this.cover.visible = true;
			this.gameOver();
		}
		
		public function gameOver():void {
			btnPlayAgain.visible = true;
		}
		
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