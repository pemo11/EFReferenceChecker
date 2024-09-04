// ============================================================================
// File: XMLHelper.prg
// ============================================================================

USING System
USING System.Collections.Generic
USING System.Xml.Linq

BEGIN NAMESPACE EFReferenceChecker

	/// <summary>
    /// XML-Functions für den Report
    /// </summary>
    CLASS XMLHelper
    
        /// <summary>
        /// Assembly-Vergleich als XML speichern
        /// </summary>
        /// <param name="checkList"></param>
        /// <param name="xmlPath"></param>
        /// <returns></returns>
        STATIC METHOD WriteReport(checkList AS List<AssemblyCheck>, xmlPath AS STRING) AS LOGIC
            LOCAL retVal := TRUE AS LOGIC
            VAR xDoc := XDocument{}
            xDoc:Add(XElement{"AssemblyCheck"})
            VAR xRoot := xDoc:Root
            TRY
                FOREACH VAR check IN checkList
                    xRoot:Add(XElement{"Assembly", XElement{"Name",check:Name},;
                        XElement{"VersionNeeded", check:VersionNeeded}, XElement{"VersionFound", check:VersionFound},;
                        XElement{"Location", check:Location}})
                NEXT
                xDoc:Save(xmlPath)
            CATCH Ex AS SystemException
                VAR logMsg := i"Allgemeiner Fehler in WriteReport ({ex.Message})"
                retVal := FALSE
            END TRY
            RETURN retVal

	END CLASS
END NAMESPACE // EFReferenceChecker