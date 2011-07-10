"Load Opal Compiler"
Gofer new
	squeaksource: 'rb';
	package: 'AST-Core';
	load.

Gofer new
	squeaksource: 'OpalCompiler';
	package: 'OpalCompiler-Core';
	package: 'OpalCompiler-Tests';
	package: 'OpalCompiler-RegressionTests';
	load.
