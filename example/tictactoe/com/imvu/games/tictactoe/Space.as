package com.imvu.games.tictactoe {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.interactiveAlchemy.utils.Debug;
	import com.imvu.widget.WidgetAsset;
	import com.imvu.widget.ClientWidget;
	
	/**
	 * Represents an X/O space on the Tic-Tac-Toe gameboard
	 */
	public class Space extends MovieClip {
		
		/**
		 * The index of the current space in the game board.
		 */
		public var index:Number = 0;
		
		/**
		 * The handler function that is executed when the player clicks the space.
		 * This function is defined by the TicTacToe class.
		 * @see com.imvu.games.tictactoe.TicTacToe TicTacToe
		 */
		public var clickHandler:Function;
		
		/**
		 * The skinnable asset that is displayed when the space is marked with "O".
		 */
		public var oMarker:WidgetAsset;
		
		/**
		 * The skinnable asset that is displayed when the space is marked with "X".
		 */
		public var xMarker:WidgetAsset;
		
		/**
		 * A reference to the marker's parent widget.
		 */
		public var widget:ClientWidget;
		
		public function Space() {
			this.buttonMode = true;
			this.useHandCursor = false;
			this.clear();
			this.widget = ClientWidget(this.parent);
		}
		
		/**
		 * Marks the space with "X".
		 */
		public function setX() {
			this.gotoAndStop("x");
		}
		
		/**
		 * Marks the space with "O".
		 */
		public function setO() {
			this.gotoAndStop("o");
		}
		
		/** 
		 * Marks the space for a specific player by number.
		 * @param player The player number
		 */
		public function markForPlayer(player:Number) {
			switch (player) {
				case 1:
					this.setX();
					break;
				case 2:
					this.setO();
					break;
			}
		}
		
		/**
		 * Clears the space to a blank state.
		 */
		public function clear() {
			this.gotoAndStop("off");
		}
		
		/**
		 * Attaches the event handler that processes clicks on the space from the user.
		 */
		public function enableClick() {
			if (this.clickHandler is Function) {
				Debug.write("Enabling click for " + this.index);
				this.useHandCursor = true;
				this.addEventListener(MouseEvent.CLICK, this.clickHandler);
			}
		}
		
		/**
		 * Detaches the event handler that processes clicks on the space.
		 */
		public function disableClick() {
			if (this.clickHandler is Function) {
				Debug.write("Disabling click for " + this.index);
				this.useHandCursor = false;
				this.removeEventListener(MouseEvent.CLICK, this.clickHandler);
			}
		}
	}
	
}