"Run Sista Tests"
[ HDCoverageReport runPackages: #('SistaTests').
  HDLintReport runPackages: #('Sista') ]
	on: Deprecation
	do: [ :err | err resume ]
