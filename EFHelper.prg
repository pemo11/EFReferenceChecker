// File: EFHelper.prg


USING System
USING System.Collections.Generic
USING System.Configuration
USING System.IO

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
        INTERNAL STATIC METHOD ReadConfigData(Frm AS MainForm) AS VOID
            TRY
                Frm:binPath := ConfigurationManager.AppSettings["binPath"]
                Frm:projFile := ConfigurationManager.AppSettings["projFile"]
                Frm:lblBinPath:Text :=Frm:binPath
                IF Directory.Exists(Frm:binPath)
                    EFHelper.ReadBinFolder(Frm:binPath, Frm:binAssemblies)
                ENDIF
                Frm:UpdateStatus("*** Daten aus Config-Datei eingelesen")
            CATCH ex AS SystemException
                Frm:UpdateStatus(i"!!! Fehler beim Einlesen der Config-Datei")
            END TRY
        END METHOD
        
        
        /// <summary>
        /// Prüfen, ob sich eine Dll im GAC befindet
        /// </summary>    
        INTERNAL STATIC METHOD CheckGACForFile(AssemblyName AS STRING, AssemblyVersion AS STRING) AS LOGIC
                VAR gacPath := "C:\Windows\assembly\GAC_MSIL"
                VAR dllDirpath := Path.Combine(gacPath, Path.GetFileNameWithoutExtension(AssemblyName))
                IF Directory.Exists(dllDirpath)
                    VAR dllDirname := DirectoryInfo{dllDirpath}:GetDirectories()[1].Name
                    RETURN dllDirname:Split(c"_")[1] == AssemblyVersion
                ELSE
                    RETURN FALSE
                END IF
            END METHOD
        

    END CLASS

END NAMESPACE // EFReferenceChecker