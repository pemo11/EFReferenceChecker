// File: MainForm.prg
USING System
USING System.Collections.Generic
USING System.Configuration
USING System.Data
USING System.Drawing
USING System.IO
USING System.Reflection
USING System.Text.RegularExpressions
USING System.Windows.Forms
USING System.Xml.Linq

USING Ookii.Dialogs.WinForms
USING DevExpress.Utils

BEGIN NAMESPACE EFReferenceChecker

PUBLIC PARTIAL CLASS MainForm INHERIT Form
    PRIVATE binPath AS STRING
    PRIVATE projFile AS STRING

    PRIVATE ns := XNamespace.Get("http://schemas.microsoft.com/developer/msbuild/2003") AS XNamespace


    PRIVATE METHOD ReadConfigData() AS VOID
        SELF:binPath := ConfigurationManager.AppSettings["binPath"]
        SELF:projFile := ConfigurationManager.AppSettings["projFile"]
        SELF:lblBinPath:Text := SELF:binPath

        PUBLIC CONSTRUCTOR() STRICT
            InitializeComponent()
            ReadConfigData()
            RETURN
        END CONSTRUCTOR

        PRIVATE METHOD btnChooseBinFolder_Click(sender AS OBJECT, e AS EventArgs) AS VOID STRICT
            VAR fbd := VistaFolderBrowserDialog{}
            fbd:SelectedPath := Path.GetDirectoryName(SELF:binPath)
            IF fbd:ShowDialog() == DialogResult.OK
                binPath := fbd:SelectedPath
                SELF:lblBinPath:Text := binPath
            END IF
            RETURN
        END METHOD

        PRIVATE METHOD bntStart_Click(sender AS OBJECT, e AS EventArgs) AS VOID STRICT
            LOCAL xDoc AS XDocument
            LOCAL refCounter AS INT
            BEGIN USING VAR st := Assembly.GetExecutingAssembly():GetManifestResourceStream("EFReferenceChecker." + projFile)
                xDoc := XDocument.Load(st)
            END USING
            VAR references := xDoc:Descendants(ns + "Reference")
            VAR checkList := List<AssemblyCheck>{}
            FOREACH VAR reference IN references
                IF reference:Element(ns + "AssemblyName") != NULL
                    VAR check := AssemblyCheck{}{Id := ++refCounter}
                    VAR include := reference:Attribute("Include"):Value
                    VAR version := Regex.Match(include, "Version=([\d.]+)"):Groups[1]:Value
                    check:Name := reference:Element(ns + "AssemblyName"):Value
                    check:VersionDetected := version
                    checkList:Add(check)
                END IF
            NEXT
            SELF:gridControl1:DataSource := checkList
            // SELF:gridView1:Columns["Id"]:Width := 80
            SELF:gridView1:Columns["Id"]:BestFit()
            SELF:gridView1:Columns["Name"]:Width := 240
            RETURN
        END METHOD
    END CLASS

END NAMESPACE
