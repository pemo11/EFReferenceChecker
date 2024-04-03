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
        METHOD ReferenceCount1() AS VOID  STRICT
            VAR result := EFHelper.GetReferenceElements(projPath, NULL, FALSE)
		    Assert.IsTrue(result:Count == 4)
            RETURN

        [TestMethod];
        METHOD RefCheck1() AS VOID
            VAR assName := "System.Core.dll"
            VAR result := EFHelper.CheckRefAssembly("4.7.2", TRUE, "System.Core.dll", NULL)
            Assert.IsTrue(result != "")
            RETURN
            
        [TestMethod];
        METHOD RefCheck2() AS VOID
            VAR assName := "System.Core.dll"
            VAR result := EFHelper.CheckRefAssembly("4.7.2", TRUE, "System.Core.dll", NULL)
            Assert.IsTrue(result == "4.7.3062.0")
            RETURN

        [TestMethod];
        METHOD GACCheck1() AS VOID
            VAR gacPath := "C:\Windows\assembly\GAC_MSIL"
            VAR assName := "System.Deployment.dll"
            VAR result := EFHelper.CheckGACForFile(assName, NULL)
            Assert.IsTrue(result != "")
            RETURN

        [TestMethod];
        METHOD GACCheck2() AS VOID
            VAR gacPath := "C:\Windows\assembly\GAC_MSIL"
            VAR assName := "System.Deployment.dll"
            VAR result := EFHelper.CheckGACForFile(assName, NULL)
            Assert.IsTrue(result == "2.0.0.0")
            RETURN

        [TestMethod];
        METHOD GACCheck3() AS VOID
            VAR gacPath := "C:\Windows\assembly\GAC_MSIL"
            VAR assName := "GibtEsNicht.dll"
            VAR result := EFHelper.CheckGACForFile(assName, NULL)
            Assert.IsTrue(result == "")
            RETURN


	END CLASS

END NAMESPACE
