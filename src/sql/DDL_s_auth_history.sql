drop table if exists VT26052617E774__DWH.s_auth_history;

create table VT26052617E774__DWH.s_auth_history(
	hk_l_user_group_activity int,
	user_id_from int,
	event varchar(20),
	event_dt datetime,
	load_dt datetime,
	load_src varchar(20)
)
order by load_dt
SEGMENTED BY hk_l_user_group_activity all nodes 
PARTITION BY load_dt::date 
GROUP BY CALENDAR_HIERARCHY_DAY(load_dt::date, 3, 2);