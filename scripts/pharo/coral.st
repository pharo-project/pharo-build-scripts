"Gofer new squeaksource: 'Coral'; package: 'ConfigurationOfCoral'; load."
Gofer new url: 'http://ss3.gemstone.com/ss/coral';
    package: 'ConfigurationOfCoral';
    load.

(Smalltalk at: #ConfigurationOfCoral) perform: #loadBleedingEdge.
(Smalltalk at: #CoralInstaller) perform: #generateCoralScript.
(Smalltalk at: #CoralInstaller) perform: #generateAllExamples.

