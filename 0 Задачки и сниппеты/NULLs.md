/* Нужно внимательно работать с функциями, обрабатывающими NULL
   В первом запросе NULL - 182, во втором - 0!
*/
SELECT coalesce(density, 0), COUNT(*) as cnt FROM MAT_STRUCTURAL GROUP BY coalesce(density, 0) order by cnt;
SELECT coalesce(density, 0), COUNT(density) as cnt FROM MAT_STRUCTURAL GROUP BY coalesce(density, 0) order by cnt;
/

Какова цель функций COALESCE и NVL?
