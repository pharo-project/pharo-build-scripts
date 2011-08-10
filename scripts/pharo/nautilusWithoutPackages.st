"Load Nautilus"
Gofer new
	squeaksource: 'Nautilus';
	package: 'ConfigurationOfNautilusWithoutPackages';
	load.
	
(Smalltalk at: #ConfigurationOfNautilusWithoutPackages) perform: #loadDefault