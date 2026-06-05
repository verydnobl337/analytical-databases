INSERT INTO VT26052617E774__DWH.l_user_group_activity(
	hk_l_user_group_activity, 
	hk_user_id,
	hk_group_id,
	load_dt,
	load_src
)
select distinct
	hash(u.hk_user_id, g.hk_group_id) as hk_l_user_group_activity,
	u.hk_user_id as hk_user_id,
	g.hk_group_id as hk_group_id,
	now() as load_dt,
	's3' as load_src
from VT26052617E774__STAGING.group_log as gl
left join VT26052617E774__DWH.h_users u on gl.user_id = u.user_id 
left join VT26052617E774__DWH.h_groups g on gl.group_id = g.group_id;
