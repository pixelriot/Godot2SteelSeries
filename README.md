# Godot2SteelSeries
High level interface for calling Steel Series events from Godot

![DEMO CLIP](https://steamcommunity.com/games/975150/announcements/detail/2232043825315670896)

## Testing the app

* download and import the Godot2SteelSeries-project as a new Godot-project.
* run the project. If your SteelSeries engine is running and Godot connects succesfully, the checkbox *Steel Series connected* should be active. 
* click on the controls. It should change some colors on your Steel Series periphery.

![ui](https://user-images.githubusercontent.com/21098503/84658424-2dc13700-af16-11ea-908c-68dbe5bba7d0.png)

## Add SteelSeries integration to your project

* download the Godot2SteelSeries repositoty
* copy the **SteelSeriesController.tscn**-scene and **SteelSeriesController.gd**-script to your project
* add the **SteelSeriesController.tscn**-scene as a [singleton](https://docs.godotengine.org/en/3.0/getting_started/step_by_step/singletons_autoload.html) and name is **steelseries**.
* now you can call several SteelSeries functions from anywhere in your code.

# SteelSeries functions

The plugin is meant to act as a high level, easy to use interface with predefined events for the SteelSeries REST api.
Feel free to change the effect definitions in ```func register_events()```.

```steelseries.trigger_bitmap_event("UPGRADE")```   
A red and blue color effect will iluminate your full keyboard.

```steelseries.trigger_bitmap_event("RESET")```   
A white color effect will iluminate your full keyboard.
	
```steelseries.trigger_event("HEALTH", value)```   
value needs to be between 0 and 100.  
Function keys F1 - F12 display the value in green and red. 
	
```steelseries.trigger_event("DEATH", value)```   
Keyboard, mouse and headset flash in red.  
Keyboard screen shows skull icon and the value-parameter as death count.
	
```steelseries.trigger_event("KILL", value)```   
Keyboard, mouse and headset flash in white.  
Keyboard screen shows another skull icon and the value parameter as kill count.

```steelseries.trigger_event("FLASH", value)```   
value needs to be between 0 and 18.  
Keyboard, mouse and headset flash in a color depending on the value parameter.

