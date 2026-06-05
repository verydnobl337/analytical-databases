drop table if exists VT26052617E774__STAGING.group_log;

create table VT26052617E774__STAGING.group_log(
	group_id int,
	user_id int, 
	user_id_from int, 
	event varchar(20),
	datetime timestamp 
)