SELECT decode(grouping(level_1.abbrev),0,level_1.abbrev,'total') yr_abbrev
      ,count(*) as N
      ,ROUND((AVG(level_1.graduate_flag)*100),0) pct_thru_8th
FROM
      (SELECT basis.studentid
            ,basis.lastfirst
            ,basis.grade_level as base_gr
            ,basis.abbreviation as abbrev
            ,basis.year
            ,eighth_outcome.grade_level as eighth_gr
            ,basis.cohort as start_cohort
            ,basis.highest_achieved as base_high_ach
            ,eighth_outcome.exitcode
            ,CASE
              --edge case: 8th grade transfers
               WHEN basis.highest_achieved = 8 AND eighth_outcome.exitcode LIKE 'T%' THEN 0
              --another edge case: retained students that are continuing to make progress
               WHEN students.enroll_status = 0 AND students.grade_level <= 8 THEN 1
              --8th grade graduate or better 
               WHEN basis.highest_achieved >= 8 THEN 1
               ELSE 0
             END as graduate_flag
      FROM cohort_table_long basis
      LEFT OUTER JOIN cohort_table_long eighth_outcome
        ON basis.studentid = eighth_outcome.studentid
       AND eighth_outcome.grade_level = 8
      LEFT OUTER JOIN students@PS_TEAM
        ON basis.studentid = students.id
      WHERE basis.grade_level = 5
        AND basis.year <= 2008
      ORDER BY start_cohort
              ,lastfirst
      ) level_1
GROUP BY ROLLUP(level_1.abbrev)
ORDER BY level_1.abbrev
;

--verbose version of above query: listagg students to see WHO transferred
SELECT decode(grouping(level_1.abbrev),0,level_1.abbrev,'total') yr_abbrev
      ,count(*) as N
      ,ROUND((AVG(level_1.graduate_flag)*100),0) pct_thru_8th
      ,listagg(level_1.transfers, ' | ') within group (order by level_1.transfers) as transfers
FROM
      (SELECT basis.studentid
            ,basis.lastfirst
            ,basis.grade_level as base_gr
            ,basis.abbreviation as abbrev
            ,basis.year
            ,eighth_outcome.grade_level as eighth_gr
            ,basis.cohort as start_cohort
            ,basis.highest_achieved as base_high_ach
            ,eighth_outcome.exitcode
            ,CASE
              --edge case: 8th grade transfers
               WHEN basis.highest_achieved = 8 AND eighth_outcome.exitcode LIKE 'T%' THEN 0
              --another edge case: retained students that are continuing to make progress
               WHEN students.enroll_status = 0 AND students.grade_level <= 8 THEN 1
              --8th grade graduate or better 
               WHEN basis.highest_achieved >= 8 THEN 1
               ELSE 0
             END as graduate_flag
            ,CASE
               WHEN basis.highest_achieved = 8 AND eighth_outcome.exitcode LIKE 'T%' THEN basis.lastfirst
               WHEN students.enroll_status = 0 AND students.grade_level <= 8 THEN null
               WHEN basis.highest_achieved < 8 THEN basis.lastfirst
               ELSE null
             END as transfers
      FROM cohort_table_long basis
      LEFT OUTER JOIN cohort_table_long eighth_outcome
        ON basis.studentid = eighth_outcome.studentid
       AND eighth_outcome.grade_level = 8
      LEFT OUTER JOIN students@PS_TEAM
        ON basis.studentid = students.id
      WHERE basis.grade_level = 5
        AND basis.year <= 2008
      ORDER BY start_cohort
              ,lastfirst
      ) level_1
GROUP BY level_1.abbrev
ORDER BY level_1.abbrev