package asunit.textui {
	import asunit.errors.AssertionFailedError;
	import asunit.framework.Test;
	import asunit.framework.TestFailure;
	import asunit.framework.TestListener;
	import asunit.framework.TestResult;
	import asunit.runner.BaseTestRunner;
	import asunit.runner.Version;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.StyleSheet;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import flash.utils.getQualifiedClassName;
    import mx.core.LayoutContainer;

	import mx.controls.TextArea;

	public class ResultPrinter extends LayoutContainer implements TestListener {
		private var fColumn:int = 0;
		private var textArea:TextArea;
		private var gutter:uint = 0;
		private var backgroundColor:uint = 0x333333;
		private var bar:SuccessBar;
		private var barHeight:Number = 3;
    	private var showTrace:Boolean;
        private var curText:String = '';

		public function ResultPrinter(showTrace:Boolean = false) {
			this.showTrace = showTrace;
			configureAssets();
			println("<font size='16' color='#000000'>");
		}

		private function configureAssets():void {

			textArea = new TextArea();
            textArea.editable = false;
			addChild(textArea);

			//bar = new SuccessBar();
			//addChild(bar);
		}

		public function setShowTrace(showTrace:Boolean):void {
			this.showTrace = showTrace;
		}
		
		public override function set width(w:Number):void {
            textArea.width = w - 2*gutter;
		}

		public override function set height(h:Number):void {
            textArea.move(gutter,gutter);
            textArea.height =  h - 2*gutter;
		}

		public function println(...args:Array):void {
            curText = curText + args.toString() + "\n";
            textArea.htmlText = curText;
            trace(args.toString()+"\n");
		}

		public function print(...args:Array):void {
            curText = curText + args.toString();
            textArea.htmlText = curText;
            trace(args.toString());
		}

		public function printResult(result:TestResult, runTime:Number):void {
			printHeader(runTime);
		    printErrors(result);
		    printFailures(result);
		    printFooter(result);

//   		    bar.setSuccess(result.wasSuccessful());
   		    if(showTrace) {
			    trace(textArea.text);
   		    }
		}

		/* Internal methods
		 */
		protected function printHeader(runTime:Number):void {
			println();
			println();
			println("Time: " + elapsedTimeAsString(runTime));
		}

		protected function printErrors(result:TestResult):void {
			printDefects(result.errors(), result.errorCount(), "error");
		}

		protected function printFailures(result:TestResult):void {
			printDefects(result.failures(), result.failureCount(), "failure");
		}

		protected function printDefects(booBoos:Object, count:int, type:String):void {
			if (count == 0) {
				return;
			}
			if (count == 1) {
				println("<font color='#FF0000'><b>There was " + count + " " + type + ":</b></font>");
			}
			else {
				println("<font color='#FF0000'><b>There were " + count + " " + type + "s:</b></font>");
			}
			var i:uint;
			for each (var item:TestFailure in booBoos) {
				printDefect(TestFailure(item), i);
				i++;
			}
		}

		public function printDefect(booBoo:TestFailure, count:int ):void { // only public for testing purposes
			printDefectHeader(booBoo, count);
			printDefectTrace(booBoo);
		}

		protected function printDefectHeader(booBoo:TestFailure, count:int):void {
			println("<br/><font color='#FF0000'><b>" + count + ") " + booBoo.failedTest() + "</b></font>");
		}

		protected function printDefectTrace(booBoo:TestFailure):void {
			println('Type: ' + getQualifiedClassName(booBoo.thrownException()));
			println(BaseTestRunner.getFilteredTrace(booBoo.thrownException().getStackTrace()));
		}

		protected function printFooter(result:TestResult):void {
			println();
			if (result.wasSuccessful()) {
                print("<font color='#00AA00'><b>");
				print("OK");
				println (" (" + result.runCount() + " test" + (result.runCount() == 1 ? "": "s") + ")");
                print("</b>");
			} else {
                print("<font color='#FF0000'><b>");
				println("FAILURES!!!");
				println("Tests run: " + result.runCount()+
					         ",  Failures: "+result.failureCount()+
					         ",  Errors: "+result.errorCount());
                print("</b>");
			}
		    println();
		}

		/**
		 * Returns the formatted string of the elapsed time.
		 * Duplicated from BaseTestRunner. Fix it.
		 */
		protected function elapsedTimeAsString(runTime:Number):String {
			return Number(runTime/1000).toString();
		}

		/**
		 * @see junit.framework.TestListener#addError(Test, Throwable)
		 */
		public function addError(test:Test, t:Error):void {
			print("<font color='#FF0000'><b>E</b></font>");
		}

		/**
		 * @see junit.framework.TestListener#addFailure(Test, AssertionFailedError)
		 */
		public function addFailure(test:Test, t:AssertionFailedError):void {
			print("<font color='#FF0000'><b>F</b></font>");
		}

		/**
		 * @see junit.framework.TestListener#endTest(Test)
		 */
		public function endTest(test:Test):void {
		}

		/**
		 * @see junit.framework.TestListener#startTest(Test)
		 */
		public function startTest(test:Test):void {
			var count:uint = test.countTestCases();
			for(var i:uint; i < count; i++) {
				print(".");
				if (fColumn++ >= 80) {
					println();
					fColumn = 0;
				}
			}
		}
	}
}

import flash.display.Sprite;

class SuccessBar extends Sprite {
	private var myWidth:uint;
	private var myHeight:uint;
	private var bgColor:uint;
	private var passingColor:uint = 0x00FF00;
	private var failingColor:uint = 0xFD0000;

	public function SuccessBar() {
	}

	public function setSuccess(success:Boolean):void {
		bgColor = (success) ? passingColor : failingColor;
		draw();
	}

	public override function set width(num:Number):void {
		myWidth = num;
		draw();
	}

	public override function set height(num:Number):void {
		myHeight = num;
		draw();
	}

	private function draw():void {
		graphics.clear();
		graphics.beginFill(bgColor);
		graphics.drawRect(0, 0, myWidth, myHeight);
		graphics.endFill();
	}
}
