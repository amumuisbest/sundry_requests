
SELECT attr_test
      ,grade_level
      ,COUNT(*) AS N
      ,LISTAGG(detail_string, ' | ')
         WITHIN GROUP
        (ORDER BY grade_level
                 ,lastfirst) AS elements
FROM
      (SELECT base.*
            ,cur.schoolid || ' grade ' || cur.grade_level AS cur_status
            ,CASE
               WHEN base.grad_test IS NULL AND cur.schoolid IS NULL THEN 'Leaver'
               ELSE 'Stayer'
             END AS attr_test
            ,CASE
               WHEN base.grad_test IS NULL AND cur.schoolid IS NULL THEN stu_string
               ELSE NULL
             END AS detail_string
      FROM
           (SELECT studentid
                  ,lastfirst
                  ,grade_level
                  ,lastfirst || ': ' || grade_level || '(' || exitcode || ' on ' || TO_CHAR(exitdate, 'MM/DD') || ')' AS stu_string
                  ,CASE
                     WHEN grade_level = 8 AND exitcode = 'G1' THEN 'Grad'
                     ELSE NULL
                   END AS grad_test
            FROM cohort$comprehensive_long cohort
            WHERE schoolid = 73252
              AND year = 2011
              AND exitdate > '15-OCT-11'
              AND rn = 1
            ) base
      LEFT OUTER JOIN cohort$comprehensive_long cur
        ON base.studentid = cur.studentid
        AND cur.year = 2012
        AND cur.rn = 1
        AND cur.schoolid != 999999
      ) return_test 
GROUP BY attr_test
        ,CUBE(grade_level)