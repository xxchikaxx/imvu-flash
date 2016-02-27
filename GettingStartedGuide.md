# IMVU Flash Widget API - Getting Started Guide #

The IMVU Flash Widget API allows you to create Adobe Flash widgets that can be accessed by users of the IMVU 3D Instant Messenger chat client. These widgets are overlaid on top of IMVU's 3D window, and can be used for any number of purposes, including interactive games that can be played by two or more players in a 3D chat session.

Using IMVU's unique virtual marketplace, which receives thousands of shoppers every hour, developers can earn money selling their widgets to other IMVU users. Developers can also allow others to create derived widget skins to alter the default look and feel, and earn a profit from derived sales as well.

This tutorial assumes basic knowledge of ActionScript 3, Adobe Flash CS3, and basic   familiarity with IMVU's product submission tool, the IMVU Previewer. For more information about IMVU's developer program, you can visit [the IMVU Developer Center](http://www.imvu.com/catalog/devtools/).

You can find the completed tutorial files in the "cicle" directory under the "example" folder of the install.

Let's get started!

1. Download the latest [IMVU Flash API install package](http://code.google.com/p/imvu-flash/) from Google Code, and unzip it to a folder on your hard drive. (If you're reading this document from the install package, you've already completed this step!)

Next, let's get the lay of the land and take an inventory of what's included in the install package. In the folder where you've unzipped the package, you'll see the following directories:

  * **bin**- The compiled IMVU ActionScript library (imvu-flash.swc). You'll use this library when developing and compiling your widgets.
  * **doc**- The API documentation for the IMVU ActionScript library. Open "index.html" to browse the API reference.
  * **example**- Example files that will help you better understand how the API works for different types of widgets.
  * **fla**- Various Adobe Flash (FLA) files used for compiling the ActionScript libraries.
  * **lib**- External 3rd party libraries used alongside the IMVU API.
  * **src**- The full source code of the IMVU Flash Widget API.
  * **test**- A collection of AsUnit (see http://www.AsUnit.org) test cases that verify that the IMVU API is functioning properly. Writing test cases for your widgets can be very beneficial, especially as they become more complex.
  * **tools**- A set of tools for running your widgets locally without using the IMVU 3D client. The tools will allow you to simulate multi-user chat sessions and test your widgets. We will cover these tools in more detail later in the tutorial.

2. Create a new folder called "circle" for the example that we're going to build.

3. Copy "imvu-flash.swc" from the "bin" folder (mentioned above) into your new "circle" folder that you created. This will make the IMVU libraries available to the widget that you're going to create.

4. Start Adobe Flash CS3 and click File->New. Choose "Flash File (ActionScript 3.0)" and click "OK". You should now have a shiny-new, blank document ready for you to get started. Before we move on, save the file in the "circle" directory you created by clicking File->Save. Call the file "circle.swf".

5. Next, we're going to do a little bit of drawing. In the toolbox, select the "Oval Primitive" tool, and draw a circle on the stage, and make it whatever color you'd like. Mine is going to be dark blue.

6. Convert the circle you just drew to a Symbol by right-clicking on it and choosing "Convert to Symbol". For the name, type "Circle", and choose "Button" as the type. Under the "Linkage" section, check "Export for ActionScript". The class name will be pre-filled as "Circle", which is great, because that's what we're going to call it. The base class is also pre-set to "flash.display.SimpleButton", which is fine for now. Click "OK".

7. Click your circle on the stage, and in the box that says "<Instance Name>", type "circleButton". This will allow you to refer to the circle in your code when you want to make something happen.

8. Before we move on from our circle, let's get rid of all that extra white space on the stage so we can focus more easily on the content. Click in any blank area inside or outside the stage, and you'll see the document properties in your Properties panel. Click the button labeled "Size", and under "Match" choose the "Contents" option. Click "OK". This will make your stage shrink to match the circle that you created.

9. Now it's time to get our hands dirty with a little bit of ActionScript. Click File->New, and choose "ActionScript File", followed by clicking "OK". You should have a blank ActionScript file called Script-1. Go ahead and save the file in your "circle" folder, and call it "CircleWidget.as".

10. Our widget is going to be a simple circle-shaped button that either user can click, and when it's clicked it will change to a different color on both users' screens.

In your blank CircleWidget.as file, copy and paste the following code:

```
package {
    import com.imvu.widget.*;
    import com.imvu.events.*;
    import flash.events.*;
    import fl.motion.Color;

    public class CircleWidget extends ClientWidget {

		public function initWidget():void {
		}
  
	}
}
```


This is the base document class for your first widget. Whenever you want to build an IMVU widget, you'll want to make sure that it extends IMVU's ClientWidget class, which will give you access to special capabilities in the IMVU client, including multi-user communication.

To associate this code with your widget, go back to your "circle.fla" file, click on any empty part of the stage, and in the Properties panel in the "Document class" box, type "CircleWidget". You can verify that everything works by clicking the pencil next to the text box you just typed in -- that will take you to your CircleWidget.as file so that you can continue building your widget.

11. Now is where the fun really begins. We're going to make your Circle Widget actually do something -- we're going to make it turn red when you click it. First, we will add a variable to our CircleWidget class to keep track of whether the widget is in the "clicked" state or not. Before your `initWidget` function, add this line:

```
public var active:Boolean = false;
```

Then, after your `initWidget` function, paste this new function:

```
private function toggleColor(e:Event) {
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
```


Now you have some code that will change the color of the circle, but it won't do anything until you wire it up to change color when you click on it. In order to do that, we need to attach an event listener to the button. In your `initWidget` function, add this line:

```
this.circleButton.addEventListener(MouseEvent.CLICK, toggleColor);
```

Anything you put in the `initWidget` function will get executed when your widget is first loaded and intialized. In this case, we're adding an event listener so that when the user loads the widget, the circle button will be clickable immediately.

Adding this event listener will tell ActionScript to call the "toggleColor" function whenever the circle is clicked, changing the circle from blue to red and back again.

12. Next, we'll become familiar with the IMVU Flash tools by loading our circle widget into a simulated IMVU chat client. Click "File->Publish Settings", and in the "Flash" tab under "Local playback security", choose "Access network only". Then, publish your "circle.fla" file to a SWF file by clicking on the "Publish" button. This will create a circle.swf file in the folder you created. Locate "circle.swf", copy it, and paste it in the "tools" folder under the IMVU Flash API install folder.

_Note: The files you are testing in the simulator must be in the "tools" folder due to Flash local file security restrictions._

13. Now, we're ready to test your widget in a mock version of the IMVU client. First, in the "tools" folder, open "MockServer.swf". This file will allow multiple instances of the mock client to talk to one another on your computer in the same way that the IMVU server manages chat messages between remote clients. Next, open two instances of "MockClient.swf". Each one represents a different chat user. You can see the connection in action by typing in the chat field at the bottom of the window.

14. Next, we're going to load your newly created "circle.swf" widget into the mock client. Click the "+" button at the top-right hand corner of each MockClient window, and choose "circle.swf". Once you do that, your blue circle will load into each window, and if you click it, it will turn red. However, you'll notice that the circles on each client are not synchronized, and where's the fun in that? Next, we'll use IMVU's API to create a connection between each user's widget to synchronize them. This is the basis for creating interactive, shared experiences on IMVU.

15. Let's revisit your CircleWidget code and make some changes to create some basic multi-user interactivity. We want to make it so that when the circle is clicked by one user, it also changes for the other user. This requires us to add two things to the code: a) Make it so that when you click your circle, the other user's circle changes too, and b) Make it so that your circle is listening for the other user to click, and changes as well. Let's tackle the second item first.

Add the following line to your `initWidget` function:

```
this.addEventListener("circleClicked", toggleColor);
```

This line tells your your widget to listen for an event called "circleClicked" to be fired, and to execute the "toggleColor" function in response. The IMVU Flash API makes use of the ActionScript 3 built-in event handling model. Adobe offers [a helpful introduction to ActionScript 3 event handling](http://www.adobe.com/devnet/ActionScript/articles/event_handling_as3.html) at their developer site. With this line of code in place, your local circle widget will respond to remote instances of the same widget firing the "circleClicked" event. The next step involves setting up your widget to broadcast the event indicating that the circle has been clicked.

Since we only want to broadcast the event when you physically click on the circle, we'll add the following lines of code to the beginning of the "toggleColor" function:

```
if (e.type == MouseEvent.CLICK) {
	this.fireRemoteEvent("circleClicked");
}
```


This code simply checks to make sure that the "toggleColor" function was fired as a result of a click (as opposed to a remote event being fired by another user), and fires the remote event (broadcasting the change) if you click on the circle. If you try taking out the "if" statement, you'll see that when a click happens, the message would simply be bounced back and forth, resulting in an infinite loop.

16. Now. you're ready to publish your Flash file again, and re-open the MockServer and MockClient files (see steps 12-14). If you reload the circle.swf widget in each of your MockClient windows, and try clicking on one of the circles, you'll see that they are now synchronized.

17. In order to submit your product, you'll need to fire up latest release of the IMVU Previewer, available from the [IMVU Developer Center](http://www.imvu.com/catalog/devtools/devtools_Previewer.php). You will either need to create a product with two or more seats, or derive from an existing product. For the sake of this tutorial, you'll derive from an existing product, the IMVU denim couch. To derive from a product in the Previewer, go to the File menu and click "Create a Derived Product". Enter 12907 in the box, and click OK. The couch will load in the Previewer's 3D window.

18. Click the "Special" tab, and near the bottom you will see a "Flash SWF" field. Click "Browse" and choose the "circle.swf" file that you published earlier in the tutorial. In the "Trigger Type" field, choose "Seat", and then go to File and Save. If you click on the "CFL Assets" tab, you should see your SWF file included in the product. Click the button at the top of the Previewer window labeled "Submit Product To IMVU Catalog" and follow the product submission instructions there.

That's it! You should be able to try your 3D product in the IMVU client, and when you sit in one of the seats, your Flash circle should launch in the 3D window. For a more complex example, see the Tic-Tac-Toe game included in the "example" folder of this release.