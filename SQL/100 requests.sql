-- ============================================================
-- ЛАБОРАТОРНАЯ РАБОТА: SQL-ЗАПРОСЫ К БАЗЕ ДАННЫХ TRAVEL PLANNER
-- ============================================================

-- ============================================================
-- РАЗДЕЛ 1. ЗАПРОСЫ ИЗ ФУНКЦИОНАЛЬНЫХ ТРЕБОВАНИЙ
-- ============================================================

-- 1.1. Получить список всех поездок пользователя по его username
SELECT
    t.id,
    t.title,
    t.status
FROM trip t
INNER JOIN "User" u ON t.user_id = u.id
WHERE u.username = 'alex_traveler';

-- 1.2. Получить профиль путешественника по username
SELECT
    tp.full_name,
    tp.birth_date,
    u.username,
    u.language
FROM traveler_profile tp
INNER JOIN "User" u ON tp.user_id = u.id
WHERE u.username = 'maria_smirnova';

-- 1.3. Получить все активности в поездке по названию поездки
SELECT
    a.start_time,
    a.description,
    a.address,
    l.name AS location_name
FROM activity_schedule a
INNER JOIN location l ON a.location_id = l.id
INNER JOIN trip t ON a.trip_id = t.id
WHERE t.title = 'Отпуск в Париже';

-- 1.4. Получить все отели в поездке по названию поездки
SELECT
    hb.hotel_name,
    hb.check_in,
    hb.check_out,
    hb.address
FROM hotel_booking hb
INNER JOIN trip t ON hb.trip_id = t.id
WHERE t.title = 'Business Trip to Tokyo';

-- 1.5. Получить все билеты путешественника по его полному имени
SELECT
    tt.type,
    tt.booking_ref,
    tt.departure_time,
    rs.origin,
    rs.destination
FROM transport_ticket tt
INNER JOIN traveler_profile tp ON tt.traveler_id = tp.id
INNER JOIN route_segment rs ON tt.segment_id = rs.id
WHERE tp.full_name = 'Александр Иванов';

-- 1.6. Получить суммарные расходы по поездке
SELECT
    t.title,
    SUM(e.amount) AS total_expenses
FROM expense e
INNER JOIN trip t ON e.trip_id = t.id
WHERE t.title = 'Отпуск в Париже'
GROUP BY t.title;

-- 1.7. Получить все ещё не отправленные напоминания пользователя
SELECT
    r.trigger_at,
    r.is_sent,
    u.username
FROM reminder r
INNER JOIN "User" u ON r.user_id = u.id
WHERE u.username = 'alex_traveler'
  AND r.is_sent = FALSE;

-- 1.8. Получить сегменты маршрута поездки в правильном порядке
SELECT
    rs.order_index,
    rs.origin,
    rs.destination
FROM route_segment rs
INNER JOIN trip t ON rs.trip_id = t.id
WHERE t.title = 'Eurotour 2026'
ORDER BY rs.order_index ASC;

-- 1.9. Получить расходы по категориям в поездке
SELECT
    e.category,
    SUM(e.amount) AS total,
    COUNT(*) AS records_count
FROM expense e
INNER JOIN trip t ON e.trip_id = t.id
WHERE t.title = 'Отпуск в Париже'
GROUP BY e.category;

-- 1.10. Получить все поездки со статусом Active
SELECT
    t.title,
    t.status,
    u.username
FROM trip t
INNER JOIN "User" u ON t.user_id = u.id
WHERE t.status = 'Active';

-- 1.11. Получить ближайшие активности пользователя (по дате)
SELECT
    a.start_time,
    a.description,
    l.name AS location_name,
    t.title AS trip_title
FROM activity_schedule a
INNER JOIN location l ON a.location_id = l.id
INNER JOIN trip t ON a.trip_id = t.id
INNER JOIN "User" u ON t.user_id = u.id
WHERE u.username = 'alex_traveler'
ORDER BY a.start_time ASC;


-- ============================================================
-- РАЗДЕЛ 2. UPDATE — обновление данных в разных таблицах
-- ============================================================

-- 2.1. Обновить язык пользователя
UPDATE "User"
SET language = 'en'
WHERE username = 'siri_nordic';

-- 2.2. Исправить статус завершённой поездки
UPDATE trip
SET status = 'Completed'
WHERE title = 'Выходные в Сочи';

-- 2.3. Обновить дату рождения в профиле путешественника
UPDATE traveler_profile
SET birth_date = '1991-03-22'
WHERE full_name = 'Yuki Tanaka';

-- 2.4. Отметить напоминание как отправленное
UPDATE reminder
SET is_sent = TRUE
WHERE trigger_at = '2026-06-01 09:00:00';

-- 2.5. Исправить адрес отеля
UPDATE hotel_booking
SET address = 'Континентальный пр-т, 6, Сириус, Краснодарский край'
WHERE hotel_name = 'Сочи Парк Отель';


-- ============================================================
-- РАЗДЕЛ 3. DELETE — удаление данных
-- ============================================================

-- 3.1. Удалить тестовый расход (некорректная запись с нулевой суммой — предварительно добавим её)
INSERT INTO expense (trip_id, amount, category) VALUES (1, 0.00, 'Test');
DELETE FROM expense
WHERE amount = 0.00 AND category = 'Test';

-- 3.2. Удалить напоминание, которое уже давно прошло и было отправлено
DELETE FROM reminder
WHERE is_sent = TRUE
  AND trigger_at < '2026-02-01 00:00:00';

-- 3.3. Удалить активность по описанию (дубликат)
INSERT INTO activity_schedule (location_id, trip_id, start_time, description, address)
VALUES (1, 1, '2026-06-16 20:00:00', 'Дубликат — удалить', 'Champ de Mars, Paris');
DELETE FROM activity_schedule
WHERE description = 'Дубликат — удалить';

-- 3.4. Удалить сегмент маршрута тестовой поездки
INSERT INTO route_segment (trip_id, origin, destination, order_index)
VALUES (1, 'Test Origin', 'Test Destination', 99);
DELETE FROM route_segment
WHERE origin = 'Test Origin' AND destination = 'Test Destination';

-- 3.5. Удалить профиль с некорректным именем (тестовый)
INSERT INTO traveler_profile (user_id, full_name, birth_date)
VALUES (1, 'TEST_DELETE_ME', '2000-01-01');
DELETE FROM traveler_profile
WHERE full_name = 'TEST_DELETE_ME';


-- ============================================================
-- РАЗДЕЛ 4. SELECT с разными условиями и операторами
-- ============================================================

-- 4.1. DISTINCT — уникальные языки пользователей
SELECT DISTINCT language
FROM "User";

-- 4.2. WHERE с AND — поездки со статусом Planned у русскоязычных пользователей
SELECT
    t.title,
    t.status,
    u.language
FROM trip t
INNER JOIN "User" u ON t.user_id = u.id
WHERE t.status = 'Planned'
  AND u.language = 'ru';

-- 4.3. WHERE с OR — пользователи, говорящие по-английски или по-французски
SELECT username, language
FROM "User"
WHERE language = 'en' OR language = 'fr';

-- 4.4. WHERE с NOT — все поездки, кроме завершённых
SELECT title, status
FROM trip
WHERE NOT status = 'Completed';

-- 4.5. IN — пользователи с определёнными языками
SELECT username, language
FROM "User"
WHERE language IN ('ru', 'en', 'de');

-- 4.6. BETWEEN — расходы в диапазоне сумм
SELECT trip_id, amount, category
FROM expense
WHERE amount BETWEEN 100.00 AND 5000.00;

-- 4.7. Работа с датами — напоминания на текущий месяц (май 2026)
SELECT *
FROM reminder
WHERE EXTRACT(MONTH FROM trigger_at) = 5
  AND EXTRACT(YEAR FROM trigger_at) = 2026;

-- 4.8. Работа с датами — возраст путешественников
SELECT
    full_name,
    birth_date,
    DATE_PART('year', AGE(birth_date)) AS age
FROM traveler_profile;

-- 4.9. IS NULL / IS NOT NULL — активности с адресом
SELECT
    id,
    description,
    address
FROM activity_schedule
WHERE address IS NOT NULL;

-- 4.10. AS для таблиц и столбцов — псевдонимы
SELECT
    u.username AS "Пользователь",
    tp.full_name AS "Полное имя",
    tp.birth_date AS "Дата рождения"
FROM "User" AS u
INNER JOIN traveler_profile AS tp ON u.id = tp.user_id;

-- 4.11. Преобразование данных — перевод суммы расхода в рубли (условно 1$ = 90 руб)
SELECT
    category,
    amount AS amount_usd,
    ROUND(amount * 90, 2) AS amount_rub
FROM expense;

-- 4.12. Числовые функции — максимальный и минимальный расходы
SELECT
    MAX(amount) AS max_expense,
    MIN(amount) AS min_expense,
    ROUND(AVG(amount), 2) AS avg_expense
FROM expense;

-- 4.13. Отбор отелей, где check_in после определённой даты
SELECT hotel_name, check_in, check_out
FROM hotel_booking
WHERE check_in > '2026-06-01 00:00:00';

-- 4.14. Длительность проживания в отеле в днях
SELECT
    hotel_name,
    check_in,
    check_out,
    DATE_PART('day', check_out - check_in) AS nights
FROM hotel_booking;

-- 4.15. Билеты с вылетом в определённый промежуток дат
SELECT booking_ref, type, departure_time
FROM transport_ticket
WHERE departure_time BETWEEN '2026-05-01 00:00:00' AND '2026-06-30 23:59:59';


-- ============================================================
-- РАЗДЕЛ 5. LIKE и работа со строками
-- ============================================================

-- 5.1. Поиск поездок, в названии которых есть слово "Paris" или "Париж"
SELECT title, status
FROM trip
WHERE title ILIKE '%paris%' OR title ILIKE '%париж%';

-- 5.2. Поиск отелей, название которых начинается с "Hotel"
SELECT hotel_name, address
FROM hotel_booking
WHERE hotel_name LIKE 'Hotel%';

-- 5.3. Пользователи, username которых оканчивается на цифру
SELECT username, language
FROM "User"
WHERE username ~ '[0-9]$';

-- 5.4. Локации, в названии которых есть "парк" или "Park"
SELECT name, title
FROM location
WHERE name ILIKE '%park%' OR name ILIKE '%парк%';

-- 5.5. Поиск активностей по ключевому слову в описании
SELECT description, address, start_time
FROM activity_schedule
WHERE description ILIKE '%катан%';

-- 5.6. Строковые функции — имена пользователей в верхнем регистре
SELECT
    UPPER(username) AS username_upper,
    language
FROM "User";

-- 5.7. Длина имени путешественника
SELECT
    full_name,
    LENGTH(full_name) AS name_length
FROM traveler_profile
ORDER BY name_length DESC;


-- ============================================================
-- РАЗДЕЛ 6. INSERT INTO ... SELECT (копирование данных)
-- ============================================================

-- Создаём вспомогательные таблицы для копирования

CREATE TABLE IF NOT EXISTS archived_trips (
    id          SERIAL PRIMARY KEY,
    original_id INT,
    title       TEXT,
    status      TEXT,
    archived_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ru_users_snapshot (
    id       SERIAL PRIMARY KEY,
    username TEXT,
    language TEXT
);

-- 6.1. Скопировать завершённые поездки в архив
INSERT INTO archived_trips (original_id, title, status)
SELECT id, title, status
FROM trip
WHERE status = 'Completed';

-- 6.2. Скопировать русскоязычных пользователей в снимок
INSERT INTO ru_users_snapshot (username, language)
SELECT username, language
FROM "User"
WHERE language = 'ru';

-- 6.3. Скопировать напоминания, которые ещё не отправлены
CREATE TABLE IF NOT EXISTS pending_reminders_snapshot (
    id         SERIAL PRIMARY KEY,
    user_id    INT,
    trigger_at TIMESTAMP,
    copied_at  TIMESTAMP DEFAULT NOW()
);

INSERT INTO pending_reminders_snapshot (user_id, trigger_at)
SELECT user_id, trigger_at
FROM reminder
WHERE is_sent = FALSE;


-- ============================================================
-- РАЗДЕЛ 7. JOIN — разные виды объединений
-- ============================================================

-- 7.1. INNER JOIN — пользователи с их профилями
SELECT
    u.username,
    tp.full_name,
    tp.birth_date
FROM "User" u
INNER JOIN traveler_profile tp ON u.id = tp.user_id;

-- 7.2. INNER JOIN — поездки с расходами
SELECT
    t.title,
    e.category,
    e.amount
FROM trip t
INNER JOIN expense e ON t.id = e.trip_id;

-- 7.3. LEFT JOIN — все пользователи, даже без поездок
SELECT
    u.username,
    t.title AS trip_title,
    t.status
FROM "User" u
LEFT JOIN trip t ON u.id = t.user_id;

-- 7.4. LEFT JOIN — все поездки, даже без отелей
SELECT
    t.title,
    hb.hotel_name
FROM trip t
LEFT JOIN hotel_booking hb ON t.id = hb.trip_id;

-- 7.5. RIGHT JOIN — все отели (включая гипотетически без поездок)
SELECT
    t.title AS trip_title,
    hb.hotel_name,
    hb.check_in
FROM trip t
RIGHT JOIN hotel_booking hb ON t.id = hb.trip_id;

-- 7.6. FULL OUTER JOIN — все поездки и все расходы, включая несвязанные
SELECT
    t.title,
    e.category,
    e.amount
FROM trip t
FULL OUTER JOIN expense e ON t.id = e.trip_id;

-- 7.7. CROSS JOIN — все пары категорий расходов и статусов поездок
SELECT DISTINCT
    e.category,
    t.status
FROM expense e
CROSS JOIN trip t
ORDER BY e.category, t.status;

-- 7.8. NATURAL JOIN — пользователи и напоминания (общий столбец user_id неявно)
-- Используем INNER JOIN для явности (NATURAL JOIN не рекомендован)
SELECT
    u.username,
    r.trigger_at,
    r.is_sent
FROM "User" u
INNER JOIN reminder r ON u.id = r.user_id;

-- 7.9. Несколько JOIN — билет + сегмент + поездка + пользователь
SELECT
    u.username,
    tp.full_name,
    tt.booking_ref,
    tt.type,
    tt.departure_time,
    rs.origin,
    rs.destination,
    t.title AS trip_title
FROM transport_ticket tt
INNER JOIN traveler_profile tp ON tt.traveler_id = tp.id
INNER JOIN "User" u ON tp.user_id = u.id
INNER JOIN route_segment rs ON tt.segment_id = rs.id
INNER JOIN trip t ON rs.trip_id = t.id;

-- 7.10. JOIN через многие-ко-многим: traveler_profile <-> transport_ticket <-> route_segment <-> trip
SELECT
    tp.full_name,
    t.title AS trip_title,
    COUNT(tt.id) AS tickets_count
FROM traveler_profile tp
INNER JOIN transport_ticket tt ON tp.id = tt.traveler_id
INNER JOIN route_segment rs ON tt.segment_id = rs.id
INNER JOIN trip t ON rs.trip_id = t.id
GROUP BY tp.full_name, t.title;

-- 7.11. JOIN — активности с локациями и поездками
SELECT
    t.title AS trip_title,
    l.name AS location_name,
    a.start_time,
    a.description
FROM activity_schedule a
INNER JOIN location l ON a.location_id = l.id
INNER JOIN trip t ON a.trip_id = t.id
ORDER BY a.start_time;

-- 7.12. LEFT JOIN — поездки без активностей
SELECT
    t.title,
    t.status
FROM trip t
LEFT JOIN activity_schedule a ON t.id = a.trip_id
WHERE a.id IS NULL;

-- 7.13. LEFT JOIN — пользователи без профиля
SELECT
    u.username,
    u.language
FROM "User" u
LEFT JOIN traveler_profile tp ON u.id = tp.user_id
WHERE tp.id IS NULL;

-- 7.14. Многотабличный JOIN — полная информация о поездке (пользователь, отель, расходы)
SELECT
    u.username,
    t.title AS trip,
    hb.hotel_name,
    SUM(e.amount) AS total_expenses
FROM "User" u
INNER JOIN trip t ON u.id = t.user_id
LEFT JOIN hotel_booking hb ON t.id = hb.trip_id
LEFT JOIN expense e ON t.id = e.trip_id
GROUP BY u.username, t.title, hb.hotel_name;

-- 7.15. JOIN — все сегменты маршрутов с их поездками и пользователями
SELECT
    u.username,
    t.title AS trip_title,
    rs.order_index,
    rs.origin,
    rs.destination
FROM route_segment rs
INNER JOIN trip t ON rs.trip_id = t.id
INNER JOIN "User" u ON t.user_id = u.id
ORDER BY t.id, rs.order_index;


-- ============================================================
-- РАЗДЕЛ 8. GROUP BY, HAVING, ORDER BY, агрегатные функции
-- ============================================================

-- 8.1. Количество поездок по статусам
SELECT
    status,
    COUNT(*) AS trips_count
FROM trip
GROUP BY status;

-- 8.2. Суммарные расходы по категориям
SELECT
    category,
    SUM(amount) AS total_amount,
    COUNT(*) AS records
FROM expense
GROUP BY category
ORDER BY total_amount DESC;

-- 8.3. Средние расходы по поездкам
SELECT
    trip_id,
    ROUND(AVG(amount), 2) AS avg_expense
FROM expense
GROUP BY trip_id
ORDER BY avg_expense DESC;

-- 8.4. Количество пользователей по языкам
SELECT
    language,
    COUNT(*) AS users_count
FROM "User"
GROUP BY language
ORDER BY users_count DESC;

-- 8.5. Поездки с суммарными расходами более 1000
SELECT
    t.title,
    SUM(e.amount) AS total
FROM trip t
INNER JOIN expense e ON t.id = e.trip_id
GROUP BY t.title
HAVING SUM(e.amount) > 1000;

-- 8.6. Максимальная сумма расхода по каждой поездке
SELECT
    trip_id,
    MAX(amount) AS max_expense,
    MIN(amount) AS min_expense
FROM expense
GROUP BY trip_id;

-- 8.7. Топ-3 самых дорогих поездок
SELECT
    t.title,
    SUM(e.amount) AS total_expenses
FROM trip t
INNER JOIN expense e ON t.id = e.trip_id
GROUP BY t.title
ORDER BY total_expenses DESC
LIMIT 3;

-- 8.8. Количество активностей в каждой поездке
SELECT
    t.title,
    COUNT(a.id) AS activities_count
FROM trip t
LEFT JOIN activity_schedule a ON t.id = a.trip_id
GROUP BY t.title
ORDER BY activities_count DESC;

-- 8.9. Количество отелей по поездкам (только поездки с отелями)
SELECT
    t.title,
    COUNT(hb.id) AS hotels_count
FROM trip t
INNER JOIN hotel_booking hb ON t.id = hb.trip_id
GROUP BY t.title
HAVING COUNT(hb.id) >= 1;

-- 8.10. Количество билетов по типу транспорта
SELECT
    type,
    COUNT(*) AS tickets_count
FROM transport_ticket
GROUP BY type
ORDER BY tickets_count DESC;

-- 8.11. Число сегментов маршрута по поездкам
SELECT
    trip_id,
    COUNT(*) AS segments_count
FROM route_segment
GROUP BY trip_id
ORDER BY segments_count DESC;

-- 8.12. Напоминания: количество отправленных vs неотправленных
SELECT
    is_sent,
    COUNT(*) AS count
FROM reminder
GROUP BY is_sent;

-- 8.13. Самый ранний и самый поздний вылет по типу транспорта
SELECT
    type,
    MIN(departure_time) AS earliest,
    MAX(departure_time) AS latest
FROM transport_ticket
GROUP BY type;

-- 8.14. Пользователи с более чем одной поездкой (HAVING)
SELECT
    u.username,
    COUNT(t.id) AS trips_count
FROM "User" u
INNER JOIN trip t ON u.id = t.user_id
GROUP BY u.username
HAVING COUNT(t.id) > 1;

-- 8.15. Общая длительность проживания в отелях по поездкам
SELECT
    t.title,
    SUM(DATE_PART('day', hb.check_out - hb.check_in)) AS total_nights
FROM trip t
INNER JOIN hotel_booking hb ON t.id = hb.trip_id
GROUP BY t.title
ORDER BY total_nights DESC;


-- ============================================================
-- РАЗДЕЛ 9. UNION, EXCEPT, INTERSECT
-- ============================================================

-- 9.1. UNION — объединение всех городов отправления и прибытия
SELECT origin AS city FROM route_segment
UNION
SELECT destination AS city FROM route_segment
ORDER BY city;

-- 9.2. UNION ALL — все адреса отелей и активностей вместе
SELECT address, 'hotel' AS source FROM hotel_booking
UNION ALL
SELECT address, 'activity' AS source FROM activity_schedule;

-- 9.3. EXCEPT — поездки без записей расходов
SELECT id, title FROM trip
EXCEPT
SELECT DISTINCT t.id, t.title
FROM trip t
INNER JOIN expense e ON t.id = e.trip_id;

-- 9.4. INTERSECT — trip_id, у которых есть и отель, и активность
SELECT trip_id FROM hotel_booking
INTERSECT
SELECT trip_id FROM activity_schedule;

-- 9.5. UNION — имена из профилей и username пользователей в одном списке
SELECT full_name AS name, 'traveler_profile' AS source FROM traveler_profile
UNION
SELECT username AS name, 'user' AS source FROM "User"
ORDER BY source, name;


-- ============================================================
-- РАЗДЕЛ 10. Вложенные SELECT, ALL, ANY, EXISTS
-- ============================================================

-- 10.1. Поездки, у которых суммарные расходы выше среднего по всем поездкам
SELECT t.title, SUM(e.amount) AS total
FROM trip t
INNER JOIN expense e ON t.id = e.trip_id
GROUP BY t.title
HAVING SUM(e.amount) > (
    SELECT AVG(sub.total)
    FROM (
        SELECT SUM(amount) AS total
        FROM expense
        GROUP BY trip_id
    ) sub
);

-- 10.2. EXISTS — пользователи, у которых есть хотя бы одна активная поездка
SELECT u.username
FROM "User" u
WHERE EXISTS (
    SELECT 1
    FROM trip t
    WHERE t.user_id = u.id
      AND t.status = 'Active'
);

-- 10.3. NOT EXISTS — пользователи без поездок
SELECT u.username
FROM "User" u
WHERE NOT EXISTS (
    SELECT 1
    FROM trip t
    WHERE t.user_id = u.id
);

-- 10.4. ANY — расходы, превышающие хотя бы один расход в категории Food
SELECT category, amount
FROM expense
WHERE amount > ANY (
    SELECT amount FROM expense WHERE category = 'Food'
);

-- 10.5. ALL — расходы, превышающие все расходы категории Food
SELECT category, amount
FROM expense
WHERE amount > ALL (
    SELECT amount FROM expense WHERE category = 'Food'
);

-- 10.6. Вложенный SELECT с GROUP BY — пользователи с числом поездок больше среднего
SELECT u.username, COUNT(t.id) AS trips_count
FROM "User" u
INNER JOIN trip t ON u.id = t.user_id
GROUP BY u.username
HAVING COUNT(t.id) > (
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(id) AS cnt
        FROM trip
        GROUP BY user_id
    ) sub
);


-- ============================================================
-- РАЗДЕЛ 11. STRING_AGG и другие разнообразные функции
-- ============================================================

-- 11.1. STRING_AGG — список всех категорий расходов по поездке
SELECT
    t.title,
    STRING_AGG(DISTINCT e.category, ', ' ORDER BY e.category) AS categories
FROM trip t
INNER JOIN expense e ON t.id = e.trip_id
GROUP BY t.title;

-- 11.2. STRING_AGG — список городов маршрута в порядке следования
SELECT
    t.title,
    STRING_AGG(rs.origin || ' → ' || rs.destination, ' | ' ORDER BY rs.order_index) AS route
FROM trip t
INNER JOIN route_segment rs ON t.id = rs.trip_id
GROUP BY t.title;

-- 11.3. ARRAY_AGG — собрать все booking_ref одного типа в массив
SELECT
    type,
    ARRAY_AGG(booking_ref ORDER BY departure_time) AS refs
FROM transport_ticket
GROUP BY type;


-- ============================================================
-- РАЗДЕЛ 12. Запросы с WITH (CTE)
-- ============================================================

-- 12.1. CTE — топ пользователей по числу поездок
WITH user_trip_count AS (
    SELECT
        u.username,
        COUNT(t.id) AS trips_count
    FROM "User" u
    LEFT JOIN trip t ON u.id = t.user_id
    GROUP BY u.username
)
SELECT *
FROM user_trip_count
ORDER BY trips_count DESC;

-- 12.2. CTE — расходы с пометкой «дорого»/«дёшево» относительно среднего
WITH avg_expense AS (
    SELECT AVG(amount) AS avg_val FROM expense
)
SELECT
    e.category,
    e.amount,
    CASE
        WHEN e.amount > a.avg_val THEN 'дорого'
        ELSE 'дёшево'
    END AS price_label
FROM expense e
CROSS JOIN avg_expense a;

-- 12.3. CTE — поездки с их общими расходами и длительностью отеля
WITH trip_expenses AS (
    SELECT trip_id, SUM(amount) AS total_expenses
    FROM expense
    GROUP BY trip_id
),
trip_hotel_nights AS (
    SELECT trip_id, SUM(DATE_PART('day', check_out - check_in)) AS total_nights
    FROM hotel_booking
    GROUP BY trip_id
)
SELECT
    t.title,
    COALESCE(te.total_expenses, 0) AS expenses,
    COALESCE(thn.total_nights, 0) AS hotel_nights
FROM trip t
LEFT JOIN trip_expenses te ON t.id = te.trip_id
LEFT JOIN trip_hotel_nights thn ON t.id = thn.trip_id;


-- ============================================================
-- РАЗДЕЛ 13. Строковые, временные и арифметические функции
-- ============================================================

-- 13.1. Форматирование даты отъезда (русский формат DD.MM.YYYY)
SELECT
    hotel_name,
    TO_CHAR(check_in, 'DD.MM.YYYY HH24:MI') AS check_in_formatted,
    TO_CHAR(check_out, 'DD.MM.YYYY') AS check_out_formatted
FROM hotel_booking;

-- 13.2. Возраст путешественников на основе даты рождения
SELECT
    full_name,
    birth_date,
    AGE(NOW(), birth_date::TIMESTAMP) AS exact_age
FROM traveler_profile;

-- 13.3. Извлечение компонентов даты из напоминаний
SELECT
    id,
    trigger_at,
    EXTRACT(YEAR FROM trigger_at) AS year,
    EXTRACT(MONTH FROM trigger_at) AS month,
    EXTRACT(DAY FROM trigger_at) AS day,
    EXTRACT(HOUR FROM trigger_at) AS hour
FROM reminder;

-- 13.4. Конкатенация строк — полное описание маршрута
SELECT
    CONCAT(origin, ' → ', destination) AS route_description,
    order_index
FROM route_segment
ORDER BY trip_id, order_index;

-- 13.5. LOWER / UPPER / TRIM — нормализация данных
SELECT
    TRIM(hotel_name) AS hotel_trimmed,
    LOWER(hotel_name) AS hotel_lower,
    UPPER(hotel_name) AS hotel_upper
FROM hotel_booking;

-- 13.6. Арифметика — стоимость одной ночи в отеле по расходу на проживание
SELECT
    e.trip_id,
    e.amount AS accommodation_cost,
    DATE_PART('day', hb.check_out - hb.check_in) AS nights,
    ROUND(
        e.amount / NULLIF(DATE_PART('day', hb.check_out - hb.check_in), 0), 2
    ) AS cost_per_night
FROM expense e
INNER JOIN hotel_booking hb ON e.trip_id = hb.trip_id
WHERE e.category = 'Accommodation';

-- 13.7. Временной интервал до вылета от текущей даты
SELECT
    booking_ref,
    departure_time,
    departure_time - NOW() AS time_until_departure
FROM transport_ticket
WHERE departure_time > NOW()
ORDER BY departure_time ASC;


-- ============================================================
-- РАЗДЕЛ 14. СЛОЖНЫЕ ЗАПРОСЫ (JOIN + GROUP BY + WHERE + ORDER BY + LIMIT)
-- ============================================================

-- 14.1. Полная сводка по поездке: пользователь, отель, активности, расходы
SELECT
    u.username,
    tp.full_name,
    t.title AS trip,
    t.status,
    hb.hotel_name,
    COUNT(DISTINCT a.id) AS activities_count,
    COALESCE(SUM(e.amount), 0) AS total_expenses
FROM "User" u
INNER JOIN traveler_profile tp ON u.id = tp.user_id
INNER JOIN trip t ON u.id = t.user_id
LEFT JOIN hotel_booking hb ON t.id = hb.trip_id
LEFT JOIN activity_schedule a ON t.id = a.trip_id
LEFT JOIN expense e ON t.id = e.trip_id
GROUP BY u.username, tp.full_name, t.title, t.status, hb.hotel_name
ORDER BY total_expenses DESC;

-- 14.2. Рейтинг локаций по числу посещений в активностях
SELECT
    l.name AS location,
    l.title AS type,
    COUNT(a.id) AS visit_count
FROM location l
INNER JOIN activity_schedule a ON l.id = a.location_id
GROUP BY l.name, l.title
ORDER BY visit_count DESC
LIMIT 5;

-- 14.3. Путешественники с наибольшими суммарными расходами по всем поездкам
SELECT
    tp.full_name,
    u.username,
    SUM(e.amount) AS total_spent
FROM traveler_profile tp
INNER JOIN "User" u ON tp.user_id = u.id
INNER JOIN trip t ON u.id = t.user_id
INNER JOIN expense e ON t.id = e.trip_id
GROUP BY tp.full_name, u.username
ORDER BY total_spent DESC
LIMIT 3;

-- 14.4. Активные поездки с их маршрутами и ближайшей активностью
SELECT
    u.username,
    t.title,
    rs.origin,
    rs.destination,
    MIN(a.start_time) AS nearest_activity
FROM trip t
INNER JOIN "User" u ON t.user_id = u.id
INNER JOIN route_segment rs ON t.id = rs.trip_id
LEFT JOIN activity_schedule a ON t.id = a.trip_id
WHERE t.status = 'Active'
GROUP BY u.username, t.title, rs.origin, rs.destination
ORDER BY nearest_activity ASC;

-- 14.5. Пользователи с языком 'ru' и суммарные расходы их поездок
SELECT
    u.username,
    u.language,
    t.title,
    SUM(e.amount) AS expenses
FROM "User" u
INNER JOIN trip t ON u.id = t.user_id
INNER JOIN expense e ON t.id = e.trip_id
WHERE u.language = 'ru'
GROUP BY u.username, u.language, t.title
ORDER BY expenses DESC;

-- 14.6. Билеты с полной информацией: тип, маршрут, поездка, путешественник
SELECT
    tp.full_name,
    tt.type AS ticket_type,
    tt.booking_ref,
    tt.departure_time,
    rs.origin,
    rs.destination,
    t.title AS trip_title,
    t.status
FROM transport_ticket tt
INNER JOIN traveler_profile tp ON tt.traveler_id = tp.id
INNER JOIN route_segment rs ON tt.segment_id = rs.id
INNER JOIN trip t ON rs.trip_id = t.id
WHERE t.status IN ('Planned', 'Active')
ORDER BY tt.departure_time ASC;

-- 14.7. Сводка по категориям расходов: только категории с общей суммой > 500
SELECT
    e.category,
    COUNT(*) AS records,
    SUM(e.amount) AS total,
    ROUND(AVG(e.amount), 2) AS avg_amount,
    MAX(e.amount) AS max_amount
FROM expense e
INNER JOIN trip t ON e.trip_id = t.id
GROUP BY e.category
HAVING SUM(e.amount) > 500
ORDER BY total DESC;
