

| log packagesDir|

[	

log := ((SmalltalkImage current getSystemAttribute: 3) ifNil: [FileDirectory default] ifNotNilDo: [:path | FileDirectory on: path]) forceNewFileNamed: 'info_loadTests.txt'.

packagesDir := ((SmalltalkImage current getSystemAttribute: 4) ifNil: [FileDirectory default] ifNotNilDo: [:path | FileDirectory on: path]).

packagesDir readOnlyFileNamed: 'SUnit.st' do: [:file | file fileInSilently ].
log nextPutAll: 'SUnit loaded'; cr.

packagesDir readOnlyFileNamed: 'CompilerTests.st' do: [:file | file fileInSilently ].
packagesDir readOnlyFileNamed: 'CollectionsTests.st' do: [:file | file fileInSilently ].
packagesDir readOnlyFileNamed: 'HudsonBuildTools.st' do: [:file | file fileInSilently ].

log nextPutAll: 'Tests loaded'; cr.

log close.

SmalltalkImage current snapshot: true andQuit: true.


] ifError: [:e |
	| rep |
	rep := FileStream forceNewFileNamed: 'PharoDebug.log'.
	rep nextPutAll: 'Error:'; cr.
	rep nextPutAll: e asString; cr.
	rep nextPutAll: thisContext stack size asString; cr.
"	rep nextPutAll: ((thisContext stack copy at: 12) tempsAndValues ) asString; cr."
	thisContext stack copy withIndexDo: [:stck :i |
		[rep nextPutAll: i asString; space; nextPutAll: stck asString; cr] ifError: [:er | rep nextPutAll: er asString; cr]].
	rep close. 
	Smalltalk quitPrimitive.]
  
! 