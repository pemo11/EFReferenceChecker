// File: ReferenceElement.prg

USING System

BEGIN NAMESPACE EFReferenceChecker

	/// <summary>
    /// Bildet ein Reference-Element in der Projektdatei ab
    /// </summary>
	CLASS ReferenceElement
        INTERNAL PROPERTY AssemblyName AS STRING AUTO
        INTERNAL PROPERTY Version AS STRING AUTO
    END CLASS

END NAMESPACE // EFReferenceChecker