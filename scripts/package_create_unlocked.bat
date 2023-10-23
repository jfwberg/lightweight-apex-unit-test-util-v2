REM *****************************
REM        PACKAGE CREATION   
REM *****************************

REM Package Create Config
SET devHub=devHubAlias
SET packageName=Lightweight - Apex Unit Test Util v2 (Unlocked)
SET packageDescription=A lightweight Apex Unit Test Utility library for User creation, Exception Testing, HTTP Callout and Callable Mocking
SET packageType=Unlocked
SET packagePath=force-app/package

REM Package Config
SET packageId=0Ho4K0000008OZISA2
SET packageVersionId=04tP30000007og1IAA

REM Create package
sf package create --name "%packageName%" --description "%packageDescription%" --package-type "%packageType%" --path "%packagePath%" --target-dev-hub %devHub%

REM Create package version
sf package version create --package "%packageName%"  --target-dev-hub %devHub% --code-coverage --installation-key-bypass --wait 30

REM Delete package
sf package:delete -p %packageId% --target-dev-hub %devHub% --no-prompt

REM Delete package version
sf package:version:delete -p %packageVersionId% --target-dev-hub %devHub% --no-prompt

REM Promote package
sf package:version:promote -p %packageVersionId% --target-dev-hub %devHub% --no-prompt
