SELECT AVG(level_01.returned_08)
FROM
      (SELECT cohort_07.*
            ,CASE
               WHEN cohort_08.grade_level IS NOT NULL THEN 1
               ELSE 0
             END as returned_08
      FROM cohort_table_long cohort_07
      LEFT OUTER JOIN cohort_table_long cohort_08
        ON cohort_07.studentid = cohort_08.studentid
       AND cohort_08.year = 2008
      WHERE cohort_07.schoolid = 73253
        AND cohort_07.year = 2007
      ) level_01
;
SELECT AVG(level_01.returned_09)
FROM
      (SELECT cohort_08.*
            ,CASE
               WHEN cohort_09.grade_level IS NOT NULL THEN 1
               ELSE 0
             END as returned_09
      FROM cohort_table_long cohort_08
      LEFT OUTER JOIN cohort_table_long cohort_09
        ON cohort_08.studentid = cohort_09.studentid
       AND cohort_09.year = 2009
      WHERE cohort_08.schoolid = 73253
        AND cohort_08.year = 2008
      ) level_01
;
SELECT AVG(level_01.returned_10)
FROM
      (SELECT cohort_09.*
            ,CASE
               WHEN cohort_10.grade_level IS NOT NULL THEN 1
               ELSE 0
             END as returned_10
      FROM cohort_table_long cohort_09
      LEFT OUTER JOIN cohort_table_long cohort_10
        ON cohort_09.studentid = cohort_10.studentid
       AND cohort_10.year = 2010
      WHERE cohort_09.schoolid = 73253
        AND cohort_09.year = 2009
      ) level_01

;
SELECT AVG(level_01.returned_11)
FROM
      (SELECT cohort_10.*
            ,CASE
               WHEN cohort_11.grade_level IS NOT NULL THEN 1
               ELSE 0
             END as returned_11
      FROM cohort_table_long cohort_10
      LEFT OUTER JOIN cohort_table_long cohort_11
        ON cohort_10.studentid = cohort_11.studentid
       AND cohort_11.year = 2011
      WHERE cohort_10.schoolid = 73253
        AND cohort_10.year = 2010
      ) level_01

;

SELECT AVG(level_01.returned_12)
FROM
      (SELECT cohort_11.*
            ,CASE
               WHEN cohort_11.exitcode = 'G1' THEN 1
               WHEN cohort_12.grade_level IS NOT NULL THEN 1
               ELSE 0
             END as returned_12
      FROM cohort_table_long cohort_11
      LEFT OUTER JOIN cohort_table_long cohort_12
        ON cohort_11.studentid = cohort_12.studentid
       AND cohort_12.year = 2011
      WHERE cohort_11.schoolid = 73253
        AND cohort_11.year = 2010
      ) level_01      
;
