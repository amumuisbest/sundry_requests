--cube and drop audit detail
SELECT decode(GROUPING(school),0,to_char(school),'network') AS school
      ,decode(GROUPING(year),0,to_char(year),'all years') AS year
      ,ROUND(AVG(reenroll_dummy)*100,0) AS reenroll_pct
      ,100 - ROUND(AVG(reenroll_dummy)*100,0) AS attr_pct
      ,COUNT(*) AS N
      --,listagg(attr_detail, ', ') WITHIN GROUP 
      --   (ORDER BY lastfirst) AS audit_detail
FROM
      (SELECT reenroll.*
            ,CASE
               WHEN reenroll.reenroll_dummy = 0 THEN short_name
               ELSE null
             END AS attr_detail
      FROM 
           (SELECT base.studentid
                  ,base.lastfirst
                  ,SUBSTR(students.first_name,1,1) || ' ' || students.last_name AS short_name
                  ,base.grade_level
                  ,base.year
                  ,schools.abbreviation AS school
                  ,to_char(base.exitdate,'MON') AS exit_month
                  ,CASE
                     WHEN base.exitcode = 'G1' 
                       OR (base.grade_level = 8 AND to_char(base.exitdate,'MON') = 'JUN') THEN 1
                     WHEN next.year IS NOT NULL THEN 1
                     ELSE 0
                   END AS reenroll_dummy
                  ,next.grade_level AS grade_plus_1
                  ,next.year AS year_plus_1
            FROM cohort$comprehensive_long base
            JOIN students ON base.studentid = students.id
            JOIN schools@PS_TEAM on base.schoolid = schools.school_number
            --left outer keeps all base records even if no matching next year record is found
            LEFT OUTER JOIN cohort$comprehensive_long next
             --same studentd 
              ON base.studentid = next.studentid
             --next academic year
             AND next.year = base.year + 1
             --evaluate canonical record from next year result set
             AND next.rn = 1
            --canonical record from base and don't include graduated students
            WHERE base.rn = 1 AND base.schoolid != 999999 AND base.year < 2012
            ) reenroll
      ) audit_detail
GROUP BY CUBE(school
             ,year
             )
ORDER BY decode(school, 'network', 10
                        ,'TEAM'   , 20
                        ,'Rise'   , 30
                        ,'NCA'    , 40
                        ,'SPARK'  , 50
                        ,'THRIVE' , 60
               )
        ,year DESC
        
;
--no cube, keep audit detail
SELECT school
      ,year
      ,ROUND(AVG(reenroll_dummy)*100,0) AS reenroll_pct
      ,100 - ROUND(AVG(reenroll_dummy)*100,0) AS attr_pct
      ,COUNT(*) AS N
      ,listagg(attr_detail, ', ') WITHIN GROUP 
         (ORDER BY lastfirst) AS audit_detail
FROM
      (SELECT reenroll.*
            ,CASE
               WHEN reenroll.reenroll_dummy = 0 THEN short_name
               ELSE null
             END AS attr_detail
      FROM 
           (SELECT base.studentid
                  ,base.lastfirst
                  ,SUBSTR(students.first_name,1,1) || ' ' || students.last_name AS short_name
                  ,base.grade_level
                  ,base.year
                  ,schools.abbreviation AS school
                  ,to_char(base.exitdate,'MON') AS exit_month
                  ,CASE
                     WHEN base.exitcode = 'G1' 
                       OR (base.grade_level = 8 AND to_char(base.exitdate,'MON') = 'JUN') THEN 1
                     WHEN next.year IS NOT NULL THEN 1
                     ELSE 0
                   END AS reenroll_dummy
                  ,next.grade_level AS grade_plus_1
                  ,next.year AS year_plus_1
            FROM cohort$comprehensive_long base
            JOIN students ON base.studentid = students.id
            JOIN schools@PS_TEAM on base.schoolid = schools.school_number
            --left outer keeps all base records even if no matching next year record is found
            LEFT OUTER JOIN cohort$comprehensive_long next
             --same studentd 
              ON base.studentid = next.studentid
             --next academic year
             AND next.year = base.year + 1
             --evaluate canonical record from next year result set
             AND next.rn = 1
            --canonical record from base and don't include graduated students
            WHERE base.rn = 1 AND base.schoolid != 999999 AND base.year < 2012
            ) reenroll
      ) audit_detail
GROUP BY school
        ,year
ORDER BY school
        ,year DESC