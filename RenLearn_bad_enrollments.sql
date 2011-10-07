create or replace view y_ops_rise_bad_ar as
select distinct student_number
      ,lastfirst
      ,class_name
      ,RL_status
      ,PS_status
      ,schoolid
      ,status
from
     (select rluser."vchPreviousIDNum" as student_number
            ,s.lastfirst
            ,s.enroll_status as PS_status
            ,s.schoolid
            ,rluser."tiRowStatus" as RL_status
            ,consolidated."vchClassName" as class_name
            ,case when s.schoolid != 73252 then 'in error'
                  when s.enroll_status != 0 then 'in error'
                  else 'ok' end as status
         --   ,enr."iClassID" as classid
            from "dbo"."rl_User"@RLRISE rluser
            join students@PS_TEAM s on to_char(s.student_number) = rluser."vchPreviousIDNum"
            join "dbo"."rp_CurrentEnrollment"@RLRISE enr on enr."iUserID" = rluser."iUserID"
            join "dbo"."rp_ConsolidatedClass"@RLRISE consolidated on enr."iClassID" = consolidated."iClassID" 
            )
where status = 'in error'
order by lastfirst;