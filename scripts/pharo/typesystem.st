"Load The TypeSystem..."
"see  http://pleiad.dcc.uchile.cl/private/gradual-types/installation"


"Installing NCAPI"
Gofer new
	squeaksource: 'OpalFrontend';
	package: 'Compiler-Frontend';
	package: 'Compiler-Debugger';
	package: 'Compiler-Shout';
	package: 'AncientCompiler-Frontend';
	package: 'AncientCompiler-Debugger';
	package: 'AncientCompiler-Shout';
	package: 'OpalCompiler-Fixes';
	package: 'OpalCompiler-Frontend';
	package: 'OpalCompiler-Debugger';
	package: 'OpalCompiler-Shout';
	load.
	
	
Gofer new
	squeaksource: 'OpalFrontend';
	package: 'Compiler-Extensions';
		load.

	
	


