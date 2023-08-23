REM *****************************
REM      INSTALL ON TEST ORG   
REM *****************************

REM Config
SET testOrg=orgAlias
SET packageVersionId=04t4K000002JvUDQA0

REM Install the package
sf package:install -p %packageVersionId% --target-org %testOrg% --wait 30

REM Deploy the demo files
sf project deploy start --source-dir force-app/demo --target-org %testOrg%

REM Run the tests
sf apex run test --class-names MckDemoTest --class-names TstDemoTest --code-coverage --detailed-coverage --wait 30 --result-format human --target-org %testOrg%

REM Delete the test files
sf project delete source --metadata ApexClass:TstDemo --metadata ApexClass:MckDemo --metadata ApexClass:TstDemoTest --metadata ApexClass:MckDemoTest --target-org %testOrg% --no-prompt

REM Uninstall the package
sf package uninstall --package %packageVersionId% --target-org %testOrg% --wait 30
