USE DW_Reporting
GO

GRANT VIEW DEFINITION TO SomeUser

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: <schema> TO <user>;