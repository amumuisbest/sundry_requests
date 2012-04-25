SELECT decode(GROUPING(level_03.grade_level),0,level_03.grade_level,'total') AS grade
       --decode(GROUPING(level_03.school),0,level_03.school,'total') AS school
      ,decode(GROUPING(level_03.year),0,CAST(level_03.year AS VARCHAR2(4)),'total') AS year
      ,round((1 - AVG(level_03.attr_test)) * 100,1) AS attrition
      ,listagg(level_03.audit_string, '|') within group (order by level_03.lastfirst) AS audit_trail
FROM
     (SELECT level_02.studentid
            ,level_02.lastfirst
            ,level_02.grade_level
            ,level_02.school
            ,level_02.year
            ,level_02.cohort
            ,CASE
                WHEN level_02.next_yr_gr IS NULL AND level_02.exitcode LIKE '%G%' THEN 1
                WHEN level_02.next_yr_gr IS NOT NULL THEN 1
                ELSE 0
             END AS attr_test
            ,CASE
               WHEN level_02.next_yr_gr IS NULL AND level_02.exitcode LIKE '%G%' THEN null
               WHEN level_02.next_yr_gr IS NOT NULL THEN null
               ELSE level_02.short_name
             END AS audit_string
      FROM
           --if LEAD matches student id, return next year grade
           (SELECT level_01.studentid
                  ,level_01.lastfirst
                  ,level_01.short_name
                  ,level_01.grade_level
                  ,level_01.abbreviation as school
                  ,level_01.year
                  ,level_01.cohort
                  ,level_01.exitcode
                  ,CASE
                     WHEN level_01.next_row_stu = level_01.studentid THEN level_01.next_row_gr
                     ELSE null
                   END as next_yr_gr
            FROM
                  (SELECT cohort.studentid
                        ,cohort.lastfirst
                        ,cohort.grade_level
                        ,schools.abbreviation
                        ,SUBSTR(students.first_name, 1, 1) || '. ' || students.last_name as short_name
                        ,cohort.year
                        ,cohort.cohort
                        ,cohort.exitcode
                        ,LEAD(cohort.studentid, 1) OVER (ORDER BY cohort.studentid, year asc)   as next_row_stu
                        ,LEAD(cohort.grade_level, 1) OVER (ORDER BY cohort.studentid, year asc) as next_row_gr
                        ,LEAD(cohort.schoolid, 1)    OVER (ORDER BY cohort.studentid, year asc) as next_row_sch
                        --,row_number() OVER (PARTITION BY studentid
                        --                    order by year asc) as rn
                  FROM cohort_table_long cohort
                  JOIN schools@PS_TEAM on cohort.schoolid = schools.school_number
                  JOIN students@PS_TEAM on cohort.studentid = students.id
                  --exclude graduated students entries
                  WHERE cohort.grade_level != 99
                  ) level_01
              --after LEAD for 2011 is done (to see who came back from 2010), exclude it.  
              --we don't know who will return in 2012 (yet!)
              WHERE level_01.year < 2011
            ) level_02
      ) level_03
GROUP BY level_03.grade_level
         --level_03.school
        ,level_03.year
--GROUP BY CUBE(level_03.school
--             ,level_03.year)
ORDER BY level_03.grade_level 
        --level_03.school
        ,level_03.year