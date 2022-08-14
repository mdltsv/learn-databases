[Chal66]

-- CREATING
CREATE TABLE a_people
(
a_id NUMBER(10),
a_name VARCHAR2(20)
);
/
CREATE TABLE a_people_qual
(
aq_guid NUMBER(10),
aq_name VARCHAR2(20),
qual1 VARCHAR2(20),
qual2 VARCHAR2(20),
qual3 VARCHAR2(20),
qual4 VARCHAR2(20),
qual5 VARCHAR2(20)
);
/
INSERT INTO a_people (a_id, a_name) VALUES (1, 'Паша');
INSERT INTO a_people (a_id, a_name) VALUES (2, 'Вася');
/
INSERT INTO a_people_qual (aq_guid, aq_name, qual1, qual2, qual3, qual4)
VALUES (1, 'Паша', 'сильный', 'смелый', 'умный', 'смешной');
INSERT INTO a_people_qual (aq_guid, aq_name, qual1, qual2, qual3, qual4)
VALUES (2, 'Вася', 'прямой', 'лидер', 'благородный', NULL);
/
CREATE TABLE a_people_numbqual
(
anq_guid NUMBER(10),
anq_name VARCHAR2(20),
qual VARCHAR2(20)
);
/
INSERT INTO a_people_numbqual (anq_guid, anq_name, qual) VALUES (1, 'Паша', 'сильный');
INSERT INTO a_people_numbqual (anq_guid, anq_name, qual) VALUES (2, 'Паша', 'смелый');
INSERT INTO a_people_numbqual (anq_guid, anq_name, qual) VALUES (3, 'Паша', 'умный');
INSERT INTO a_people_numbqual (anq_guid, anq_name, qual) VALUES (4, 'Паша', 'смешной');
INSERT INTO a_people_numbqual (anq_guid, anq_name, qual) VALUES (5, 'Вася', 'прямой');
INSERT INTO a_people_numbqual (anq_guid, anq_name, qual) VALUES (6, 'Вася', 'лидер');
INSERT INTO a_people_numbqual (anq_guid, anq_name, qual) VALUES (7, 'Вася', 'благородный');
/
--------------------------------------------------

SELECT
    anq_guid,
    anq_name,
    qual,
    rank() OVER (PARTITION BY anq_name ORDER BY qual ASC) AS qual_numb
FROM a_people_numbqual;
/
SELECT
    CASE WHEN anq_guid = 1 THEN qual END qual1,
    CASE WHEN anq_guid = 2 THEN qual END qual2,
    CASE WHEN anq_guid = 3 THEN qual END qual3,
    CASE WHEN anq_guid = 4 THEN qual END qual4
FROM a_people_numbqual
WHERE anq_name = 'Паша';
/

-- Через создание типа и помещения данных в коллекцию
create or replace TYPE anq_categorytype as TABLE OF VARCHAR2(20);
/
select anq_name, CAST ( COLLECT(qual) as anq_categorytype ) categories
FROM a_people_numbqual group by anq_name;
/

-- Через PIVOT, по всей видимости, нельзя, т.к. нужна агрегатна€ функци€, а мне строки нужно оставить.
CREATE VIEW a_view_numbqual AS
SELECT
    anq_guid,
    anq_name,
    qual,
    rank() OVER (PARTITION BY anq_name ORDER BY qual ASC) AS qual_numb
FROM a_people_numbqual;
/
SELECT * FROM a_view_numbqual
PIVOT(
    COUNT(qual) order_count
    FOR qual_numb
    IN (
        1,
        2, 
        3,
        4
    )
)
ORDER BY anq_guid, anq_name;
/

-- Через аналитическую функцию LISTAGG (пока самый перспективный метод)
SELECT
    DISTINCT anq_name,
    LISTAGG(qual, ', ') WITHIN GROUP (ORDER BY anq_guid) OVER (Partition BY anq_name)
FROM a_view_numbqual;
/

-- Попробовать через PL/SQL
