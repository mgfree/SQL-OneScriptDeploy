select 'script is' = '505_SRV1_i_AddressType', 'The time is :' = getdate(), 'on server' = @@servername
go

Use [AdventureWorks2014]
go

-- before change row counts
print 'Before image'
SELECT 'AddressType count' = count(*) FROM [Person].[AddressType]
SELECT * FROM [Person].[AddressType] where [name] in ('Postal')
GO

set XACT_ABORT ON
;
-- for testing,
-- comment out for production migration
begin tran
go

print 'Update Begin'
go

INSERT INTO [Person].[AddressType]
SELECT
	[Name] = 'Postal'
	,[rowguid] = NEWID()
	,[ModifiedDate] = getdate()
GO

print 'Update Done'
go

-- after change row counts
print 'After image'
SELECT 'AddressType count' = count(*) FROM [Person].[AddressType]
SELECT * FROM [Person].[AddressType] where [name] in ('Postal')
go

-- for testing,
-- comment out for production migration
rollback tran
--commit
go

select 'script is' = '505_SRV1_i_AddressType', 'The time is :' = getdate(), 'on server' = @@servername
go
