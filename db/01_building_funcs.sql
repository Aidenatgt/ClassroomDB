CREATE EXTENSION IF NOT EXISTS "pg_trgm";

CREATE OR REPLACE FUNCTION get_building_id (building_alias text)
    RETURNS integer
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        building_id
    FROM
        building_aliases
    WHERE
        alias = lower(trim(building_alias));
$$;

CREATE OR REPLACE FUNCTION find_building_id_fuzzy (input_name text)
    RETURNS integer
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        building_id
    FROM (
        SELECT
            id AS building_id,
            lower(trim(name)) AS search_name,
            similarity (lower(trim(name)), lower(trim(input_name))) AS score
        FROM
            buildings
        UNION ALL
        SELECT
            building_id,
            lower(trim(alias)) AS search_name,
            similarity (lower(trim(alias)), lower(trim(input_name))) AS score
        FROM
            building_aliases) matches
WHERE
    score > 0.3
ORDER BY
    score DESC
LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION get_building_names ()
    RETURNS TABLE (
        id integer,
        name text)
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        buildings.id,
        buildings.name
    FROM
        buildings
$$;

CREATE OR REPLACE FUNCTION add_building (input_name text)
    RETURNS integer
    LANGUAGE sql
    AS $$
    WITH inserted_building AS (
INSERT INTO buildings (name)
            VALUES (trim(input_name))
        ON CONFLICT (name)
            DO UPDATE SET
                name = EXCLUDED.name
            RETURNING
                id, name
),
inserted_alias AS (
INSERT INTO building_aliases (alias, building_id)
    SELECT
        lower(trim(name)),
        id FROM inserted_building
    ON CONFLICT (alias)
        DO NOTHING
)
SELECT
    id
FROM
    inserted_building;
$$;

CREATE OR REPLACE FUNCTION add_building_alias (input_building_id integer, input_alias text)
    RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO building_aliases (alias, building_id)
        VALUES (lower(trim(input_alias)), input_building_id)
    ON CONFLICT (alias)
        DO NOTHING;
    RETURN FOUND;
END;
$$;

SELECT
    add_building ('Haley Center');

SELECT
    add_building_alias (get_building_id ('Haley Center'), 'Haley');

