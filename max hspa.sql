WITH prior_hspa_ela AS
   (SELECT yearid
          ,test_date
          ,sid
          ,'ELA' AS subject
          ,LAL_scale_score AS scale_score
          ,LAL_proficiency AS proficiency
    FROM KIPP_NJ..HSPA$scaled_scores_roster
    WHERE yearid = 22
      AND retest_flag IS NULL
    )
  ,prior_hspa_math AS
   (SELECT yearid
          ,test_date
          ,sid
          ,'Math' AS subject
          ,Math_scale_score AS scale_score
          ,Math_proficiency AS proficiency
    FROM KIPP_NJ..HSPA$scaled_scores_roster
    WHERE yearid = 22
      AND retest_flag IS NULL
   )
SELECT sid
      ,s.id AS studentid
      ,s.lastfirst
      ,test_date
      ,subject
      ,scale_score
      ,proficiency
      ,CASE 
         WHEN scale_score >= 200 THEN 1
         WHEN scale_score < 200 THEN 0
       END AS proficiency_dummy
FROM
      (SELECT sub.*
             ,ROW_NUMBER() OVER
               (PARTITION BY sid
                            ,subject
                ORDER BY scale_score DESC
               ) AS rn
       FROM
             (SELECT prior_hspa_ela.*
              FROM prior_hspa_ela
              UNION ALL
              SELECT h2014_ela.yearid
                    ,h2014_ela.test_date
                    ,h2014_ela.sid
                    ,'ELA' AS subject
                    ,h2014_ela.LAL_scale_score AS scale_score
                    ,h2014_ela.LAL_proficiency AS proficiency
              FROM KIPP_NJ..HSPA$scaled_scores_roster h2014_ela
              JOIN prior_hspa_ela
                ON h2014_ela.sid = prior_hspa_ela.sid
              WHERE h2014_ela.yearid = 23
                AND h2014_ela.LAL_scale_score IS NOT NULL

              UNION ALL
              SELECT prior_hspa_math.*
              FROM prior_hspa_math
              UNION ALL
              SELECT h2014_math.yearid
                    ,h2014_math.test_date
                    ,h2014_math.sid
                    ,'Math' AS subject
                    ,h2014_math.Math_scale_score AS scale_score
                    ,h2014_math.Math_proficiency AS proficiency
              FROM KIPP_NJ..HSPA$scaled_scores_roster h2014_math
              JOIN prior_hspa_math
                ON h2014_math.sid = prior_hspa_math.sid
              WHERE h2014_math.yearid = 23
                AND h2014_math.Math_scale_score IS NOT NULL
              ) sub
       ) sub
LEFT OUTER JOIN KIPP_NJ..STUDENTS s
  ON sub.sid = s.state_studentnumber
LEFT OUTER JOIN KIPP_NJ..CUSTOM_STUDENTS cust
  ON s.id = cust.studentid
WHERE rn = 1