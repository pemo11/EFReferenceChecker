// Note: Inside Visual Studio you should open the Test - Windows - Test Explorer Window
// From there you can run the tests and see which tests succeeded and which tests failed
//
USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text
using Microsoft.VisualStudio.TestTools.UnitTesting

BEGIN NAMESPACE EFReferenceCheckerTest
    
    [TestClass]	;
	CLASS StandardTests1
        
		
	[TestMethod];
	METHOD TestMethod1 AS VOID  STRICT
		Assert.AreEqual(1,1)
        RETURN
        
	[TestMethod];
	METHOD TestMethod2 AS VOID  STRICT
		Assert.AreEqual(True, False) // Note that this will fail of course
        
	END CLASS
	
END NAMESPACE
