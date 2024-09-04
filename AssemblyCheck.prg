// File: AssemblyCheck.prg

USING System

BEGIN NAMESPACE EFReferenceChecker

	/// <summary>
    /// Definition of the AssemblyCheck class
    /// </summary>
    CLASS AssemblyCheck
        PROPERTY Id AS INT AUTO
        PROPERTY Name AS STRING AUTO
        PROPERTY VersionNeeded AS STRING AUTO
        PROPERTY VersionFound AS STRING AUTO
        PROPERTY Location AS STRING AUTO
	END CLASS

END NAMESPACE