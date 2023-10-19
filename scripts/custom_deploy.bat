REM Configuration
SET testOrg=orgAlias

REM Deploy the custom implementation files
sf project deploy start --source-dir force-app/custom --target-org %testOrg%

REM Run the tests
sf apex run test --class-names "ApexUnitTestUtilTest" --class-names "HttpMockUtilTest" --class-names "MockCallableUtilTest" --code-coverage --detailed-coverage --wait 30 --result-format human --target-org %testOrg%
