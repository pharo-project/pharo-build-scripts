Gofer new
	squeaksource: 'Handle';
	package: 'Handles';
	load.
	
Smalltalk recreateSpecialObjectsArrayForHandle.


"Hard code rule !!!!"
"ImageMorph allInstances first image: ((Form fromFileNamed:'./Doc/Handle.png') scaledIntoFormOfSize:(ImageMorph allInstances first image extent))."

(Smalltalk saveAs: 'HandlesImage.image') 
	ifFalse: [ Smalltalk snapshot: false andQuit: true ]