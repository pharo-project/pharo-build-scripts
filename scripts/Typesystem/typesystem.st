"Load The TypeSystem ..."
"see  http://pleiad.dcc.uchile.cl/private/gradual-types/installation"


"Installing NCAPI"
Gofer new
	squeaksource: 'OpalFrontend';
	package: 'Compiler-Frontend';
	load.
Gofer new
	squeaksource: 'OpalFrontend';
	package: 'Compiler-Requests';
	load.
Gofer new	
	squeaksource: 'OpalFrontend';
	package: 'Compiler-Debugger';
	load.
Gofer new	
	squeaksource: 'OpalFrontend';
	package: 'Compiler-Shout';
	load.
Gofer new
	squeaksource: 'OpalFrontend';
	package: 'AncientCompiler-Frontend';
	load.
Gofer new	
	squeaksource: 'OpalFrontend';
	package: 'AncientCompiler-Debugger';
	load.
Gofer new
	squeaksource: 'OpalFrontend';
	package: 'AncientCompiler-Shout';
	load.
Gofer new
	squeaksource: 'OpalFrontend';
	package: 'OpalCompiler-Fixes';
	load.
Gofer new	
	squeaksource: 'OpalFrontend';
	package: 'OpalCompiler-Frontend';
	load.
Gofer new	
	squeaksource: 'OpalFrontend';
	package: 'OpalCompiler-Debugger';
	load.
Gofer new
	squeaksource: 'OpalFrontend';
	package: 'OpalCompiler-Shout';
	load.
Gofer new
	squeaksource: 'OpalFrontend';
	package: 'Compiler-Extensions';
	load.

"Installing Spec"
Gofer it
        squeaksource3: 'Spec';
        package: 'ConfigurationOfSpec';
        load.
(Smalltalk at: #ConfigurationOfSpec) perform: #loadDefault.

"Installing Toothpick"
Gofer it
        squeaksource: 'Toothpick';
        package: 'ConfigurationOfToothpick';
        load.
(Smalltalk at: #ConfigurationOfToothpick) perform: #load.

"Installing RoelTyper"
Gofer it
        squeaksource: 'RoelTyper';
        package: 'RoelTyper';
        load.

"Installing bootstrapper"	
Gofer new
	squeaksource: 'GradualTypeSystem';
	package: 'TypeSystem-Bootstrap';
	load.

(FileStream oldFileNamed: '../scripts/Typesystem/loadfiles.st') fileIn.
TypeConfiguration uniqueInstance bootstrap: false.
(FileStream oldFileNamed: '../scripts/Typesystem/loadfiles.st') fileIn.
(FileStream oldFileNamed: '../scripts/Typesystem/loadfiles.st') fileIn.

TypeConfiguration uniqueInstance enableInstrumentation: true.
TypeConfiguration uniqueInstance enableCasts: true.
