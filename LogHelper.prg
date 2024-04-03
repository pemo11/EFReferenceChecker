// File: LogHelper.prg

USING System
USING NLog

BEGIN NAMESPACE EFReferenceChecker

	/// <summary>
    /// The LogHelper class
    /// </summary>
	INTERNAL STATIC CLASS LogHelper
        STATIC PRIVATE logMan AS Logger
    
        STATIC CONSTRUCTOR()
            logMan := LogManager.GetCurrentClassLogger()
            RETURN
 
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Message"></param> 
        STATIC METHOD LogInfo(Message AS STRING) AS VOID
            logMan:Info(Message)
            RETURN
            
        /// <summary>
        /// hier Beschreibung eingeben 
        /// </summary>
        /// <param name="Message"></param> 
        /// <param name="Error"></param> 
        STATIC METHOD LogError(Message AS STRING, Error AS Exception) AS VOID
            logMan:Error(Error, Message)
            RETURN


    END CLASS
    
END NAMESPACE // EFReferenceChecker