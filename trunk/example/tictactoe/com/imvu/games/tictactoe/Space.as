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
		public var txt:TextField;
		public var index:Number = 0;
		public var clickHandler:Function;
		public var oMarker:WidgetAsset;
		public var xMarker:WidgetAsset;
		public var widget:ClientWidget;
		
		public function Space() {
			this.buttonMode = true;
			this.useHandCursor = false;
			this.clear();
			this.widget = ClientWidget(this.parent);
		}
		
		public function setX() {
			this.gotoAndStop("x");
		}
		
		public function setO() {
			this.gotoAndStop("o");
		}
		
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
		
		public function clear() {
			this.gotoAndStop("off");
		}
		
		public function enableClick() {
			if (this.clickHandler is Function) {
				Debug.write("Enabling click for " + this.index);
				this.useHandCursor = true;
				this.addEventListener(MouseEvent.CLICK, this.clickHandler);
			}
		}
		
		public function disableClick() {
			if (this.clickHandler is Function) {
				Debug.write("Disabling click for " + this.index);
				this.useHandCursor = false;
				this.removeEventListener(MouseEvent.CLICK, this.clickHandler);
			}
		}
	}
	
}