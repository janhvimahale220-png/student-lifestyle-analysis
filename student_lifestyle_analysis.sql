-- Q1. Average mock score by class (11th vs 12th)
SELECT
    class,
    ROUND(AVG(mock_score_mid)::numeric, 1) AS avg_mock_score,
    COUNT(*) AS student_count
FROM student_lifestyle
GROUP BY class
ORDER BY avg_mock_score DESC;

-- Q2. Does more sleep correlate with higher scores?
SELECT
    CASE
        WHEN avg_sleep_hours < 6 THEN 'Under 6 hrs'
        WHEN avg_sleep_hours BETWEEN 6 AND 7.5 THEN '6-7.5 hrs'
        ELSE 'Above 7.5 hrs'
    END AS sleep_bucket,
    ROUND(AVG(mock_score_mid)::numeric, 1) AS avg_mock_score,
    COUNT(*) AS num_students
FROM student_lifestyle
GROUP BY sleep_bucket
ORDER BY avg_mock_score DESC;

-- Q3. Top 3 hardest subjects by student count
SELECT
    hardest_subject,
    COUNT(*) AS num_students,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_total
FROM student_lifestyle
GROUP BY hardest_subject
ORDER BY num_students DESC
LIMIT 3;

-- Q4. Which students are high-stress AND burning out?
SELECT
    gender,
    class,
    stress_level,
    mental_state,
    mock_score_mid
FROM student_lifestyle
WHERE stress_level >= 4
  AND mental_state IN ('Burn Out', 'Anxious', 'Struggling')
ORDER BY stress_level DESC;

-- Q5. Phone usage vs performance
SELECT
    CASE
        WHEN avg_phone_hours <= 1.5 THEN 'Low (≤1.5 hrs)'
        WHEN avg_phone_hours <= 3 THEN 'Medium (1.5-3 hrs)'
        ELSE 'High (>3 hrs)'
    END AS phone_usage_bucket,
    ROUND(AVG(mock_score_mid)::numeric, 1) AS avg_mock_score,
    COUNT(*) AS num_students
FROM student_lifestyle
GROUP BY phone_usage_bucket
ORDER BY avg_mock_score DESC;

-- Q6. Rank students within each class by mock score
SELECT
    class,
    gender,
    mock_score_mid,
    RANK() OVER (PARTITION BY class ORDER BY mock_score_mid DESC) AS rank_in_class
FROM student_lifestyle
ORDER BY class, rank_in_class;

-- Q7. Score trend breakdown ( improving / declining / same)
WITH trend_counts AS (
    SELECT
        score_trend,
        COUNT(*) AS num_students
    FROM student_lifestyle
    GROUP BY score_trend
)
SELECT
    score_trend,
    num_students,
    ROUND(100.0 * num_students / SUM(num_students) OVER (), 1) AS pct_of_students
FROM trend_counts
ORDER BY num_students DESC;

-- Q8. Students sleeping below average who are still high-stress (subquery)
SELECT
    gender,
    class,
    avg_sleep_hours,
    stress_level,
    mock_score_mid
FROM student_lifestyle
WHERE avg_sleep_hours < (SELECT AVG(avg_sleep_hours) FROM student_lifestyle)
  AND stress_level >= 4
ORDER BY avg_sleep_hours ASC;

-- Q9. Self-study hours split into quartiles vs score
WITH study_quartiles AS (
    SELECT
        self_study_hours_mid,
        mock_score_mid,
        NTILE(4) OVER (ORDER BY self_study_hours_mid) AS study_quartile
    FROM student_lifestyle
)
SELECT
    study_quartile,
    ROUND(AVG(self_study_hours_mid)::numeric, 1) AS avg_study_hours,
    ROUND(AVG(mock_score_mid)::numeric, 1) AS avg_mock_score,
    COUNT(*) AS num_students
FROM study_quartiles
GROUP BY study_quartile
ORDER BY study_quartile;

-- Q10. Gender-wise stress & confidence comparison
SELECT
    gender,
    ROUND(AVG(stress_level)::numeric, 2) AS avg_stress,
    ROUND(AVG(confidence_level)::numeric, 2) AS avg_confidence,
    ROUND(AVG(mock_score_mid)::numeric, 1) AS avg_mock_score,
    COUNT(*) AS num_students
FROM student_lifestyle
GROUP BY gender
ORDER BY gender;
