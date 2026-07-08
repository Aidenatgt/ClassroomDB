CREATE EXTENSION IF NOT EXISTS "pg_trgm";

CREATE OR REPLACE FUNCTION get_room_id (input_building_id integer, input_room_alias text)
    RETURNS integer
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        room_id
    FROM
        room_aliases
    WHERE
        building_id = input_building_id
        AND alias = lower(trim(input_room_alias));
$$;

CREATE OR REPLACE FUNCTION find_room_id_fuzzy (input_building_id integer, input_number text)
    RETURNS integer
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        room_id
    FROM (
        SELECT
            id AS room_id,
            lower(trim(room_number)) AS search_number,
            similarity (lower(trim(room_number)), lower(trim(input_number))) AS score
        FROM
            rooms
        WHERE
            building_id = input_building_id
        UNION ALL
        SELECT
            room_id,
            lower(trim(alias)) AS search_number,
            similarity (lower(trim(alias)), lower(trim(input_number))) AS score
        FROM
            room_aliases
        WHERE
            building_id = input_building_id) matches
WHERE
    score > 0.3
    OR search_number = lower(trim(input_number))
ORDER BY
    (search_number = lower(trim(input_number))) DESC,
    score DESC
LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION get_room_numbers (input_building_id integer)
    RETURNS TABLE (
        id integer,
        name text)
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        rooms.id,
        rooms.room_number
    FROM
        rooms
    WHERE
        rooms.building_id = input_building_id
$$;

CREATE OR REPLACE FUNCTION add_room_alias (input_building_id integer, input_room_id integer, input_alias text)
    RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO room_aliases (building_id, room_id, alias)
        VALUES (input_building_id, input_room_id, lower(trim(input_alias)))
    ON CONFLICT (building_id, alias)
        DO NOTHING;
    RETURN FOUND;
END;
$$;

CREATE OR REPLACE FUNCTION add_room (input_building_id integer, input_room_number text, input_room_type_id integer)
    RETURNS integer
    LANGUAGE sql
    AS $$
    WITH inserted_room AS (
INSERT INTO rooms (building_id, room_number, room_type_id)
            VALUES (input_building_id, trim(input_room_number), input_room_type_id)
        ON CONFLICT (building_id, room_number)
            DO UPDATE SET
                room_type_id = EXCLUDED.room_type_id
            RETURNING
                id, room_number
),
inserted_alias AS (
    SELECT
        add_room_alias (input_building_id, id, room_number)
    FROM
        inserted_room
)
SELECT
    id
FROM
    inserted_room;
$$;

CREATE OR REPLACE FUNCTION get_room_types ()
    RETURNS TABLE (
        id integer,
        name text)
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        room_types.id,
        room_types.name
    FROM
        room_types
$$;

CREATE OR REPLACE FUNCTION add_room_type (input_name text)
    RETURNS integer
    LANGUAGE sql
    AS $$
    INSERT INTO room_types (name)
        VALUES (trim(input_name))
    ON CONFLICT (name)
        DO UPDATE SET
            name = EXCLUDED.name
        RETURNING
            id;
$$;

CREATE OR REPLACE FUNCTION get_rooms_of_type (input_type_id integer, input_building_id integer)
    RETURNS TABLE (
        id integer,
        room_number text)
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        rooms.id,
        rooms.room_number
    FROM
        rooms
    WHERE
        room_type_id = input_type_id
        AND building_id = input_building_id
    ORDER BY
        room_number
$$;

