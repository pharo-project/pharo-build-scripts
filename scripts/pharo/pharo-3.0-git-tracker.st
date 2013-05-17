| version versionString |
Gofer new
	smalltalkhubUser: 'dh83' project: 'FileSystemST';
	package: 'ConfigurationOfFileSystemST';
	load.

version := SystemVersion current highestUpdate.
FileStream stdout nextPutAll: 'Extracting commit message';lf.
versionString := (ScriptLoader >> ('update', version asString) asSymbol) literals 
	detect: [ :e| e isString and: [ e isSymbol not ]]
	ifNone: [ '' ].

version asString asFileReference writeStreamDo: [ :stream| 
	stream nextPutAll: versionString ].



FileStream stdout nextPutAll: 'Installing FileSystemST';lf.
(Smalltalk at: #ConfigurationOfFileSystemST) loadDevelopment.


FileStream stdout nextPutAll: 'Exporting all Packages';lf.
(FileSystem st root) copyAllTo: 'pharo-core' asFileReference.

Smalltalk snapshot: true andQuit: true.