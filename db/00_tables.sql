CREATE TABLE users (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    phone_number text,
    email text
);

CREATE TABLE technicians (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    phone_number text,
    email text
);

CREATE TABLE buildings (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE building_aliases (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    building_id integer NOT NULL REFERENCES buildings (id) ON DELETE CASCADE,
    alias text NOT NULL UNIQUE
);

CREATE TABLE room_types (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

INSERT INTO room_types (name)
VALUES
    ('Class'),
    ('Auditorium'),
    ('Office'),
    ('Common')
ON CONFLICT (name)
    DO NOTHING;

CREATE TABLE rooms (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type_id integer NOT NULL REFERENCES room_types (id) ON DELETE CASCADE,
    room_number text NOT NULL,
    building_id integer NOT NULL REFERENCES buildings (id) ON DELETE CASCADE,
    closet_id integer REFERENCES rooms (id) ON DELETE SET NULL,
    UNIQUE (building_id, room_number)
);

CREATE TABLE room_aliases (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id integer NOT NULL REFERENCES rooms (id) ON DELETE CASCADE,
    alias text NOT NULL UNIQUE
);

CREATE TABLE component_types (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

INSERT INTO component_types (name)
VALUES
    ('Control Panel'),
    ('Projector'),
    ('TV'),
    ('Encoder'),
    ('Decoder'),
    ('Switcher'),
    ('Control Processor'),
    ('Transceiver'),
    ('Amplifiers'),
    ('DTP Rx'),
    ('DTP Tx'),
    ('Microphone')
ON CONFLICT (name)
    DO NOTHING;

CREATE TABLE models (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    manufacturer text NOT NULL,
    model_name text NOT NULL,
    notes text,
    UNIQUE (manufacturer, model_name)
);

CREATE TABLE components (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id integer NOT NULL REFERENCES rooms (id) ON DELETE CASCADE,
    type_id integer NOT NULL REFERENCES component_types (id) ON DELETE CASCADE,
    functional bool NOT NULL DEFAULT TRUE,
    serial_number text,
    mac_address text,
    device_number text,
    stream_number text,
    ip_address text,
    port text,
    model_id integer REFERENCES models (id) ON DELETE CASCADE,
    UNIQUE (room_id, type_id, serial_number)
);

CREATE TABLE cleanings (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id integer NOT NULL REFERENCES rooms (id),
    time timestamptz NOT NULL DEFAULT now(),
    technician_id integer NOT NULL REFERENCES technicians (id),
    notes text
);

CREATE TABLE test_types (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

INSERT INTO test_types (name)
VALUES
    ('Monitors'),
    ('PC Input'),
    ('Laptop Input'),
    ('Doc Cam Input'),
    ('Solstice Input'),
    ('Audio'),
    ('Cameras')
ON CONFLICT (name)
    DO NOTHING;

CREATE TABLE tests (
    cleaning_id integer NOT NULL REFERENCES cleanings (id) ON DELETE CASCADE,
    test_type_id integer NOT NULL REFERENCES test_types (id),
    working bool NOT NULL,
    PRIMARY KEY (cleaning_id, test_type_id)
);

CREATE TABLE tickets (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id integer NOT NULL REFERENCES rooms (id) ON DELETE CASCADE,
    technician_id integer NOT NULL REFERENCES technicians (id) ON DELETE CASCADE,
    time timestamptz NOT NULL DEFAULT now(),
    user_id integer NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    message text NOT NULL
);

CREATE TABLE solutions (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    component_id integer NOT NULL REFERENCES components (id) ON DELETE CASCADE,
    ticket_id integer NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
    problem text NOT NULL,
    solution text NOT NULL
);

