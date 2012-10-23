/*
--Hayden Foundation Questionnaire
--Hayden Foundation Questionnaire
--Hayden Foundation Questionnaire



--last updated 2012-10-23 LD6

*/

--SUSPENSIONS
--(powerschool)
--what is the total # of suspensions last year and currently across network?
--what is the total count of students suspended?

--use this for student roster detail
--req. maintenance: change year parameters
select  s.schoolid
       ,s.student_number
       ,s.lastfirst
       ,s.grade_level
       ,sum(case
              when psad.att_code = 'OS'
              then 1
              when psad.att_code = 'S'
              then 1
              else 0
              end) as Suspensions
       From PS.STUDENTS s
left outer join ps_attendance_daily psad on s.id=psad.studentid
where s.enroll_status = 0 
  --and s.schoolid = 73254 
    and psad.att_date > '01-AUG-12' and psad.att_date < '01-JUL-13'
group by s.schoolid, s.student_number, s.lastfirst, s.grade_level
order by s.schoolid, s.grade_level, s.lastfirst

;


--SUSPENSIONS
--count total students
--run sub query to see full cubed report
--req. maintenance: change year parameters
select count(student_number) as count
from
    (select schoolid
            ,student_number
            ,Suspensions_Total
            ,Sus_Out_of_School
            ,Sus_In_School
      from
            (select  s.schoolid
                    ,s.student_number
                    ,case when s.schoolid = 133570965 then 'TEAM'
                          when s.schoolid = 73252 then 'Rise'
                          when s.schoolid = 73253 then 'NCA'
                          when s.schoolid = 73254 then 'SPARK'
                          when s.schoolid = 73255 then 'THRIVE'
                          else null end School
                   ,sum(case
                          when psad.att_code = 'OS'
                          then 1
                          when psad.att_code = 'S'
                          then 1
                          else 0
                          end) as Suspensions_Total
                   ,sum(case
                          when psad.att_code = 'OS'
                          then 1
                          else 0
                          end) as Sus_Out_of_School
                   ,sum(case
                          when psad.att_code = 'S'
                          then 1
                          else 0
                          end) as Sus_In_School
                   From PS.STUDENTS s
            left outer join ps_attendance_daily psad on s.id=psad.studentid
            where psad.att_date > '01-AUG-12' and psad.att_date < '01-JUL-13'
            group by s.schoolid, s.student_number, s.schoolid
      )
      where suspensions_total >= 1
)


;

--COHORT COUNTS
--(KIPP_NWK)
--what was the starting count of students in cohort XX?
--and what was the end count of students in cohort XX graduating NCA?
--req. maintenance: two union all statements need 'cohort' and 'year' changed to match request

select count(lastfirst) as count
            ,'count of 2012 cohort first year enrollment september 2004' as detail
from
      (select *
       from
            (select cohort.studentid
                  ,cohort.lastfirst
                  ,cohort.year
                  ,cohort.cohort
                  ,cohort.grade_level
                  ,cohort.highest_achieved
                  ,case when cohort.schoolid = 999999 
                        then null 
                        else row_number() over (partition by cohort.studentid
                                                order by cohort.year asc) end as rn_cycle
            from cohort$comprehensive_long cohort
            where cohort = 2012
                  and year = 2004 --first year of 2012 cohort
            )
      where rn_cycle = 1
      )
      
UNION ALL

select count(lastfirst) as count
      ,'count of 2012 cohort graduating NCA june 2012' as detail
from
           (select cohort.studentid
                  ,cohort.lastfirst
                  ,cohort.year
                  ,cohort.cohort
                  ,cohort.grade_level
                  ,cohort.highest_achieved
                  ,case when cohort.schoolid = 999999 
                        then null 
                        else row_number() over (partition by cohort.studentid
                                                order by cohort.year asc) end as rn_cycle
            from cohort$comprehensive_long cohort
            where cohort =  2012
              and year   =  2011
              and highest_achieved = 99
      )
;