:out D:\"SQL Scripts"\20160922_User1_demoScripting\SRV1\20160922\_010_SRV1_exec_SQLCMD.rpt
:on error exit
select getdate()

declare 
	@err_no int
	,@err_msg varchar(100)
	,@tgt_server varchar(100)
select 
	@err_no = 0
	,@err_msg = ''
	,@tgt_server = 'WIN-CK1GU04TCNH\SQL2K14BI'

IF @@servername <> @tgt_server
BEGIN
	select 
		@err_no = 1
		,@err_msg = replace('Please run the commands on server &server&','&server&',@tgt_server)
	raiserror( 'Error %d: %s', 16, 1, @err_no, @err_msg)
END
ELSE
BEGIN
	select 
		@err_no = 0
		,@err_msg = replace('Ready to execute commands on server &server&','&server&',@tgt_server)

	print @err_msg
END
:on error exit
go
 
:out D:\"SQL Scripts"\20160922_User1_demoScripting\SRV1\20160922\100_SRV1_p_uspUpdateEmployeeHireInfo.rpt
:r D:\"SQL Scripts"\20160922_User1_demoScripting\100_SRV1_p_uspUpdateEmployeeHireInfo.sql
:on error exit
GO
:out D:\"SQL Scripts"\20160922_User1_demoScripting\SRV1\20160922\505_SRV1_i_AddressType.rpt
:r D:\"SQL Scripts"\20160922_User1_demoScripting\505_SRV1_i_AddressType.sql
:on error exit
GO
