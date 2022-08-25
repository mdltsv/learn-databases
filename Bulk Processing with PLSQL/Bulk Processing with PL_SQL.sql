--------------------------------------------------------------------------------
--									TODO:
-- На заметку для отладки смотреть, как перехвачен ECEPTION в 11 модуле.
-- Пункты из 6-го модуля выделить!
-- Пункты и пункты из 9-го модуля выделить!
-- Начиная, кажется, с модуля 10 идёт SQL%... (соотнести)!
-- Exercise 3.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                  1 About Tutorial (here's empty)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                  2 The Row by Row Problem
--------------------------------------------------------------------------------
/*
Write a procedure that accepts a department ID and a salary percentage increase
and gives everyone in that department a raise by the specified percentage.
*/
CREATE OR REPLACE PROCEDURE increase_salary
( dep_id          IN  hr.employees.department_id%TYPE
, sal_percentage  IN  NUMBER)
AS
BEGIN
  FOR rec IN (SELECT EMPLOYEE_ID
              FROM EMPLOYEES
              WHERE DEPARTMENT_ID = dep_id)
  LOOP
      UPDATE EMPLOYEES SET salary = salary + salary*sal_percentage
      WHERE EMPLOYEE_ID = rec.EMPLOYEE_ID;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE ('Updated ' || SQL%ROWCOUNT);
END;
/

BEGIN
   increase_salary (50, .005);
   ROLLBACK;
END;
/

--------------------------------------------------------------------------------
--                  3 Possible Solutions
--------------------------------------------------------------------------------
/* Use RAW SQL (without PL/SQL) */

--------------------------------------------------------------------------------
--                  4 Introduction to BULK COLLECT
--------------------------------------------------------------------------------
/*
Here's a block of code that fetches all rows in the employees table with a
single context switch, and loads the data into a collection of records
that are based on the table.
*/
DECLARE
TYPE coll_nt IS TABLE OF employees%ROWTYPE;
coll  coll_nt;
BEGIN
  SELECT *
    BULK COLLECT INTO coll
    FROM EMPLOYEES;
    DBMS_OUTPUT.PUT_LINE (coll.COUNT);
END;
/

/*
If you do not want to retrieve all the columns in a table,
create your own user-defined record type and use that to define your collection.
All you have to do is make sure the list of expressions in the SELECT
match the record type's fields.
*/
DECLARE
TYPE coll_rec IS  RECORD
                    ( emp employees.employee_id%TYPE
                    , sal employees.salary%TYPE);
TYPE coll_nt  IS TABLE OF coll_rec;
coll  coll_nt;
BEGIN
  SELECT employee_id, salary
    BULK COLLECT INTO coll
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID=50;
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
    DBMS_OUTPUT.PUT_LINE(coll.COUNT);
END;
/

--------------------------------------------------
--          Fill in the Blanks
--------------------------------------------------
/*In the block below replace the #FINISH# tags with code so that
the last names of all employees in department 50 are displayed.
*/
DECLARE
   TYPE     names_t IS TABLE OF employees.last_name%TYPE;
   l_names  names_t;
BEGIN
   SELECT last_name
     BULK COLLECT INTO l_names
     FROM employees
    WHERE department_id = 50
    ORDER BY last_name;
    DBMS_OUTPUT.PUT_LINE(l_names.COUNT);
END;
/

--------------------------------------------------
--          Exercise 1
--------------------------------------------------
/*
Write a stored procedure that accepts a department ID, uses BULK COLLECT to
retrieve all employees in that department, and displays their name and salary.
Then write an anonymous block to run that procedure for department 100.
*/
CREATE OR REPLACE PROCEDURE displ_name_sal
(dep_id_in employees.department_id%TYPE)
AS
CURSOR cur IS SELECT last_name, salary FROM EMPLOYEES;
TYPE  coll_nt IS TABLE OF cur%ROWTYPE;
coll  coll_nt;
BEGIN
  SELECT last_name, salary
    BULK COLLECT INTO coll
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = dep_id_in;
  DBMS_OUTPUT.PUT_LINE(coll.COUNT);
  DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------');
  FOR i IN 1..coll.COUNT LOOP
    --DBMS_OUTPUT.PUT_LINE(coll(i-1).last_name  ||  ' ' ||  coll(i-1).salary);
    DBMS_OUTPUT.PUT_LINE(coll(i).last_name  ||  ' ' ||  coll(i).salary);
  END LOOP;
END;
/

EXEC displ_name_sal(100);
/

--------------------------------------------------------------------------------
--                  5 Managing PGA Memory with the LIMIT Clause
--------------------------------------------------------------------------------
DECLARE
   l_strings   DBMS_SQL.varchar2a;
BEGIN
   FOR indx IN 1 .. 2 ** 31 - 1
   LOOP
      l_strings (indx) := RPAD ('abc', 32767, 'def');
   END LOOP;
END;
/

DECLARE
   c_limit PLS_INTEGER := 10;

   CURSOR employees_cur
   IS
      SELECT employee_id
        FROM employees
       WHERE department_id = 50;

   TYPE employee_ids_t IS TABLE OF 
      employees.employee_id%TYPE;

   l_employee_ids   employee_ids_t;
BEGIN
   OPEN employees_cur;

   LOOP
      FETCH employees_cur
      BULK COLLECT INTO l_employee_ids
      LIMIT c_limit;

      DBMS_OUTPUT.PUT_LINE (l_employee_ids.COUNT || ' fetched');

      EXIT WHEN l_employee_ids.COUNT = 0;
   END LOOP;
END;
/

DECLARE
   CURSOR emps_c IS SELECT * FROM employees;
   l_emp   emps_c%ROWTYPE;
   l_count INTEGER := 0;
BEGIN
   OPEN emps_c;

   LOOP
      FETCH emps_c INTO l_emp;
      EXIT WHEN emps_c%NOTFOUND;
      DBMS_OUTPUT.put_line (l_emp.employee_id);
      l_count := l_count + 1;
   END LOOP;
   DBMS_OUTPUT.put_line ('Total rows fetched: ' || l_count);
END;
/

DECLARE
   CURSOR emps_c IS SELECT * FROM employees;
   TYPE emps_t IS TABLE OF emps_c%ROwTYPE;
   l_emps   emps_t;
   l_count INTEGER := 0;
BEGIN
   OPEN emps_c;

   LOOP
      FETCH emps_c BULK COLLECT INTO l_emps LIMIT 10;
      EXIT WHEN emps_c%NOTFOUND;
      DBMS_OUTPUT.put_line (l_emps.COUNT);
      l_count := l_count + l_emps.COUNT;
   END LOOP;
   DBMS_OUTPUT.put_line ('Total rows fetched: ' || l_count);
END;
/

DECLARE
  CURSOR cur IS SELECT * FROM employees;
  TYPE  coll_nt IS TABLE OF cur%ROWTYPE;
  coll  coll_nt;
  v_flag NUMBER := 0;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur BULK COLLECT INTO coll LIMIT 20;
    DBMS_OUTPUT.PUT_LINE(coll.COUNT);
    EXIT WHEN cur%NOTFOUND;
  END LOOP;
  CLOSE cur;
END;
/

DECLARE
  CURSOR cur IS SELECT * FROM employees;
  TYPE  coll_nt IS TABLE OF cur%ROWTYPE;
  coll  coll_nt;
  v_flag NUMBER := 0;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur BULK COLLECT INTO coll LIMIT 20;
    EXIT WHEN coll.COUNT = 0;
    DBMS_OUTPUT.PUT_LINE(coll.COUNT);
  END LOOP;
  CLOSE cur;
END;
/

--------------------------------------------------
--          Fill in the Blanks
--------------------------------------------------
/*
The employees table has 107 rows in it.
In the block below replace the #FINISH# tags with code so that
when the block is executed, the following text is displayed:
Rows fetched 25
Rows fetched 25
Rows fetched 25
Rows fetched 25
Rows fetched 7
Rows fetched 0
*/

DECLARE
   CURSOR ids_c IS SELECT employee_id FROM employees;
   TYPE coll_nt IS TABLE OF ids_c%ROWTYPE;
   coll coll_nt;
   l_count INTEGER;
BEGIN
   OPEN ids_c;

   LOOP
      FETCH ids_c BULK COLLECT INTO coll LIMIT 25;
      l_count := coll.COUNT;
      DBMS_OUTPUT.put_line ('Rows fetched: ' || l_count);
      EXIT WHEN coll.COUNT = 0;
   END LOOP;

   CLOSE ids_c;
END;
/

--------------------------------------------------
--          Exercise 2
--------------------------------------------------
/*
Write an anonymous block that fetches (using BULK COLLECT) only the last name
and salary from the employees table 5 rows at a time,
and then displays that information. Make sure 107 names and salaries are shown!
*/
DECLARE
  CURSOR cur IS SELECT last_name, salary FROM employees;
  TYPE  coll_nt IS TABLE OF cur%ROWTYPE;
  coll  coll_nt;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur BULK COLLECT INTO coll LIMIT 5;
    FOR i IN 1..5 LOOP
      DBMS_OUTPUT.PUT_LINE(coll(i).last_name || '   ' || coll(i).salary);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(cur%ROWCOUNT);
    EXIT WHEN coll.COUNT = 0;
  END LOOP;
END;
/

--------------------------------------------------------------------------------
--                  6 Cursor FOR Loops and BULK COLLECT
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE test_cursor_performance (approach IN VARCHAR2)
IS
   CURSOR cur IS
      SELECT * FROM all_source WHERE ROWNUM < 100001;

   one_row cur%ROWTYPE;

   TYPE t IS TABLE OF cur%ROWTYPE INDEX BY PLS_INTEGER;

   many_rows     t;
   last_timing   NUMBER;
   cntr number := 0;

   PROCEDURE start_timer
   IS
   BEGIN
      last_timing := DBMS_UTILITY.get_cpu_time;
   END;

   PROCEDURE show_elapsed_time (message_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
            '"'
         || message_in
         || '" completed in: '
         || TO_CHAR (
               ROUND ( (DBMS_UTILITY.get_cpu_time - last_timing) / 100, 2)));
   END;
BEGIN
   start_timer;

   CASE approach
      WHEN 'implicit cursor for loop'
      THEN
         FOR j IN cur
         LOOP
            cntr := cntr + 1;
         END LOOP;

         DBMS_OUTPUT.put_line (cntr);

      WHEN 'explicit open, fetch, close'
      THEN
         OPEN cur;

         LOOP
            FETCH cur INTO one_row;
            EXIT WHEN cur%NOTFOUND;
            cntr := cntr + 1;
         END LOOP;

         DBMS_OUTPUT.put_line (cntr);

         CLOSE cur;
      WHEN 'bulk fetch'
      THEN
         OPEN cur;

         LOOP
            FETCH cur BULK COLLECT INTO many_rows LIMIT 100;
            EXIT WHEN many_rows.COUNT () = 0;

            FOR indx IN 1 .. many_rows.COUNT
            loop
               cntr := cntr + 1;
            end loop;
         END LOOP;

         DBMS_OUTPUT.put_line (cntr);

         CLOSE cur;
   END CASE;

   show_elapsed_time (approach);
END test_cursor_performance;
/

ALTER PROCEDURE test_cursor_performance
COMPILE plsql_optimize_level=0
/

BEGIN
   dbms_output.put_line ('No optimization...');
   
   test_cursor_performance ('implicit cursor for loop');

   test_cursor_performance ('explicit open, fetch, close');

   test_cursor_performance ('bulk fetch');
END;
/

/* Try different approaches with default optimization. */

ALTER PROCEDURE test_cursor_performance
COMPILE plsql_optimize_level=2
/

BEGIN
   DBMS_OUTPUT.put_line ('Default optimization...');

   test_cursor_performance ('implicit cursor for loop');

   test_cursor_performance ('explicit open, fetch, close');

   test_cursor_performance ('bulk fetch');
END;
/

--------------------------------------------------
--          Exercise 3
--------------------------------------------------
/*
This exercise has two parts
(and for this exercise assume that the employees table has 1M rows
with data distributed equally among departments):
(1) Write an anonymous block that contains a cursor FOR loop that does not need
to be converted to using BULK COLLECT.
(2) Write an anonymous block that contains a cursor FOR loop that does need to
use BULK COLLECT
(assume it cannot be rewritten in "pure" SQL).
*/
--Основываясь на описании в начале урока:
--(1)
-- Придумать блок, в котором FOR LOOP, который не надо переписывать в BULK.
--(2)
-- Придумать блок, в котором FOR LOOP, который надо переписать в BULK?!

--------------------------------------------------------------------------------
--                  7 RETURNING and BULK COLLECT
--------------------------------------------------------------------------------
/* RETURNING INTO траснлируется в INSERT INTO.
 Если надо вернуть много строк, то надо так же использовать BULK COLLECT.
*/

--------------------------------------------------
--          Fill in the Blanks
--------------------------------------------------
/*
In the block below replace the #FINISH# tag with code so that
"Deleted = 3" is displayed after execution
*/

DECLARE
   TYPE ids_t IS TABLE OF employees.employee_id%TYPE;
   l_ids ids_t;
BEGIN
   DELETE FROM employees
    WHERE salary > 15000
    RETURNING employee_id BULK COLLECT INTO l_ids;

   DBMS_OUTPUT.PUT_LINE ('Deleted = ' || l_ids.COUNT);

   ROLLBACK;
END;
/

--------------------------------------------------
--          Exercise 4
--------------------------------------------------
/*
Write an anonymous block that deletes all the rows in the employees for
dep 50 and returns all the employee_IDs and the last_names of deleted rows.
Then display those values using DBMS_OUTPUT.PUT_LINE.
Finally, you might want to rollback.
That will make it easier to test your code - and continue on with the tutorial.
*/
CREATE TABLE emp AS SELECT * FROM employees;
/
DECLARE
CURSOR cur IS SELECT employee_ID, last_name FROM employees;
TYPE  am IS TABLE OF cur%ROWTYPE;
coll  am;
BEGIN
  DELETE FROM emp WHERE department_id=50
  RETURNING employee_ID, last_name BULK COLLECT INTO coll;
  FOR I IN 1..coll.cOUNT LOOP
    dbms_output.put_line(coll(i).employee_ID || ' ' || coll(i).last_name);
  END LOOP;
END;
/
--------------------------------------------------------------------------------
--                  8 Dynamic SQL and BULK COLLECT
--------------------------------------------------------------------------------
/* Можно использовать BULK COLLECT с NDSQL, который возвращает более 1-й строки.
Добавлять вне строки динамического SQL, или прямо внутри.
*/

--------------------------------------------------
--          Exercise 5
--------------------------------------------------
/*
Write the rest of the procedure whose signature is shown below.
Use BULK COLLECT to fetch all the last names from employees identified by
that WHERE clause and return the collection.
Then write an anonymous block to test your procedure:
pass different WHERE clauses, and display names retrieved.
*/

CREATE OR REPLACE PROCEDURE get_names (
   where_in IN VARCHAR2,
   names_out OUT DBMS_SQL.VARCHAR2_TABLE)
AS
quer VARCHAR2(400) := 'SELECT last_name FROM ';
BEGIN
  quer := quer || where_in;
  dbms_output.put_line(quer);
  EXECUTE IMMEDIATE quer BULK COLLECT INTO names_out;
END;
/

DECLARE
  aa DBMS_SQL.VARCHAR2_TABLE;
BEGIN
  get_names('EMPLOYEES', aa);
  FOR I IN 1..aa.COUNT LOOP
    dbms_output.put_line(aa(i));
  END LOOP;
END;
/
--------------------------------------------------------------------------------
--                  9 Intro to FORALL
--------------------------------------------------------------------------------
/* Выполняя nqDML в цикле, нужно конвертировать код для использования FORALL - в
в том случае, если не выходит избавиться от цикла полностью, обрабатывая
требование на "чистом SQL".
FORALL - не цикл; это декларативное обращение к PL/SQL-движку:
"Создать все DML-операторы, которые должны выполняться по одной строке, и
отправить их все в SQL-движок с одним переключением контекста."
Начнём с простого примера, показывающего базовую конвертацию из цикла в FORALL.
Потом будет показано много нюансов работы с этим мощным инструментом.

Классический анти-паттерн "row-by-row", удаляющий всех работников dept 50 и 100.
Пример не на чистом SQL намеренн, т.к. в реальности чистый редко возможен:
*/
BEGIN
   FOR emp_rec IN (SELECT employee_id
                     FROM employees
                    WHERE department_id IN (50, 100))
   LOOP
      DELETE FROM employees
            WHERE employee_id = emp_rec.employee_id;
   END LOOP;
   ROLLBACK;
END;
/
/* Что меняется для FORALL:
    Объявляется nt, переменная её типа и инициализируется.
    Цикл FOR LOOP преобразуется в обращение FORALL!
    Неявно объявляется итератор l_index.
    Ну и удобно просмотривать количество изменяемых строк.
*/
DECLARE
   TYPE ids_t IS TABLE OF EMP.department_id%TYPE;
   l_ids ids_t := ids_t (50, 100);
BEGIN
   FORALL l_index IN 1 .. l_ids.COUNT
      DELETE FROM EMP
            WHERE department_id = l_ids (l_index);
   DBMS_OUTPUT.put_line (SQL%ROWCOUNT);
   ROLLBACK;
END;
/
/*
Всё довольно просто, но уже в чуть более сложных случаях нужно заботиться о том,
чтобы данные, передаваемые в FORALL из многомерных коллекций были согласованы.
Обычно это не такая уж проблема, но надо помнить.
Самое важное о FORALL:
 FORALL соответствует только одному DML. Если несколько, нужно несколько FORALL.
 PL/SQL объявляет итератор типа integer для FORALL неявно. Хотя бы в одном месте
 DML нужно сослаться на коллекцию и использовать итератор FORALL как её индекс.
 Используя IN min..max в FORALL, коллекции для FORALL должны быть полными.
 Если разрежены, нужно использовать синтаксис INDICES OF или VALUES OF.
*/

/* Fill in the Blanks
  In the block below replace the #FINISH# tags with code so that
  the last names of employees with IDs 111, 121 and 131 are all upper-cased. */
DECLARE
   l_ids        DBMS_SQL.number_table;
   l_names      DBMS_SQL.varchar2a;
BEGIN

  SELECT employee_id, first_name BULK COLLECT INTO l_ids, l_names
  FROM EMP WHERE employee_id IN (111,121,112);
  dbms_output.put_line(l_names.COUNT);
  dbms_output.put_line(l_ids.COUNT);

-- 0 в FORALL нельзя менять по условию. Пришлось переопределять индексы.

  FOR i IN 1..l_names.COUNT LOOP
    l_ids(i-1):=l_ids(i);
    l_names(i-1):=l_names(i);
    dbms_output.put_line(l_ids(i-1));
    dbms_output.put_line(l_names(i-1));
  END LOOP;

  l_ids.DELETE(l_names.COUNT-1);
  l_names.DELETE(l_names.COUNT-1);
  dbms_output.put_line(l_names.COUNT);
  dbms_output.put_line(l_ids.COUNT);
  
  FORALL indx IN 0 .. (l_names.COUNT-1)
    UPDATE employees
    SET first_name = UPPER (l_names (indx))
    WHERE employee_id = l_ids (indx);

  DBMS_OUTPUT.put_line ('Total rows modified = ' || SQL%ROWCOUNT);

  ROLLBACK;
END;
/

/* Exercise 6:
  Написать анонимный блок с BULK COLLECT для пополнения двух коллекций:
  1 - employee_Id 2- last_name.
  Исползовать коллекции в FORALL для изменения фамилий до заглавных букв
  из имён сотрудников. */

DECLARE
  TYPE l_ids_nt IS TABLE OF INTEGER;
  TYPE l_names_nt IS TABLE OF emp.last_name%TYPE;
  l_ids l_ids_nt;
  l_names l_names_nt;
  l_names_upd l_names_nt; --для отладки
BEGIN

  SELECT employee_id, last_name BULK COLLECT INTO l_ids, l_names FROM EMP;

  FORALL i IN 1..l_names.COUNT
    UPDATE EMP
    SET last_name = SUBSTR(l_names(i),1,1)
    WHERE EMPLOYEE_ID=l_ids(i)
    RETURN last_name BULK COLLECT INTO l_names_upd;

  -- Для отладки:
  FOR i IN 1..l_names_upd.COUNT LOOP
    dbms_output.put_line(l_names_upd(i));
  END LOOP;

  ROLLBACK;
END;
/

--------------------------------------------------------------------------------
--                  10 SQL%ROWCOUNT and SQL%BULK_ROWCOUNT
--------------------------------------------------------------------------------
/* SQL%ROWCOUNT возвращает сумму числа строк изменённых посредством FORALL.
SQL%BULK_ROWCOUNT - псевдоколлекция, содержащая один элемент для каждого DML,
выполненного в FORALL. Элемент содержит число строк, изменённых конкретным DML.
Ниже процедура, обновляющая зп по специальным фильтрам имён. Также показано
общее число изменённых строк, а потом итерируется псевдоколлекция для вывода
числа изменённых строк по каждой DML. В допонение проведена проверка качества:
если фильтр не меняет ни одной строки, выбрасывается исключение.
Это как раз то, зачем нужен SQL%BULK_ROWCOUNT.
*/
CREATE OR REPLACE TYPE filter_nt IS TABLE OF VARCHAR2(100)
/
CREATE OR REPLACE PROCEDURE update_by_filter (filter_in IN filter_nt)
IS
BEGIN
   FORALL indx IN 1 .. filter_in.COUNT
      UPDATE EMP
         SET salary = salary * 1.1
       WHERE UPPER (last_name) LIKE filter_in (indx);

   DBMS_OUTPUT.put_line ('Total rows modified = ' || SQL%ROWCOUNT);

   FOR indx IN 1 .. filter_in.COUNT
   LOOP
      IF SQL%BULK_ROWCOUNT (indx) = 0
      THEN
         raise_application_error (
            -20000,
            'No rows found for filter "' || filter_in (indx) || '"');
      ELSE
         DBMS_OUTPUT.put_line (
               'Number of employees with names like "'
            || filter_in (indx)
            || '" given a raise: '
            || SQL%BULK_ROWCOUNT (indx));
      END IF;
   END LOOP;

   ROLLBACK;
END;
/
BEGIN
   update_by_filter (filter_nt ('S%', 'E%', '%A%', 'XXXXX'));
END;
/

/* Fill in the Blanks
Заменить #FINISH# так, чтобы вывести полное число удалённых строк и число строк,
удалённых для отделов 10 и 100.*/
DECLARE
  TYPE ids_t IS TABLE OF employees.department_id%TYPE;
  l_ids ids_t := ids_t (10, 100);
BEGIN
  FORALL l_index IN 1..l_ids.COUNT
    DELETE FROM EMP
    WHERE department_id = l_ids (l_index);

  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);

  FOR l_index IN 1..l_ids.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(SQL%BULK_ROWCOUNT(l_index));
  END LOOP;
  
  ROLLBACK;
END;
/
/* Exercise 8:
Дописать процедуру, использующую FORALL для обновления зп всех работников в
каждом отделе в соответствии с массивом зп. Отобразить число изменённых строк.
Выбросить PROGRAM_ERROR, если какой-либо update изменит меньше 2 строк. */
CREATE OR REPLACE PROCEDURE update_salaries (
   department_ids_i IN department_ids_in,
   salaries_i IN salaries_in)
IS
BEGIN
  FORALL i IN 1..department_ids_i.COUNT
    UPDATE EMP
    SET salary = salaries_i(i)
    WHERE DEPARTMENT_ID = department_ids_i(i);

  DBMS_OUTPUT.put_line(SQL%ROWCOUNT);

  FOR i IN 1..department_ids_i.COUNT LOOP
    IF SQL%BULK_ROWCOUNT(i) < 2 THEN
      RAISE_APPLICATION_ERROR(-20000, 'В отделе '||department_ids_i(i)||
                                                     ' измеено меньше 2-х ЗП!');
    ELSE
      DBMS_OUTPUT.put_line('В отделе '||department_ids_i(i)|| ' изменены ' ||
                                                  SQL%BULK_ROWCOUNT(i)||' ЗП.');
    END IF;
  END LOOP;

END;
/
-- Пришлось пересоздать тип, чтобы можно было передать коллекцию в процедуру.
CREATE OR REPLACE TYPE department_ids_in IS TABLE OF INTEGER;
CREATE OR REPLACE TYPE salaries_in IS TABLE OF INTEGER;
/
BEGIN
  update_salaries(department_ids_in(10, 20, 30, 40, 50)
                , salaries_in(111111, 222222, 333333, 444444, 55555));
END;
/

--------------------------------------------------------------------------------
--                  10 Errors and FORALL

--------------------------------------------------------------------------------
/* При изменении строк в таблицах постоянно возникают ошибки.
Нарушение ограничений целостности, неподходящий тип для столбца для столбца итд.
А с использованием FORALL DML выполняется ещё и много раз.
Управление ошибками при FORALL - хитрый и важный процесс!
Перед поружением в мир управления ошибками с FORALL важно помнить кое-что о
транзакциях, ошибках и исключениях в PLSQL:
- Если SQL-движок возвращает ошибку в PL/SQL-движок, это не приводит к
автоматическому rollback совершённых успешных DML. Они ожидают commit/rollback.
- Если исключение не обработано в PLSQL происходит автоматический rollback.
- Все SQL-выражения атомарны, если не используется LOG ERRORS feature.
Другими словами, если update находит 100 строк для изменения,
и при изменении сотой происходит ошибка изменения всех 100 откатываются.
- LOG ERRORS - это SQL-feature, позволяющая подавлять ошибки на уровне строк,
как бы изменяя атомарность. LOG ERRORS найти в LiveSQL.
Главное - по умолчанию, когда SQL-движок первый раз ошибкой выполнения DML,
переданного из FORALL, он останавливается и передаёт ошибку в PL/SQL-движок.
Дальнейшая обработка не выполняется, bно успешно соверёшнные операторы в
FORALL ожидают commit/rollback. Ниже видно, что ограничения размера строк в
столбце n: 1 и 10 - OK, 100 - превышает.
*/
CREATE TABLE mynums (n NUMBER (2))
/
DECLARE
   TYPE numbers_t IS TABLE OF NUMBER;
   l_numbers   numbers_t := numbers_t (1, 10, 100);
BEGIN
   FORALL indx IN 1 .. l_numbers.COUNT
      INSERT INTO mynums (n)
         VALUES (l_numbers (indx));
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Updated ' || SQL%ROWCOUNT || ' rows.');
      DBMS_OUTPUT.put_line (SQLERRM);
      ROLLBACK;
END;
/
DECLARE
   TYPE numbers_t IS TABLE OF NUMBER;
   l_numbers   numbers_t := numbers_t (100, 10, 1);
BEGIN
   FORALL indx IN 1 .. l_numbers.COUNT
      INSERT INTO mynums (n)
         VALUES (l_numbers (indx));
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Updated ' || SQL%ROWCOUNT || ' rows.');
      DBMS_OUTPUT.put_line (SQLERRM);
      ROLLBACK;
END;
/
DROP TABLE mynums
/
/* Это пример non-bulk поведения. FORALL, грубо говоря, может сразу отвалиться.
При non-bulk подходе можно сказать PLSQL-движку выполнять работу после получения
ошибки, если DML операции несколько: */
BEGIN
   BEGIN
      INSERT INTO ...
   EXCEPTION 
      WHEN OTHERS 
      THEN
          log_error ...
   END;

   BEGIN
      UPDATE ...
   EXCEPTION 
      WHEN OTHERS 
      THEN
          log_error ...
   END;
END;
/
/* Крайне не рекомедуется помещать каждый nqDML в nt, перехватывать исключение,
и продолжать выполнение! Это возможно, но не нужно! С FORALL каждый DML
выполняется многократно. Можно остановить FORALL, как только произойдёт сбой.
Но если случится ошибка SQL и нужно продолжить выполнение,
придётся воспользоваться SAVE EXCEPTIONS. */

/* Exercise 6:
Complete the block below as follows:
use FORALL to update the salaries of employees whose IDs are in l_ids with the
corresponding salary in l_salaries.
Display the total number of employees modified.
First, use values for salaries that will allow all statements to complete
successfully (salary is defined as NUMBER (8,2).
Then change the salary values to explore the different
ways that FORALL deals with errors. */

DECLARE
   TYPE numbers_nt IS TABLE OF NUMBER;
   l_ids numbers_nt := numbers_nt (101, 111, 131);
   l_salaries numbers_nt := numbers_nt (#FINISH#);
BEGIN
   #FINISH#
END;
/
