REM RUN FROM SCRIPTS DIRECTORY
rem SECURITY SCAN - PMD
sf scanner:run -t "../force-app" -f html -o "scan-results/pmd-result.html" --verbose

rem SECURITY SCAN - GRAPH RULES
sf scanner:run:dfa --target ".\**\*.cls" --projectdir "../force-app/package/,../force-app/demo/" -f html -o "scan-results/graph-result.html" --verbose

