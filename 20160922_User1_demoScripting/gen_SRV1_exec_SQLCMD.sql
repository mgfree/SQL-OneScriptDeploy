/*
SQLCMD -S<Computer_name>\<instance_name> -U<user> -P<password> -e -s"," -i<input_file_path>\execSQLCMD.sql
*/
declare
	@p_src_file_dir nvarchar(1000)
	,@p_sub_folder nvarchar(100)
	,@p_targetServe nvarchar(100)

select
	@p_src_file_dir = 'D:\"SQL Scripts"\20160922_User1_demoScripting\'
	,@p_sub_folder = 'SRV1\20160922\'
	,@p_targetServe = 'WIN-CK1GU04TCNH\SQL2K14BI'

declare
	@tmpl_outLine varchar(1000)
	,@tmpl_rLine varchar(1000)
	,@tmpl_prolog varchar(1000)

select 
	@tmpl_outLine = ':out &filePath&&subFolder&&file&.rpt'
	,@tmpl_rLine = ':r &filePath&&file&.sql'
	,@tmpl_prolog = ':out &filePath&&subFolder&_010_SRV1_exec_SQLCMD.rpt
:on error exit
select getdate()

declare 
	@err_no int
	,@err_msg varchar(100)
	,@tgt_server varchar(100)
select 
	@err_no = 0
	,@err_msg = ''''
	,@tgt_server = ''&tgtServer&''

IF @@servername <> @tgt_server
BEGIN
	select 
		@err_no = 1
		,@err_msg = replace(''Please run the commands on server &server&'',''&server&'',@tgt_server)
	raiserror( ''Error %d: %s'', 16, 1, @err_no, @err_msg)
END
ELSE
BEGIN
	select 
		@err_no = 0
		,@err_msg = replace(''Ready to execute commands on server &server&'',''&server&'',@tgt_server)

	print @err_msg
END
:on error exit
go
'

set nocount on

declare	
	@tmpl_dir_cmd varchar(255)
	,@cmd_string varchar(255)
	,@file_full_name varchar(255)
	,@file_name varchar(255)
	,@sql varchar(1000)
	,@script_no int
	,@script_no_disp char(3)
	,@sproc_name nvarchar(1000)
	,@src_file_path nvarchar(1000)

-- Print Prolog
print replace(replace(replace(@tmpl_prolog,'&filePath&',@p_src_file_dir),'&subFolder&',@p_sub_folder),'&tgtServer&',@p_targetServe)
print replace(replace(replace(replace(@tmpl_prolog,'&filePath&',@p_src_file_dir),'&file&',@file_name),'&subFolder&',@p_sub_folder),'&tgtServer&',@p_targetServe)

if object_id( 'tempdb.dbo.#tmp_Src_File_List' ) is not null
	drop table #tmp_Src_File_List

-- create temp tables
create table #tmp_Src_File_List (
	[file_name]	varchar(255)
)

SELECT 
	@tmpl_dir_cmd = 'dir /A:-D /B &src_backup_dir&*.sql'
	,@cmd_string = replace(@tmpl_dir_cmd, '&src_backup_dir&', @p_src_file_dir)
	,@script_no = 100

INSERT INTO #tmp_Src_File_List
exec master..xp_cmdshell @cmd_string

-- select * from #tmp_Src_File_List
DECLARE csr_files CURSOR FOR
select s.file_name
from #tmp_Src_File_List s (nolock)
where s.file_name like '[0-9]%'
and s.file_name not like '%suo%'
order by s.file_name

open csr_files
fetch csr_files into @file_full_name
while @@fetch_status = 0
begin
	select @file_name = replace(@file_full_name,'.sql','')
--	print @file_full_name
--	print @file_name
	print replace(replace(replace(@tmpl_outLine,'&filePath&',@p_src_file_dir),'&file&',@file_name),'&subFolder&',@p_sub_folder)
	print replace(replace(@tmpl_rLine,'&filePath&',@p_src_file_dir),'&file&',@file_name)
	print ':on error exit'
	print 'GO'
	fetch csr_files into @file_full_name
end

-- clean up
close csr_files
deallocate csr_files


set nocount off
go
