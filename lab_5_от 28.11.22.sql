--Задание 1
--1.	Используя оператор INSERT …VALUES вставьте в таблицы вашей БД по 2 записи (с учетом ограничений целостности). Приведите скрипт, который вы использовали.

-- внесение значений в таблицу "Library"."Reader"
insert into "Library"."Reader"
	(library_card, last_name, first_name, patronymic, address_home, phone_number)
values
	(001, 'Зелёный', 'Первый', 'Изумрудович', 'ул. Цветная д. 16', '89117547823'),
	(002, 'Красный', 'Второй', 'Рубинович', 'ул. Каменная д. 4', '89215546808'),
	(003, 'Синий', 'Третий', Default,'ул. Каменная д. 4', '89215546808');

select *
from "Library"."Reader";
	
-- внесение значений в таблицу "Manuscript"."Author"
insert into "Manuscript"."Author" 
	(author_id, last_name, first_name, patronymic, country_of_birth)
values
	(default, 'Однодольная', 'Пшеница', 'Злаковая', 'РФ'),
	(default, 'Двудольная', 'Ежевика', 'Ягодовна', 'Китай');

select *
from "Manuscript"."Author";

-- внесение значений в таблицу "Manuscript"."Manuscript"
insert into "Manuscript"."Manuscript" 
	(manuscript_id, "style", manuscript_name, author_id)
values
	(0101, 'Наука', 'Справочник о растениях', 3)
	(0202, 'Детектив', 'Поиск ягод в лесу', 4);

select *
from "Manuscript"."Manuscript";

--2.	Выполните модификацию записей в таблицах вашей БД, в соответствии с бизнес-требованиями выбранной предметной области. Приведите скрипт.
update "Library"."Reader"
set patronymic = 'Сапфирович'
where library_card = 3;

-- 3.	Напишите скрипт, для удаления неактуальных записей из таблиц вашей БД.
delete from "Manuscript"."Manuscript"
where "style" = 'Наука';


--Задание 2
--1.	Создайте в вашей БД таблицу и добавьте в нее записи
--Создание таблицы
CREATE TABLE public."Goods" (
      "ProductId" serial NOT NULL,
      "ProductName" VARCHAR(100) NOT NULL,
      "Price" MONEY NULL
   );

  --Добавление данных в таблицу public."Goods"
INSERT INTO public."Goods"
	("ProductName", "Price")
VALUES
	('Велосипед', 7550),
	('Перчатки', 230),
	('Насос', 150);

--2.	Выполните запрос для проверки наличия в таблице данных записей. Приведите скрипт.
select *
from public."Goods";

-- 3.	Используя явную транзакцию выполните изменение цены продуктов
--в соответствии с таблицей и приведите скрипт:
begin;
	update  public."Goods"
	set "Price" = "Price" + ("Price" * 0.3)
	where "ProductId" = 1;

	update  public."Goods"
	set "Price" = "Price" + ("Price" * 0.13)
	where "ProductId" = 2;

	select "ProductId", "ProductName", "Price" as "New Price"
	from public."Goods"
commit 

--4.	Выполните запрос для проверки наличия в таблице данных записей. Приведите скрипт.
select *
from public."Goods";

--5.	Используя явную транзакцию выполните изменение цены продуктов в соответствии со следующей таблицей и приведите скрипт:
begin;
	update  public."Goods"
	set "Price" = "Price" + ("Price" * 0.3)
	where "ProductId" = 2;

	update  public."Goods"
	set "Price" = '250 рублей'
	where "ProductId" = 3;

	select "ProductId", "ProductName", "Price" as "New Price"
	from public."Goods"
--rollback;
end;

drop table public."Goods"

--Задание 3. Уровни изоляции транзакций
--Задача 1.
--1.	Откройте две параллельные сессии.
--2.	В первой сессии: 
--a.	Проверьте, какой уровень изоляции транзакций использует ваше соединение
select current_setting('transaction_isolation');
--Ответ: read committed

--b.	Откройте явную транзакцию 
--c.	Добавьте в рамках транзакции новый товар в таблицу public."Goods".
begin;
	INSERT INTO public."Goods"
	("ProductName", "Price")
	VALUES
	('Рюкзак', 20);

--d.	Узнайте  и зафиксируйте номер текущей транзакции, выполнив запрос:
--SELECT txid_current ();
SELECT txid_current ();

-- номер текущей транзакции: 17742

--4.	В первой сессии: 
--a.	Зафиксируйте выполнение транзакции
SAVEPOINT point_1;
--6.	Закройте обе сессии
end;

--ЗАДАЧА 2.
--1.	Откройте две параллельные сессии.
--2.	В первой сессии: 
--a.	Откройте явную транзакцию
begin;

--b.	Узнайте и зафиксируйте номер текущей транзакции, выполнив запрос
SELECT txid_current ();
--Ответ: 17747
--c.	Напишите запрос, извлекающий все записи из таблицы public."Goods". Транзакцию не закрывайте
select *
from public."Goods";

--4.	В первой сессии: 
--a.	Напишите запрос, извлекающий все записи из таблицы public."Goods".
select *
from public."Goods"; 
--b.	Каков результат?
--Ответ: Позиция "Инструменты" не добавились
--c.	Закройте транзакцию
commit;
--5.	Закройте сессии
end;


--ЗАДАЧА 3.
--1.	Откройте две параллельные сессии.
--2.	В первой сессии: 
--a.	Откройте явную транзакцию c уровнем изоляции REPEATABLE READ
begin ISOLATION LEVEL REPEATABLE READ;
--b.	Напишите запрос, извлекающий из таблицы public."Goods"все записи, удовлетворяющие условию "ProductId">2
select *
from public."Goods"
where "ProductId">2; 
--c.	Добавьте в рамках транзакции новый товар в таблицу public."Goods".
INSERT INTO public."Goods"
("ProductName", "Price")
VALUES
('Фонарик', 60); 
--Транзакцию не закрывайте!

--4.	В первой сессии: 
--a.	Напишите запрос, извлекающий из таблицы public."Goods"все записи, удовлетворяющие условию "ProductId">2 
select *
from public."Goods"
where "ProductId">2;
--b.	Каков результат?
--Ответ: добавлен товар с первой сессии, нет товара со второй сессии

--6.	Откатите открытые транзакции 
rollback;

--ЗАДАЧА 4
--1.	Откройте две параллельные сессии.
--2.	В первой сессии: 
--a.	Откройте явную транзакцию c уровнем изоляции REPEATABLE READ
begin ISOLATION LEVEL REPEATABLE READ;

--b.	Напишите запрос, извлекающий из таблицы public."Goods"все записи, удовлетворяющие условию "ProductId">2
select *
from public."Goods"
where "ProductId">2;

 
--4.	В первой сессии: 
--a.	Измените наименование товара с кодом 3, добавив к нему ‘silver’
update  public."Goods"
set "ProductName" = "ProductName" + 'silver'
where "ProductId" = 3; 
--b.	Каков результат?


--5.	Во второй сессии: 
--a.	Напишите запрос, извлекающий из таблицы public."Goods"все записи, удовлетворяющие условию "ProductId"<2 
--b.	Зафиксируйте транзакцию
--6.	В первой сессии: 
--a.	Каково состояние вашей транзакции?
--7.	Откатите открытые транзакции и удалите вашу БД!
