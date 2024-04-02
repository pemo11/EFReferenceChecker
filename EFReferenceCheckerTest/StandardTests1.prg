// Note: Inside Visual Studio you should open the Test - Windows - Test Explorer Window
// From there you can run the tests and see which tests succeeded and which tests failed
//
USING System
USING System.Collections.Generic
USING System.IO
USING System.Linq

USING Microsoft.VisualStudio.TestTools.UnitTesting
USING EFReferenceChecker

BEGIN NAMESPACE EFReferenceCheckerTest

    [TestClass]	;
	CLASS StandardTest1
    PRIVATE projPath AS STRING

    CONSTRUCTOR()
		projPath := Path.Combine(Environment.CurrentDirectory, "Test1.proj")

	[TestMethod];
    METHOD ReferenceCount1 AS VOID  STRICT
        VAR result := EFHelper.GetReferenceElements(projPath, NULL, False)
		Assert.IsTrue(result:Count == 4)
        RETURN


	END CLASS

END NAMESPACE
