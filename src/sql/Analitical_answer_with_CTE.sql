with user_group_messages as (
	select 
		luga.hk_group_id,
		COUNT(DISTINCT luga.hk_user_id) AS cnt_users_in_group_with_messages
	from VT26052617E774__DWH.s_auth_history sah
	join VT26052617E774__DWH.l_user_group_activity luga on sah.hk_l_user_group_activity = luga.hk_l_user_group_activity
	where sah.event = 'create'
	group by luga.hk_group_id 
),
user_group_log as (
    select
    	luga.hk_group_id,
    	COUNT(DISTINCT luga.hk_user_id) as cnt_added_users
    from VT26052617E774__DWH.s_auth_history sah
    join VT26052617E774__DWH.l_user_group_activity luga on sah.hk_l_user_group_activity = luga.hk_l_user_group_activity
    where sah.event = 'add'
    group by luga.hk_group_id 
)
select
    ugl.hk_group_id,
    ugl.cnt_added_users,
    COALESCE(ugm.cnt_users_in_group_with_messages, 0) AS cnt_users_in_group_with_messages,
    COALESCE(ugm.cnt_users_in_group_with_messages, 0)
        / NULLIF(ugl.cnt_added_users, 0) AS group_conversion
from user_group_log ugl
join VT26052617E774__DWH.h_groups hg on ugl.hk_group_id = hg.hk_group_id
left join user_group_messages ugm on ugl.hk_group_id = ugm.hk_group_id
order by group_conversion DESC
limit 10;
