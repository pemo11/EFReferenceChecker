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
    PRIVATE binPath AS STRING
    PRIVATE projFile AS STRING
    PRIVATE binAssemblies AS List<FileInfo>
    PRIVATE missingAssemblies AS List<STRING>
    PRIVATE warningCount AS INT
    
    PRIVATE ns := XNamespace.Get("http://schemas.microsoft.com/developer/msbuild/2003") AS XNamespace
    
    /// <summary>
    /// Einlesen der Config-Datei-Einträge
    /// </summary>    
    PRIVATE METHOD ReadConfigData() AS VOID
        TRY
            SELF:binPath := ConfigurationManager.AppSettings["binPath"]
            SELF:projFile := ConfigurationManager.AppSettings["projFile"]
            SELF:lblBinPath:Text := SELF:binPath
            IF Directory.Exists(SELF:binPath)
                ReadBinFolder()
            ENDIF
            UpdateStatus("*** Daten aus Config-Datei eingelesen")
        CATCH ex AS SystemException
            UpdateStatus(i"!!! Fehler beim Einlesen der Config-Datei")
        END TRY
        
        /// <summary>
        ///  Konstruktor
        /// </summary>
        PUBLIC CONSTRUCTOR() STRICT
            InitializeComponent()
            ReadConfigData()
            Self:gridView1:OptionsView:ShowGroupPanel := False
            RETURN
        END CONSTRUCTOR
        
        /// <summary>
        ///  Dll-Dateien aus dem bin-Verzeichnis einlesen
        /// </summary>
        METHOD ReadBinFolder() AS VOID
            SELF:binAssemblies := List<FileInfo>{}
            FOREACH VAR dllFile IN DirectoryInfo{SELF:binPath}:GetFiles("*.dll")
                SELF:binAssemblies:Add(dllFile)
            NEXT
        END METHOD
        
        /// <summary>
        /// Statuslistbox aktualisieren
        /// </summary>
        /// <param name="msg"></param>
        METHOD UpdateStatus(msg AS STRING) AS VOID
            SELF:lsbStatus:Items:Add(msg)
            SELF:lsbStatus:SelectedIndex := SELF:lsbStatus:Items:Count - 1
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
                ReadBinFolder()
            END IF
            RETURN
        END METHOD
        
        /// <summary>
        /// Analyse starten
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        PRIVATE METHOD bntStart_Click(sender AS OBJECT, e AS EventArgs) AS VOID STRICT
            LOCAL xDoc AS XDocument
            LOCAL refCounter AS INT
            BEGIN USING VAR st := Assembly.GetExecutingAssembly():GetManifestResourceStream("EFReferenceChecker." + projFile)
                xDoc := XDocument.Load(st)
            END USING
            VAR references := xDoc:Descendants(ns + "Reference")
            VAR checkList := List<AssemblyCheck>{}
            SELF:missingAssemblies := List<STRING>{}
            SELF:progressBar1:Value := 0
            SELF:progressBar1:Maximum := references:Count()
            FOREACH VAR reference IN references
                SELF:progressBar1:Value++
                System.Threading.Thread.Sleep(50)
                Application.DoEvents()
                IF reference:Element(ns + "AssemblyName") != NULL
                    VAR check := AssemblyCheck{}{Id := ++refCounter}
                    VAR include := reference:Attribute("Include"):Value
                    VAR assVersion1 := Regex.Match(include, "Version=([\d.]+)"):Groups[1]:Value
                    VAR assemblyName := reference:Element(ns + "AssemblyName"):Value
                    check:Name := assemblyName
                    check:VersionNeeded := assVersion1
                    // Aktuelle Version abfragen
                    VAR dllFile := SELF:binAssemblies:Where({ fi => fi:Name == assemblyName}):FirstOrDefault()
                    IF dllFile != NULL
                        VAR assVersion2 := FileVersionInfo.GetVersionInfo(dllFile:FullName):FileVersion:ToString()
                        check:VersionDetected := assVersion2
                        IF String.Compare(assVersion1, assVersion2) != 0
                            SELF:warningCount++
                        END IF
                    ELSE
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
            END IF
    END CLASS

END NAMESPACE
