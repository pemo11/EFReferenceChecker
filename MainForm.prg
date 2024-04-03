// File: MainForm.prg

USING System
USING System.Collections.Generic
USING System.Configuration
USING System.Data
USING System.Diagnostics
USING System.Drawing
USING System.IO
USING System.LINQ
USING System.Reflection
USING System.Text.RegularExpressions
USING System.Windows.Forms
USING System.Xml.Linq

USING Ookii.Dialogs.WinForms
USING DevExpress.Utils
USING DevExpress.XtraGrid.Views.Grid

BEGIN NAMESPACE EFReferenceChecker

    PUBLIC PARTIAL CLASS MainForm INHERIT Form
        INTERNAL binPath AS STRING
        INTERNAL projFile AS STRING
        INTERNAL netVersion AS STRING
        INTERNAL x86 AS LOGIC
        INTERNAL binAssemblies AS List<FileInfo>
        INTERNAL missingAssemblies AS List<STRING>
        INTERNAL warningCount AS INT

        /// <summary>
        ///  Konstruktor
        /// </summary>
        PUBLIC CONSTRUCTOR() STRICT
            InitializeComponent()
            SELF:binAssemblies := List<FileInfo>{}
            Self:gridView1:OptionsView:ShowGroupPanel := False
            EFHelper.ReadConfigData(SELF)
            RETURN
        END CONSTRUCTOR


        /// <summary>
        /// Statuslistbox aktualisieren
        /// </summary>
        /// <param name="msg"></param>
        METHOD UpdateStatus(msg AS STRING) AS VOID
            SELF:lsbStatus:Items:Add(msg)
            SELF:lsbStatus:SelectedIndex := SELF:lsbStatus:Items:Count - 1
            LogHelper.LogInfo(msg)
        END METHOD

        /// <summary>
        /// Bin-Verzeichnis auswählen
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        PRIVATE METHOD btnChooseBinFolder_Click(sender AS OBJECT, e AS EventArgs) AS VOID STRICT
            VAR fbd := VistaFolderBrowserDialog{}
            fbd:SelectedPath := Path.GetDirectoryName(SELF:binPath)
            IF fbd:ShowDialog() == DialogResult.OK
                binPath := fbd:SelectedPath
                SELF:lblBinPath:Text := binPath
                EFHelper.ReadBinFolder(binPath, self:binAssemblies)
            END IF
            RETURN
        END METHOD

        /// <summary>
        /// Analyse starten
        /// Gutes Beispiel für einen nicht testbaren Eventhandler
        /// So hat man es früher gemacht;)
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /*
        PRIVATE METHOD bntStart_Click(sender AS OBJECT, e AS EventArgs) AS VOID STRICT
            LOCAL xDoc AS XDocument
            LOCAL refCounter AS INT
            LOCAL assVersion1 AS STRING
            LOCAL assVersion2 AS STRING
            BEGIN USING VAR st := Assembly.GetExecutingAssembly():GetManifestResourceStream("EFReferenceChecker." + projFile)
                xDoc := XDocument.Load(st)
            END USING
            VAR references := xDoc:Descendants(ns + "Reference")
            VAR checkList := List<AssemblyCheck>{}
            SELF:missingAssemblies := List<STRING>{}
            SELF:progressBar1:Value := 0
            SELF:progressBar1:Maximum := references:Count()
            UpdateStatus(i"*** Analysiere {Self:projFile}")
            FOREACH VAR reference IN references
                SELF:progressBar1:Value++
                System.Threading.Thread.Sleep(50)
                Application.DoEvents()
                IF reference:Element(ns + "AssemblyName") != NULL
                    VAR check := AssemblyCheck{}{Id := ++refCounter}
                    VAR include := reference:Attribute("Include"):Value
                    assVersion1 := Regex.Match(include, "Version=([\d.]+)"):Groups[1]:Value
                    VAR assemblyName := reference:Element(ns + "AssemblyName"):Value
                    check:Name := assemblyName
                    check:VersionNeeded := assVersion1
                    // Aktuelle Version abfragen
                    VAR dllFile := SELF:binAssemblies:Where({ fi => fi:Name == assemblyName}):FirstOrDefault()
                    IF dllFile != NULL
                        assVersion2 := FileVersionInfo.GetVersionInfo(dllFile:FullName):FileVersion:ToString()
                        check:VersionDetected := assVersion2
                        IF String.Compare(assVersion1, assVersion2) != 0
                            SELF:warningCount++
                        END IF
                        ELSE
                            // Ist die Datei im GAC?
                            VAR result := EFHelper.CheckGACForFile(assemblyName, assVersion2)
                            assemblyName += IIF(result, "(Im GAC)", "")
                            missingAssemblies:Add(assemblyName)
                        ENDIF
                    checkList:Add(check)
                END IF
            NEXT
            UpdateStatus(i"*** {refCounter} Assemblies in {SELF:projFile} gecheckt")
            UpdateStatus(i"*** Fehlende Dlls in {Self:binPath} = {Self:missingAssemblies:Count}")
            FOREACH VAR missingFile IN SELF:missingAssemblies
                UpdateStatus(i">>> {missingFile}")
            NEXT
            UpdateStatus(i"*** Warnungen = {warningCount}")
            SELF:progressBar1:Value := 0
            SELF:grdAssemblies:DataSource := checkList
            SELF:gridView1:Columns["Id"]:BestFit()
            SELF:gridView1:Columns["Name"]:Width := 240
            SELF:gridView1:RowStyle += RowStyleEventHandler{RowStyle}
            RETURN
        END METHOD
        */

        /// <summary>
        /// Analyse starten
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        PRIVATE METHOD bntStart_Click(sender AS OBJECT, e AS EventArgs) AS VOID STRICT
            LOCAL assVersion1 AS STRING
            LOCAL assVersion2 AS STRING
            LOCAL refCounter AS INT
            SELF:missingAssemblies := List<STRING>{}
            SELF:warningCount := 0
            VAR references := EFHelper.GetReferenceElements(SELF:projFile, SELF)
            VAR checkList := List<AssemblyCheck>{}
            // Alle reference-Elemente durchgehen
            FOREACH VAR reference IN references
                VAR check := AssemblyCheck{}{Id := ++refCounter}
                check:Name := reference:AssemblyName
                // Aktuelle Version abfragen
                VAR dllFile := SELF:binAssemblies:Where({ fi => fi:Name == reference:AssemblyName}):FirstOrDefault()
                // Liegt dll-Datei im bin-Verzeichnis?
                IF dllFile != NULL
                    // Location speichern
                    check:Location := "Bin"
                    // Versionsnummern speichern
                    assVersion1 := reference:Version
                    assVersion2 := FileVersionInfo.GetVersionInfo(dllFile:FullName):FileVersion:ToString()
                    check:VersionNeeded := assVersion1
                    check:VersionDetected := assVersion2
                    // Sind  beide Versionen ungleich?
                    IF String.Compare(assVersion1, assVersion2) != 0
                        SELF:warningCount++
                    END IF
                ELSE
                    VAR result := EFHelper.CheckRefAssembly(SELF:netVersion, SELF:x86, reference:AssemblyName, SELF)
                    IF result != ""
                        check:Location := "Ref"
                        check:VersionNeeded := reference:Version
                        check:VersionDetected := result
                    END IF
                    IF result == ""
                        result := EFHelper.CheckGACForFile(reference:AssemblyName, SELF)
                        IF result != ""
                            check:Location := "GAC"
                            check:VersionNeeded := reference:Version
                            check:VersionDetected := result
                        ELSE
                            check:Location := "Missing"
                            missingAssemblies:Add(check:Name)
                        END IF
                    END IF
                ENDIF
                checkList:Add(check)
            NEXT
            // ??? Warum checkList.Count und in der nächsten Zeile ist :Count erlaubt ???
            UpdateStatus(i"*** {checkList.Count} Assemblies in {SELF:projFile} gecheckt")
            UpdateStatus(i"*** Fehlende Dlls in {Self:binPath} = {Self:missingAssemblies:Count}")
            FOREACH VAR missingFile IN SELF:missingAssemblies
                UpdateStatus(i">>> {missingFile}")
            NEXT
            UpdateStatus(i"*** Warnungen = {warningCount}")
            SELF:progressBar1:Value := 0
            SELF:grdAssemblies:DataSource := checkList
            SELF:gridView1:Columns["Id"]:BestFit()
            SELF:gridView1:Columns["Name"]:Width := 240
            SELF:gridView1:RowStyle += RowStyleEventHandler{RowStyle}
            RETURN
        END METHOD

        /// <summary>
        /// Zellenformatierung anwenden
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        METHOD RowStyle(sender AS OBJECT, e AS RowStyleEventArgs) AS VOID
            VAR view := (GridView)sender
            IF e:RowHandle > 0
                VAR version1 := view:GetRowCellDisplayText(e:RowHandle, view:Columns["VersionNeeded"])
                VAR version2 := view:GetRowCellDisplayText(e:RowHandle, view:Columns["VersionDetected"])
                IF String.Compare(version1, version2) != 0
                    e:Appearance:BackColor := Color.FromName("Orange")
                END IF
                IF view:GetRowCellDisplayText(e:RowHandle, view:Columns["Location"]) == "Missing"
                    e:Appearance:BackColor := Color.FromName("Red")
                ENDIF
            END IF
    END CLASS

END NAMESPACE
