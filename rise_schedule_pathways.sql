select pathways
      ,count(student) as count 
      ,LTRIM(MAX(SYS_CONNECT_BY_PATH(student,' | ')) KEEP (DENSE_RANK LAST ORDER BY curr2),',') AS students      
from
      (select student
            ,pathways
            ,ROW_NUMBER() OVER (PARTITION BY pathways order by student) AS curr2
            ,ROW_NUMBER() OVER (PARTITION BY pathways order by student) -1 AS prev2
      from
            (SELECT student
                   ,grade_level
                   ,LTRIM(MAX(SYS_CONNECT_BY_PATH(hash,', ')) KEEP (DENSE_RANK LAST ORDER BY curr),',') AS pathways
            from       
                  (select student
                        ,course_number
                        ,grade_level
                        ,period
                        ,class || '|' || period as hash
                        ,ROW_NUMBER() OVER (PARTITION BY student ORDER BY period) AS curr
                        ,ROW_NUMBER() OVER (PARTITION BY student ORDER BY period) -1 AS prev
                  from
                        (select sched_cc.buildid
                              ,s.lastfirst as student
                              ,s.grade_level + 1 as grade_level
                              ,sched_cc.course_number
                              ,replace(replace(replace(replace(c.course_name,' '),'Free'),'High','Hi'),'Read','Rd') as class
                              ,substr(sched_cc.expression, 1, 1) as period
                        from schedulecc sched_cc
                        left outer join students s on sched_cc.studentid = s.id
                        left outer join courses c on sched_cc.course_number = c.course_number
                        where sched_cc.buildid = 55
                        order by student, period
                        )
                  )
            GROUP BY student, grade_level
            CONNECT BY prev = PRIOR curr AND student = PRIOR student
            START WITH curr = 1
            )
      order by pathways
              ,student
      )
GROUP BY pathways
CONNECT BY prev2 = PRIOR curr2 AND pathways = PRIOR pathways
START WITH curr2 = 1;



select pathway
      ,sum(dummy_count)
      ,wm_concat(student) as students
from
     (select student
            ,grade_level
            ,LISTAGG(class_hash, '|') WITHIN GROUP (ORDER BY grade_level) AS pathway
            ,case when grade_level > 0 then 1 else null end as dummy_count
            
      from
           (select student
                  ,course_number
                  ,grade_level
                  ,period
                  ,class || '|' || period AS class_hash
            from
                 (select sched_cc.buildid
                        ,s.lastfirst as student
                        ,s.grade_level + 1 as grade_level
                        ,sched_cc.course_number
                        ,replace(replace(replace(replace(c.course_name,' '),'Free'),'High','Hi'),'Read','Rd') as class
                        ,substr(sched_cc.expression, 1, 1) as period
                  from schedulecc sched_cc
                  left outer join students s on sched_cc.studentid = s.id
                  left outer join courses c on sched_cc.course_number = c.course_number
                  where sched_cc.buildid = 55
                  )
            )
      group by student
              ,grade_level
              ,period
      )
--where pathway like '%Math8Hi%'
group by pathway
order by pathway