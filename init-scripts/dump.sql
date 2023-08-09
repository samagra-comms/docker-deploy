\connect comms

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
-- Name: Adapter; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."Adapter" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
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
    AS integer
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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
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
    tags text[],
    "botImage" text
);


ALTER TABLE public."Bot" OWNER TO postgresql;

--
-- Name: ConversationLogic; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."ConversationLogic" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    description text,
    "adapterId" uuid NOT NULL
);


ALTER TABLE public."ConversationLogic" OWNER TO postgresql;

--
-- Name: Service; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."Service" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    meta jsonb NOT NULL,
    "transformerId" uuid NOT NULL,
    "conversationLogicId" uuid
);


ALTER TABLE public."TransformerConfig" OWNER TO postgresql;

--
-- Name: UserSegment; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public."UserSegment" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
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
-- Name: Board id; Type: DEFAULT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public."Board" ALTER COLUMN id SET DEFAULT nextval('public."Board_id_seq"'::regclass);


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
1	{"sources":[{"kind":"postgres","name":"default","tables":[{"table":{"schema":"public","name":"Adapter"}},{"table":{"schema":"public","name":"Board"}},{"table":{"schema":"public","name":"Bot"}},{"table":{"schema":"public","name":"ConversationLogic"}},{"table":{"schema":"public","name":"Service"}},{"table":{"schema":"public","name":"Transformer"}},{"table":{"schema":"public","name":"TransformerConfig"}},{"table":{"schema":"public","name":"UserSegment"}},{"table":{"schema":"public","name":"_BotToConversationLogic"}},{"table":{"schema":"public","name":"_BotToUserSegment"}}],"configuration":{"connection_info":{"use_prepared_statements":true,"database_url":{"from_env":"HASURA_GRAPHQL_DATABASE_URL"},"isolation_level":"read-committed","pool_settings":{"connection_lifetime":600,"retries":1,"idle_timeout":180,"max_connections":50}}}}],"version":3}	2
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
1	{"metadata":false,"remote_schemas":[],"sources":[]}	2	76a22db2-15f8-47c5-a1e5-c95e05edd62a	2023-08-08 17:11:53.319501+00
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgresql
--

COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state) FROM stdin;
46b1f613-4c08-4309-afbb-ef21af40a3ec	47	2023-08-08 17:09:09.579759+00	{}	{"console_notifications": {"admin": {"date": null, "read": [], "showBadge": true}}, "telemetryNotificationShown": true}
\.


--
-- Data for Name: Adapter; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."Adapter" (id, "createdAt", "updatedAt", channel, provider, config, name) FROM stdin;
44a9df72-3d7a-4ece-94c5-98cf26307324	2023-08-08 17:12:01.545	2023-08-08 17:12:01.545	WhatsApp	gupshup	{"2WAY": "2000193033", "phone": "9876543210", "HSM_ID": "2000193031", "credentials": {"vault": "samagra", "variable": "gupshupSamagraProd"}}	SamagraProd
44a9df72-3d7a-4ece-94c5-98cf26307323	2023-08-08 17:12:01.545	2023-08-08 17:12:01.545	WhatsApp	Netcore	{"phone": "912249757677", "credentials": {"vault": "samagra", "variable": "netcoreUAT"}}	SamagraNetcoreUAT
64036edb-e763-44b1-99b8-37b6c7b292c5	2023-08-08 17:12:01.545	2023-08-08 17:12:01.545	sms	gupshup	{"2WAY": "2000193033", "phone": "9876543210", "HSM_ID": "2000193031", "credentials": {"vault": "samagra", "variable": "gupshupSamagraProd"}}	SamagraGupshupSms
4e0c568c-7c42-4f88-b1d6-392ad16b8546	2023-08-08 17:12:01.545	2023-08-08 17:12:01.545	sms	cdac	{"2WAY": "2000193033", "phone": "9876543210", "HSM_ID": "2000193031", "credentials": {"vault": "samagra", "variable": "gupshupSamagraProd"}}	SamagraCdacSms
2a704e82-132e-41f2-9746-83e74550d2ea	2023-08-08 17:12:01.545	2023-08-08 17:12:01.545	web	firebase	{"credentials": {"vault": "samagra", "variable": "uci-firebase-notification"}}	SamagraFirebaseWeb
\.


--
-- Data for Name: Board; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."Board" (id, name) FROM stdin;
\.


--
-- Data for Name: Bot; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."Bot" (id, "createdAt", "updatedAt", name, "startingMessage", "ownerID", "ownerOrgID", purpose, description, "startDate", "endDate", status, tags, "botImage") FROM stdin;
\.


--
-- Data for Name: ConversationLogic; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."ConversationLogic" (id, name, "createdAt", "updatedAt", description, "adapterId") FROM stdin;
\.


--
-- Data for Name: Service; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."Service" (id, "createdAt", "updatedAt", type, config, name) FROM stdin;
94b7c56a-6537-49e3-88e5-4ea548b2f075	2023-08-08 17:12:01.545	2023-08-08 17:12:01.545	odk	{"cadence": {"retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10}, "credentials": {"vault": "samagra", "variable": "samagraMainODK"}}	\N
\.


--
-- Data for Name: Transformer; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."Transformer" (id, "createdAt", "updatedAt", name, tags, config, "serviceId") FROM stdin;
bbf56981-b8c9-40e9-8067-468c2c753659	2023-08-08 17:12:01.545	2023-08-08 17:12:01.545	SamagraODKAgg	{ODK}	{}	94b7c56a-6537-49e3-88e5-4ea548b2f075
774cd134-6657-4688-85f6-6338e2323dde	2023-08-08 17:12:01.545	2023-08-08 17:12:01.545	SamagraBroadcast	{broadcast}	{}	94b7c56a-6537-49e3-88e5-4ea548b2f075
0832ca13-c698-4234-8070-b5f708bc0b1a	2023-08-08 17:12:01.545	2023-08-08 17:12:01.545	SamagraGeneric	{generic}	{}	94b7c56a-6537-49e3-88e5-4ea548b2f075
\.


--
-- Data for Name: TransformerConfig; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."TransformerConfig" (id, "createdAt", "updatedAt", meta, "transformerId", "conversationLogicId") FROM stdin;
\.


--
-- Data for Name: UserSegment; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."UserSegment" (id, "createdAt", "updatedAt", name, description, count, category, "allServiceID", "byPhoneServiceID", "byIDServiceID", "botId") FROM stdin;
\.


--
-- Data for Name: _BotToConversationLogic; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."_BotToConversationLogic" ("A", "B") FROM stdin;
\.


--
-- Data for Name: _BotToUserSegment; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public."_BotToUserSegment" ("A", "B") FROM stdin;
\.


--
-- Name: Board_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgresql
--

SELECT pg_catalog.setval('public."Board_id_seq"', 1, false);


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