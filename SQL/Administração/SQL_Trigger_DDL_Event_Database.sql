USE MASTER
GO

CREATE DATABASE DDL_TRIGGERS_DB
GO

USE DDL_TRIGGERS_DB
GO

CREATE TABLE [dbo].[DDL_Event_Log](
[ID] [int] IDENTITY(1,1) NOT NULL,
[EventTime] [datetime] NULL,
[EventType] [varchar](15) NULL,
[ServerName] [varchar](25) NULL,
[DatabaseName] [varchar](25) NULL,
[ObjectType] [varchar](25) NULL,
[ObjectName] [varchar](25) NULL,
[UserName] [varchar](15) NULL,
[CommandText] [varchar](max) NULL)

GO


USE MIDB01P
GO


CREATE TRIGGER [DDL_TRG_LOG] 
ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS 

AS

SET NOCOUNT ON 

DECLARE @xmlEventData XML 


-- Capture the event data that is created 

SET @xmlEventData = eventdata() 


-- Insert information to a EventLog table

INSERT INTO DDL_TRIGGERS_DB.dbo.DDL_Event_Log
(
EventTime,
EventType,
ServerName,
DatabaseName,
ObjectType,
ObjectName,
UserName,
CommandText
)
SELECT REPLACE(CONVERT(VARCHAR(50), @xmlEventData.query('data(/EVENT_INSTANCE/PostTime)')),
'T', ' '),
CONVERT(VARCHAR(15), @xmlEventData.query('data(/EVENT_INSTANCE/EventType)')),
CONVERT(VARCHAR(25), @xmlEventData.query('data(/EVENT_INSTANCE/ServerName)')),
CONVERT(VARCHAR(25), @xmlEventData.query('data(/EVENT_INSTANCE/DatabaseName)')),
CONVERT(VARCHAR(25), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectType)')),
CONVERT(VARCHAR(25), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectName)')),
CONVERT(VARCHAR(15), @xmlEventData.query('data(/EVENT_INSTANCE/UserName)')),
CONVERT(VARCHAR(MAX), @xmlEventData.query('data(/EVENT_INSTANCE/TSQLCommand/CommandText)')) 

GO

-- SELECT * FROM DDL_TRIGGERS_DB.dbo.DDL_Event_Log

-- DELETE DDL_TRIGGERS_DB.dbo.DDL_Event_Log

-- DROP TRIGGER DDL_TRG_LOG 