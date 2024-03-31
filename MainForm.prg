USING System
USING System.Collections.Generic
USING System.Configuration
USING System.Data
USING System.Drawing

USING System.Text

USING System.Windows.Forms

BEGIN NAMESPACE EFReferenceChecker

PUBLIC PARTIAL CLASS MainForm INHERIT Form
    PRIVATE binPath AS STRING
    
    PRIVATE METHOD ReadConfigData() AS VOID
        SELF:binPath := ConfigurationManager.AppSettings["binPath"]  
        SELF:lblBinPath:Text := SELF:binPath
        
        PUBLIC CONSTRUCTOR() STRICT
            InitializeComponent()
            ReadConfigData()
            return
        end constructor
        PRIVATE METHOD btnChooseBinFolder_Click(sender AS System.Object, e AS System.EventArgs) AS VOID STRICT
            RETURN
        END METHOD
    END CLASS 
END NAMESPACE
