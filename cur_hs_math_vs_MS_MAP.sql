SELECT level_2.*
      ,CASE
         WHEN stored_pct IS NOT NULL THEN stored_pct
         ELSE cur_pct
       END AS composite_pct
FROM
     (SELECT map.*
           ,grades.course_name
           ,grades.course_number
           ,grades.e1
           ,grades.y1 AS cur_pct
           ,CASE
              WHEN grades.y1 IS NOT NULL THEN 2100
              ELSE null
            END as cur_term
           ,sg.course_name AS stored_course
           ,sg.percent AS stored_pct
           ,sg.termid AS stored_term
           ,ROW_NUMBER() OVER
              (PARTITION BY map.ps_studentid
               ORDER BY sg.termid, grades.y1) AS RN_2
           ,map_reading.testritscore
      FROM
            (SELECT map.ps_studentid
                  ,students.lastfirst AS student
                  ,students.grade_level as current_gr
                  ,map.percentile_2008_norms
                  ,map.map_year_academic
                  ,map.testritscore as math_rit
                  ,CASE
                     WHEN map.testritscore >= 235 THEN 1
                     WHEN map.testritscore < 235 THEN 0
                     ELSE NULL
                   END as map_235_indicator
                  ,ROW_NUMBER() OVER 
                     (PARTITION BY map.ps_studentid
                        ORDER BY map_year_academic DESC)
                   AS rn
            FROM KIPP_NWK.map$comprehensive_identifiers map
            --demographics
            JOIN students 
              ON students.id = map.ps_studentid
            WHERE map.measurementscale = 'Mathematics'
              AND map.grade_level = 8
              AND map.fallwinterspring = 'Spring'
              AND map.rn = 1
            ORDER BY map.ps_studentid
            ) map
      LEFT OUTER JOIN grades$detail#nca grades
        ON map.ps_studentid = grades.studentid
        AND grades.course_name LIKE '%Algebra%'
        AND grades.grade_level = 9
      LEFT OUTER JOIN storedgrades@PS_TEAM sg
        ON sg.studentid = map.ps_studentid
        AND sg.storecode = 'Y1'
        AND sg.course_name IN ('Algebra','Algebra I','Honors Algebra')
        AND sg.grade_level = 9
      LEFT OUTER JOIN KIPP_NWK.map$comprehensive_identifiers map_reading
        ON map.ps_studentid = map_reading.ps_studentid
        AND map_reading.measurementscale = 'Reading'
        AND map_reading.grade_level = 8
        AND map_reading.fallwinterspring = 'Spring'
        AND map_reading.rn = 1
      --361
      WHERE map.rn = 1
      ) level_2
WHERE rn_2 = 1