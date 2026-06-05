with user_group_messages as (
	select 
		luga.hk_group_id,
		COUNT(DISTINCT luga.hk_user_id) AS cnt_users_in_group_with_messages
	from VT26052617E774__DWH.s_auth_history sah
	join VT26052617E774__DWH.l_user_group_activity luga on sah.hk_l_user_group_activity = luga.hk_l_user_group_activity
	where sah.event = 'create'
	group by luga.hk_group_id 
)
select 
	hk_group_id,
    cnt_users_in_group_with_messages
from user_group_messages
order by cnt_users_in_group_with_messages
limit 10;
