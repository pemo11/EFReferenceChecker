// File: EFHelper.prg

USING System
USING System.Collections.Generic
USING System.Configuration
USING System.Diagnostics
USING System.IO
USING System.Linq
USING System.Reflection
USING System.Xml.Linq
USING System.Text.RegularExpressions
USING System.Windows.Forms

BEGIN NAMESPACE EFReferenceChecker

	/// <summary>
    /// The EFHeloer class
    /// </summary>
    STATIC CLASS EFHelper

        /// <summary>
        ///  Dll-Dateien aus dem bin-Verzeichnis einlesen
        /// </summary>
        INTERNAL STATIC METHOD ReadBinFolder(binPath AS STRING, binList AS List<FileInfo>) AS VOID
            FOREACH VAR dllFile IN DirectoryInfo{binPath}:GetFiles("*.dll")
                binList:Add(dllFile)
            NEXT
        END METHOD

        /// <summary>
        /// Einlesen der Config-Datei-Einträge
        /// </summary>
        PUBLIC STATIC METHOD ReadConfigData(Frm AS MainForm) AS VOID
            TRY
                Frm:binPath := ConfigurationManager.AppSettings["binPath"]
                Frm:projFile := ConfigurationManager.AppSettings["projFile"]
                Frm:netVersion := ConfigurationManager.AppSettings["netVersion"]
                Frm:x86 := ConfigurationManager.AppSettings["platformType"] == "x86"
                Frm:lblBinPath:Text :=Frm:binPath
                IF Directory.Exists(Frm:binPath)
                    EFHelper.ReadBinFolder(Frm:binPath, Frm:binAssemblies)
                ENDIF
                Frm:UpdateStatus("*** Daten aus Config-Datei eingelesen")
            CATCH ex AS SystemException
                VAR msg := i"!!! Fehler beim Einlesen der Config-Datei ({ex}"
                LogHelper.LogError(msg, ex)
                Frm:UpdateStatus(msg)
            END TRY
        END METHOD


        /// <summary>
        /// Prüfen, ob sich eine Dll im GAC befinde
        /// Wenn positiv, wird Versionsnummer der gefundenen Dll zurückgegeben
        /// </summary>
        PUBLIC STATIC METHOD CheckGACForFile(AssemblyName AS STRING, Frm AS MainForm) AS STRING
            LOCAL result := "" AS STRING
            TRY
                VAR gacPath := "C:\Windows\assembly\GAC_MSIL"
                VAR dllDirpath := Path.Combine(gacPath, Path.GetFileNameWithoutExtension(AssemblyName))
                IF Directory.Exists(dllDirpath)
                    VAR dllDirname := DirectoryInfo{dllDirpath}:GetDirectories()[1].Name
                    // Versionsnummer abtrennen
                    result := dllDirname:Split(c"_")[1]
                END IF
            CATCH ex AS SystemException
                VAR msg := i"!!! Fehler in CheckGACForFile ({ex})"
                LogHelper.LogError(msg, ex)
                Frm?:UpdateStatus(msg)
            END TRY
            RETURN result
            END METHOD

            /// <summary>
            /// Prüft, ob sich eine Dll im ReferenceAssemblies-Verzeichnis befindet
            /// </summary>
            PUBLIC STATIC METHOD CheckRefAssembly(netVersion AS STRING, x86 AS LOGIC, AssemblyName AS STRING, Frm AS MainForm) AS STRING
                TRY
                    VAR AssPath := IIF(x86, "C:\Program Files (x86)", "C:\Program Files") + ;
                        i"\Reference Assemblies\Microsoft\Framework\.NETFramework\v{NetVersion}"
                    AssPath += "/" + AssemblyName
                    // Gibt es die Datei?
                    IF File.Exists(AssPath)
                        VAR dllFile := FileInfo{AssPath}
                        // Jetzt auch die Version prüfen
                        VAR productVersion := FileVersionInfo.GetVersionInfo(dllFile:FullName):ProductVersion:ToString()
                        RETURN productVersion
                    ENDIF
                CATCH ex AS SystemException
                    VAR msg := i"!!! Fehler in CheckRefAssembly ({ex})"
                    LogHelper.LogError(msg, ex)
                    Frm:UpdateStatus(msg)
                END TRY
            RETURN ""
            END METHOD

        /// <summary>
        /// Holt alle Reference-Elemente aus der Proj-Datei
        /// </summary>
        PUBLIC STATIC METHOD GetReferenceElements(projFile AS STRING, Frm AS MainForm, UseResource := TRUE AS LOGIC) AS List<ReferenceElement>
            LOCAL xDoc AS XDocument
            LOCAL ns := XNamespace.Get("http://schemas.microsoft.com/developer/msbuild/2003") AS XNamespace
            VAR referenceList := List<ReferenceElement>{}
            TRY
                // Damit Tests möglich sind mit einer beliebigen Proj-Datei
                IF UseResource
                    BEGIN USING VAR st := Assembly.GetExecutingAssembly():GetManifestResourceStream("EFReferenceChecker." + projFile)
                        xDoc := XDocument.Load(st)
                    END USING
                ELSE
                    xDoc := XDocument.Load(projFile)
                EndIf
                VAR references := xDoc:Descendants(ns + "Reference")
                // Damit Testen möglich ist (nicht optimal)
                IF Frm != NULL
                    Frm:missingAssemblies := List<STRING>{}
                    Frm:progressBar1:Value := 0
                    Frm:progressBar1:Maximum := references:Count()
                    Frm:UpdateStatus(i"*** Analysiere {projFile}")
                ENDIF
                FOREACH VAR reference IN references
                    // Geht nicht
                    // Frm?:progressBar1:Value++
                    IF Frm != NULL
                        Frm:progressBar1:Value++
                    ENDIF
                    System.Threading.Thread.Sleep(50)
                    Application.DoEvents()
                    IF reference:Element(ns + "AssemblyName") != NULL
                        VAR refElement := ReferenceElement{}
                        VAR include := reference:Attribute("Include"):Value
                        refElement:AssemblyName := reference:Element(ns + "AssemblyName"):Value
                        refElement:Version := Regex.Match(include, "Version=([\d.]+)"):Groups[1]:Value
                        refElement:SpecificVersion := Boolean.Parse(reference:Element(ns + "SpecificVersion"):Value)
                        referenceList:Add(refElement)
                    END IF
                NEXT
            CATCH ex AS SystemException
                VAR msg := i"!!! Fehler in GetReferenceElements ({ex})"
                LogHelper.LogError(msg, ex)
                Frm?:UpdateStatus(msg)
            END TRY
            RETURN referenceList

    END CLASS

END NAMESPACE // EFReferenceChecker