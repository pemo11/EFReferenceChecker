// File: Program.prg

USING System
USING System.Collections.Generic
USING System.Windows.Forms

USING EFReferenceChecker

[STAThread] ;
FUNCTION Start() AS VOID

    Application.EnableVisualStyles()
    Application.SetCompatibleTextRenderingDefault( FALSE )
    Application.Run( MainForm{} )

RETURN
