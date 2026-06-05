drop table if exists VT26052617E774__DWH.l_user_group_activity;

create table VT26052617E774__DWH.l_user_group_activity(
	hk_l_user_group_activity int not null,
	hk_user_id int not null CONSTRAINT fk_user_group_activity_user REFERENCES VT26052617E774__DWH.h_users (hk_user_id),
	hk_group_id int not null CONSTRAINT fk_user_group_activity_group REFERENCES VT26052617E774__DWH.h_groups (hk_group_id),
	load_dt datetime,
	load_src varchar(20)
)
order by load_dt
SEGMENTED BY hk_l_user_group_activity all nodes 
PARTITION BY load_dt::date
GROUP BY CALENDAR_HIERARCHY_DAY(load_dt::date, 3, 2);