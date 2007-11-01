package {
	
	import com.imvu.widget.*;
	import com.imvu.events.*;
	import flash.events.*;
	import fl.motion.Color;

	public class CircleWidget extends ClientWidget {
		
		public var active:Boolean = false;

		public function initWidget():void {
			this.circleButton.addEventListener(MouseEvent.CLICK, toggleColor);
			this.addEventListener("circleClicked", toggleColor);
		}
		
		private function toggleColor(e:Event) {
			if (e.type == MouseEvent.CLICK) {
				this.fireRemoteEvent("circleClicked");
			}
			
			if (! active) {
				active = true;
				var colorOn:Color = new Color();
				colorOn.color = 0xff0000;
				this.circleButton.transform.colorTransform = colorOn;
			} else {
				active = false;
				var colorOff:Color = new Color();
				colorOff.color = 0x000066;
				this.circleButton.transform.colorTransform = colorOff;
			}
		}
		
	}

}