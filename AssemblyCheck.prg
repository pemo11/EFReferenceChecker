// File: AssemblyCheck.prg

USING System

BEGIN NAMESPACE EFReferenceChecker

	/// <summary>
    /// The AssemblyCheck class
    /// </summary>
    CLASS AssemblyCheck
        PROPERTY Id AS INT AUTO
        PROPERTY Name AS STRING AUTO
        PROPERTY VersionDetected AS STRING AUTO
        PROPERTY VersionNeeded AS STRING AUTO
	END CLASS

END NAMESPACE