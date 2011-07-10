"Run Fuel Tests"
[ HDTestReport runPackages: ConfigurationOfFuel testsCategoriesForHudson.
  HDLintReport runPackages: #('Fuel') ]
	on: Deprecation
	do: [ :err | err resume ]
