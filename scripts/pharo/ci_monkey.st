"Load the Integration manager"
Gofer new
	url: 'http://ss3.gemstone.com/ss/ci';
	package: 'ConfigurationOfContinousIntegration';
	load.
	
(Smalltalk at: #ConfigurationOfContinousIntegration) perform: #loadDefault.

