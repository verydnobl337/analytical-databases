with user_group_log as (
    select
    	luga.hk_group_id,
    	COUNT(DISTINCT luga.hk_user_id) as cnt_added_users
    from VT26052617E774__DWH.s_auth_history sah
    join VT26052617E774__DWH.l_user_group_activity luga on sah.hk_l_user_group_activity = luga.hk_l_user_group_activity
    join VT26052617E774__DWH.h_groups hg on luga.hk_group_id = hg.hk_group_id
    where sah.event = 'add'
    	and luga.hk_group_id in(
    		select hk_group_id 
    		from VT26052617E774__DWH.h_groups
    		order by registration_dt
    		limit 10
    	)
    group by luga.hk_group_id 
)
select 
	hk_group_id,
    cnt_added_users
from user_group_log
order by cnt_added_users
limit 10;
