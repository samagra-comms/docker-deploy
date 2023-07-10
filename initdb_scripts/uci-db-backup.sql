--
-- PostgreSQL database dump
--

-- Dumped from database version 12.14 (Debian 12.14-1.pgdg110+1)
-- Dumped by pg_dump version 12.14 (Debian 12.14-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: postgresql
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO postgresql;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: BotStatus; Type: TYPE; Schema: public; Owner: postgresql
--

CREATE TYPE public."BotStatus" AS ENUM (
    'ENABLED',
    'DISABLED',
    'DRAFT'
);


ALTER TYPE public."BotStatus" OWNER TO postgresql;

--
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: postgresql
--

CREATE FUNCTION hdb_catalog.gen_hasura_uuid() RETURNS uuid
    LANGUAGE sql
    AS $$select gen_random_uuid()$$;


ALTER FUNCTION hdb_catalog.gen_hasura_uuid() OWNER TO postgresql;

--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: public; Owner: postgresql
--

CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;


ALTER FUNCTION public.set_current_timestamp_updated_at() OWNER TO postgresql;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: postgresql
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


ALTER TABLE hdb_catalog.hdb_action_log OWNER TO postgresql;

--
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgresql
--

CREATE TABLE hdb_catalog.hdb_cron_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_cron_event_invocation_logs OWNER TO postgresql;

--
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: postgresql
--

CREATE TABLE hdb_catalog.hdb_cron_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    trigger_name text NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_cron_events OWNER TO postgresql;

--
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: postgresql
--

CREATE TABLE hdb_catalog.hdb_metadata (
    id integer NOT NULL,
    metadata json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL
);


ALTER TABLE hdb_catalog.hdb_metadata OWNER TO postgresql;

--
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgresql
--

CREATE TABLE hdb_catalog.hdb_scheduled_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_scheduled_event_invocation_logs OWNER TO postgresql;

--
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: postgresql
--

CREATE TABLE hdb_catalog.hdb_scheduled_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    webhook_conf json NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    retry_conf json,
    payload json,
    header_conf json,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    comment text,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_scheduled_events OWNER TO postgresql;

--
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: postgresql
--

CREATE TABLE hdb_catalog.hdb_schema_notifications (
    id integer NOT NULL,
    notification json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL,
    instance_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hdb_schema_notifications_id_check CHECK ((id = 1))
);


ALTER TABLE hdb_catalog.hdb_schema_notifications OWNER TO postgresql;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: postgresql
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO postgresql;

--
-- Name: migration_settings; Type: TABLE; Schema: hdb_catalog; Owner: postgresql
--

CREATE TABLE hdb_catalog.migration_settings (
    setting text NOT NULL,
    value text NOT NULL
);


ALTER TABLE hdb_catalog.migration_settings OWNER TO postgresql;

--
-- Name: schema_migrations; Type: TABLE; Schema: hdb_catalog; Owner: postgresql
--

CREATE TABLE hdb_catalog.schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL
);


ALTER TABLE hdb_catalog.schema_migrations OWNER TO postgresql;

--
-- Name: Adapter; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."Adapter" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    channel text NOT NULL,
    provider text NOT NULL,
    config jsonb NOT NULL,
    name text
);


ALTER TABLE public."Adapter" OWNER TO postgresql;

--
-- Name: Board; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."Board" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Board" OWNER TO postgresql;

--
-- Name: Board_id_seq; Type: SEQUENCE; Schema: public; Owner: postgresql
--

CREATE SEQUENCE public."Board_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Board_id_seq" OWNER TO postgresql;

--
-- Name: Board_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgresql
--

ALTER SEQUENCE public."Board_id_seq" OWNED BY public."Board".id;


--
-- Name: Bot; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."Bot" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    "startingMessage" text NOT NULL,
    "ownerID" text,
    "ownerOrgID" text,
    purpose text,
    description text,
    "startDate" date,
    "endDate" date,
    status public."BotStatus" DEFAULT 'DRAFT'::public."BotStatus" NOT NULL,
    tags text[]
);


ALTER TABLE public."Bot" OWNER TO postgresql;

--
-- Name: ConversationLogic; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."ConversationLogic" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    description text,
    "adapterId" uuid NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."ConversationLogic" OWNER TO postgresql;

--
-- Name: Service; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."Service" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    type text NOT NULL,
    config jsonb,
    name text
);


ALTER TABLE public."Service" OWNER TO postgresql;

--
-- Name: Transformer; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."Transformer" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    tags text[],
    config jsonb NOT NULL,
    "serviceId" uuid NOT NULL
);


ALTER TABLE public."Transformer" OWNER TO postgresql;

--
-- Name: TransformerConfig; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."TransformerConfig" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "transformerId" uuid NOT NULL,
    meta jsonb NOT NULL,
    "conversationLogicId" uuid
);


ALTER TABLE public."TransformerConfig" OWNER TO postgresql;

--
-- Name: UserSegment; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."UserSegment" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    description text,
    count integer DEFAULT 0 NOT NULL,
    category text,
    "allServiceID" uuid,
    "byPhoneServiceID" uuid,
    "byIDServiceID" uuid,
    "botId" uuid
);


ALTER TABLE public."UserSegment" OWNER TO postgresql;

--
-- Name: _BotToConversationLogic; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."_BotToConversationLogic" (
    "A" uuid NOT NULL,
    "B" uuid NOT NULL
);


ALTER TABLE public."_BotToConversationLogic" OWNER TO postgresql;

--
-- Name: _BotToUserSegment; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."_BotToUserSegment" (
    "A" uuid NOT NULL,
    "B" uuid NOT NULL
);


ALTER TABLE public."_BotToUserSegment" OWNER TO postgresql;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgresql;

--
-- Name: adapter; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.adapter (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    channel text NOT NULL,
    provider text NOT NULL,
    config jsonb NOT NULL,
    name text NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.adapter OWNER TO postgresql;

--
-- Name: board; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.board (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.board OWNER TO postgresql;

--
-- Name: boards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgresql
--

CREATE SEQUENCE public.boards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.boards_id_seq OWNER TO postgresql;

--
-- Name: boards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgresql
--

ALTER SEQUENCE public.boards_id_seq OWNED BY public.board.id;


--
-- Name: bot; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.bot (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    "startingMessage" text NOT NULL,
    users text[] NOT NULL,
    "logicIDs" text[] NOT NULL,
    owners text[],
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    status text,
    description text,
    "startDate" date,
    "endDate" date,
    purpose text,
    "ownerOrgID" text,
    "ownerID" text
);


ALTER TABLE public.bot OWNER TO postgresql;

--
-- Name: conversationLogic; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."conversationLogic" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    transformers jsonb NOT NULL,
    adapter uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    description text,
    "ownerOrgID" text,
    "ownerID" text
);


ALTER TABLE public."conversationLogic" OWNER TO postgresql;

--
-- Name: organisation; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.organisation (
    state text,
    district text,
    block text,
    school text,
    cluster text,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    school_code text
);


ALTER TABLE public.organisation OWNER TO postgresql;

--
-- Name: pgbench_accounts; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.pgbench_accounts (
    aid integer NOT NULL,
    bid integer,
    abalance integer,
    filler character(84)
)
WITH (fillfactor='100');


ALTER TABLE public.pgbench_accounts OWNER TO postgresql;

--
-- Name: pgbench_branches; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.pgbench_branches (
    bid integer NOT NULL,
    bbalance integer,
    filler character(88)
)
WITH (fillfactor='100');


ALTER TABLE public.pgbench_branches OWNER TO postgresql;

--
-- Name: pgbench_history; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.pgbench_history (
    tid integer,
    bid integer,
    aid integer,
    delta integer,
    mtime timestamp without time zone,
    filler character(22)
);


ALTER TABLE public.pgbench_history OWNER TO postgresql;

--
-- Name: pgbench_tellers; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.pgbench_tellers (
    tid integer NOT NULL,
    bid integer,
    tbalance integer,
    filler character(84)
)
WITH (fillfactor='100');


ALTER TABLE public.pgbench_tellers OWNER TO postgresql;

--
-- Name: role; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.role (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.role OWNER TO postgresql;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgresql
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO postgresql;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgresql
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.role.id;


--
-- Name: service; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.service (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type text NOT NULL,
    config jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    name text
);


ALTER TABLE public.service OWNER TO postgresql;

--
-- Name: transformer; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.transformer (
    name name NOT NULL,
    tags text[],
    config jsonb NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    service_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.transformer OWNER TO postgresql;

--
-- Name: userSegment; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."userSegment" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    "all" uuid NOT NULL,
    "byID" uuid NOT NULL,
    "byPhone" uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    category text,
    count integer DEFAULT 0,
    description text,
    "ownerOrgID" text,
    "ownerID" text
);


ALTER TABLE public."userSegment" OWNER TO postgresql;

--
-- Name: Board id; Type: DEFAULT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."Board" ALTER COLUMN id SET DEFAULT nextval('public."Board_id_seq"'::regclass);


--
-- Name: board id; Type: DEFAULT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.board ALTER COLUMN id SET DEFAULT nextval('public.boards_id_seq'::regclass);


--
-- Name: role id; Type: DEFAULT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Data for Name: hdb_action_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.hdb_action_log (id, action_name, input_payload, request_headers, session_variables, response_payload, errors, created_at, response_received_at, status) FROM stdin;
\.


--
-- Data for Name: hdb_cron_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.hdb_cron_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_cron_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.hdb_cron_events (id, trigger_name, scheduled_time, status, tries, created_at, next_retry_at) FROM stdin;
\.


--
-- Data for Name: hdb_metadata; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.hdb_metadata (id, metadata, resource_version) FROM stdin;
1	{"sources":[{"kind":"postgres","name":"default","tables":[{"table":{"schema":"public","name":"Adapter"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"adapterId","table":{"schema":"public","name":"ConversationLogic"}}},"name":"ConversationLogics"}]},{"table":{"schema":"public","name":"Board"}},{"table":{"schema":"public","name":"Bot"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"A","table":{"schema":"public","name":"_BotToConversationLogic"}}},"name":"_BotToConversationLogics"},{"using":{"foreign_key_constraint_on":{"column":"A","table":{"schema":"public","name":"_BotToUserSegment"}}},"name":"_BotToUserSegments"}]},{"object_relationships":[{"using":{"foreign_key_constraint_on":"adapterId"},"name":"Adapter"}],"table":{"schema":"public","name":"ConversationLogic"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"conversationLogicId","table":{"schema":"public","name":"TransformerConfig"}}},"name":"TransformerConfigs"},{"using":{"foreign_key_constraint_on":{"column":"B","table":{"schema":"public","name":"_BotToConversationLogic"}}},"name":"_BotToConversationLogics"}]},{"table":{"schema":"public","name":"Service"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"serviceId","table":{"schema":"public","name":"Transformer"}}},"name":"Transformers"},{"using":{"foreign_key_constraint_on":{"column":"allServiceID","table":{"schema":"public","name":"UserSegment"}}},"name":"UserSegments"},{"using":{"foreign_key_constraint_on":{"column":"byIDServiceID","table":{"schema":"public","name":"UserSegment"}}},"name":"userSegmentsByByidserviceid"},{"using":{"foreign_key_constraint_on":{"column":"byPhoneServiceID","table":{"schema":"public","name":"UserSegment"}}},"name":"userSegmentsByByphoneserviceid"}]},{"object_relationships":[{"using":{"foreign_key_constraint_on":"serviceId"},"name":"Service"}],"table":{"schema":"public","name":"Transformer"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"transformerId","table":{"schema":"public","name":"TransformerConfig"}}},"name":"TransformerConfigs"}]},{"object_relationships":[{"using":{"foreign_key_constraint_on":"conversationLogicId"},"name":"ConversationLogic"},{"using":{"foreign_key_constraint_on":"transformerId"},"name":"Transformer"}],"table":{"schema":"public","name":"TransformerConfig"}},{"object_relationships":[{"using":{"foreign_key_constraint_on":"allServiceID"},"name":"Service"},{"using":{"foreign_key_constraint_on":"byIDServiceID"},"name":"serviceByByidserviceid"},{"using":{"foreign_key_constraint_on":"byPhoneServiceID"},"name":"serviceByByphoneserviceid"}],"table":{"schema":"public","name":"UserSegment"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"B","table":{"schema":"public","name":"_BotToUserSegment"}}},"name":"_BotToUserSegments"}]},{"object_relationships":[{"using":{"foreign_key_constraint_on":"A"},"name":"Bot"},{"using":{"foreign_key_constraint_on":"B"},"name":"ConversationLogic"}],"table":{"schema":"public","name":"_BotToConversationLogic"}},{"object_relationships":[{"using":{"foreign_key_constraint_on":"A"},"name":"Bot"},{"using":{"foreign_key_constraint_on":"B"},"name":"UserSegment"}],"table":{"schema":"public","name":"_BotToUserSegment"}},{"table":{"schema":"public","name":"_prisma_migrations"}}],"configuration":{"connection_info":{"use_prepared_statements":true,"database_url":{"from_env":"HASURA_GRAPHQL_DATABASE_URL"},"isolation_level":"read-committed","pool_settings":{"connection_lifetime":600,"retries":1,"idle_timeout":180,"max_connections":50}}}}],"version":3}	7
\.


--
-- Data for Name: hdb_scheduled_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.hdb_scheduled_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_scheduled_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.hdb_scheduled_events (id, webhook_conf, scheduled_time, retry_conf, payload, header_conf, status, tries, created_at, next_retry_at, comment) FROM stdin;
\.


--
-- Data for Name: hdb_schema_notifications; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.hdb_schema_notifications (id, notification, resource_version, instance_id, updated_at) FROM stdin;
1	{"metadata":true,"remote_schemas":[],"sources":[]}	7	c54ed2a1-661a-4b42-bd6a-c0f45630706d	2022-06-02 07:29:53.599825+00
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state) FROM stdin;
f466152b-8ac2-446b-b160-c4e188fa1d54	47	2022-06-02 05:01:58.445079+00	{}	{"console_notifications": {"admin": {"date": "2022-08-22T11:18:41.246Z", "read": [], "showBadge": true}}, "telemetryNotificationShown": true}
\.


--
-- Data for Name: migration_settings; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.migration_settings (setting, value) FROM stdin;
migration_mode	true
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.schema_migrations (version, dirty) FROM stdin;
1629204035600	f
\.


--
-- Data for Name: Adapter; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."Adapter" (id, "createdAt", "updatedAt", channel, provider, config, name) FROM stdin;
44a9df72-3d7a-4ece-94c5-98cf26307324	2021-06-16 06:02:41.824	2021-06-16 06:02:39.125	WhatsApp	gupshup	{"2WAY": "2000193033", "phone": "9876543210", "HSM_ID": "2000193031", "credentials": {"vault": "samagra", "variable": "gupshupSamagraProd"}}	SamagraProd
44a9df72-3d7a-4ece-94c5-98cf26307323	2021-06-16 06:02:41.824	2021-06-16 06:02:39.125	WhatsApp	Netcore	{"phone": "912249757677", "credentials": {"vault": "samagra", "variable": "netcoreUAT"}}	SamagraNetcoreUAT
21f1d315-55cf-44e3-8355-4743d6519649	2022-07-06 09:34:44.024	2022-07-06 09:34:44.024	web	firebase	{"credentials": {"vault": "samagra", "variable": "uci-firebase-notification"}}	SamagraFirebaseWeb
7f699a4e-f764-4573-b626-77d2427e7208	2021-06-16 06:02:41.824	2021-06-16 06:02:39.125	sms	gupshup	{"2WAY": "2000193033", "phone": "9876543210", "HSM_ID": "2000193031", "credentials": {"vault": "samagra", "variable": "gupshupSamagraProd"}}	Samagra Gupshup SMS
6efa8087-0939-49ab-b8e5-5676e036c17b	2023-03-18 06:02:41.824	2023-03-18 06:02:41.824	web	firebase	{"credentials": {"vault": "samagra", "variable": "nl-app-firebase-notification"}}	NL App Firebase Adapter
\.


--
-- Data for Name: Board; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."Board" (id, name) FROM stdin;
\.


--
-- Data for Name: Bot; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."Bot" (id, "createdAt", "updatedAt", name, "startingMessage", "ownerID", "ownerOrgID", purpose, description, "startDate", "endDate", status, tags) FROM stdin;
56b31f3d-cc0f-49a1-b559-f7709200aa85	2021-06-16 06:02:25.091	2021-07-08 18:43:12.27	Rozgar Recruiter	Hi Rozgar2	\N	\N	\N	\N	\N	\N	DRAFT	\N
5db54579-04bb-4fb7-a9ee-0f9994cfaada	2021-07-11 11:09:42.05	2021-07-11 11:09:42.05	mirinda1dhdhu6958	hibdhh world	\N	\N	\N	\N	\N	\N	DRAFT	\N
20b0cdec-a9a6-4bd4-8b36-150d45499946	2021-07-11 11:50:41.952	2021-07-11 11:50:41.952	miriqwseddcdhu6958	hibdhh cdefvworld	\N	\N	\N	\N	\N	\N	DRAFT	\N
62879f85-3183-4424-952b-4b16cdd8b220	2021-07-11 08:53:22.685	2021-07-11 08:53:22.685	mirinda1236958	Hello world	\N	\N	\N	\N	\N	\N	DRAFT	\N
6048f674-66d5-42a1-a5eb-c5c505dca640	2021-07-11 09:34:03.042	2021-07-11 09:34:03.042	mirinda1hu6958	hi world	\N	\N	\N	\N	\N	\N	DRAFT	\N
6895bd67-3c3d-436f-84c3-31cc03a2b2c3	2021-07-13 07:44:05.08	2021-07-13 07:44:05.08	CTARA	CTARA	\N	\N	\N	\N	\N	\N	DRAFT	\N
563b8fca-7462-4bf3-819c-0111d377681d	2021-07-13 07:45:18.291	2021-07-13 07:45:18.291	karnataka Bot	KA TARA	\N	\N	\N	\N	\N	\N	DRAFT	\N
b214ac3b-6094-4e00-9a19-c8f948ae7352	2021-07-14 15:12:31.778	2021-07-14 15:12:31.778	Hello name	Hex	\N	\N	No purpose of hex	hex	2021-07-14	2021-07-31	DRAFT	\N
3ba7f3db-d596-4878-9f3f-c9858bcdaa4b	2021-11-11 06:55:34.146	2021-11-11 06:55:34.146	STest 2	Hi Test Bot 2	\N	\N	\N	\N	2021-11-11	1970-01-01	DRAFT	\N
07dd2b3c-83b1-4b1e-aa6c-826f4b8464e0	2021-11-11 07:28:59.601	2021-11-11 08:52:41.945	STest3	Hi Test Bot 3	\N	\N	\N	\N	2021-11-11	2021-11-11	DRAFT	\N
aaa7cb87-335f-4306-939d-a0337351fb6a	2021-11-11 12:47:47.565	2021-11-11 12:47:47.565	Rozgar Bot 11112021	Hi Rozgar11112021	\N	\N	\N	\N	2021-11-10	2021-11-20	DRAFT	\N
923f966e-8d0d-4d47-87dd-6804c00e60c9	2021-11-11 12:58:02.008	2021-11-11 12:58:02.008	Rozgar Bot 111120212	Hi Rozgar111120212	\N	\N	\N	\N	2021-11-10	2021-11-20	DRAFT	\N
a09075ff-5fe5-4ca0-ad78-e5450886b921	2021-11-11 13:25:21.647	2021-11-11 13:25:21.647	Rozgar Bot 111120213	Hi Rozgar111120213	\N	\N	\N	\N	2021-11-10	2021-11-20	DRAFT	\N
a79b3778-7419-46af-ba29-cbd9719a33dd	2021-11-11 14:03:28.548	2021-11-11 14:03:28.548	Rozgar Bot 111120214	Hi Rozgar111120214	\N	\N	\N	\N	2021-11-10	2021-11-20	DRAFT	\N
765511f1-cb4a-4554-8a86-0b34c6d85b8d	2021-11-11 20:24:06.321	2021-11-11 20:24:06.321	Rozgar Bot 111120215	Hi Rozgar111120215	\N	\N	\N	\N	2021-11-10	2021-11-20	DRAFT	\N
710c7340-73d2-484f-96d3-e7401999f088	2021-11-12 13:54:09.887	2021-11-12 13:54:09.887	Rozgar Employer	Hi RozgarBot	\N	\N	\N	\N	2021-11-11	2029-11-11	DRAFT	\N
b966d6a4-c6a3-485c-8647-1f3def56fdb0	2021-11-16 06:32:08.657	2021-11-16 06:32:08.657	Hi Rozgar16112021	Hi Rozgar16112021	\N	\N	\N	\N	2021-11-11	2021-12-11	DRAFT	\N
8276f638-d531-43c4-b084-cdb5d8706fc1	2021-11-16 12:56:02.956	2021-11-16 12:56:02.956	RozgarBot161121	Hi RozgarBot161121	\N	\N	\N	\N	2021-11-11	2022-11-11	DRAFT	\N
3238d90a-d46f-42e5-b0fe-84e58c527868	2021-11-16 17:06:30.542	2021-11-16 17:06:30.542	RozgarSaathi161121	Hi RozgarSaathi161121	\N	\N	\N	\N	2021-11-11	2022-11-11	DRAFT	\N
324d533b-7db7-454f-b955-7d3257919c4f	2021-11-25 12:54:40.435	2021-11-25 12:54:40.435	Rozgar Saathi Candidate Registration Form	Hi Rozgar Candidate	\N	\N	\N	\N	2021-11-11	2030-11-11	DRAFT	\N
be2473c3-3152-4415-b721-90ef98a48dfa	2021-11-25 13:17:07.028	2021-11-25 13:17:07.028	Rozgar Saathi Employer Registration and Vacancy Form	Hi Rozgar Recruiter	\N	\N	\N	\N	2021-11-11	2030-11-11	DRAFT	\N
4a654346-56dd-4881-a809-59ecfddab0b6	2021-11-25 13:47:46.856	2021-11-25 13:47:46.856	Rozgar Saathi Candidate Interest Confirmation	Hi Candidate Interested	\N	\N	\N	\N	2021-11-11	2030-11-11	DRAFT	\N
8fc85967-761c-4dd4-9dfd-2ebcfbcd1617	2021-12-14 05:31:23.749	2021-12-14 05:31:23.749	Sunbird Tara Bot	Hi Sunbird Tara Bot	\N	\N	\N	\N	2021-12-14	1970-01-01	DRAFT	\N
06801678-5ce9-470b-b2f0-eee070813774	2021-07-13 07:49:41.118	2021-11-30 09:10:08.965	Hi Tara	Hi Tara	\N	\N	\N	\N	2021-11-29	1970-01-01	DRAFT	\N
8e4296da-49da-40da-a1fd-b4e72af914cd	2021-12-17 04:11:07.012	2021-12-17 04:11:07.012	LifeSkills	YWNXT	\N	\N	\N	\N	2021-11-11	2025-11-11	DRAFT	\N
c10b951e-5094-4bbc-8846-3627236e1c07	2021-12-21 08:10:25.96	2021-12-21 08:10:25.96	YWNXT-1	Hi YWNXT	\N	\N	\N	\N	2021-11-11	2025-11-11	DRAFT	\N
701a52f6-d527-4670-9243-c4bb80d1b747	2021-12-14 05:39:14.931	2022-02-04 06:25:28.193	Tara Bot 2	Hi Tara Bot 2	\N	\N	\N	\N	2021-12-14	1970-01-01	DRAFT	\N
3cae7fd6-c843-4a7f-9b6b-9674e81f502c	2022-02-04 06:40:10.137	2022-02-04 06:40:10.137	Candidate Rozgar Bot 2	Hi Candidate Rozgar Bot 2	\N	\N	\N	\N	2021-12-14	1970-01-01	DRAFT	\N
803bd717-1fa3-45e0-b75c-8bab76fa788c	2021-07-11 06:49:54.013	2022-03-25 07:17:29.935	Demouser1234	Hi Bot 2	\N	\N	\N	\N	2022-01-01	1970-01-01	DRAFT	\N
511be17a-a6d2-443f-a3f9-a61755939c35	2022-02-24 07:07:10.523	2022-02-24 07:08:14.211	RozgarBotRecruiter-Lang	Hello Rozgar1	\N	ORG_001	\N	\N	2022-01-25	2023-01-25	DRAFT	\N
4628ede5-023a-41a0-8698-ecb72a86a597	2022-02-24 08:30:42.973	2022-02-24 08:30:42.973	RozgarBotCandidate - Phone test	Namaste Rozgar 2	\N	ORG_001	\N	\N	2022-01-25	2023-01-25	DRAFT	\N
448f0b1c-d5ce-4cff-8baf-25dff80c9257	2022-02-24 07:16:47.403	2022-02-24 08:15:11.148	RozgarBotRecruiter-Phone test	Hello Rozgar 2	\N	ORG_001	\N	\N	2022-01-25	2023-01-25	DRAFT	\N
e8960328-e6ae-44cd-b9e4-30ee6e74c4a9	2022-01-25 13:16:19.14	2022-03-23 11:30:49.574	RozgarBotRecruiter	Hello Rozgar	\N	ORG_001	\N	\N	2022-01-25	2023-01-25	DRAFT	\N
b1aae704-7254-4d26-8d34-09c99704f3c3	2022-02-24 13:40:41.631	2022-03-09 09:09:39.012	HM Rozgar Test Bot	HM Rozgar	\N	ORG_001	\N	\N	2022-01-25	2023-01-25	DRAFT	\N
4783168a-c2f2-4fbf-b10c-01fb823da3ce	2022-03-09 09:18:42.782	2022-03-09 09:18:42.782	STest 21	Hi Test Bot 31	\N	\N	\N	\N	2021-11-11	2021-11-11	DRAFT	\N
ae74e2ee-f39a-4370-91ff-cf00af23bcba	2022-03-09 09:48:02.209	2022-03-09 09:48:02.209	STest 22	Hi Test Bot 32	\N	\N	\N	\N	2021-11-11	2021-11-11	DRAFT	\N
b0854201-754c-4d69-993d-f5e897625170	2022-03-09 10:03:36.253	2022-03-09 10:03:36.253	STest 23	Hi Test Bot 33	\N	\N	\N	\N	2021-11-11	2021-11-11	DRAFT	\N
0fbaf814-727e-44e5-93a5-3469bb0da33c	2022-03-09 11:34:40.43	2022-03-09 11:34:40.43	STest 25	Hi Test Bot 35	\N	\N	\N	\N	2021-11-11	2021-11-11	DRAFT	\N
8a8c26e5-6227-47a9-8e70-7b6ca90d14e5	2022-03-09 11:39:22.533	2022-03-09 11:39:22.533	STest 26	Hi Test Bot 36	\N	\N	\N	\N	2021-11-11	2021-11-11	DRAFT	\N
fe577c9a-11a1-431a-9617-8d93dad233b5	2022-03-10 14:05:14.097	2022-03-10 14:05:14.097	Bot Name March 10	Bot Test March 10	\N	\N	\N	\N	2021-03-10	2022-11-11	DRAFT	\N
eef0ddfa-a3db-4d62-933a-c3e55fa5c664	2022-03-10 14:14:14.165	2022-03-10 14:14:14.165	Bot Name 10Mar	Bot Test 10Mar	\N	\N	\N	\N	2021-03-10	2022-11-11	DRAFT	\N
e5363a73-4ff0-4cc8-935d-9ffa4fc975a3	2022-03-11 04:17:44.858	2022-03-11 04:17:44.858	CSM Demo Test	CSM Demo Test	\N	\N	\N	\N	2021-03-10	2022-11-11	DRAFT	\N
858a8db0-9d55-4276-84da-f9974c885a18	2022-03-11 04:29:14.091	2022-03-11 04:29:14.091	CSM Demo Test Mar11	CSM Demo Test Mar11	\N	\N	\N	\N	2021-03-10	2022-11-11	DRAFT	\N
5cc4cc3d-b1b5-45ef-95b7-262b4fd4a086	2022-03-11 04:54:47.292	2022-03-11 04:54:47.292	CSM Demo	CSM Demo	\N	\N	\N	\N	2021-03-10	2022-11-11	DRAFT	\N
2d1f0c34-d942-49e4-89ff-7cd19318a685	2022-03-14 11:25:08.088	2022-03-14 11:25:08.088	UP FGD UCI	Hi UP Bot	\N	\N	\N	\N	2021-11-11	2022-11-11	DRAFT	\N
86f60113-6315-4059-a0e7-1dd3e876f10c	2022-03-14 11:49:04.578	2022-03-14 11:49:04.578	UP FGD UCI Test	Hi UP Bot Test	\N	\N	\N	\N	2021-11-11	2022-11-11	DRAFT	\N
05274f3c-d23e-4cd4-bcc5-9eab18bfe740	2022-03-14 12:25:37.887	2022-03-14 12:25:37.887	UP FGD UCI Test 1	Hi UP Bot Test1	\N	\N	\N	\N	2021-11-11	2022-11-11	DRAFT	\N
780b9ee6-6f52-498b-b370-45601bd986aa	2022-03-14 17:43:18.774	2022-03-14 17:43:18.774	UP Bot Mar14	Hello UP Bot	\N	\N	\N	\N	2021-11-11	2022-11-11	DRAFT	\N
c4c81867-7301-4e90-996a-0741a5dca374	2022-03-14 17:59:45.309	2022-03-14 17:59:45.309	UP Bot March14	Hello UP bot	\N	\N	\N	\N	2021-11-11	2022-11-11	DRAFT	\N
94c17e18-98a5-47fb-9c71-deb4a4af1c2d	2022-03-25 07:17:35.795	2022-03-25 09:45:55.796	UP Textbook Delivery v1	Hi Bot 3	\N	\N	\N	\N	2021-11-11	2025-11-11	DRAFT	\N
ee448621-ae60-449c-8d8e-9417eb997797	2022-03-25 09:48:48.411	2022-03-25 09:48:48.411	UP Textbook Delivery v2	Hi Bot	\N	\N	\N	\N	2021-11-11	2025-11-11	DRAFT	\N
3d370c30-8ac8-496a-a908-4975b07056b9	2022-07-06 07:33:18.037	2022-07-06 07:33:18.037	UCI Firebase Broadcast	Hi UCI Firebase Broadcast	8f7ee860-0163-4229-9d2a-01cef53145ba	org01	\N	\N	2022-07-06	2023-07-06	ENABLED	\N
137b297c-f0fc-4ced-8451-ea4da3f5a343	2022-01-25 13:16:19.14	2022-02-10 11:54:23.039	RozgarBotCandidate	Namaste Rozgar	8f7ee860-0163-4229-9d2a-01cef53145ba	ORG_001	\N	\N	2022-01-25	2023-01-25	ENABLED	\N
fabc64a7-c9b0-4d0b-b8a6-8778757b2bb5	2021-06-16 06:02:25.091	2021-07-11 10:59:28.417	Global Bot	Bye	8f7ee860-0163-4229-9d2a-01cef53145ba	org1	\N	\N	\N	\N	DRAFT	\N
a246e69f-f2c4-403a-8e54-31f57e6fd34e	2022-02-17 10:21:07.155	2022-03-14 09:36:23.894	Upload Media	Hi Upload Media	\N	\N	\N	\N	2021-12-14	2023-12-01	ENABLED	\N
f0d4614b-377e-4791-9688-1b00199448d5	2022-07-06 07:33:18.037	2022-07-06 07:33:18.037	Gupshup Whatsapp Broadcast	Hi Gupshup Whatsapp Broadcast	8f7ee860-0163-4229-9d2a-01cef53145ba	org01	\N	\N	2022-07-06	2023-07-06	ENABLED	\N
d0dad28e-8b84-4bc9-92ab-f22f90c2432a	2022-03-03 12:33:04.614	2022-03-03 12:33:04.614	DST Location Bot	Hi DST	8f7ee860-0163-4229-9d2a-01cef53145ba	org1	For Internal Demo	For Internal Demo	2022-02-01	2023-12-01	ENABLED	\N
5b962e70-7a14-48fb-804c-31e9f5505b16	2021-07-08 18:48:37.74	2022-02-11 14:09:53.571	ODK Hop Test	Hi ODK Hop Test	95e4942d-cbe8-477d-aebd-ad8e6de4bfc8	ORG_001	For Internal Demo	For Internal Demo	2022-02-01	2023-02-01	ENABLED	\N
bc029c38-1d25-4b27-a319-207abef2b41c	2021-07-13 07:49:41.118	2021-11-30 09:10:08.965	Hi Tara 3	Hi Tara 3	\N	\N	\N	\N	2021-11-29	2023-01-01	ENABLED	\N
6af8832d-fd68-427e-9369-4dbae2c71305	2021-07-08 18:48:37.74	2021-11-10 12:50:45.088	Tara Bot	Hi Tara 2	\N	\N	For Internal Demo	For Internal Demo	2021-07-08	2023-07-23	ENABLED	\N
38574867-5f98-4f6b-959c-f8317606106f	2022-07-06 07:33:18.037	2022-07-06 07:33:18.037	Gupshup SMS Broadcast	Hi Gupshup SMS Broadcast	8f7ee860-0163-4229-9d2a-01cef53145ba	org01	\N	\N	2022-07-06	2023-07-06	ENABLED	\N
92edfc02-1dee-4c56-8d8c-fc801d4cd883	2022-02-17 10:21:07.155	2022-03-14 09:36:23.894	All Display Media	Hi All Display Media	\N	\N	\N	\N	2021-12-14	2023-12-01	ENABLED	\N
e4588565-a138-426f-96ed-a3dcd29aadee	2022-08-22 11:01:50.276	2022-08-22 11:01:50.278	UCI Demo 34.2	Hi UCI 34.2	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	\N
bb1adb79-5a32-42cd-adda-07a60d5968bb	2022-08-22 11:53:24.73	2022-08-22 11:53:24.731	Test Bot - 2	Hi Test Bot - 2	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	\N
0a00661b-6968-4fcb-a646-6c975fdba27f	2022-08-23 09:57:04.406	2022-08-23 09:57:04.406	Test Bot - 3	Hi Test Bot - 3	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	\N
200f7ffe-f411-4543-a8b3-a64bf91e62b8	2022-08-23 10:03:13.496	2022-08-23 10:03:13.497	Test Bot - 4	Hi Test Bot - 4	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	\N
2d3b189e-cee4-4c0e-8b54-25d529d520f4	2022-08-23 10:07:51.107	2022-08-23 10:07:51.108	Test Bot - 5	Hi Test Bot - 5	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	\N
519b6d22-889a-4afb-a5a5-eba5d14b8d15	2022-08-24 05:10:06.705	2022-08-24 05:10:06.707	Test Bot - 6	Hi Test Bot - 6	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	\N
6611c78a-2454-4b83-a5c5-d8e384db576d	2022-08-24 07:42:03.136	2022-08-24 07:42:03.137	UCI Demo 34.3	Hi UCI 34.3	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	\N
1d9bbd1a-ecee-42fd-91c6-157e1b517810	2022-08-24 07:45:01.932	2022-08-24 07:45:01.936	UCI Demo 34.4	Hi UCI 34.4	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	{test2,test-tag3}
7d58a921-40f1-448d-844d-9a742d163f03	2022-08-25 05:17:07.047	2022-08-25 05:17:07.05	Test Bot - 7	Hi Test Bot - 7	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	{tag1,tag2}
ce99bf58-34ac-4097-9516-318c59e83500	2022-08-25 09:29:16.447	2022-08-25 09:29:16.447	UCI Gupshup Whatsapp Broadcast 2	UCI Gupshup Whatsapp Broadcast 2	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	{attendance}
c3ea9d13-2c6a-4003-af98-0419682a56e8	2022-08-26 06:49:10.952	2022-08-26 06:49:10.953	Hi UCI Demo 2	UCI Demo 2	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	{uci,demo}
e7b3727a-90ee-4ec5-9918-b2018ef98d25	2022-08-26 06:51:38.834	2022-08-26 06:51:38.835	UCI Demo 3	Hi UCI Demo 3	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	{uci,demo}
778f56ee-db58-4f31-b38a-398d202492cb	2022-08-26 07:12:25.879	2022-08-26 07:12:25.879	Test Disabled Bot	Hi Test Disabled Bot	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	{test,disabled}
d614d307-86ac-40ce-9a67-1caaa444171c	2022-08-26 07:13:01.805	2022-08-26 07:13:01.806	Test Disabled Bot 2	Hi Test Disabled Bot 2	\N	\N	\N	\N	2022-07-29	2023-07-05	DISABLED	{test,disabled}
d655cf03-1f6f-4510-acf6-d3f51b488a5e	2021-07-08 18:48:37.74	2022-02-11 14:09:53.571	UCI Demo	Hi UCI	95e4942d-cbe8-477d-aebd-ad8e6de4bfc8	ORG_001	For Internal Demo	For Internal Demo	2022-02-01	2024-02-01	ENABLED	\N
1aaa7453-4a23-4228-be0c-911cb9dd1185	2023-03-18 06:39:09.936	2023-03-18 06:39:09.937	Survery Form	Hi SB	\N	\N	\N	\N	2023-03-01	2024-12-01	ENABLED	\N
5dc65cd9-31b0-44d7-867b-2d78eee383e2	2023-03-18 07:00:27.167	2023-03-18 07:00:27.168	Firebase Notification - 2	Hi FCM	\N	\N	\N	\N	2023-03-01	2024-12-01	ENABLED	\N
5d45c918-be6f-40f4-b6ac-758a4dd6dacd	2023-03-18 07:09:23.481	2023-03-18 07:09:23.482	Doubtnut	Doubt Solving	\N	\N	\N	\N	2023-03-01	2024-12-01	ENABLED	\N
46e36ec2-d522-4933-94f2-0656607067e0	2023-03-18 07:38:47.474	2023-03-18 07:38:47.474	NL App - Test Firebase Notification	Hi NL - FCM	\N	\N	\N	\N	2023-03-01	2024-12-01	ENABLED	\N
8f65ccd2-d635-433e-83c8-f867c49ce87f	2023-03-18 20:11:03.243	2023-03-18 20:11:03.244	Test Bot - 69	Hi Test Bot - 6	\N	\N	\N	\N	2022-07-29	2023-07-05	ENABLED	{tag1,tag2}
\.


--
-- Data for Name: ConversationLogic; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."ConversationLogic" (id, "createdAt", "updatedAt", description, "adapterId", name) FROM stdin;
314c8a3e-397f-434d-bd19-df7b86aa412c	2021-07-01 12:53:54.296	2021-07-01 12:53:54.296	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Mission pass
5640c1a2-aa22-47a5-b0fc-e176a2e15413	2021-07-01 13:59:12.004	2021-07-01 13:59:12.004	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Name
938ed2e5-2b76-4ec8-877c-cfdf7e9cbc3a	2021-07-01 14:10:54.72	2021-07-01 14:10:54.72	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	New Logic
623b6944-4b59-4672-8f75-0c2946ca856f	2021-07-01 14:30:51.234	2021-07-01 14:30:51.234	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	
2dbcd68d-7665-465d-a9a3-34286ab8d8b4	2021-07-01 14:31:51.667	2021-07-01 14:31:51.667	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Tester
f7f40cc3-93a3-4d48-b7da-b5545f48ffd6	2021-07-01 14:32:42.115	2021-07-01 14:32:42.115	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Tester 2
e5c5334b-8ce1-4a53-be9d-78d24fa2e0e1	2021-06-16 06:02:53.918	2021-06-16 06:02:57.828	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Global Form
419b79d5-3a74-4250-9df3-6633c0b4b380	2021-07-01 14:54:27.025	2021-07-01 14:54:27.025	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Anup
106a6aaa-a1c6-4a6e-9cac-ffe35997c9fd	2021-07-01 15:16:13.079	2021-07-01 15:16:13.079	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Anup Singh
d97b0d3e-2662-44ad-a777-3bab74a5fcf1	2021-06-16 06:02:53.918	2021-06-22 06:38:09.889	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Rozgar-Recruiter
35e927b0-d3bf-4a26-a21b-c6c342a0e15a	2021-07-01 15:16:33.504	2021-07-01 15:16:33.504	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Anup 
5d39afbb-0e49-4e6b-8d27-99bbe343aed8	2021-06-16 06:02:53.918	2021-06-22 16:16:51.344	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Rozgar-CI
c875eb68-1bed-41cb-8763-5982a2affb74	2021-07-01 16:15:17.793	2021-07-01 16:15:17.793	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	New Logicxxxx
026984c9-8585-42ef-a39c-d3f7af1cf74d	2021-07-01 16:25:53.089	2021-07-01 16:25:53.089	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Name XXXXX
ff9447b0-1ac0-49a7-a812-1152b2fe8192	2021-07-01 16:26:37.345	2021-07-01 16:26:37.345	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Name XXXXYT
e86f0efd-9cc9-423c-9ff5-fd0870d60f3b	2021-07-01 16:32:17.915	2021-07-01 16:32:17.915	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	NO name exist
d0079ffb-a78f-4631-b350-25e242b9d2a8	2021-07-01 16:45:52.208	2021-07-01 16:45:52.208	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Convo name 9090
45ee7e1b-acd5-4d3b-9bd1-20b1a1ca2a22	2021-07-01 17:03:16.847	2021-07-01 17:03:16.847	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	no
b1c4d7b8-153c-4f73-9aef-e4fcc7c0ca94	2021-07-01 17:11:56.186	2021-07-01 17:11:56.186	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	New Logic add
4262251e-5612-49b9-aa2f-64934b9b292f	2021-07-02 12:35:18.544	2021-07-02 12:35:18.544	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	tester
1ac4cb55-cddd-46fd-8803-9097c98735c7	2021-07-02 15:08:19.594	2021-07-02 15:09:00.817	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	tester001
01316dba-f089-4eb5-8bf2-d88d29c86ad9	2021-07-02 15:25:29.424	2021-07-02 15:25:29.424	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Tester 123
89509ee1-1f25-4315-9694-e6bf9ab2b368	2021-07-02 15:26:58.736	2021-07-02 15:27:23.087	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	dfsf
caff100d-7d62-4246-b7c6-b9fc833decfa	2021-07-03 13:04:00.988	2021-07-03 13:04:00.988	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Desc
b6942720-faf2-4da4-90dc-e0584b691a1c	2021-07-02 16:32:37.245	2021-07-02 17:14:23.786	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Yes logic is this
ef728558-0bcf-4045-a791-315354c0c435	2021-07-03 11:35:09.968	2021-07-03 11:35:09.968	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	nxt name
c684a3f7-6b92-4629-86eb-a67c39d51480	2021-07-05 11:00:17.286	2021-07-05 11:00:17.286	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Sample
ec1816c3-0f87-4c61-813e-945c43d43355	2021-07-05 18:00:29.099	2021-07-05 18:00:29.099	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Test Bot Conv Logic
834d7364-7136-4719-a441-559be23c9ee8	2021-07-07 05:09:34.504	2021-07-07 05:09:34.504	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Demo2
ad91f5c6-93f8-433b-9461-aafb896812db	2021-07-07 05:50:32.738	2021-07-07 05:50:32.738	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Demo3
61cbdfb6-e1c1-4433-a2d4-ccc502cfd5bd	2021-07-07 07:06:10.376	2021-07-07 07:06:10.376	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Test 10 Logic
3f7d264b-5e18-4309-88c2-de190a95db02	2021-07-07 09:37:26.889	2021-07-07 09:37:26.889	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Te2
4ca8abf3-f1c7-4f8d-967d-ee059d32ea19	2021-07-07 09:45:17.422	2021-07-07 09:45:17.422	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Abc1
f6b80a0c-b39e-4b19-ac8d-e103825c991a	2021-07-07 10:12:20.667	2021-07-07 10:12:20.667	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Demo4
9fd2c5e1-4e33-4a51-b097-c735d3f92d84	2021-07-07 11:13:56.86	2021-07-07 11:13:56.86	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Logic 1
6293fd66-43e2-4323-9b4e-ad7a3d95bbf8	2021-06-16 06:02:53.918	2021-07-07 11:15:10.641	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Mission Prerna Form
8d6a7e32-0d6c-47c1-9fa6-529e3c4de48a	2021-07-07 11:23:30.284	2021-07-07 11:23:30.284	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Demo5
38044707-ec23-4e8a-9482-6aa462b010b5	2021-07-07 17:30:59.603	2021-07-07 17:30:59.603	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Demo AK
52dedc00-8cea-4cfa-8ac9-9a7c68bad406	2021-07-08 06:53:39.256	2021-07-08 06:53:39.256	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Demo 10
21b7cee2-b0e3-4778-bc71-a7db8e0e9933	2021-07-08 07:08:02.191	2021-07-08 07:08:02.191	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	deo
7a7debc3-d0ed-4fa0-b0d2-3a632e87aa89	2021-07-08 08:05:26.436	2021-07-08 08:05:26.436	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Demo
de059e59-a1fe-4f2d-9209-112f19912e32	2021-07-08 13:22:19.595	2021-07-08 13:22:19.595	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Demo15
ad552ba3-296d-4be1-98bd-a10f8519b679	2021-07-08 13:47:29.881	2021-07-08 13:47:29.881	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Logic_tester_1
90aea89e-ee25-48c0-ad39-87586d538183	2021-07-08 16:33:13.594	2021-07-08 16:33:13.594	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Test007
b254a6b2-abce-43da-bd05-ae801bcab71c	2021-07-08 16:44:35.12	2021-07-08 16:56:36.661	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Demo100
e69b63e4-eed7-499d-a8a9-ea3a0c4b8f67	2021-07-08 18:25:26.979	2021-07-08 18:25:26.979	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	UCIDemo
32702947-2072-4fb9-9936-3fd2bcb34742	2021-07-13 07:42:30.296	2021-07-13 07:42:30.296	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Tara bot Testing with Netcore adapter
0d4ee8e9-8501-4969-8049-6bf918ba6d17	2021-07-13 07:43:20.069	2021-07-13 07:43:20.069	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Genearal Tara bot
e342bd51-a322-4973-ab89-a8a382d514b9	2021-07-13 07:44:47.953	2021-07-13 07:44:47.953	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	karnataka Tara bot
18f2a486-63ef-4072-a16b-d9bd9fcc0112	2021-07-13 07:49:16.634	2021-07-13 07:49:16.634	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Global Tara bot
0763144a-9a95-4fc5-9ae2-dbf1816ec384	2021-09-29 18:47:44.926	2021-09-29 08:05:23.946	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Consent Form
dd33fa11-d66e-4645-844a-106f6f94b7d9	2021-11-11 07:27:34.794	2021-11-11 07:27:34.794	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	STest Form1
4ea24f2c-74eb-4f20-b39f-a1ab810588f1	2021-11-11 12:46:13.853	2021-11-11 12:46:13.853	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar
84941b0a-6eae-4b46-a810-2065d8bc6f8a	2021-11-11 12:56:55.216	2021-11-11 12:56:55.216	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar1
5eca4f02-e5c9-4109-b238-52ce5ce845dc	2021-11-11 13:24:50.377	2021-11-11 13:24:50.377	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar2
0bf66a2c-e504-4fce-9970-43620888929a	2021-11-11 14:02:17.436	2021-11-11 14:02:17.436	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar3
be24a027-8856-4439-958b-43a1057ddcfe	2021-11-11 20:23:41.609	2021-11-11 20:23:41.609	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar4
fe6dd157-ca49-4101-9ec0-aa1d871c5955	2021-11-12 13:49:16.812	2021-11-12 13:49:16.812	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	wabot1e
3a583e97-853e-40c4-8be2-0ed9459ecf64	2021-11-16 06:31:00.987	2021-11-16 06:31:00.987	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	RozgarTesting
ec5287e7-886e-4e46-93e0-ab616973b370	2021-11-16 12:49:54.497	2021-11-16 12:49:54.497	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	wabote161121
82733742-65cb-493d-baee-3299b9dfe882	2021-11-16 17:01:53.954	2021-11-16 17:01:53.954	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	wabotc161121
7f8f2086-34e8-4a6d-a7ed-302642fd043b	2021-11-25 12:53:21.36	2021-11-25 12:53:21.36	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar Saathi Candidate Registration Form
742c2671-4dab-4ccc-adab-1167f98c3dc7	2021-11-25 13:16:05.17	2021-11-25 13:16:05.17	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar Saathi Employer Registration and Vacancy Form
458698db-b305-467a-9ea3-5ceea95503d6	2021-11-25 13:46:15.135	2021-11-25 13:46:15.135	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar Saathi Candidate Interest Confirmation Form
95d75bee-689d-43cf-a4bf-184a40c4e8a8	2021-11-30 09:13:09.608	2021-11-30 09:13:09.608	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Global Form 12
74a38946-9979-49a4-841e-e244d0d2ac3c	2021-12-14 05:29:04.778	2021-12-14 05:42:50.529	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Sunbird Tara Bot Form
1cd933be-22af-4ca2-8726-eaab4ec1c60b	2021-12-14 05:39:49.797	2022-02-04 08:16:40.035	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Tara Bot Form 2
8eb5eb29-b37f-443c-9e2b-147a560698fc	2021-12-17 04:07:56.728	2021-12-21 08:08:34.592	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	YWNXT
80c2331a-d581-4fcd-9b5d-cabc01fb42c0	2021-12-21 08:09:16.543	2021-12-21 08:09:16.543	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	YWNXT-1
01016c08-1fc6-453a-af18-b18fe7aedb67	2022-01-25 13:15:23.875	2022-01-27 09:05:32.941	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Namaste Rozgar Bot Logic
e96b0865-5a76-4566-8694-c09361b8ae32	2021-07-08 18:47:44.926	2022-02-03 12:29:32.959	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	UCI Demo
f4569b71-87e3-49a0-bb33-e67d4f73f91b	2022-01-31 05:23:39.95	2022-03-06 14:30:34.39	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar Recruiter
7bbac85b-18ad-4b18-a095-39fb4edcadbc	2022-02-04 06:39:19.129	2022-02-21 13:10:33.638	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Candidate Rozgar Bot Form 2
4519e197-ebdd-4390-be85-051149d5e563	2022-02-24 08:29:54.626	2022-02-24 08:29:54.626	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Rozgar Candidate - phone test
e65a1541-18e1-4dc3-92ca-82a57bf36b65	2022-02-24 07:15:49.654	2022-02-24 09:24:56.373	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar Recruiter - phone test
142e47e3-7bc6-4094-9708-6c8da7a17ec0	2022-02-24 07:07:49.416	2022-02-28 06:48:37.438	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar Recruiter - Lang
a00d2b05-0bea-4216-b46d-6810c1ecd5e5	2022-01-31 05:22:48.565	2022-03-04 11:21:37.473	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Rozgar Candidate Interest
229ff6b3-ba4d-4842-98de-8f84a24acac6	2022-03-09 10:04:07.319	2022-03-09 10:04:07.319	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	STest Form4
ec7709e2-b712-4601-902a-4faacb7bc7ad	2022-03-09 10:09:40.888	2022-03-09 10:09:40.888	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	STest Form5
ee426a47-e690-4dae-ae89-d74ccbfdba40	2022-03-09 11:36:05.54	2022-03-09 11:36:05.54	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	STest Form6
8db7faf0-eed5-43bc-83e9-389b2f3c3c3b	2022-03-11 04:53:49.931	2022-03-11 04:53:49.931	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	CSM CL
c2aeb5bb-8dde-4512-8404-ae5540bebe21	2022-03-25 07:15:54.437	2022-03-25 07:15:54.437	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	UP Textbook Delivery v1
eb6be5eb-40bc-4c6e-a596-0cfd2881b5ba	2022-03-09 09:18:13.962	2022-03-09 09:18:13.962	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	STest Form2
97e509a7-f413-45b4-b2fc-35370eab1366	2022-03-09 09:53:05.041	2022-03-09 09:53:05.041	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	STest Form3
ff33342c-bccc-4b41-8ed3-8fb2eaf1706f	2022-03-14 11:24:25.954	2022-03-14 11:24:25.954	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	CL_UP_FGD
ad644b95-28cb-4905-a175-3403337b3b7a	2022-03-14 11:48:17.493	2022-03-14 11:48:17.493	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	CL_UP_FGD_v2
f11bf421-c58d-41ba-85c4-67476547b418	2022-03-14 12:25:20.719	2022-03-14 12:25:20.719	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	CL_UP_FGD_v3
a660bac4-0d3f-4095-9988-50b0c3620bac	2022-03-10 14:03:25.657	2022-03-10 14:03:25.657	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	CL Test March 10
d06cfecb-3a94-40dc-b544-eeacfa0bdc89	2022-03-10 14:13:09.04	2022-03-10 14:13:09.04	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	CL March 10
b4d244e9-8dc1-4d1d-ac75-8d21a8b25755	2022-03-11 04:16:46.377	2022-03-11 04:16:46.377	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	CL March 11
3008d1eb-da54-4a78-83c9-3686e7b95879	2022-03-11 04:28:33.126	2022-03-11 04:28:33.126	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	CL March11
f9719454-41d8-46d5-8932-cc0ba8f6c0de	2022-03-14 17:42:18.175	2022-03-14 17:42:18.175	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	UP CL Test
8597514f-b931-4cb5-802e-e30ec8a2bbd3	2022-03-14 17:59:00.143	2022-03-14 17:59:00.143	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	UP CL Test March14
6cf23215-6736-4d22-9d7c-9787040a4eeb	2022-03-03 12:32:00.297	2022-03-15 08:58:13.745	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	DST Location Form
20909cbe-3181-45c2-8e7b-a707da7949ec	2022-03-23 11:23:09.156	2022-03-25 05:09:04.813	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Rozgar Recruiter - Broadcast 
52f9ff38-3897-4fa4-835b-4a42b8fd08a6	2022-02-24 13:42:19.837	2022-03-24 12:36:50.587	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	HM Rozgar Test
956f0d05-299c-4c92-85b1-c516c7b6c349	2022-03-25 10:49:35.414	2022-03-25 10:49:35.414	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	UP Textbook Delivery v3
57613545-54b8-406f-9b02-b54662945279	2022-03-25 09:48:12.914	2022-03-25 10:54:11.402	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	UP Textbook Delivery v2
c8326462-29cd-4027-9474-940179644347	2022-07-06 07:33:18.037	2022-07-06 07:33:18.037	\N	21f1d315-55cf-44e3-8355-4743d6519649	UCI Firebase Broadcast
9c118296-b761-4253-b89f-442ddaf46af8	2021-07-08 18:47:44.926	2022-02-03 12:29:32.959	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	ODK Hop Test
1c221dd9-ba8d-4e35-8a07-7219264e7f56	2022-07-06 07:33:18.037	2022-07-06 07:33:18.037	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Gupshup Whatsapp Broadcast 
1e7bbc07-adce-4510-bcae-833c2117c9d5	2022-07-06 07:33:18.037	2022-07-06 07:33:18.037	\N	7f699a4e-f764-4573-b626-77d2427e7208	Gupshup SMS Broadcast 
9f83b73e-09ca-41f7-a5d4-11d40cb70ed3	2022-02-17 10:20:04.522	2022-03-22 11:59:28.98	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	All Display Media Logic
5e613f4a-2a7d-48a4-80ab-2661be1f7963	2022-02-17 10:20:04.522	2022-03-22 11:59:28.98	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Upload Media Logic
a9722711-78d7-4b58-8668-59ba3cba1717	2022-08-22 08:51:35.387	2022-08-22 08:51:35.387	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Mission Prerna Form
2e56cead-15ea-4bfa-b038-69fa6480b8fc	2022-08-22 09:08:09.777	2022-08-22 09:08:09.777	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Mission Prerna Form
025d132b-f718-4227-9c5e-d32c12064c2d	2022-08-22 09:08:25.017	2022-08-22 09:08:25.018	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Mission Prerna Form
1a89f773-9734-46ea-8fa8-33360dd34031	2022-08-22 09:11:53.86	2022-08-22 09:11:53.861	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Mission Prerna Form
a03e57c8-5d6f-4aca-8588-3ae85b69e813	2022-08-22 09:12:24.105	2022-08-22 09:12:24.106	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Mission Prerna Form
36506207-e3d7-421b-9c68-1cc51d167712	2022-08-22 09:24:15.13	2022-08-22 09:24:15.131	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Mission Prerna Form
a3ab6169-1053-4eda-9afc-fdb39ae38709	2022-08-22 11:49:18.75	2022-08-22 11:49:18.75	\N	44a9df72-3d7a-4ece-94c5-98cf26307324	Test Bot - 2
7b84b2d6-31fd-4ed6-afed-fc8231ec6b67	2022-08-23 09:56:52.062	2022-08-23 09:56:52.062	\N	21f1d315-55cf-44e3-8355-4743d6519649	Test Bot - 3
7f9232b2-7bfc-4d6c-82dd-f211b2f2a99d	2022-08-23 10:02:35.214	2022-08-23 10:02:35.214	\N	21f1d315-55cf-44e3-8355-4743d6519649	Test Bot - 4
e267d86f-fdd7-4fd5-ab37-2891e68393e6	2022-08-23 10:07:36.79	2022-08-23 10:07:36.791	\N	21f1d315-55cf-44e3-8355-4743d6519649	Test Bot - 5
afcffc28-f37d-49f7-af16-6e017ad62a7d	2023-03-18 06:36:49.352	2023-03-18 06:36:49.353	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Survey form
43648e17-e26a-4bf3-b8e6-051b95ed8c0c	2023-03-18 06:58:54.132	2023-03-18 06:58:54.133	\N	21f1d315-55cf-44e3-8355-4743d6519649	Firebase Notification - 2
6572ee3a-fd66-4733-badb-b364841a6d24	2023-03-18 07:08:45.03	2023-03-18 07:08:45.03	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Doubtnut
52bd466d-cbef-46ef-89c7-e2e0a2741426	2023-03-18 07:32:27.813	2023-03-18 07:32:27.814	\N	6efa8087-0939-49ab-b8e5-5676e036c17b	NL App - Firebase Notification
900ea924-0c6b-469d-86f7-7cf236746e98	2023-03-18 19:46:04.216	2023-03-18 19:46:04.217	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Firebase Broadcast Logic
11d218ca-c7ab-4289-9390-d4d186c320ae	2023-03-20 06:11:55.977	2023-03-20 06:11:55.978	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Firebase Broadcast Logic
2023e7b1-b28b-4fef-b9d4-03a3a8c330a2	2023-03-20 06:15:24.137	2023-03-20 06:15:24.138	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Firebase Broadcast Logic
435f31cd-c965-4deb-8810-47dd88456556	2023-03-20 06:16:57.922	2023-03-20 06:16:57.923	\N	44a9df72-3d7a-4ece-94c5-98cf26307323	Firebase Broadcast Logic
\.


--
-- Data for Name: Service; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."Service" (id, "createdAt", "updatedAt", type, config, name) FROM stdin;
ecb0a27b-587f-4575-a1de-7b7d44abba96	2021-06-29 08:11:49.171	2021-06-29 08:11:49.171	gql	{"gql": "query getChakshu($phoneNo: String!) {users: candidate_profile(where: {whatsapp_mobile_number: {_eq: $phoneNo}}) { id: uuid name phone: whatsapp_mobile_number}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "rozgarBotGQL"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
4320c89b-b111-4b30-be38-37a949d4453d	2021-06-29 08:11:49.171	2021-06-29 08:11:49.171	gql	{"gql": "query getChakshu($id: uuid!) {users: candidate_profile(where: {uuid: {_eq: $id}}) {id: uuid name phone: whatsapp_mobile_number}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "rozgarBotGQL"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
4f102bb1-61c6-4cea-a157-411b107f0ada	2021-07-05 06:59:49.745	2021-07-05 06:59:49.745	gql	{"gql": "query Query {users: getCandidatesForVacancy(vacancyID: 15, threshold: 16) {id name whatsapp_mobile_number mobile_number vacancyData marks }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "skills"}}	\N
7e0462d9-7009-4861-adf4-2e545b65506e	2021-07-05 06:59:49.745	2021-07-05 06:59:49.745	gql	{"gql": "query getChakshu($phoneNo: String!) {users: candidate_profile(where: {whatsapp_mobile_number: {_eq: $phoneNo}}) { id: uuid name phone: whatsapp_mobile_number}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "skills"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
057087a6-10ec-4e60-8904-f3184b73d5b2	2021-07-05 06:59:49.745	2021-07-05 06:59:49.745	gql	{"gql": "query getChakshu($id: uuid!) {users: candidate_profile(where: {uuid: {_eq: $id}}) {id: uuid name phone: whatsapp_mobile_number}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "skills"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
4325224c-90f2-4fa0-a15c-fd7721befa8e	2021-07-08 12:44:33.477	2021-07-08 12:44:33.477	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
1c56e232-74b0-4bc6-9fb9-b94d16e64969	2021-07-08 13:45:09.46	2021-07-08 13:45:09.46	gql	{"gql": "query Query {users: getUsersByQuery(queryString: \\"((data.userLocation.state : 'Haryana') AND (data.userLocation.district : 'Charkhi Dadri') AND (data.userLocation.block : 'Badhra')) AND (data.roles : PUBLIC) AND (data.userType.type : student)\\") {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType}}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}}	\N
7d016d07-f7ae-4e06-963c-fd31a29c14f4	2021-07-08 13:45:09.46	2021-07-08 13:45:09.46	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
bf7f1c95-9e98-49b1-aaf0-a86f55e9be77	2021-07-08 13:45:09.46	2021-07-08 13:45:09.46	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
b71ab062-bfb8-485b-8421-eda72f0ea496	2021-07-08 16:40:53.963	2021-07-08 16:40:53.963	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
b2ca7511-b707-4261-ad26-1242e4ed2deb	2021-07-08 16:40:53.963	2021-07-08 16:40:53.963	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
b6cc0f09-6b3a-4467-9ad7-28dd67a408f1	2021-07-08 16:42:03.911	2021-07-08 16:42:03.911	gql	{"gql": "query Query {users: getUsersByQuery(queryString: \\"((data.userLocation.state : 'Haryana') AND (data.userLocation.district : 'Bhiwani') AND (data.userLocation.block : 'Bawani Khera')) AND (data.roles : PUBLIC) AND (data.userType.type : student)\\") {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType}}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}}	\N
5ca8bdfa-7b57-4f8f-949f-51b9faa89c69	2021-07-08 16:42:03.911	2021-07-08 16:42:03.911	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
2b4a7e70-f47d-4a1e-93c1-d88c62c81967	2022-07-06 09:36:05.804	2022-07-06 06:02:41.824	get	{"url": "http://143.110.255.220:8080/fusionAuth/fetchFcmTokens", "type": "GET", "cadence": {"perPage": 5, "retries": 5, "timeout": 60, "concurrent": true, "pagination": true, "concurrency": 10, "retries-interval": 10}, "pageParam": "page", "credentials": {}, "totalRecords": 200000}	UCI Firebase Tokens
93ed4043-b812-40a1-b1bc-b24e457a2143	2021-07-08 12:39:27.362	2021-07-08 12:39:27.362	gql	{"gql": "query Query {users: getUsersByQuery(queryString: \\"(((data.userLocation.state : 'Haryana') AND (data.userLocation.district : 'Ambala')) OR ((data.userLocation.state : 'Haryana') AND (data.userLocation.district : 'Panipat') AND (data.userLocation.block : 'Panipat'))) AND (data.roles : PUBLIC) AND (data.userType.type : student)\\") {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType}}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}}	\N
b4a18b1d-4d50-4531-adec-3327e16a716b	2021-07-08 12:39:27.362	2021-07-08 12:39:27.362	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
fec5ac3e-10ce-474e-95a1-06efb02cadd7	2021-07-08 12:39:27.362	2021-07-08 12:39:27.362	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
ba353725-c27c-4adf-b154-634ed5dc0184	2021-07-08 12:54:22.268	2021-07-08 12:54:22.268	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
97d7f045-c7d1-4cd7-9a89-17a2d71a984c	2021-07-08 12:54:22.268	2021-07-08 12:54:22.268	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
7d426d37-ea3e-42c7-b739-09e3cbec8be8	2021-07-08 13:11:14.197	2021-07-08 13:11:14.197	gql	{"gql": "query Query {users: getUsersByQuery(queryString: \\"((data.userLocation.state : 'Haryana') AND (data.userLocation.district : 'Ambala') AND (data.userLocation.block : 'Ambala-I (City)')) AND (data.roles : PUBLIC) AND (data.userType.type : student)\\") {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType}}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}}	\N
427f2cdf-c129-403c-84fe-73af867b1274	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query getMissionPrernaUsers {users: getUsersByApplication(application: \\"SamagraX Testing App\\", limit: 2000) {id full_name mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}}	\N
515a6028-b5f0-4381-ad97-e8651b820412	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($phoneNo: String) {users: getUsersByQuery(queryString: $phoneNo) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
056d0f87-8287-4c1e-8b2d-19f8f9d7e419	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
ad3e8427-8286-42fc-8a11-0c3977d9194f	2021-07-08 13:11:14.197	2021-07-08 13:11:14.197	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
8d6a12f7-7820-428f-a2f4-001f054ff98e	2021-07-08 13:11:14.197	2021-07-08 13:11:14.197	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
39d297a8-a5a5-434e-be2f-166d83f7c417	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query getMissionPrernaUsers {users: getUsersByApplication(application: \\"SamagraX Testing App\\", limit: 2000) {id full_name mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}}	\N
f59038e4-8c7e-4b79-a368-ab1200d5c566	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($phoneNo: String) {users: getUsersByQuery(queryString: $phoneNo) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
3fb0e35f-46dc-44cf-95cc-43d1df1c9a11	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	rest-service	{"url": "http://localhost:8888", "cadence": {"retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10}, "credentials": {"vault": "diksha", "variable": "tranformerHeadersRasa"}}	\N
c4a94310-66f6-44fa-892d-013e1a4ddb36	2021-07-08 12:42:27.29	2021-07-08 12:42:27.29	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
e7774a21-d16b-41ab-bebf-a5c8bd5ac85a	2021-07-08 12:42:27.29	2021-07-08 12:42:27.29	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
94b7c56a-6537-49e3-88e5-4ea548b2f075	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	odk	{"cadence": {"retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10}, "credentials": {"vault": "samagra", "variable": "samagraMainODK"}}	\N
65020b3a-1582-4a2d-8d7c-70615a14d112	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query getMissionPrernaUsers {users: getUsersByApplication(application: \\"SamagraX Testing App\\", limit: 2000) {id full_name mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}}	\N
683cda34-67e5-4314-addb-52bf713c2d03	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($phoneNo: String) {users: getUsersByQuery(queryString: $phoneNo) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
9aa1a713-e01a-497a-84b7-7a9ad58078ea	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
7c113a19-32e5-4c52-9bd5-26a90b316db5	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
f5d0df5b-f97a-4d7d-880f-27d8fade3ced	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query getMissionPrernaUsers {users: getUsersByApplication(application: \\"SamagraX Testing App\\", limit: 2000) {id full_name mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}}	\N
d97ca587-f513-4c8a-9ff4-05d2bc8b3d00	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($phoneNo: String) {users: getUsersByQuery(queryString: $phoneNo) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
0583bda2-feb3-4cf8-b76f-0b4b7e00bb55	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
11488102-448c-4a55-8d2d-8cb388946a56	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query getMissionPrernaUsers {users: getUsersByApplication(application: \\"SamagraX Testing App\\", limit: 2000) {id full_name mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}}	\N
571f4849-798e-4806-b068-77b3d37bce9d	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($phoneNo: String) {users: getUsersByQuery(queryString: $phoneNo) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
aa53af62-6b41-4ee4-9fc6-eeaaa60584e7	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
c69466da-943c-49ab-ab88-a87f5fa76185	2021-06-16 19:27:55.992	2021-06-16 19:27:55.992	gql	{"gql": "query getChakshu {users: candidate_profile(where: {id: {_eq: 27}}) {id name mobilePhone: whatsapp_mobile_number}}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "rozgarBotGQL"}}	\N
4943e900-2ada-42b0-9e76-c76bc31a8aef	2021-06-16 19:27:55.992	2021-06-16 19:27:55.992	gql	{"gql": "query getChakshu($phoneNo: String!) {users: candidate_profile(where: {whatsapp_mobile_number: {_eq: $phoneNo}}) { id: uuid name phone: whatsapp_mobile_number}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "rozgarBotGQL"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
fb1ba557-5511-47ff-829d-13ff7ae17be9	2021-06-16 19:27:55.992	2021-06-16 19:27:55.992	gql	{"gql": "query getChakshu($id: uuid!) {users: candidate_profile(where: {uuid: {_eq: $id}}) {id: uuid name phone: whatsapp_mobile_number}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "rozgarBotGQL"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
0f7f2826-4fc3-419a-923a-478032d0d07c	2023-03-18 07:35:39.23	2023-03-18 07:35:39.231	GET	\N	\N
96cc2670-6c7d-42f3-9051-409067285bb9	2021-07-08 12:44:33.477	2021-07-08 12:44:33.477	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
5d35524d-75df-45f9-8cad-e16d561c79c9	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query getMissionPrernaUsers {users: getUsersByApplication(application: \\"SamagraX Testing App\\", limit: 2000) {id full_name mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}}	\N
06fa6ffd-7bde-4910-b039-910a20459280	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($phoneNo: String) {users: getUsersByQuery(queryString: $phoneNo) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
e93e82ba-28e2-46a0-9a05-8259420ca60e	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
40a8a8ab-5b66-440e-852b-454483bdb06d	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query getMissionPrernaUsers {users: getUsersByApplication(application: \\"SamagraX Testing App\\", limit: 2000) {id full_name mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}}	\N
262d7e74-a06f-4273-9395-3d32166bdca1	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($phoneNo: String) {users: getUsersByQuery(queryString: $phoneNo) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
bd6c42a6-e3f2-4516-b6cd-3d45ae623cae	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
032774e8-1af6-4e97-8eda-a613dbb74753	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query getMissionPrernaUsers {users: getUsersByApplication(application: \\"SamagraX Testing App\\", limit: 2000) {id full_name mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}}	\N
3f12be55-2962-4166-bb73-96a78950b72c	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($phoneNo: String) {users: getUsersByQuery(queryString: $phoneNo) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
73dcab05-e81d-47ba-91f7-c49ce52d1c73	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
8aff5172-7e7d-43be-a75f-c038ad6b40e1	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query getMissionPrernaUsers {users: getUsersByApplication(application: \\"SamagraX Testing App\\", limit: 2000) {id full_name mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}}	\N
95dc77c9-184e-444b-8930-d5ff7d94bd39	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($phoneNo: String) {users: getUsersByQuery(queryString: $phoneNo) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
84863dba-d4bd-46d3-aecb-c38b845b2e80	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
cab5ccee-88ad-4818-a8d5-fb8adcc76d8a	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query getMissionPrernaUsers {users: getUsersByApplication(application: \\"SamagraX Testing App\\", limit: 2000) {id full_name mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}}	\N
555f6739-e770-4c99-b40e-420b4a92af0e	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($phoneNo: String) {users: getUsersByQuery(queryString: $phoneNo) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
d13380b1-056b-4449-9e80-170e2e4e891f	2021-06-16 06:03:06.01	2021-06-16 06:03:12.609	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {id username mobilePhone data: jdata}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "commsgql"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
1e2580f4-2fc3-4e5f-89b3-8c470e4be8c2	2021-06-22 00:04:37.405	2021-06-22 00:04:37.405	gql	{"gql": "query Query {users: getCandidatesForVacancy(vacancyID: 15, threshold: 16) {id name whatsapp_mobile_number mobile_number vacancyData marks }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "skills"}}	\N
3b954c1d-8411-4134-af2d-222eff7288fc	2021-06-22 00:04:37.405	2021-06-22 00:04:37.405	gql	{"gql": "query getChakshu($phoneNo: String!) {users: candidate_profile(where: {whatsapp_mobile_number: {_eq: $phoneNo}}) { id: uuid name phone: whatsapp_mobile_number}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "skills"}, "verificationParams": {"phoneNo": "9415787824"}}	\N
f9489adc-e725-4e72-8b38-a25f30181b6c	2021-06-22 00:04:37.405	2021-06-22 00:04:37.405	gql	{"gql": "query getChakshu($id: uuid!) {users: candidate_profile(where: {uuid: {_eq: $id}}) {id: uuid name phone: whatsapp_mobile_number}}", "cadence": {"perPage": 10000, "retries": 0, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "skills"}, "verificationParams": {"id": "f5c49bcc-b96c-4206-950e-a2ba4319f149"}}	\N
1a905d52-265c-4370-92cb-1e75db834881	2021-06-29 08:11:49.171	2021-06-29 08:11:49.171	gql	{"gql": "query getChakshu {users: candidate_profile(where: {id: {_eq: 27}}) {id name mobilePhone: whatsapp_mobile_number}}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "rozgarBotGQL"}}	\N
02816797-2d6c-4fda-8200-4de886998e46	2021-07-08 16:42:03.911	2021-07-08 16:42:03.911	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
9397d5d3-d607-49db-8d61-446e0b675854	2021-07-08 16:59:19.114	2021-07-08 16:59:19.114	gql	{"gql": "query Query {users: getUsersByQuery(queryString: \\"((data.userLocation.state : 'Haryana') AND (data.userLocation.district : 'Ambala') AND (data.userLocation.block : 'Ambala-II (Cantt)')) AND (data.roles : PUBLIC) AND (data.userType.type : student)\\") {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType}}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}}	\N
737d44fd-d3e7-4d82-8a6e-09f401feb817	2021-07-08 16:59:19.114	2021-07-08 16:59:19.114	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
37a3955d-2d39-4535-97bb-2060b32d0002	2021-07-08 16:59:19.114	2021-07-08 16:59:19.114	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
ec1c73a3-f6b6-4a99-81fc-4ae24373ae26	2021-07-08 18:24:36.441	2021-07-08 18:24:36.441	gql	{"gql": "query Query {users: getUsersByQuery(queryString: \\"((data.userLocation.state : 'Haryana') AND (data.userLocation.district : 'Bhiwani') AND (data.userLocation.block : 'Badhra')) AND (data.roles : PUBLIC) AND (data.userType.type : student)\\") {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType}}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}}	\N
c22ea850-b4ec-47d5-bdc5-e5ba6433b51d	2021-07-08 18:24:36.441	2021-07-08 18:24:36.441	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
838f8a31-64cf-4b39-87d0-6b4c3f628233	2021-07-08 18:24:36.441	2021-07-08 18:24:36.441	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
13b5498a-7227-4e2f-a870-c525619fd5ba	2021-07-08 18:37:17.073	2021-07-08 18:37:17.073	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
8657c864-88f6-4e8f-8ce9-7e3e7bf6958c	2021-07-08 18:37:17.073	2021-07-08 18:37:17.073	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
dee02320-f414-42ee-a08b-fc2bbb86dd0a	2022-07-06 09:36:05.804	2022-07-06 06:02:41.824	get	{"url": "http://143.110.255.220:8080/service/testUserSegment", "type": "GET", "cadence": {"perPage": 5, "retries": 5, "timeout": 60, "concurrent": true, "pagination": true, "concurrency": 10, "retries-interval": 10}, "pageParam": "page", "credentials": {}, "totalRecords": 200000}	UCI User Segment
27e46dc5-9669-4c77-a65b-d145c38e9282	2021-07-08 18:46:04.63	2021-07-08 18:46:04.63	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
da0f17ca-d9d0-4658-9b8a-c94de94d576b	2021-07-08 18:46:04.63	2021-07-08 18:46:04.63	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
4951f07e-e88c-4fa0-9d82-e40fe80256c6	2021-07-09 08:51:43.531	2021-07-09 08:51:43.531	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
f9299338-c43f-45af-b593-7c43f4cc887c	2021-07-09 08:51:43.531	2021-07-09 08:51:43.531	gql	{"gql": "query Query($id: String) {users: getUsersByQuery(queryString: $id) {lastName firstName device customData externalIds framework lastName roles rootOrgId userLocation userType }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "dummygql"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	\N
794b5378-4043-4b48-a086-af8179126cb8	2021-07-13 07:40:59.267	2021-07-13 07:40:59.267	odk	{"cadence": {"retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10}, "credentials": {"vault": "samagra", "variable": "samagraSandboxODK"}}	\N
af9be82e-d59e-4eba-83e4-d19c7f07d8f6	2021-11-11 12:33:44.768	2021-11-11 12:33:44.768	odk	{"cadence": {"retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10}, "credentials": {"vault": "samagra", "variable": "samagraSandboxODK"}}	\N
ff170fed-cb7a-463d-a8f9-4c8371241e16	2021-11-12 13:14:32.667	2021-11-12 13:14:32.667	odk	{"cadence": {"retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10}, "credentials": {"vault": "samagra", "variable": "samagraSandboxODK"}}	\N
2e38e1bb-1c74-4546-95f3-45a084d0ec3c	2021-11-16 06:29:21.057	2021-11-16 06:29:21.057	odk	{"cadence": {"retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10}, "credentials": {"vault": "samagra", "variable": "samagraSandboxODK"}}	\N
74f9f3c0-856b-4299-ab76-ec4a027bf2bf	2021-11-16 12:40:20.507	2021-11-16 12:40:20.507	odk	{"cadence": {"retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10}, "credentials": {"vault": "samagra", "variable": "samagraSandboxODK"}}	\N
3a97cd1a-834f-488c-9c39-252261ae23d0	2021-12-16 06:51:03.362	2021-12-16 06:51:03.362	odk	{"cadence": {"retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10}, "credentials": {"vault": "samagra", "variable": "samagraSandboxODK"}}	\N
7280592a-fd1d-4774-96de-77fd397ade86	2021-12-17 03:55:36.124	2021-12-17 03:55:36.124	odk	{"cadence": {"retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10}, "credentials": {"vault": "samagra", "variable": "samagraSandboxODK"}}	\N
8f40dd4f-147a-4c6c-8166-3ff731fad84e	2022-01-31 05:15:58.747	2022-01-31 05:15:58.747	gql	{"gql": "query getCandidatesByPhone($phoneNo: String!) { users: candidate_profile(where: {mobile_number: {_eq: $phoneNo}}) { id mobile_number phone: whatsapp_mobile_number whatsapp_mobile_number name district_travel { id } location { longitude latitude } matches_count: candidate_vacancy_interests_aggregate(where: {interested: {_is_null: true}, vacancy_detail: {is_live: {_eq: true}}}) { aggregate { count } } matched: candidate_vacancy_interests(where: {interested: {_is_null: true}, vacancy_detail: {is_live: {_eq: true}}}) { vacancy_detail { job_role employer_detail { company_name district_name { name } } expected_salary { salary_range } id } } interested: candidate_vacancy_interests(where: {interested: {_eq: true}, vacancy_detail: {is_live: {_eq: true}}}) { id vacancy_detail { job_role expected_salary { salary_range } employer_detail { company_name district_name { name } } id } } denied: candidate_vacancy_interests(where: {interested: {_eq: false}, vacancy_detail: {is_live: {_eq: true}}}) { id vacancy_detail { job_role expected_salary { salary_range } employer_detail { company_name district_name { name } } id } } } }", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "rozgarBotGQL"}, "verificationParams": {"phoneNo": "9415787824"}}	Rozgar Candidates By Phone
e873a7dc-87e9-44e7-af7f-2e05c8bb33be	2022-01-31 05:17:07.741	2022-01-31 05:17:07.741	gql	{"gql": "query getRecruiterByPhone($phoneNo: String!) { users: employer_details(where: {mobile_number: {_eq: $phoneNo}}) { id phone: mobile_number company_name name location { longitude latitude } } }", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "rozgarBotGQL"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	Rozgar Recruiters
21e86402-d030-4315-8120-647e38cbd01e	2022-03-23 11:29:24.305	2022-03-23 12:37:10.906	gql	{"gql": "query getAllCandidates { users: candidate_profile(limit: 5){ id mobile_number phone: whatsapp_mobile_number whatsapp_mobile_number name district_travel { id } location { longitude latitude } matches_count: candidate_vacancy_interests_aggregate(where: {interested: {_is_null: true}, vacancy_detail: {is_live: {_eq: true}}}) { aggregate { count } } matched: candidate_vacancy_interests(where: {interested: {_is_null: true}, vacancy_detail: {is_live: {_eq: true}}}) { vacancy_detail { job_role employer_detail { company_name district_name { name } } expected_salary { salary_range } id } } interested: candidate_vacancy_interests(where: {interested: {_eq: true}, vacancy_detail: {is_live: {_eq: true}}}) { id vacancy_detail { job_role expected_salary { salary_range } employer_detail { company_name district_name { name } } id } } denied: candidate_vacancy_interests(where: {interested: {_eq: false}, vacancy_detail: {is_live: {_eq: true}}}) { id vacancy_detail { job_role expected_salary { salary_range } employer_detail { company_name district_name { name } } id } } } }", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "rozgarBotGQL"}, "verificationParams": {"id": "(data.device.deviceID : '96102c3f-2c22-4614-8dcc-6b130cefe586')"}}	Rozgar Recruiters - Broadcast Test
c765edda-8100-47e7-96f2-77c5fe99487d	2022-08-22 08:02:16.767	2022-08-22 08:02:16.768	gql	{"gql": "query Query {users: getCandidatesForVacancy(vacancyID: 15, threshold: 16) {id name whatsapp_mobile_number mobile_number vacancyData marks }}", "cadence": {"perPage": 10000, "retries": 5, "timeout": 60, "concurrent": true, "pagination": false, "retries-interval": 10}, "pageParam": "page", "credentials": {"vault": "samagra", "variable": "skills"}}	\N
02854c26-b2a6-4176-ac6d-38b7a5a8f576	2023-03-18 07:38:08.886	2023-03-18 07:38:08.886	get	{"url": "http://103.154.251.109:8070/segments/1/mentors?deepLink=nipunlakshya://chatbot", "type": "GET", "cadence": {"perPage": 5, "retries": 5, "timeout": 60, "concurrent": true, "pagination": true, "concurrency": 10, "retries-interval": 10}, "pageParam": "page", "credentials": {}, "totalRecords": 200000}	\N
\.


--
-- Data for Name: Transformer; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."Transformer" (id, "createdAt", "updatedAt", name, tags, config, "serviceId") FROM stdin;
02f010b8-29ce-41e5-be3c-798536a2818b	2021-06-16 06:03:52.868	2021-06-16 06:03:55.937	PassThrough	{generic}	{"validation": {"in": "xMessage-XML-In", "out": "xMessage-XML-Out"}}	3fb0e35f-46dc-44cf-95cc-43d1df1c9a11
bbf56981-b8c9-40e9-8067-468c2c753659	2021-06-16 06:03:52.868	2021-06-16 06:03:55.937	SamagraODKAgg	{ODK}	{}	94b7c56a-6537-49e3-88e5-4ea548b2f075
7cae4d04-6def-4a9b-8e1e-70dc7fee4e28	2021-07-13 07:40:59.267	2021-07-13 07:40:59.267	sunbird-tara-odk	{ODK}	{}	794b5378-4043-4b48-a086-af8179126cb8
19c6a532-436d-4487-ac98-257343a8cae7	2021-11-11 12:33:44.768	2021-11-11 12:33:44.768	RozgarODK	{ODK}	{}	af9be82e-d59e-4eba-83e4-d19c7f07d8f6
358ee7a7-4e2c-4ea5-acab-92e5d668695c	2021-11-12 13:14:32.667	2021-11-12 13:14:32.667	wabot1	{ODK}	{}	ff170fed-cb7a-463d-a8f9-4c8371241e16
637e2858-18f6-45a3-a492-6c9027963e0c	2021-11-16 06:29:21.057	2021-11-16 06:29:21.057	RozgarTesting	{ODK}	{}	2e38e1bb-1c74-4546-95f3-45a084d0ec3c
d8b69b04-a683-4217-a1bf-9b5f27f0fe7a	2021-11-16 12:40:20.507	2021-11-16 12:40:20.507	wabot161121	{ODK}	{}	74f9f3c0-856b-4299-ab76-ec4a027bf2bf
412e9390-e11e-4732-abb1-1caac476f018	2021-12-16 06:51:03.362	2021-12-16 06:51:03.362	LifeSkillsODK	{ODK}	{}	3a97cd1a-834f-488c-9c39-252261ae23d0
e1d72ae5-fe03-4c9a-83ec-6f689393a558	2021-12-17 03:55:36.124	2021-12-17 03:55:36.124	LifeSkills	{ODK}	{}	7280592a-fd1d-4774-96de-77fd397ade86
774cd134-6657-4688-85f6-6338e2323dde	2022-03-23 11:18:40.43	2022-03-23 11:18:40.43	BroadcastTransformer	{Broadcast}	{}	94b7c56a-6537-49e3-88e5-4ea548b2f075
228b739f-38b4-47d9-a7c4-7f6f30178821	2022-08-22 08:02:16.767	2022-08-22 08:02:16.768	Generic Transformer	{generic}	{}	c765edda-8100-47e7-96f2-77c5fe99487d
\.


--
-- Data for Name: TransformerConfig; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."TransformerConfig" (id, "createdAt", "updatedAt", "transformerId", meta, "conversationLogicId") FROM stdin;
7a3dab22-43de-46ec-b19a-37f1be55d483	2022-06-02 07:33:18.461	2022-06-02 07:33:18.462	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	5640c1a2-aa22-47a5-b0fc-e176a2e15413
c3d9754b-be2c-43bc-aeb7-cccbd3f58a5a	2022-06-02 07:33:18.76	2022-06-02 07:33:18.76	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	938ed2e5-2b76-4ec8-877c-cfdf7e9cbc3a
813bbfbd-2357-4e7d-bfa9-ecfe6a607c01	2022-06-02 07:33:19.058	2022-06-02 07:33:19.058	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	623b6944-4b59-4672-8f75-0c2946ca856f
18aee0e9-d7f8-4a3a-ab85-c915da3ce8eb	2022-06-02 07:33:19.368	2022-06-02 07:33:19.368	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	2dbcd68d-7665-465d-a9a3-34286ab8d8b4
41e76dfe-b0c3-4890-94f8-e6aa907d3659	2022-06-02 07:33:19.66	2022-06-02 07:33:19.661	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	f7f40cc3-93a3-4d48-b7da-b5545f48ffd6
bdcdb6e0-310d-4f33-af94-59c1c5c24acd	2022-06-02 07:33:19.956	2022-06-02 07:33:19.957	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "global_form"}	e5c5334b-8ce1-4a53-be9d-78d24fa2e0e1
d8eb0670-1477-4eb9-b358-5a35dd8fab63	2022-06-02 07:33:20.292	2022-06-02 07:33:20.293	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	419b79d5-3a74-4250-9df3-6633c0b4b380
8fa014d2-a990-43df-ac49-ceb10cd85f18	2022-06-02 07:33:20.586	2022-06-02 07:33:20.586	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	106a6aaa-a1c6-4a6e-9cac-ffe35997c9fd
c0b44d7c-755b-49b4-946f-5f7b734dbef3	2022-06-02 07:33:20.883	2022-06-02 07:33:20.884	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "Rozgar-Saathi-MVP-EmpReg-Vac-Chatbot4"}	d97b0d3e-2662-44ad-a777-3bab74a5fcf1
628682b0-1635-4233-91b0-0b3db86b370b	2022-06-02 07:33:21.137	2022-06-02 07:33:21.138	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	35e927b0-d3bf-4a26-a21b-c6c342a0e15a
976b0810-69a0-4875-9de1-c862db9925a1	2022-06-02 07:33:21.434	2022-06-02 07:33:21.435	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "Rozgar-Saathi-MVP-Candidate-Interest-Confirm", "hiddenFields": [{"name": "candidate_name", "path": "name", "type": "param", "config": {"dataObjName": "user"}}, {"name": "vacancy_name", "path": "vacancyData.jobRole", "type": "param", "config": {"dataObjName": "user"}}, {"name": "candidate_mobile", "path": "whatsapp_mobile_number", "type": "param", "config": {"dataObjName": "user"}}, {"name": "vacancy_id", "path": "vacancyData.id", "type": "param", "config": {"dataObjName": "user"}}, {"name": "recruiter_name", "path": "vacancyData.employer_detail.company_name", "type": "param", "config": {"dataObjName": "user"}}, {"name": "candidate_id", "path": "id", "type": "param", "config": {"dataObjName": "user"}}]}	5d39afbb-0e49-4e6b-8d27-99bbe343aed8
5c85985e-4bf0-41fd-9740-c1d3581a510e	2022-06-02 07:33:21.743	2022-06-02 07:33:21.743	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	c875eb68-1bed-41cb-8763-5982a2affb74
4cc7182e-6ebc-4ceb-b7a5-84bbbb2766fa	2022-06-02 07:33:22.043	2022-06-02 07:33:22.044	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	026984c9-8585-42ef-a39c-d3f7af1cf74d
87195b50-96f4-4605-a65a-f430f47e09a3	2022-06-02 07:33:22.339	2022-06-02 07:33:22.339	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	ff9447b0-1ac0-49a7-a812-1152b2fe8192
0b7d64c9-eb3b-4e3a-9def-92cccaa8e913	2022-06-02 07:33:22.637	2022-06-02 07:33:22.638	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	e86f0efd-9cc9-423c-9ff5-fd0870d60f3b
32c60487-5640-45ae-a1d4-45a24c71607e	2022-06-02 07:33:22.933	2022-06-02 07:33:22.934	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	d0079ffb-a78f-4631-b350-25e242b9d2a8
43ebd9bd-99cb-42d3-82d7-ec2d42078557	2022-06-02 07:33:23.233	2022-06-02 07:33:23.233	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	45ee7e1b-acd5-4d3b-9bd1-20b1a1ca2a22
6bda8e3c-4f8a-48d2-9eb4-02acf403fab9	2022-06-02 07:33:23.526	2022-06-02 07:33:23.527	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	b1c4d7b8-153c-4f73-9aef-e4fcc7c0ca94
0585dc40-4439-438d-bce4-07cf254bd382	2022-06-02 07:33:23.823	2022-06-02 07:33:23.823	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	4262251e-5612-49b9-aa2f-64934b9b292f
c1daf796-3d8f-46aa-b76c-90a1f3f4156d	2022-06-02 07:33:24.079	2022-06-02 07:33:24.079	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	1ac4cb55-cddd-46fd-8803-9097c98735c7
32d917c1-400b-46e1-8c5d-46446079fbd4	2022-06-02 07:33:24.376	2022-06-02 07:33:24.376	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	01316dba-f089-4eb5-8bf2-d88d29c86ad9
d2101dcb-5fc1-451c-967b-9f099205968f	2022-06-02 07:33:24.67	2022-06-02 07:33:24.671	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	89509ee1-1f25-4315-9694-e6bf9ab2b368
05670597-7464-4849-a39e-545a17fc1b15	2022-06-02 07:33:24.924	2022-06-02 07:33:24.925	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "global_form"}	caff100d-7d62-4246-b7c6-b9fc833decfa
530e8926-9d46-4c21-8499-d22add54375f	2022-06-02 07:33:25.218	2022-06-02 07:33:25.219	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	b6942720-faf2-4da4-90dc-e0584b691a1c
51968223-ee10-437f-bfba-36e24a1d9d91	2022-06-02 07:33:25.513	2022-06-02 07:33:25.513	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "global_form"}	ef728558-0bcf-4045-a791-315354c0c435
12fb7b86-f9f8-4a6e-9b58-141e012ce85b	2022-06-02 07:33:25.805	2022-06-02 07:33:25.806	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "sunbird-demo-april"}	c684a3f7-6b92-4629-86eb-a67c39d51480
c190e8cd-ba67-4ff9-95f8-2ce6ed1040ba	2022-06-02 07:33:26.102	2022-06-02 07:33:26.102	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "global_form"}	ec1816c3-0f87-4c61-813e-945c43d43355
476c2e12-b235-4b23-b9aa-b65e1a3a594d	2022-06-02 07:33:26.397	2022-06-02 07:33:26.398	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-1"}	834d7364-7136-4719-a441-559be23c9ee8
0f45acbe-5761-4b47-b53a-e207b0bf2674	2022-06-02 07:33:26.695	2022-06-02 07:33:26.696	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": ""}	ad91f5c6-93f8-433b-9461-aafb896812db
585f75c2-ff3b-4caf-a300-ad47b264a461	2022-06-02 07:33:26.989	2022-06-02 07:33:26.989	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-2"}	61cbdfb6-e1c1-4433-a2d4-ccc502cfd5bd
e9feafa0-e1d1-40f6-be07-c9f434990763	2022-06-02 07:33:27.296	2022-06-02 07:33:27.296	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "Rozgar-Saathi-MVP-Chatbot-New"}	3f7d264b-5e18-4309-88c2-de190a95db02
e9a5fe3c-87bc-4832-bfa5-76223eec02e7	2022-06-02 07:33:27.558	2022-06-02 07:33:27.559	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "Rozgar-Saathi-MVP-Chatbot-New"}	4ca8abf3-f1c7-4f8d-967d-ee059d32ea19
9ab194d1-ccc0-4a5b-9438-c9dad0c2098b	2022-06-02 07:33:27.811	2022-06-02 07:33:27.812	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-4"}	f6b80a0c-b39e-4b19-ac8d-e103825c991a
100c5f58-e6bd-4bd0-ac7a-30cc88de0c35	2022-06-02 07:33:28.066	2022-06-02 07:33:28.066	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-2"}	9fd2c5e1-4e33-4a51-b097-c735d3f92d84
2c55f2ee-4dc8-40df-bc4c-7bee6ac8cabd	2022-06-02 07:33:28.365	2022-06-02 07:33:28.365	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "ss_form_mpc"}	6293fd66-43e2-4323-9b4e-ad7a3d95bbf8
7c717c10-b160-4a36-bc09-1ce6f197b1c1	2022-06-02 07:33:28.629	2022-06-02 07:33:28.63	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-4"}	8d6a7e32-0d6c-47c1-9fa6-529e3c4de48a
8d6b1c4c-e654-4143-ad5a-b7f84ca23b54	2022-06-02 07:33:28.926	2022-06-02 07:33:28.927	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-4"}	38044707-ec23-4e8a-9482-6aa462b010b5
d7d5c261-95b5-4c8e-91a2-09486cd64b1a	2022-06-02 07:33:29.221	2022-06-02 07:33:29.222	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-4"}	52dedc00-8cea-4cfa-8ac9-9a7c68bad406
1215e247-dba2-49bf-a83c-b8906064a058	2022-06-02 07:33:29.516	2022-06-02 07:33:29.516	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-4"}	21b7cee2-b0e3-4778-bc71-a7db8e0e9933
0c8dc74d-ab3a-45b9-b247-74522531b093	2022-06-02 07:33:29.81	2022-06-02 07:33:29.811	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-4"}	7a7debc3-d0ed-4fa0-b0d2-3a632e87aa89
355185ee-8b7d-4dd6-949c-2f4a9d4bdd1c	2022-06-02 07:33:30.066	2022-06-02 07:33:30.067	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-4"}	de059e59-a1fe-4f2d-9209-112f19912e32
bb0d4bb6-ff8c-4d0e-9c71-34a47853aebe	2022-06-02 07:33:30.365	2022-06-02 07:33:30.366	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "Rozgar-Saathi-MVP-Chatbot-New"}	ad552ba3-296d-4be1-98bd-a10f8519b679
25de377d-fd79-4d69-8ff6-4f31bc0d9938	2022-06-02 07:33:30.627	2022-06-02 07:33:30.627	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-4"}	90aea89e-ee25-48c0-ad39-87586d538183
a77f6d3a-5c35-4b15-9506-b9fdf59d8963	2022-06-02 07:33:30.924	2022-06-02 07:33:30.925	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-2"}	b254a6b2-abce-43da-bd05-ae801bcab71c
53e35f0c-968d-4e6b-b7f4-5a3e7d9ac565	2022-06-02 07:33:31.432	2022-06-02 07:33:31.433	7cae4d04-6def-4a9b-8e1e-70dc7fee4e28	{"formID": "global_bot_1"}	32702947-2072-4fb9-9936-3fd2bcb34742
89141b05-3a44-4fc9-bea2-872031f42af7	2022-06-02 07:33:31.726	2022-06-02 07:33:31.726	7cae4d04-6def-4a9b-8e1e-70dc7fee4e28	{"formID": "sunbird-general-bot"}	0d4ee8e9-8501-4969-8049-6bf918ba6d17
5de66a49-20b7-414b-ad40-5ec0758c7933	2022-06-02 07:33:31.976	2022-06-02 07:33:31.977	7cae4d04-6def-4a9b-8e1e-70dc7fee4e28	{"formID": "sunbird-karnataka-bot"}	e342bd51-a322-4973-ab89-a8a382d514b9
a553d572-705b-4d70-b1b1-b97946a9b13a	2022-06-02 07:33:32.23	2022-06-02 07:33:32.231	7cae4d04-6def-4a9b-8e1e-70dc7fee4e28	{"formID": "global_form"}	18f2a486-63ef-4072-a16b-d9bd9fcc0112
b0fab5c5-3f67-4a6d-9e87-b8c0414543f1	2022-06-02 07:33:32.532	2022-06-02 07:33:32.532	7cae4d04-6def-4a9b-8e1e-70dc7fee4e28	{"formID": "mandatory-consent-v1"}	0763144a-9a95-4fc5-9ae2-dbf1816ec384
64f3a8b6-dfc4-442b-834f-602cf029665f	2022-06-02 07:33:32.827	2022-06-02 07:33:32.828	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "global_bot_1"}	dd33fa11-d66e-4645-844a-106f6f94b7d9
d170baac-bd5e-46a6-9e5c-93bda2be5ec8	2022-06-02 07:33:33.125	2022-06-02 07:33:33.126	19c6a532-436d-4487-ac98-257343a8cae7	{"form": "https://hosted.my.form.here.com", "formID": "rozgar-11112021"}	4ea24f2c-74eb-4f20-b39f-a1ab810588f1
a26e9ad3-437c-4d70-be1d-9d67b3cd105d	2022-06-02 07:33:33.42	2022-06-02 07:33:33.421	19c6a532-436d-4487-ac98-257343a8cae7	{"form": "https://hosted.my.form.here.com", "formID": "Rozgar-Saathi-MVP-EmpReg-Vac-Chatbot4"}	84941b0a-6eae-4b46-a810-2065d8bc6f8a
b02a91e9-0fa8-409d-9838-26287dc9629c	2022-06-02 07:33:33.723	2022-06-02 07:33:33.723	19c6a532-436d-4487-ac98-257343a8cae7	{"form": "https://hosted.my.form.here.com", "formID": "rozgar-11112021"}	5eca4f02-e5c9-4109-b238-52ce5ce845dc
a9565293-b30c-422b-99bb-d8b0f7638b3c	2022-06-02 07:33:34.016	2022-06-02 07:33:34.017	19c6a532-436d-4487-ac98-257343a8cae7	{"form": "https://hosted.my.form.here.com", "formID": "rozgar-11112021"}	0bf66a2c-e504-4fce-9970-43620888929a
f369ad25-affa-429f-9c52-7de23bec665d	2022-06-02 07:33:34.311	2022-06-02 07:33:34.311	19c6a532-436d-4487-ac98-257343a8cae7	{"form": "https://hosted.my.form.here.com", "formID": "rozgar-11112021"}	be24a027-8856-4439-958b-43a1057ddcfe
c60c4b38-7fb7-43fe-a059-090fa17990d5	2022-06-02 07:33:34.604	2022-06-02 07:33:34.605	358ee7a7-4e2c-4ea5-acab-92e5d668695c	{"form": "https://hosted.my.form.here.com", "formID": "rozgar-11112021"}	fe6dd157-ca49-4101-9ec0-aa1d871c5955
6251bd43-dc3f-43d4-82af-13b55134322d	2022-06-02 07:33:34.897	2022-06-02 07:33:34.898	637e2858-18f6-45a3-a492-6c9027963e0c	{"form": "https://hosted.my.form.here.com", "formID": "rozgar-11112021"}	3a583e97-853e-40c4-8be2-0ed9459ecf64
6d1c9994-0623-4f0f-8f2d-216427140ec3	2022-06-02 07:33:35.152	2022-06-02 07:33:35.153	d8b69b04-a683-4217-a1bf-9b5f27f0fe7a	{"formID": "rozgar-11112021"}	ec5287e7-886e-4e46-93e0-ab616973b370
4ef0dddd-a3a8-492d-ade3-4c70e192ca89	2022-06-02 07:33:35.459	2022-06-02 07:33:35.46	d8b69b04-a683-4217-a1bf-9b5f27f0fe7a	{"formID": "Rozgar-Saathi-MVP-Chatbot1"}	82733742-65cb-493d-baee-3299b9dfe882
f63042bd-fe1c-4257-a1aa-73ce40d892dc	2022-06-02 07:33:35.754	2022-06-02 07:33:35.755	637e2858-18f6-45a3-a492-6c9027963e0c	{"formID": "rozgar-candidate-registration"}	7f8f2086-34e8-4a6d-a7ed-302642fd043b
1cc666f0-3f1d-497c-a5c3-30b8e0be6c5e	2022-06-02 07:33:36.063	2022-06-02 07:33:36.063	637e2858-18f6-45a3-a492-6c9027963e0c	{"formID": "rozgar-recruiter"}	742c2671-4dab-4ccc-adab-1167f98c3dc7
6af2951a-5d44-4ceb-8dd9-681dfb0e301c	2022-06-02 07:33:36.317	2022-06-02 07:33:36.317	637e2858-18f6-45a3-a492-6c9027963e0c	{"formID": "rozgar-candidate-interest-form"}	458698db-b305-467a-9ea3-5ceea95503d6
9f559142-7ed0-47dd-982e-c2e9856f9639	2022-06-02 07:33:36.569	2022-06-02 07:33:36.57	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "global_form_v12"}	95d75bee-689d-43cf-a4bf-184a40c4e8a8
eab62dcf-2b52-49c1-ab01-a55d0764f34c	2022-06-02 07:33:36.821	2022-06-02 07:33:36.822	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "sunbird_tara_bot_form_v11"}	74a38946-9979-49a4-841e-e244d0d2ac3c
041ac6e3-cab4-4fb1-ba01-dfd1e38b2e2e	2022-06-02 07:33:37.076	2022-06-02 07:33:37.077	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "global_form_v24"}	1cd933be-22af-4ca2-8726-eaab4ec1c60b
3358f520-a9a3-4651-9d1b-77f62d69810f	2022-06-02 07:33:37.371	2022-06-02 07:33:37.372	e1d72ae5-fe03-4c9a-83ec-6f689393a558	{"form": "https://hosted.my.form.here.com", "formID": "baps"}	8eb5eb29-b37f-443c-9e2b-147a560698fc
354df316-8554-4ca4-8807-1cad898e6f6a	2022-06-02 07:33:37.665	2022-06-02 07:33:37.666	e1d72ae5-fe03-4c9a-83ec-6f689393a558	{"formID": "Baps-1"}	80c2331a-d581-4fcd-9b5d-cabc01fb42c0
81f1f2e0-8c5a-4a2e-a6c0-361ae11b24dd	2022-06-02 07:33:37.923	2022-06-02 07:33:37.924	e1d72ae5-fe03-4c9a-83ec-6f689393a558	{"formID": "rozgar-candidate-vFF", "select1": [{"name": "select_one vacancies", "type": "param", "label": {"path": "${vacancy_detail.job_role} at ${employer_detail.company_name}"}, "value": {"path": "${vacancy_detail.id}"}, "config": {"dataObjName": "user"}, "listPath": "matched"}], "triggers": [{"onTrigger": [{"do": "updateHiddenFields", "data": {"name": "candidate_name", "path": "name", "type": "param", "config": {"dataObjName": "user"}}, "when": {"lhs": "xPath", "rhs": "question./data/group_matched_vacancies[1]/initial_interest[1]", "conditionalParams": "eq"}}]}], "hiddenFields": [{"name": "is_registered", "path": "is_registered", "type": "param", "config": {"dataObjName": "user"}}, {"name": "matched_vac_count", "path": "matches_count.aggregate.count", "type": "param", "config": {"dataObjName": "user"}}, {"name": "candidate_id", "path": "id", "type": "param", "config": {"dataObjName": "user"}}, {"name": "selected_vac_vacancy_detail_job_role", "path": "job_role", "type": "param", "config": {"dataObjName": "vacancy_detail"}}, {"name": "selected_vac_employer_detail_company_name", "path": "employer_detail.company_name", "type": "param", "config": {"dataObjName": "vacancy_detail"}}, {"name": "selected_vac_expected_salary_salary_range", "path": "expected_salary.salary_range", "type": "param", "config": {"dataObjName": "vacancy_detail"}}, {"name": "selected_vac_employer_detail_district_name_name", "path": "employer_detail.district_name.name", "type": "param", "config": {"dataObjName": "user.vacancy_detail"}}]}	01016c08-1fc6-453a-af18-b18fe7aedb67
40c6d596-e1da-45d0-8765-1d15d25aa665	2022-06-02 07:33:38.179	2022-06-02 07:33:38.18	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-1"}	e96b0865-5a76-4566-8694-c09361b8ae32
dbe6cbf7-13a4-479e-96a8-253c53565e11	2022-06-02 07:33:38.487	2022-06-02 07:33:38.488	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "Vf-rozgar-recruiter-Mar04.2", "hiddenFields": [{"name": "is_registered", "path": "is_registered", "type": "param", "config": {"dataObjName": "user"}}]}	f4569b71-87e3-49a0-bb33-e67d4f73f91b
efdad1ec-c5bb-43d5-8510-5fbad80c75b9	2022-06-02 07:33:38.739	2022-06-02 07:33:38.74	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "Bot-button-test-v5"}	7bbac85b-18ad-4b18-a095-39fb4edcadbc
f8a4b105-b577-4f4c-960a-65f947f9f27c	2022-06-02 07:33:39.033	2022-06-02 07:33:39.033	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "Testing-Eng-Cand-Feb24", "select1": [{"name": "select_one vacancies", "type": "param", "label": {"path": "${vacancy_detail.job_role} at ${employer_detail.company_name}"}, "value": {"path": "${vacancy_detail.id}"}, "config": {"dataObjName": "user"}, "listPath": "matched"}], "triggers": [{"data": {"key": "initial_interest", "path": "vacancyData.id", "keyType": "select1"}, "xPath": "select_one vacancies", "onTrigger": [{"data": {"name": "candidate_name", "path": "name", "type": "param", "config": {"dataObjName": "user"}}, "triggerType": "hiddenFields"}]}], "hiddenFields": [{"name": "is_registered", "path": "is_registered", "type": "param", "config": {"dataObjName": "user"}}, {"name": "matched_vac_count", "path": "matches_count.aggregate.count", "type": "param", "config": {"dataObjName": "user"}}, {"name": "candidate_id", "path": "id", "type": "param", "config": {"dataObjName": "user"}}, {"name": "selected_vac_vacancy_detail_job_role", "path": "job_role", "type": "param", "config": {"dataObjName": "vacancy_detail"}}, {"name": "selected_vac_employer_detail_company_name", "path": "employer_detail.company_name", "type": "param", "config": {"dataObjName": "vacancy_detail"}}, {"name": "selected_vac_expected_salary_salary_range", "path": "expected_salary.salary_range", "type": "param", "config": {"dataObjName": "vacancy_detail"}}, {"name": "selected_vac_employer_detail_district_name_name", "path": "employer_detail.district_name.name", "type": "param", "config": {"dataObjName": "vacancy_detail"}}]}	4519e197-ebdd-4390-be85-051149d5e563
78c77342-dbd1-4f4b-9de2-173ccefcac7a	2022-06-02 07:33:39.293	2022-06-02 07:33:39.294	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "Rozgar-employer-test-feb24-4", "hiddenFields": [{"name": "is_registered", "path": "is_registered", "type": "param", "config": {"dataObjName": "user"}}]}	e65a1541-18e1-4dc3-92ca-82a57bf36b65
59d3aafb-b384-468b-b0f6-269aab31a594	2022-06-02 07:33:39.587	2022-06-02 07:33:39.588	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "Vf-rozgar-recruiter-Feb28.3", "hiddenFields": [{"name": "is_registered", "path": "is_registered", "type": "param", "config": {"dataObjName": "user"}}]}	142e47e3-7bc6-4094-9708-6c8da7a17ec0
7ae8dc1e-9bae-4532-9ac8-97593da224b4	2022-06-02 07:33:40.099	2022-06-02 07:33:40.1	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "vF-rozgar-candidate-Mar04.2", "select1": [{"name": "select_one vacancies", "type": "param", "label": {"path": "${vacancy_detail.job_role} at ${employer_detail.company_name}"}, "value": {"path": "${vacancy_detail.id}"}, "config": {"dataObjName": "user"}, "listPath": "matched"}], "triggers": [{"data": {"key": "initial_interest", "path": "vacancyData.id", "keyType": "select1"}, "xPath": "select_one vacancies", "onTrigger": [{"data": {"name": "candidate_name", "path": "name", "type": "param", "config": {"dataObjName": "user"}}, "triggerType": "hiddenFields"}]}], "hiddenFields": [{"name": "is_registered", "path": "is_registered", "type": "param", "config": {"dataObjName": "user"}}, {"name": "matched_vac_count", "path": "matches_count.aggregate.count", "type": "param", "config": {"dataObjName": "user"}}, {"name": "candidate_id", "path": "id", "type": "param", "config": {"dataObjName": "user"}}, {"name": "selected_vac_vacancy_detail_job_role", "path": "job_role", "type": "param", "config": {"dataObjName": "vacancy_detail"}}, {"name": "selected_vac_employer_detail_company_name", "path": "employer_detail.company_name", "type": "param", "config": {"dataObjName": "vacancy_detail"}}, {"name": "selected_vac_expected_salary_salary_range", "path": "expected_salary.salary_range", "type": "param", "config": {"dataObjName": "vacancy_detail"}}, {"name": "selected_vac_employer_detail_district_name_name", "path": "employer_detail.district_name.name", "type": "param", "config": {"dataObjName": "vacancy_detail"}}]}	a00d2b05-0bea-4216-b46d-6810c1ecd5e5
8e50b680-d771-4307-ab9a-01c311899ca0	2022-06-02 07:33:40.402	2022-06-02 07:33:40.403	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "global_bot_2"}	229ff6b3-ba4d-4842-98de-8f84a24acac6
bd724e5b-b96c-4aa3-a6b8-1e059c1d385c	2022-06-02 07:33:40.658	2022-06-02 07:33:40.658	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "Dst-test-v2"}	ec7709e2-b712-4601-902a-4faacb7bc7ad
3a822e54-829a-4382-8c4d-f5f084a2a81e	2022-06-02 07:33:40.955	2022-06-02 07:33:40.956	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "global_bot_2"}	ee426a47-e690-4dae-ae89-d74ccbfdba40
319c8d71-bad2-450b-bbe7-7e82b88f6fbe	2022-06-02 07:33:41.215	2022-06-02 07:33:41.216	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "vf-rozgar-recruiter-Mar11"}	8db7faf0-eed5-43bc-83e9-389b2f3c3c3b
da0322b8-329c-4284-a952-651427dbd922	2022-06-02 07:33:41.467	2022-06-02 07:33:41.467	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "HM_Textbook_Delivery_Test_v7"}	c2aeb5bb-8dde-4512-8404-ae5540bebe21
815ba473-0626-4dae-a41a-abcdf1e46dfe	2022-06-02 07:33:41.762	2022-06-02 07:33:41.763	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "global_bot_2"}	eb6be5eb-40bc-4c6e-a596-0cfd2881b5ba
d632d30b-e750-4fe4-8522-6cbb9bb0cc04	2022-06-02 07:33:42.016	2022-06-02 07:33:42.017	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "global_bot_2"}	97e509a7-f413-45b4-b2fc-35370eab1366
1bb4cd9b-4392-4e36-9a7f-5c285c0a7ade	2022-06-02 07:33:42.313	2022-06-02 07:33:42.314	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "HM Textbook Delivery_FGD_TestForm_v1"}	ff33342c-bccc-4b41-8ed3-8fb2eaf1706f
385be82b-914e-473f-a0af-ac98b081abf9	2022-06-02 07:33:42.569	2022-06-02 07:33:42.569	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "HM Textbook Delivery_FGD_TestForm_v2"}	ad644b95-28cb-4905-a175-3403337b3b7a
f9ed1912-254f-4adf-b9f5-b71d0dfde361	2022-06-02 07:33:42.863	2022-06-02 07:33:42.864	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "HM Textbook Delivery_FGD_TestForm_v3"}	f11bf421-c58d-41ba-85c4-67476547b418
3c37572b-5947-44fa-9876-7a54f49f52d0	2022-06-02 07:33:43.16	2022-06-02 07:33:43.16	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "HM Textbook Delivery_Test"}	a660bac4-0d3f-4095-9988-50b0c3620bac
de170eac-818e-4bbf-8c57-2a2900db4d74	2022-06-02 07:33:43.413	2022-06-02 07:33:43.414	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "HM_Textbook_Delivery_Test"}	d06cfecb-3a94-40dc-b544-eeacfa0bdc89
b4a0d385-003d-4514-b72d-7a882cbb673b	2022-06-02 07:33:43.667	2022-06-02 07:33:43.667	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "csm-demo-march-testtttt"}	b4d244e9-8dc1-4d1d-ac75-8d21a8b25755
f74b201e-7520-437f-bc51-d22ccfc26aa0	2022-06-02 07:33:43.92	2022-06-02 07:33:43.921	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "vF-rozgar-candidate-Mar04.2"}	3008d1eb-da54-4a78-83c9-3686e7b95879
c12c9799-9b24-4092-8bb2-33a772c17ead	2022-06-02 07:33:44.224	2022-06-02 07:33:44.224	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "HM_Textbook_Delivery_FGD_TestForm_Mar14"}	f9719454-41d8-46d5-8932-cc0ba8f6c0de
dc6d952a-99e0-4db5-9aed-1ca5f7f146f4	2022-06-02 07:33:44.521	2022-06-02 07:33:44.521	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "HM_Textbook_Delivery_Test_March14"}	8597514f-b931-4cb5-802e-e30ec8a2bbd3
afbce600-914d-4df5-955d-ea2fea5bab93	2022-06-02 07:33:44.77	2022-06-02 07:33:44.77	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "Dst-test-v9"}	6cf23215-6736-4d22-9d7c-9787040a4eeb
d1b00637-b0a9-4bbc-9aaa-601af8d4f5e6	2022-06-02 07:33:45.025	2022-06-02 07:33:45.026	774cd134-6657-4688-85f6-6338e2323dde	{"body": "Hi Sanchita! ${name} has submitted an air travel request for ${country}.", "type": "JS_TEMPLATE_LITERALS", "user": "25bbdbf7-5286-4b85-a03c-c53d1d990a23"}	20909cbe-3181-45c2-8e7b-a707da7949ec
3935af97-9bad-4ec3-a6ad-052770d22881	2022-06-02 07:33:45.32	2022-06-02 07:33:45.321	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "HM_Textbook_Delivery_Test_v4"}	52f9ff38-3897-4fa4-835b-4a42b8fd08a6
2dfcf993-3c2d-4e97-ad71-f81db6c77cd9	2022-06-02 07:33:45.619	2022-06-02 07:33:45.62	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "HM_Textbook_Delivery_Test_v9"}	956f0d05-299c-4c92-85b1-c516c7b6c349
ef2dcf3f-7079-4f8a-9317-d2a551978c60	2022-06-02 07:33:45.939	2022-06-02 07:33:45.939	bbf56981-b8c9-40e9-8067-468c2c753659	{"formID": "HM_Textbook_Delivery_Test_v9"}	57613545-54b8-406f-9b02-b54662945279
949670f9-3a2f-4195-a051-f8d53b3f2e32	2022-07-06 07:33:18.037	2022-07-06 07:33:18.037	774cd134-6657-4688-85f6-6338e2323dde	{"body": "Kindly note your OTP @__123__@. Submission of the OTP will be taken as authentication that you have personally verified and overseen the distribution of smartphone to the mentioned student ID of your school. Thank you! - Samagra Shiksha, Himachal Pradesh", "type": "broadcast", "params": ["name", "phoneNo"], "templateType": "JS_TEMPLATE_LITERALS"}	1e7bbc07-adce-4510-bcae-833c2117c9d5
a140b594-6fca-4f2a-a4b9-5b653c9719f0	2022-06-02 07:33:38.179	2022-06-02 07:33:38.18	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "Odk-hop-v4"}	9c118296-b761-4253-b89f-442ddaf46af8
faeaf893-8c9a-4404-b141-22712db6808e	2022-07-06 07:33:18.037	2022-07-06 07:33:18.037	774cd134-6657-4688-85f6-6338e2323dde	{"body": "Hi Sanchita! ${name} has submitted an air travel request for ${phoneNo}.", "type": "broadcast", "params": ["name", "phoneNo"], "templateType": "JS_TEMPLATE_LITERALS"}	1c221dd9-ba8d-4e35-8a07-7219264e7f56
05dd045a-f6d1-4a63-8a5c-5ca11c0521bf	2022-06-02 07:33:39.841	2022-06-02 07:33:39.841	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "Display-all-media-v2"}	9f83b73e-09ca-41f7-a5d4-11d40cb70ed3
2000022a-6901-48d8-bac7-1e13b6009a19	2022-06-02 07:33:44.77	2022-06-02 07:33:44.77	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "Upload-media-test-v9.0"}	5e613f4a-2a7d-48a4-80ab-2661be1f7963
9604b21f-730c-4ccc-8f35-9d2f2f32468f	2022-08-22 09:14:53.98	2022-08-22 09:14:53.98	02f010b8-29ce-41e5-be3c-798536a2818b	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	\N
3bac17af-2bf7-4dc0-9c60-52c46b4ea708	2022-08-22 09:16:01.211	2022-08-22 09:16:01.211	02f010b8-29ce-41e5-be3c-798536a2818b	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	\N
4a01134c-6ba5-4996-af71-94251f2acf19	2022-08-22 09:17:49.887	2022-08-22 09:17:49.888	02f010b8-29ce-41e5-be3c-798536a2818b	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	\N
2013a423-c2d3-4912-b0fc-49df3d29149b	2022-08-22 09:19:30.248	2022-08-22 09:19:30.249	02f010b8-29ce-41e5-be3c-798536a2818b	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	\N
81df416a-7e66-4af6-9fca-9a0d19fc3fd6	2022-08-22 09:20:16.269	2022-08-22 09:20:16.27	02f010b8-29ce-41e5-be3c-798536a2818b	{}	\N
7d36db8d-16f4-4acf-b501-7898bf376272	2022-08-22 09:20:16.281	2022-08-22 09:20:16.282	02f010b8-29ce-41e5-be3c-798536a2818b	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	\N
e90ca9ec-7450-405f-ac4b-6e85a622fa7d	2022-08-22 09:23:06.213	2022-08-22 09:23:06.214	02f010b8-29ce-41e5-be3c-798536a2818b	{}	\N
fe50cd8c-4fd2-41c6-865e-8bd369d1c891	2022-08-22 09:23:06.222	2022-08-22 09:23:06.223	02f010b8-29ce-41e5-be3c-798536a2818b	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	\N
114ce352-991f-4314-a950-c610d2c0051a	2022-08-22 09:23:34.79	2022-08-22 09:23:34.791	02f010b8-29ce-41e5-be3c-798536a2818b	{}	\N
46b29923-a74d-44ba-95bf-f40cce6abefc	2022-08-22 09:23:34.794	2022-08-22 09:23:34.795	02f010b8-29ce-41e5-be3c-798536a2818b	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	\N
11ccd9c6-6dda-4861-b7b6-7cf840123d62	2022-08-22 09:24:15.115	2022-08-22 09:24:15.133	02f010b8-29ce-41e5-be3c-798536a2818b	{}	36506207-e3d7-421b-9c68-1cc51d167712
0b0eaa72-903a-44ad-9795-f822b88b4a8d	2022-08-22 09:24:15.123	2022-08-22 09:24:15.133	02f010b8-29ce-41e5-be3c-798536a2818b	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	36506207-e3d7-421b-9c68-1cc51d167712
900b1a0e-866a-477c-ad29-3cc17e6649db	2022-08-22 11:49:18.697	2022-08-22 11:49:18.752	02f010b8-29ce-41e5-be3c-798536a2818b	{"form": "https://hosted.my.form.here.com", "formID": "uci_demo_1"}	a3ab6169-1053-4eda-9afc-fdb39ae38709
43e36625-f7a9-49d7-aa3e-bad63c4aad49	2022-06-02 07:33:18.037	2022-08-23 09:56:52.066	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "ss_form_mpc"}	7b84b2d6-31fd-4ed6-afed-fc8231ec6b67
2c5cf27b-e263-44fe-bbfb-335a982baaf2	2022-08-23 10:02:35.195	2022-08-23 10:02:35.216	02f010b8-29ce-41e5-be3c-798536a2818b	{"body": "Hello ${name}-${phoneNo}, Test Notification", "type": "broadcast", "params": ["name", "phoneNo"], "templateType": "JS_TEMPLATE_LITERALS"}	7f9232b2-7bfc-4d6c-82dd-f211b2f2a99d
4341e5f9-a293-4f3c-93e8-ae22ca0023d5	2022-08-23 10:07:36.767	2022-08-23 10:07:36.794	02f010b8-29ce-41e5-be3c-798536a2818b	{"body": "Hello ${name}-${phoneNo}, Test Notification", "type": "broadcast", "params": ["name", "phoneNo"], "templateType": "JS_TEMPLATE_LITERALS"}	e267d86f-fdd7-4fd5-ab37-2891e68393e6
ba234f42-1809-444a-a1a7-0986ce0c41c6	2022-06-02 07:33:31.18	2022-06-02 07:33:31.18	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "UCI-demo-1"}	e69b63e4-eed7-499d-a8a9-ea3a0c4b8f67
60c2fc7b-8c40-4201-8cb1-9340d60d62c5	2022-07-06 07:33:18.037	2022-07-06 07:33:18.037	774cd134-6657-4688-85f6-6338e2323dde	{"body": "Hello ${name}-${phoneNo}, Test Notification", "type": "broadcast", "title": "Firebase Test Notification", "params": ["name", "phoneNo"], "templateType": "JS_TEMPLATE_LITERALS"}	c8326462-29cd-4027-9474-940179644347
95ad0d69-221a-4b83-8c91-d4ee41b0e5ee	2023-03-18 06:36:49.308	2023-03-18 06:36:49.355	bbf56981-b8c9-40e9-8067-468c2c753659	{"form": "https://hosted.my.form.here.com", "formID": "chatbot_form6", "hiddenFields": [{"name": "fullName", "path": "fullName", "type": "param", "config": {"dataObjName": "user"}}], "serviceClass": "SurveyService"}	afcffc28-f37d-49f7-af16-6e017ad62a7d
a67ca2ba-65d6-45ce-b17d-2b85c352d6e8	2023-03-18 06:58:54.114	2023-03-18 06:58:54.135	774cd134-6657-4688-85f6-6338e2323dde	{"body": "Hello ${name}-${phoneNo}, Test Notification", "type": "broadcast", "title": "Test Notification", "params": ["name", "phoneNo"], "templateType": "JS_TEMPLATE_LITERALS"}	43648e17-e26a-4bf3-b8e6-051b95ed8c0c
9ebbb57d-2ff9-4628-962e-fd3dfb0c9247	2023-03-18 07:32:27.788	2023-03-18 07:32:27.817	774cd134-6657-4688-85f6-6338e2323dde	{"body": "Hello ${name}-${phoneNo}, This is a test Notification for NL App Integration", "type": "broadcast", "title": "NL App - Test Notification", "params": ["name", "phoneNo"], "templateType": "JS_TEMPLATE_LITERALS"}	52bd466d-cbef-46ef-89c7-e2e0a2741426
fbcbacd8-c6a9-4bea-a6bb-7f7136ebe93a	2023-03-18 07:08:45	2023-03-18 07:08:45.034	228b739f-38b4-47d9-a7c4-7f6f30178821	{"type": "generic"}	6572ee3a-fd66-4733-badb-b364841a6d24
6ddc127a-87cc-4ce0-9bc9-fb677392e39f	2023-03-18 10:15:16.565	2023-03-18 10:15:16.566	774cd134-6657-4688-85f6-6338e2323dde	{"body": "desc", "form": "https://hosted.my.form.here.com", "type": "JS_TEMPLATE_LITERALS", "title": "name", "formID": {"formID": "DST Updation"}}	\N
079d5267-6894-4618-9259-9de3e36401ec	2023-03-18 19:41:09.967	2023-03-18 19:41:09.97	774cd134-6657-4688-85f6-6338e2323dde	{"body": "desc", "form": "https://hosted.my.form.here.com", "type": "JS_TEMPLATE_LITERALS", "title": "name", "formID": {"formID": "DST Updation"}}	\N
6f4034e6-edfa-4337-b36e-fd834f017993	2023-03-18 19:42:58.498	2023-03-18 19:42:58.499	774cd134-6657-4688-85f6-6338e2323dde	{"body": "desc", "form": "https://hosted.my.form.here.com", "type": "JS_TEMPLATE_LITERALS", "title": "name", "formID": {"formID": "DST Updation"}}	\N
d131974e-c449-4b28-859d-0988c47069bd	2023-03-18 19:44:14.278	2023-03-18 19:44:14.279	774cd134-6657-4688-85f6-6338e2323dde	{"body": "desc", "form": "https://hosted.my.form.here.com", "type": "JS_TEMPLATE_LITERALS", "title": "name", "formID": {"formID": "DST Updation"}}	\N
cec813e3-e6c9-47c3-93cb-5ae3d059d3a5	2023-03-18 19:46:04.21	2023-03-18 19:46:04.218	774cd134-6657-4688-85f6-6338e2323dde	{"body": "desc", "form": "https://hosted.my.form.here.com", "type": "JS_TEMPLATE_LITERALS", "title": "name", "formID": {"formID": "DST Updation"}}	900ea924-0c6b-469d-86f7-7cf236746e98
3fdb86de-4cc3-4b18-a7e3-430c0c1efdbe	2023-03-20 05:38:50.047	2023-03-20 05:38:50.048	774cd134-6657-4688-85f6-6338e2323dde	{"body": "desc", "form": "https://hosted.my.form.here.com", "type": "JS_TEMPLATE_LITERALS", "title": "name", "formID": {"formID": {"formID": "DST Updation"}}}	\N
c900f04f-f821-4f55-be43-b75aea02ee7f	2023-03-20 05:40:28.665	2023-03-20 05:40:28.666	774cd134-6657-4688-85f6-6338e2323dde	{"body": "desc", "form": "https://hosted.my.form.here.com", "type": "JS_TEMPLATE_LITERALS", "title": "name", "formID": {"formID": "DST Updation"}}	\N
f41b9f9f-a8c2-46df-8a2f-6329ef271515	2023-03-20 06:11:55.953	2023-03-20 06:11:55.981	774cd134-6657-4688-85f6-6338e2323dde	{"body": "desc", "form": "https://hosted.my.form.here.com", "type": "JS_TEMPLATE_LITERALS", "title": "name", "formID": {"formID": "DST Updation"}}	11d218ca-c7ab-4289-9390-d4d186c320ae
e2ac4d1a-97ea-4eb1-a4cc-3f41c25fc765	2023-03-20 06:15:24.128	2023-03-20 06:15:24.14	774cd134-6657-4688-85f6-6338e2323dde	{"body": "desc", "form": "https://hosted.my.form.here.com", "type": "JS_TEMPLATE_LITERALS", "title": "name", "formID": {"formID": "DST Updation"}}	2023e7b1-b28b-4fef-b9d4-03a3a8c330a2
fbabf892-c916-4a76-93ee-2dfe1929af1c	2023-03-20 06:16:57.915	2023-03-20 06:16:57.925	774cd134-6657-4688-85f6-6338e2323dde	{"body": "desc", "form": "https://hosted.my.form.here.com", "type": "JS_TEMPLATE_LITERALS", "title": "name", "formID": {"formID": "DST Updation"}}	435f31cd-c965-4deb-8810-47dd88456556
\.


--
-- Data for Name: UserSegment; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."UserSegment" (id, "createdAt", "updatedAt", name, description, count, category, "allServiceID", "byPhoneServiceID", "byIDServiceID", "botId") FROM stdin;
0ed82f44-e857-443c-9010-90d3ab1b6793	2021-06-16 06:04:02.358	2022-06-02 07:33:09.805	SamagraX-Team-Users	\N	0	\N	427f2cdf-c129-403c-84fe-73af867b1274	515a6028-b5f0-4381-ad97-e8651b820412	056d0f87-8287-4c1e-8b2d-19f8f9d7e419	\N
89bda9d4-a905-43a9-966f-6c2442c67681	2021-06-16 06:04:02.358	2022-06-02 07:33:10.208	SamagraX-Team-Users-Test	\N	0	\N	65020b3a-1582-4a2d-8d7c-70615a14d112	683cda34-67e5-4314-addb-52bf713c2d03	9aa1a713-e01a-497a-84b7-7a9ad58078ea	\N
d056d341-75a1-4445-8739-af92ad7f5237	2021-06-16 06:04:02.358	2022-06-02 07:33:10.506	SamagraX-Team-Users-Test-2	\N	0	\N	40a8a8ab-5b66-440e-852b-454483bdb06d	262d7e74-a06f-4273-9395-3d32166bdca1	bd6c42a6-e3f2-4516-b6cd-3d45ae623cae	\N
d0aaadfb-676b-4611-831e-25d15e46fb0c	2021-06-16 06:04:02.358	2022-06-02 07:33:10.804	SamagraX-Team-Users-Test-3	\N	0	\N	39d297a8-a5a5-434e-be2f-166d83f7c417	f59038e4-8c7e-4b79-a368-ab1200d5c566	7c113a19-32e5-4c52-9bd5-26a90b316db5	\N
7d5b635a-d372-4bb1-8c00-da1b43cc6d0b	2021-06-16 06:04:02.358	2022-06-02 07:33:11.102	SamagraX-Team-Users-Test-5	\N	0	\N	032774e8-1af6-4e97-8eda-a613dbb74753	3f12be55-2962-4166-bb73-96a78950b72c	73dcab05-e81d-47ba-91f7-c49ce52d1c73	\N
7dfa4a70-6aae-4eaf-8b0c-41690c90548d	2021-06-16 06:04:02.358	2022-06-02 07:33:11.4	SamagraX-Team-Users-Test-8	\N	0	\N	8aff5172-7e7d-43be-a75f-c038ad6b40e1	95dc77c9-184e-444b-8930-d5ff7d94bd39	84863dba-d4bd-46d3-aecb-c38b845b2e80	\N
e2a56c7f-0df3-40d1-8b48-5f89629582f9	2021-06-16 06:04:02.358	2022-06-02 07:33:11.693	SamagraX-Team-Users-Test-19	\N	0	\N	f5d0df5b-f97a-4d7d-880f-27d8fade3ced	d97ca587-f513-4c8a-9ff4-05d2bc8b3d00	0583bda2-feb3-4cf8-b76f-0b4b7e00bb55	\N
7b1a87bc-fd34-435a-94c8-ad0222306384	2021-06-16 06:04:02.358	2022-06-02 07:33:11.991	SamagraX-Team-Users-Test-20	\N	0	\N	cab5ccee-88ad-4818-a8d5-fb8adcc76d8a	555f6739-e770-4c99-b40e-420b4a92af0e	d13380b1-056b-4449-9e80-170e2e4e891f	\N
fb5799ca-22b0-4e2e-a00d-e96464c8ebfb	2021-06-16 06:04:02.358	2022-06-02 07:33:12.289	SamagraX-Team-Users-Test-21	\N	0	\N	11488102-448c-4a55-8d2d-8cb388946a56	571f4849-798e-4806-b068-77b3d37bce9d	aa53af62-6b41-4ee4-9fc6-eeaaa60584e7	\N
20f1c782-4a9e-4eb1-ad85-126c5d9f7849	2021-06-22 00:04:37.405	2022-06-02 07:33:12.588	Saksham Skills - vID: 15, threshold: 16	\N	0	Teacher	1e2580f4-2fc3-4e5f-89b3-8c470e4be8c2	3b954c1d-8411-4134-af2d-222eff7288fc	f9489adc-e725-4e72-8b38-a25f30181b6c	\N
64190a70-dbcd-4c3d-926f-e1690bf6abbc	2021-06-29 08:11:49.171	2022-06-02 07:33:12.885	SamagraX-Team-Users-007	\N	0	Teacher	1a905d52-265c-4370-92cb-1e75db834881	ecb0a27b-587f-4575-a1de-7b7d44abba96	4320c89b-b111-4b30-be38-37a949d4453d	\N
d3d1d6ce-805b-4423-b3dc-8a7c59b96133	2021-07-05 06:59:49.745	2022-06-02 07:33:13.182	Saksham Skills New - vID: 15, threshold: 16	\N	0	Teacher	4f102bb1-61c6-4cea-a157-411b107f0ada	7e0462d9-7009-4861-adf4-2e545b65506e	057087a6-10ec-4e60-8904-f3184b73d5b2	\N
81f7c4b4-c682-4b3c-be1c-1a1e80a7aa65	2021-07-08 12:39:27.362	2022-06-02 07:33:13.477	Tester	HI abcd	0	student	93ed4043-b812-40a1-b1bc-b24e457a2143	b4a18b1d-4d50-4531-adec-3327e16a716b	fec5ac3e-10ce-474e-95a1-06efb02cadd7	\N
3980d3ad-7e2b-4054-a8ff-51a5046c62a1	2021-07-08 12:42:27.29	2022-06-02 07:33:13.778	Testerx	HI abcd	0	student	93ed4043-b812-40a1-b1bc-b24e457a2143	c4a94310-66f6-44fa-892d-013e1a4ddb36	e7774a21-d16b-41ab-bebf-a5c8bd5ac85a	\N
f49f9cb5-42bb-45ad-9e77-d4644f756590	2021-07-08 12:44:33.477	2022-06-02 07:33:14.072	userSegment1	abcd	0	student	93ed4043-b812-40a1-b1bc-b24e457a2143	96cc2670-6c7d-42f3-9051-409067285bb9	4325224c-90f2-4fa0-a15c-fd7721befa8e	\N
bbb6c48d-61d7-40d7-9d04-a36b1788141c	2021-07-08 12:54:22.268	2022-06-02 07:33:14.367	Anup001	hiiii	0	student	93ed4043-b812-40a1-b1bc-b24e457a2143	ba353725-c27c-4adf-b154-634ed5dc0184	97d7f045-c7d1-4cd7-9a89-17a2d71a984c	\N
8d04f0ee-1156-4b6e-8dd9-5d4097520717	2021-07-08 13:11:14.197	2022-06-02 07:33:14.662	tester0012	hi this is tester	0	student	7d426d37-ea3e-42c7-b739-09e3cbec8be8	ad3e8427-8286-42fc-8a11-0c3977d9194f	8d6a12f7-7820-428f-a2f4-001f054ff98e	\N
073540ea-3812-4082-902d-f039940019e0	2021-07-08 13:45:09.46	2022-06-02 07:33:14.96	TestSegemnt1	abcd sjskd sdsd sd s	0	student	1c56e232-74b0-4bc6-9fb9-b94d16e64969	7d016d07-f7ae-4e06-963c-fd31a29c14f4	bf7f1c95-9e98-49b1-aaf0-a86f55e9be77	\N
a620a0c9-1271-44fa-99a5-4481394eee31	2021-07-08 16:40:53.963	2022-06-02 07:33:15.252	Demo100	Demo100	0	student	7d426d37-ea3e-42c7-b739-09e3cbec8be8	b71ab062-bfb8-485b-8421-eda72f0ea496	b2ca7511-b707-4261-ad26-1242e4ed2deb	\N
5aad61ba-9c11-4cf4-83bb-12ecce9d495a	2021-07-08 16:42:03.911	2022-06-02 07:33:15.554	Demo200	Demo200	0	student	b6cc0f09-6b3a-4467-9ad7-28dd67a408f1	5ca8bdfa-7b57-4f8f-949f-51b9faa89c69	02816797-2d6c-4fda-8200-4de886998e46	\N
7fbcc8c6-347c-4791-8648-a4438b3be853	2021-07-08 16:59:19.114	2022-06-02 07:33:15.848	Demo22	Demo22	0	student	9397d5d3-d607-49db-8d61-446e0b675854	737d44fd-d3e7-4d82-8a6e-09f401feb817	37a3955d-2d39-4535-97bb-2060b32d0002	\N
9251022a-68db-4c9f-859e-0e923e7656be	2021-07-08 18:24:36.441	2022-06-02 07:33:16.153	UCIDemo	UCIDemo	0	student	ec1c73a3-f6b6-4a99-81fc-4ae24373ae26	c22ea850-b4ec-47d5-bdc5-e5ba6433b51d	838f8a31-64cf-4b39-87d0-6b4c3f628233	\N
13398718-c015-4f1c-b77c-f8fc73534908	2021-07-08 18:37:17.073	2022-06-02 07:33:16.452	MGNREGS	https://vidyadaan.sunbird.samagra.io/uci	0	student	ec1c73a3-f6b6-4a99-81fc-4ae24373ae26	13b5498a-7227-4e2f-a870-c525619fd5ba	8657c864-88f6-4e8f-8ce9-7e3e7bf6958c	\N
b265d8e0-be4a-4105-9339-46078c093944	2021-07-08 18:46:04.63	2022-06-02 07:33:16.746	UCI Demo	UCI Demo	0	student	7d426d37-ea3e-42c7-b739-09e3cbec8be8	27e46dc5-9669-4c77-a65b-d145c38e9282	da0f17ca-d9d0-4658-9b8a-c94de94d576b	\N
1111df80-9d04-46ab-8cda-d0159e31e45e	2021-07-09 08:51:43.531	2022-06-02 07:33:17.048	Rozor segment	segment new 	0	student	9397d5d3-d607-49db-8d61-446e0b675854	4951f07e-e88c-4fa0-9d82-e40fe80256c6	f9299338-c43f-45af-b593-7c43f4cc887c	\N
7031e51a-6081-4bd2-ad9e-f2fd05aa4223	2022-01-31 05:20:30.238	2022-06-02 07:33:17.344	Rozgar Candidate Segment	\N	0	\N	8f40dd4f-147a-4c6c-8166-3ff731fad84e	8f40dd4f-147a-4c6c-8166-3ff731fad84e	8f40dd4f-147a-4c6c-8166-3ff731fad84e	\N
10a3bea7-8801-4d1f-820b-3d28e3faf115	2022-01-31 05:18:53.433	2022-06-02 07:33:17.652	Rozgar Recruiter Segment	\N	0	\N	21e86402-d030-4315-8120-647e38cbd01e	e873a7dc-87e9-44e7-af7f-2e05c8bb33be	e873a7dc-87e9-44e7-af7f-2e05c8bb33be	\N
045817ad-45d1-4815-a62c-a193422b8687	2022-07-06 16:40:53.963	2022-07-06 16:40:53.963	UCI Firebase User Segment	\N	0	\N	2b4a7e70-f47d-4a1e-93c1-d88c62c81967	2b4a7e70-f47d-4a1e-93c1-d88c62c81967	2b4a7e70-f47d-4a1e-93c1-d88c62c81967	3d370c30-8ac8-496a-a908-4975b07056b9
bf6c19d8-c904-4101-b03d-1df1dbcbddb5	2022-07-06 16:40:53.963	2022-07-06 16:40:53.963	UCI User Segment	\N	0	\N	dee02320-f414-42ee-a08b-fc2bbb86dd0a	dee02320-f414-42ee-a08b-fc2bbb86dd0a	dee02320-f414-42ee-a08b-fc2bbb86dd0a	\N
8945831e-56ad-4d25-ab74-41ef6b604282	2022-08-22 23:47:22.589	2022-08-22 23:47:22.59	Test US:1.01	\N	0	\N	4f102bb1-61c6-4cea-a157-411b107f0ada	4f102bb1-61c6-4cea-a157-411b107f0ada	4f102bb1-61c6-4cea-a157-411b107f0ada	\N
456aad12-0917-4d72-bb30-b4bcfc3eedb9	2022-08-22 23:48:08.784	2022-08-22 23:48:08.785	Test US:1.02	\N	0	\N	4f102bb1-61c6-4cea-a157-411b107f0ada	4f102bb1-61c6-4cea-a157-411b107f0ada	4f102bb1-61c6-4cea-a157-411b107f0ada	\N
07fe5afa-05f7-4678-87f1-d800cf2551c9	2022-08-22 23:50:28.4	2022-08-22 23:50:28.401	Test US:1.03	\N	0	\N	4f102bb1-61c6-4cea-a157-411b107f0ada	\N	\N	\N
069780ad-0427-4ac0-becf-7f2570cd8ec4	2022-08-23 09:21:38.683	2022-08-23 09:21:38.684	UCI User Segment - 2	\N	0	\N	dee02320-f414-42ee-a08b-fc2bbb86dd0a	dee02320-f414-42ee-a08b-fc2bbb86dd0a	\N	\N
8866c239-3cd9-498a-94b4-97f2696a83ec	2022-08-23 10:07:13.869	2022-08-23 10:07:13.87	UCI User Segment - 5	\N	0	\N	2b4a7e70-f47d-4a1e-93c1-d88c62c81967	2b4a7e70-f47d-4a1e-93c1-d88c62c81967	\N	\N
ac2077cd-8735-4d95-8651-9e05efbe36a1	2023-03-18 07:35:39.24	2023-03-18 07:35:39.241	NL App - User Segment	\N	0	\N	0f7f2826-4fc3-419a-923a-478032d0d07c	\N	\N	\N
6e7433d0-db4f-4e3f-8ce8-fb216fb9ac07	2023-03-18 07:38:08.896	2023-03-18 07:38:08.896	NL App - User Segment 02	\N	0	\N	02854c26-b2a6-4176-ac6d-38b7a5a8f576	02854c26-b2a6-4176-ac6d-38b7a5a8f576	\N	\N
\.


--
-- Data for Name: _BotToConversationLogic; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."_BotToConversationLogic" ("A", "B") FROM stdin;
fabc64a7-c9b0-4d0b-b8a6-8778757b2bb5	e5c5334b-8ce1-4a53-be9d-78d24fa2e0e1
56b31f3d-cc0f-49a1-b559-f7709200aa85	d97b0d3e-2662-44ad-a777-3bab74a5fcf1
6895bd67-3c3d-436f-84c3-31cc03a2b2c3	0d4ee8e9-8501-4969-8049-6bf918ba6d17
563b8fca-7462-4bf3-819c-0111d377681d	e342bd51-a322-4973-ab89-a8a382d514b9
6af8832d-fd68-427e-9369-4dbae2c71305	95d75bee-689d-43cf-a4bf-184a40c4e8a8
3ba7f3db-d596-4878-9f3f-c9858bcdaa4b	e96b0865-5a76-4566-8694-c09361b8ae32
07dd2b3c-83b1-4b1e-aa6c-826f4b8464e0	dd33fa11-d66e-4645-844a-106f6f94b7d9
aaa7cb87-335f-4306-939d-a0337351fb6a	4ea24f2c-74eb-4f20-b39f-a1ab810588f1
923f966e-8d0d-4d47-87dd-6804c00e60c9	84941b0a-6eae-4b46-a810-2065d8bc6f8a
a09075ff-5fe5-4ca0-ad78-e5450886b921	5eca4f02-e5c9-4109-b238-52ce5ce845dc
a79b3778-7419-46af-ba29-cbd9719a33dd	0bf66a2c-e504-4fce-9970-43620888929a
765511f1-cb4a-4554-8a86-0b34c6d85b8d	be24a027-8856-4439-958b-43a1057ddcfe
710c7340-73d2-484f-96d3-e7401999f088	fe6dd157-ca49-4101-9ec0-aa1d871c5955
b966d6a4-c6a3-485c-8647-1f3def56fdb0	3a583e97-853e-40c4-8be2-0ed9459ecf64
8276f638-d531-43c4-b084-cdb5d8706fc1	ec5287e7-886e-4e46-93e0-ab616973b370
3238d90a-d46f-42e5-b0fe-84e58c527868	82733742-65cb-493d-baee-3299b9dfe882
324d533b-7db7-454f-b955-7d3257919c4f	7f8f2086-34e8-4a6d-a7ed-302642fd043b
be2473c3-3152-4415-b721-90ef98a48dfa	742c2671-4dab-4ccc-adab-1167f98c3dc7
4a654346-56dd-4881-a809-59ecfddab0b6	458698db-b305-467a-9ea3-5ceea95503d6
bc029c38-1d25-4b27-a319-207abef2b41c	95d75bee-689d-43cf-a4bf-184a40c4e8a8
8fc85967-761c-4dd4-9dfd-2ebcfbcd1617	74a38946-9979-49a4-841e-e244d0d2ac3c
06801678-5ce9-470b-b2f0-eee070813774	18f2a486-63ef-4072-a16b-d9bd9fcc0112
d655cf03-1f6f-4510-acf6-d3f51b488a5e	e96b0865-5a76-4566-8694-c09361b8ae32
8e4296da-49da-40da-a1fd-b4e72af914cd	8eb5eb29-b37f-443c-9e2b-147a560698fc
c10b951e-5094-4bbc-8846-3627236e1c07	80c2331a-d581-4fcd-9b5d-cabc01fb42c0
701a52f6-d527-4670-9243-c4bb80d1b747	1cd933be-22af-4ca2-8726-eaab4ec1c60b
3cae7fd6-c843-4a7f-9b6b-9674e81f502c	7bbac85b-18ad-4b18-a095-39fb4edcadbc
803bd717-1fa3-45e0-b75c-8bab76fa788c	e96b0865-5a76-4566-8694-c09361b8ae32
137b297c-f0fc-4ced-8451-ea4da3f5a343	a00d2b05-0bea-4216-b46d-6810c1ecd5e5
511be17a-a6d2-443f-a3f9-a61755939c35	142e47e3-7bc6-4094-9708-6c8da7a17ec0
4628ede5-023a-41a0-8698-ecb72a86a597	4519e197-ebdd-4390-be85-051149d5e563
448f0b1c-d5ce-4cff-8baf-25dff80c9257	e65a1541-18e1-4dc3-92ca-82a57bf36b65
e8960328-e6ae-44cd-b9e4-30ee6e74c4a9	20909cbe-3181-45c2-8e7b-a707da7949ec
d0dad28e-8b84-4bc9-92ab-f22f90c2432a	6cf23215-6736-4d22-9d7c-9787040a4eeb
b1aae704-7254-4d26-8d34-09c99704f3c3	52f9ff38-3897-4fa4-835b-4a42b8fd08a6
4783168a-c2f2-4fbf-b10c-01fb823da3ce	eb6be5eb-40bc-4c6e-a596-0cfd2881b5ba
ae74e2ee-f39a-4370-91ff-cf00af23bcba	eb6be5eb-40bc-4c6e-a596-0cfd2881b5ba
b0854201-754c-4d69-993d-f5e897625170	eb6be5eb-40bc-4c6e-a596-0cfd2881b5ba
0fbaf814-727e-44e5-93a5-3469bb0da33c	eb6be5eb-40bc-4c6e-a596-0cfd2881b5ba
8a8c26e5-6227-47a9-8e70-7b6ca90d14e5	ee426a47-e690-4dae-ae89-d74ccbfdba40
fe577c9a-11a1-431a-9617-8d93dad233b5	a660bac4-0d3f-4095-9988-50b0c3620bac
eef0ddfa-a3db-4d62-933a-c3e55fa5c664	d06cfecb-3a94-40dc-b544-eeacfa0bdc89
e5363a73-4ff0-4cc8-935d-9ffa4fc975a3	b4d244e9-8dc1-4d1d-ac75-8d21a8b25755
858a8db0-9d55-4276-84da-f9974c885a18	3008d1eb-da54-4a78-83c9-3686e7b95879
5cc4cc3d-b1b5-45ef-95b7-262b4fd4a086	8db7faf0-eed5-43bc-83e9-389b2f3c3c3b
92edfc02-1dee-4c56-8d8c-fc801d4cd883	9f83b73e-09ca-41f7-a5d4-11d40cb70ed3
2d1f0c34-d942-49e4-89ff-7cd19318a685	ff33342c-bccc-4b41-8ed3-8fb2eaf1706f
86f60113-6315-4059-a0e7-1dd3e876f10c	ad644b95-28cb-4905-a175-3403337b3b7a
05274f3c-d23e-4cd4-bcc5-9eab18bfe740	f11bf421-c58d-41ba-85c4-67476547b418
780b9ee6-6f52-498b-b370-45601bd986aa	f9719454-41d8-46d5-8932-cc0ba8f6c0de
c4c81867-7301-4e90-996a-0741a5dca374	8597514f-b931-4cb5-802e-e30ec8a2bbd3
94c17e18-98a5-47fb-9c71-deb4a4af1c2d	c2aeb5bb-8dde-4512-8404-ae5540bebe21
ee448621-ae60-449c-8d8e-9417eb997797	57613545-54b8-406f-9b02-b54662945279
3d370c30-8ac8-496a-a908-4975b07056b9	c8326462-29cd-4027-9474-940179644347
5b962e70-7a14-48fb-804c-31e9f5505b16	9c118296-b761-4253-b89f-442ddaf46af8
f0d4614b-377e-4791-9688-1b00199448d5	1c221dd9-ba8d-4e35-8a07-7219264e7f56
38574867-5f98-4f6b-959c-f8317606106f	1e7bbc07-adce-4510-bcae-833c2117c9d5
a246e69f-f2c4-403a-8e54-31f57e6fd34e	5e613f4a-2a7d-48a4-80ab-2661be1f7963
e4588565-a138-426f-96ed-a3dcd29aadee	314c8a3e-397f-434d-bd19-df7b86aa412c
bb1adb79-5a32-42cd-adda-07a60d5968bb	a3ab6169-1053-4eda-9afc-fdb39ae38709
0a00661b-6968-4fcb-a646-6c975fdba27f	7b84b2d6-31fd-4ed6-afed-fc8231ec6b67
200f7ffe-f411-4543-a8b3-a64bf91e62b8	7f9232b2-7bfc-4d6c-82dd-f211b2f2a99d
2d3b189e-cee4-4c0e-8b54-25d529d520f4	e267d86f-fdd7-4fd5-ab37-2891e68393e6
519b6d22-889a-4afb-a5a5-eba5d14b8d15	e267d86f-fdd7-4fd5-ab37-2891e68393e6
6611c78a-2454-4b83-a5c5-d8e384db576d	314c8a3e-397f-434d-bd19-df7b86aa412c
1d9bbd1a-ecee-42fd-91c6-157e1b517810	314c8a3e-397f-434d-bd19-df7b86aa412c
7d58a921-40f1-448d-844d-9a742d163f03	e267d86f-fdd7-4fd5-ab37-2891e68393e6
ce99bf58-34ac-4097-9516-318c59e83500	1c221dd9-ba8d-4e35-8a07-7219264e7f56
c3ea9d13-2c6a-4003-af98-0419682a56e8	e69b63e4-eed7-499d-a8a9-ea3a0c4b8f67
e7b3727a-90ee-4ec5-9918-b2018ef98d25	e69b63e4-eed7-499d-a8a9-ea3a0c4b8f67
778f56ee-db58-4f31-b38a-398d202492cb	e69b63e4-eed7-499d-a8a9-ea3a0c4b8f67
d614d307-86ac-40ce-9a67-1caaa444171c	e69b63e4-eed7-499d-a8a9-ea3a0c4b8f67
1aaa7453-4a23-4228-be0c-911cb9dd1185	afcffc28-f37d-49f7-af16-6e017ad62a7d
5dc65cd9-31b0-44d7-867b-2d78eee383e2	43648e17-e26a-4bf3-b8e6-051b95ed8c0c
5d45c918-be6f-40f4-b6ac-758a4dd6dacd	6572ee3a-fd66-4733-badb-b364841a6d24
46e36ec2-d522-4933-94f2-0656607067e0	52bd466d-cbef-46ef-89c7-e2e0a2741426
8f65ccd2-d635-433e-83c8-f867c49ce87f	314c8a3e-397f-434d-bd19-df7b86aa412c
\.


--
-- Data for Name: _BotToUserSegment; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."_BotToUserSegment" ("A", "B") FROM stdin;
b214ac3b-6094-4e00-9a19-c8f948ae7352	20f1c782-4a9e-4eb1-ad85-126c5d9f7849
137b297c-f0fc-4ced-8451-ea4da3f5a343	7031e51a-6081-4bd2-ad9e-f2fd05aa4223
511be17a-a6d2-443f-a3f9-a61755939c35	10a3bea7-8801-4d1f-820b-3d28e3faf115
4628ede5-023a-41a0-8698-ecb72a86a597	7031e51a-6081-4bd2-ad9e-f2fd05aa4223
448f0b1c-d5ce-4cff-8baf-25dff80c9257	10a3bea7-8801-4d1f-820b-3d28e3faf115
e8960328-e6ae-44cd-b9e4-30ee6e74c4a9	10a3bea7-8801-4d1f-820b-3d28e3faf115
b1aae704-7254-4d26-8d34-09c99704f3c3	7031e51a-6081-4bd2-ad9e-f2fd05aa4223
3d370c30-8ac8-496a-a908-4975b07056b9	045817ad-45d1-4815-a62c-a193422b8687
f0d4614b-377e-4791-9688-1b00199448d5	bf6c19d8-c904-4101-b03d-1df1dbcbddb5
38574867-5f98-4f6b-959c-f8317606106f	bf6c19d8-c904-4101-b03d-1df1dbcbddb5
e4588565-a138-426f-96ed-a3dcd29aadee	7b1a87bc-fd34-435a-94c8-ad0222306384
bb1adb79-5a32-42cd-adda-07a60d5968bb	7b1a87bc-fd34-435a-94c8-ad0222306384
0a00661b-6968-4fcb-a646-6c975fdba27f	069780ad-0427-4ac0-becf-7f2570cd8ec4
200f7ffe-f411-4543-a8b3-a64bf91e62b8	069780ad-0427-4ac0-becf-7f2570cd8ec4
2d3b189e-cee4-4c0e-8b54-25d529d520f4	8866c239-3cd9-498a-94b4-97f2696a83ec
519b6d22-889a-4afb-a5a5-eba5d14b8d15	8866c239-3cd9-498a-94b4-97f2696a83ec
6611c78a-2454-4b83-a5c5-d8e384db576d	7b1a87bc-fd34-435a-94c8-ad0222306384
1d9bbd1a-ecee-42fd-91c6-157e1b517810	7b1a87bc-fd34-435a-94c8-ad0222306384
7d58a921-40f1-448d-844d-9a742d163f03	8866c239-3cd9-498a-94b4-97f2696a83ec
ce99bf58-34ac-4097-9516-318c59e83500	069780ad-0427-4ac0-becf-7f2570cd8ec4
5dc65cd9-31b0-44d7-867b-2d78eee383e2	045817ad-45d1-4815-a62c-a193422b8687
46e36ec2-d522-4933-94f2-0656607067e0	6e7433d0-db4f-4e3f-8ce8-fb216fb9ac07
8f65ccd2-d635-433e-83c8-f867c49ce87f	8866c239-3cd9-498a-94b4-97f2696a83ec
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
8425ae42-ea3c-4747-a4d1-04c8cac6276a	5b78230822ca3503cfecf31f55317daf4a9c4354c403e3751124e49dd083cb11	2022-06-02 07:26:02.583258+00	20211029110359_init	\N	\N	2022-06-02 07:26:02.333408+00	1
a8beccda-f5e1-4ac7-b8c1-453698398cc5	b7f62b4ab5db2c4a82333aba365e7d65e28bda8e809b399ab30af67f9d7728d1	2022-06-02 07:26:06.513587+00	20220327160543_usersegment_description_optional	\N	\N	2022-06-02 07:26:06.319591+00	1
77dec258-56ed-4f14-a682-c9703ababc6a	40790cd58971db24da3eaf7bed9771ebe165c8dd5101129f7aa7afabecdbe155	2022-06-02 07:26:02.864535+00	20220203070524_tst_migration	\N	\N	2022-06-02 07:26:02.659617+00	1
8b0acd86-e480-4a16-aef8-9db364abc70e	d1760b5916b3eadbfe6af0871b6e746eaa18d868c325d68492e5c5ef29f681ef	2022-06-02 07:26:03.161796+00	20220203070953_fix_mtom_relations	\N	\N	2022-06-02 07:26:02.941538+00	1
0acb26f0-90e5-4828-8ee6-ee96d630cc22	2f2ddee2a6e93c6cc1fe13bf2f0fcfc41148b3ba2ffd993507c0fde3c154ba38	2022-08-22 15:58:39.446837+00	20220822130632_bot_add_tags	\N	\N	2022-08-22 15:58:39.439724+00	1
a3d1fab8-af0a-44b2-9a9b-7d3f0ba4ce6a	2101490726380da6594c122c8d8703bb3b486ee7313f508986f90337b1e73723	2022-06-02 07:26:03.439152+00	20220327072038_fix_remove_owner_id	\N	\N	2022-06-02 07:26:03.243269+00	1
24fc7242-4161-46e5-ab8f-974b8034869f	dd871dcad940d65c9e8926ab70554e35ac014c752034e628203a443f6b2725f5	2022-06-02 07:26:06.791278+00	20220327160740_usersegment_services_optional	\N	\N	2022-06-02 07:26:06.591055+00	1
5ac4fcf4-2fcd-4751-a483-a6133f9b960c	bf16a98124ddf40f0af2630ba87ae47c76a8682e69bc6dab99e38dbe3ce1fce5	2022-06-02 07:26:03.711233+00	20220327074749_add_cl_name	\N	\N	2022-06-02 07:26:03.518503+00	1
db66ba36-9ef7-4124-b07b-c5621ae685b0	4d994d241f3a77883b360117b34defa8db7866f9d7fda5ec42e0c4f211bcab5b	2022-06-02 07:26:03.998314+00	20220327080251_udpate_transformer_config_in_cl	\N	\N	2022-06-02 07:26:03.789511+00	1
460468d5-7023-4f0d-bd5b-0c70341d0e1a	dde22afa17d9ebb099518a512e0aa58754122fffc938a4eb823d190f9295b250	2022-06-02 07:26:04.286719+00	20220327080800_udpate_transformer_config_in_cl_2	\N	\N	2022-06-02 07:26:04.080605+00	1
a54c748d-e09a-449a-8cd1-d11eb4bacdd9	67d3192d354f3426495570c3499f2fa62899a970ab900461dacb62a96bb058b0	2022-06-02 07:26:07.065511+00	20220327160847_usersegment_category_optional	\N	\N	2022-06-02 07:26:06.872122+00	1
54723084-777e-434c-94f2-19a8859bc5ec	b736491f12459bdbeec0fff57d38bb80382db43ee563312dde70ad9614589b52	2022-06-02 07:26:04.568089+00	20220327112638_optional_start_date_end_date	\N	\N	2022-06-02 07:26:04.372095+00	1
cc376073-89fa-438a-a2da-3ee3d1aae105	b7f62b4ab5db2c4a82333aba365e7d65e28bda8e809b399ab30af67f9d7728d1	2022-06-02 07:26:04.841488+00	20220327113504_optional_description	\N	\N	2022-06-02 07:26:04.644809+00	1
84640186-3c72-4f20-a04f-10bc113ce70f	e27f10712652d57ba8f4e71f3ae7c0ca5ff88c71b80e8ca6dbc8c49d4e936974	2022-06-02 07:26:05.114796+00	20220327113624_optional_description	\N	\N	2022-06-02 07:26:04.919377+00	1
58634835-82fc-4d19-b493-120df8863bdc	ec2eb59dbb0e4167cc16566ac7af6518afc541f57557f704e2be3da62cddab9a	2022-06-02 07:26:07.358304+00	20220327161010_usersegment_service_remove_unique_constraint	\N	\N	2022-06-02 07:26:07.14825+00	1
880881d3-ce0c-4970-9ce9-66235c06a608	83077528c8442fc02004f47f46066fbdd08a7d62c503beb0150181e927f1d04b	2022-06-02 07:26:05.404636+00	20220327113749_optional_owner_id_owner_o_rg_id	\N	\N	2022-06-02 07:26:05.192258+00	1
cf01bbee-deba-4a56-9017-f664c989ff38	d5ff3072b2a25b932e3f665350e7b632dcf684b4bbaf68f7ccbb06c8077723a1	2022-06-02 07:26:05.860294+00	20220327114451_bot_start_date_date_not_time	\N	\N	2022-06-02 07:26:05.493472+00	1
74fa998d-e61d-42e3-8a15-e204b91e7ef9	921c29a6532a070566e1cdf4e6ac14e40d5b5ce96124f4b79ed12faa83e9d402	2022-06-02 07:26:06.242738+00	20220327155715_transformer_servic_not_unique	\N	\N	2022-06-02 07:26:05.997613+00	1
8aae4216-1497-4957-89b4-6b1382e2ffe0	dff74ca94c862a9b46700cef002a4c5de26aa8879bb4dbc1d6080ff3da07babb	2022-06-02 07:26:07.626037+00	20220327162041_transformer_config_remove_unique_constraint	\N	\N	2022-06-02 07:26:07.436494+00	1
44de05b8-48c4-42b5-a698-b644deaa6058	2335d4dcc06f0b08eaee877f1ac9828112ebff6952bb236fff5aa7e6df38f3c1	2022-06-02 07:26:07.899322+00	20220402120029_	\N	\N	2022-06-02 07:26:07.703421+00	1
80c8286e-30d1-45c5-bbf1-e48ea6c682b1	e7f0b6353c1af069a7bdb6fc8472ef5587e9229268aef10b60432bf654f88463	2022-06-02 07:26:08.180451+00	20220404042658_	\N	\N	2022-06-02 07:26:07.975736+00	1
4b68027b-301a-4cd4-af7b-0a80bca24413	62ffae6739998263f9fe6c261dc6560259784bc03c536c32c884b96762b5ca0c	2022-06-02 07:26:08.461397+00	20220601174909_add_status_to_bot	\N	\N	2022-06-02 07:26:08.259013+00	1
\.


--
-- Data for Name: adapter; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.adapter (id, channel, provider, config, name, updated_at, created_at) FROM stdin;
\.


--
-- Data for Name: board; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.board (id, name) FROM stdin;
\.


--
-- Data for Name: bot; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.bot (id, name, "startingMessage", users, "logicIDs", owners, created_at, updated_at, status, description, "startDate", "endDate", purpose, "ownerOrgID", "ownerID") FROM stdin;
\.


--
-- Data for Name: conversationLogic; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."conversationLogic" (id, transformers, adapter, name, created_at, updated_at, description, "ownerOrgID", "ownerID") FROM stdin;
\.


--
-- Data for Name: organisation; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.organisation (state, district, block, school, cluster, id, created_at, updated_at, school_code) FROM stdin;
\.


--
-- Data for Name: pgbench_accounts; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.pgbench_accounts (aid, bid, abalance, filler) FROM stdin;
\.


--
-- Data for Name: pgbench_branches; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.pgbench_branches (bid, bbalance, filler) FROM stdin;
\.


--
-- Data for Name: pgbench_history; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.pgbench_history (tid, bid, aid, delta, mtime, filler) FROM stdin;
\.


--
-- Data for Name: pgbench_tellers; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.pgbench_tellers (tid, bid, tbalance, filler) FROM stdin;
\.


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.role (id, name) FROM stdin;
\.


--
-- Data for Name: service; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.service (id, type, config, created_at, updated_at, name) FROM stdin;
\.


--
-- Data for Name: transformer; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.transformer (name, tags, config, id, service_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: userSegment; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."userSegment" (id, name, "all", "byID", "byPhone", created_at, updated_at, category, count, description, "ownerOrgID", "ownerID") FROM stdin;
\.


--
-- Name: Board_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgresql
--

SELECT pg_catalog.setval('public."Board_id_seq"', 1, false);


--
-- Name: boards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgresql
--

SELECT pg_catalog.setval('public.boards_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgresql
--

SELECT pg_catalog.setval('public.roles_id_seq', 1, false);


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_events
    ADD CONSTRAINT hdb_cron_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_resource_version_key UNIQUE (resource_version);


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_events
    ADD CONSTRAINT hdb_scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_notifications
    ADD CONSTRAINT hdb_schema_notifications_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: migration_settings migration_settings_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.migration_settings
    ADD CONSTRAINT migration_settings_pkey PRIMARY KEY (setting);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: Adapter Adapter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."Adapter"
    ADD CONSTRAINT "Adapter_pkey" PRIMARY KEY (id);


--
-- Name: Board Board_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."Board"
    ADD CONSTRAINT "Board_pkey" PRIMARY KEY (id);


--
-- Name: Bot Bot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."Bot"
    ADD CONSTRAINT "Bot_pkey" PRIMARY KEY (id);


--
-- Name: ConversationLogic ConversationLogic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."ConversationLogic"
    ADD CONSTRAINT "ConversationLogic_pkey" PRIMARY KEY (id);


--
-- Name: Service Service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."Service"
    ADD CONSTRAINT "Service_pkey" PRIMARY KEY (id);


--
-- Name: TransformerConfig TransformerConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."TransformerConfig"
    ADD CONSTRAINT "TransformerConfig_pkey" PRIMARY KEY (id);


--
-- Name: Transformer Transformer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."Transformer"
    ADD CONSTRAINT "Transformer_pkey" PRIMARY KEY (id);


--
-- Name: UserSegment UserSegment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."UserSegment"
    ADD CONSTRAINT "UserSegment_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: adapter adapter_name_key; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.adapter
    ADD CONSTRAINT adapter_name_key UNIQUE (name);


--
-- Name: adapter adapter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.adapter
    ADD CONSTRAINT adapter_pkey PRIMARY KEY (id);


--
-- Name: board boards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.board
    ADD CONSTRAINT boards_pkey PRIMARY KEY (id);


--
-- Name: bot bot_name_key; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.bot
    ADD CONSTRAINT bot_name_key UNIQUE (name);


--
-- Name: bot bot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.bot
    ADD CONSTRAINT bot_pkey PRIMARY KEY (id);


--
-- Name: bot bot_startingMessage_key; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.bot
    ADD CONSTRAINT "bot_startingMessage_key" UNIQUE ("startingMessage");


--
-- Name: conversationLogic conversationLogic_name_key; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."conversationLogic"
    ADD CONSTRAINT "conversationLogic_name_key" UNIQUE (name);


--
-- Name: conversationLogic conversationLogic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."conversationLogic"
    ADD CONSTRAINT "conversationLogic_pkey" PRIMARY KEY (id);


--
-- Name: organisation organisation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.organisation
    ADD CONSTRAINT organisation_pkey PRIMARY KEY (id);


--
-- Name: pgbench_accounts pgbench_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.pgbench_accounts
    ADD CONSTRAINT pgbench_accounts_pkey PRIMARY KEY (aid);


--
-- Name: pgbench_branches pgbench_branches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.pgbench_branches
    ADD CONSTRAINT pgbench_branches_pkey PRIMARY KEY (bid);


--
-- Name: pgbench_tellers pgbench_tellers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.pgbench_tellers
    ADD CONSTRAINT pgbench_tellers_pkey PRIMARY KEY (tid);


--
-- Name: role roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: service serviceType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.service
    ADD CONSTRAINT "serviceType_pkey" PRIMARY KEY (id);


--
-- Name: transformer transformer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.transformer
    ADD CONSTRAINT transformer_pkey PRIMARY KEY (id);


--
-- Name: userSegment userSegment_name_key; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."userSegment"
    ADD CONSTRAINT "userSegment_name_key" UNIQUE (name);


--
-- Name: userSegment userSegment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."userSegment"
    ADD CONSTRAINT "userSegment_pkey" PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: postgresql
--

CREATE INDEX hdb_cron_event_invocation_event_id ON hdb_catalog.hdb_cron_event_invocation_logs USING btree (event_id);


--
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: postgresql
--

CREATE INDEX hdb_cron_event_status ON hdb_catalog.hdb_cron_events USING btree (status);


--
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: postgresql
--

CREATE UNIQUE INDEX hdb_cron_events_unique_scheduled ON hdb_catalog.hdb_cron_events USING btree (trigger_name, scheduled_time) WHERE (status = 'scheduled'::text);


--
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: postgresql
--

CREATE INDEX hdb_scheduled_event_status ON hdb_catalog.hdb_scheduled_events USING btree (status);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: postgresql
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: Bot_name_key; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE UNIQUE INDEX "Bot_name_key" ON public."Bot" USING btree (name);


--
-- Name: UserSegment_name_key; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE UNIQUE INDEX "UserSegment_name_key" ON public."UserSegment" USING btree (name);


--
-- Name: _BotToConversationLogic_AB_unique; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE UNIQUE INDEX "_BotToConversationLogic_AB_unique" ON public."_BotToConversationLogic" USING btree ("A", "B");


--
-- Name: _BotToConversationLogic_B_index; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE INDEX "_BotToConversationLogic_B_index" ON public."_BotToConversationLogic" USING btree ("B");


--
-- Name: _BotToUserSegment_AB_unique; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE UNIQUE INDEX "_BotToUserSegment_AB_unique" ON public."_BotToUserSegment" USING btree ("A", "B");


--
-- Name: _BotToUserSegment_B_index; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE INDEX "_BotToUserSegment_B_index" ON public."_BotToUserSegment" USING btree ("B");


--
-- Name: bot_name; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE INDEX bot_name ON public.bot USING btree (name);


--
-- Name: bot_startingMessage; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE INDEX "bot_startingMessage" ON public.bot USING btree ("startingMessage");


--
-- Name: state_district; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE INDEX state_district ON public.organisation USING btree (state, district);


--
-- Name: state_district_block; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE INDEX state_district_block ON public.organisation USING btree (state, district, block);


--
-- Name: state_district_block_cluster; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE INDEX state_district_block_cluster ON public.organisation USING btree (state, district, block, cluster);


--
-- Name: state_index; Type: INDEX; Schema: public; Owner: postgresql
--

CREATE INDEX state_index ON public.organisation USING btree (state);


--
-- Name: adapter set_public_adapter_updated_at; Type: TRIGGER; Schema: public; Owner: postgresql
--

CREATE TRIGGER set_public_adapter_updated_at BEFORE UPDATE ON public.adapter FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_adapter_updated_at ON adapter; Type: COMMENT; Schema: public; Owner: postgresql
--

COMMENT ON TRIGGER set_public_adapter_updated_at ON public.adapter IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: bot set_public_bot_updated_at; Type: TRIGGER; Schema: public; Owner: postgresql
--

CREATE TRIGGER set_public_bot_updated_at BEFORE UPDATE ON public.bot FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_bot_updated_at ON bot; Type: COMMENT; Schema: public; Owner: postgresql
--

COMMENT ON TRIGGER set_public_bot_updated_at ON public.bot IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: conversationLogic set_public_conversationLogic_updated_at; Type: TRIGGER; Schema: public; Owner: postgresql
--

CREATE TRIGGER "set_public_conversationLogic_updated_at" BEFORE UPDATE ON public."conversationLogic" FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER "set_public_conversationLogic_updated_at" ON "conversationLogic"; Type: COMMENT; Schema: public; Owner: postgresql
--

COMMENT ON TRIGGER "set_public_conversationLogic_updated_at" ON public."conversationLogic" IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: organisation set_public_organisation_updated_at; Type: TRIGGER; Schema: public; Owner: postgresql
--

CREATE TRIGGER set_public_organisation_updated_at BEFORE UPDATE ON public.organisation FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_organisation_updated_at ON organisation; Type: COMMENT; Schema: public; Owner: postgresql
--

COMMENT ON TRIGGER set_public_organisation_updated_at ON public.organisation IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: service set_public_service_updated_at; Type: TRIGGER; Schema: public; Owner: postgresql
--

CREATE TRIGGER set_public_service_updated_at BEFORE UPDATE ON public.service FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_service_updated_at ON service; Type: COMMENT; Schema: public; Owner: postgresql
--

COMMENT ON TRIGGER set_public_service_updated_at ON public.service IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: transformer set_public_transformer_updated_at; Type: TRIGGER; Schema: public; Owner: postgresql
--

CREATE TRIGGER set_public_transformer_updated_at BEFORE UPDATE ON public.transformer FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_transformer_updated_at ON transformer; Type: COMMENT; Schema: public; Owner: postgresql
--

COMMENT ON TRIGGER set_public_transformer_updated_at ON public.transformer IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: userSegment set_public_userSegment_updated_at; Type: TRIGGER; Schema: public; Owner: postgresql
--

CREATE TRIGGER "set_public_userSegment_updated_at" BEFORE UPDATE ON public."userSegment" FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER "set_public_userSegment_updated_at" ON "userSegment"; Type: COMMENT; Schema: public; Owner: postgresql
--

COMMENT ON TRIGGER "set_public_userSegment_updated_at" ON public."userSegment" IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_cron_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgresql
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ConversationLogic ConversationLogic_adapterId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."ConversationLogic"
    ADD CONSTRAINT "ConversationLogic_adapterId_fkey" FOREIGN KEY ("adapterId") REFERENCES public."Adapter"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TransformerConfig TransformerConfig_conversationLogicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."TransformerConfig"
    ADD CONSTRAINT "TransformerConfig_conversationLogicId_fkey" FOREIGN KEY ("conversationLogicId") REFERENCES public."ConversationLogic"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: TransformerConfig TransformerConfig_transformerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."TransformerConfig"
    ADD CONSTRAINT "TransformerConfig_transformerId_fkey" FOREIGN KEY ("transformerId") REFERENCES public."Transformer"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Transformer Transformer_serviceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."Transformer"
    ADD CONSTRAINT "Transformer_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES public."Service"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: UserSegment UserSegment_allServiceID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."UserSegment"
    ADD CONSTRAINT "UserSegment_allServiceID_fkey" FOREIGN KEY ("allServiceID") REFERENCES public."Service"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: UserSegment UserSegment_byIDServiceID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."UserSegment"
    ADD CONSTRAINT "UserSegment_byIDServiceID_fkey" FOREIGN KEY ("byIDServiceID") REFERENCES public."Service"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: UserSegment UserSegment_byPhoneServiceID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."UserSegment"
    ADD CONSTRAINT "UserSegment_byPhoneServiceID_fkey" FOREIGN KEY ("byPhoneServiceID") REFERENCES public."Service"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: _BotToConversationLogic _BotToConversationLogic_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."_BotToConversationLogic"
    ADD CONSTRAINT "_BotToConversationLogic_A_fkey" FOREIGN KEY ("A") REFERENCES public."Bot"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _BotToConversationLogic _BotToConversationLogic_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."_BotToConversationLogic"
    ADD CONSTRAINT "_BotToConversationLogic_B_fkey" FOREIGN KEY ("B") REFERENCES public."ConversationLogic"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _BotToUserSegment _BotToUserSegment_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."_BotToUserSegment"
    ADD CONSTRAINT "_BotToUserSegment_A_fkey" FOREIGN KEY ("A") REFERENCES public."Bot"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _BotToUserSegment _BotToUserSegment_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."_BotToUserSegment"
    ADD CONSTRAINT "_BotToUserSegment_B_fkey" FOREIGN KEY ("B") REFERENCES public."UserSegment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: conversationLogic conversationLogic_adapter_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."conversationLogic"
    ADD CONSTRAINT "conversationLogic_adapter_fkey" FOREIGN KEY (adapter) REFERENCES public.adapter(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: transformer transformer_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.transformer
    ADD CONSTRAINT transformer_type_fkey FOREIGN KEY (service_id) REFERENCES public.service(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: userSegment userSegment_all_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."userSegment"
    ADD CONSTRAINT "userSegment_all_fkey" FOREIGN KEY ("all") REFERENCES public.service(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: userSegment userSegment_byID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."userSegment"
    ADD CONSTRAINT "userSegment_byID_fkey" FOREIGN KEY ("byID") REFERENCES public.service(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: userSegment userSegment_byPhone_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."userSegment"
    ADD CONSTRAINT "userSegment_byPhone_fkey" FOREIGN KEY ("byPhone") REFERENCES public.service(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

