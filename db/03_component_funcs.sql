CREATE OR REPLACE FUNCTION add_model (input_type_id integer, input_manufacturer text, input_model_name text)
    RETURNS integer
    LANGUAGE sql
    AS $$
    INSERT INTO models (type_id, manufacturer, model_name)
        VALUES (input_type_id, trim(input_manufacturer), trim(input_model_name))
    ON CONFLICT (type_id, manufacturer, model_name)
        DO UPDATE SET
            model_name = EXCLUDED.model_name
        RETURNING
            id;
$$;

CREATE OR REPLACE FUNCTION get_model (input_model_id integer)
    RETURNS TABLE (
        id integer,
        type_id integer,
        manufacturer text,
        model_name text)
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        models.id,
        models.type_id,
        models.manufacturer,
        models.model_name
    FROM
        models
    WHERE
        models.id = input_model_id;
$$;

CREATE OR REPLACE FUNCTION get_models_of_type (input_type_id integer)
    RETURNS TABLE (
        id integer,
        manufacturer text,
        model_name text)
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        models.id,
        models.manufacturer,
        models.model_name
    FROM
        models
    WHERE
        models.type_id = input_type_id;
    ORDER BY
        models.manufacturer,
        models.model_name;
$$;

CREATE OR REPLACE FUNCTION get_component_types ()
    RETURNS TABLE (
        id integer,
        name text)
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        component_types.id,
        component_types.name
    FROM
        component_types;
    ORDER BY
        component_types.name;
$$;

CREATE OR REPLACE FUNCTION add_component_type (input_name text)
    RETURNS integer
    LANGUAGE sql
    AS $$
    INSERT INTO component_types (name)
        VALUES (trim(input_name))
    ON CONFLICT (name)
        DO UPDATE SET
            name = EXCLUDED.name
        RETURNING
            id;
$$;

CREATE OR REPLACE FUNCTION add_component (input_model_id integer, input_room_id integer, input_serial_number text)
    RETURNS integer
    LANGUAGE sql
    AS $$
    INSERT INTO components (model_id, room_id, serial_number)
        VALUES (input_model_id, input_room_id, trim(input_serial_number))
    ON CONFLICT (model_id, room_id, serial_number)
        DO UPDATE SET
            serial_number = EXCLUDED.serial_number
        RETURNING
            id;
$$;

CREATE OR REPLACE FUNCTION get_components_of_room (input_room_id integer)
    RETURNS TABLE (
        id integer,
        model_id integer,
        serial_number text,
        ip_address text,
        functional bool,
        mac_address text,
        device_number text,
        stream_number text,
        port text,
        notes text)
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        components.id,
        components.model_id,
        components.serial_number,
        components.ip_address,
        components.functional,
        components.mac_address,
        components.device_number,
        components.stream_number,
        components.port,
        components.notes
    FROM
        components
    WHERE
        components.room_id = input_room_id;
$$;

CREATE OR REPLACE FUNCTION set_component_ip (input_component_id integer, input_ip_address text)
    RETURNS void
    LANGUAGE sql
    AS $$
    UPDATE
        components
    SET
        ip_address = NULLIF (trim(input_ip_address), '')
    WHERE
        id = input_component_id;
$$;

CREATE OR REPLACE FUNCTION set_component_functional (input_component_id integer, input_functional bool)
    RETURNS void
    LANGUAGE sql
    AS $$
    UPDATE
        components
    SET
        functional = input_functional
    WHERE
        id = input_component_id;
$$;

CREATE OR REPLACE FUNCTION set_component_mac_address (input_component_id integer, input_mac_address text)
    RETURNS void
    LANGUAGE sql
    AS $$
    UPDATE
        components
    SET
        mac_address = NULLIF (trim(input_mac_address), '')
    WHERE
        id = input_component_id;
$$;

CREATE OR REPLACE FUNCTION set_component_device_number (input_component_id integer, input_device_number text)
    RETURNS void
    LANGUAGE sql
    AS $$
    UPDATE
        components
    SET
        device_number = NULLIF (trim(input_device_number), '')
    WHERE
        id = input_component_id;
$$;

CREATE OR REPLACE FUNCTION set_component_stream_number (input_component_id integer, input_stream_number text)
    RETURNS void
    LANGUAGE sql
    AS $$
    UPDATE
        components
    SET
        stream_number = NULLIF (trim(input_stream_number), '')
    WHERE
        id = input_component_id;
$$;

CREATE OR REPLACE FUNCTION set_component_port_number (input_component_id integer, input_port_number text)
    RETURNS void
    LANGUAGE sql
    AS $$
    UPDATE
        components
    SET
        port = NULLIF (trim(input_port_number), '')
    WHERE
        id = input_component_id;
$$;

CREATE OR REPLACE FUNCTION set_component_notes (input_component_id integer, input_notes text)
    RETURNS void
    LANGUAGE sql
    AS $$
    UPDATE
        components
    SET
        notes = NULLIF (trim(input_notes), '')
    WHERE
        id = input_component_id;
$$;

