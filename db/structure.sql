\restrict wYKYerOl20vG8HMj21M4LQwtQAmO5qquIW5eio75KbndhzVLqDjoc1BddgnNXhW

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_auth0_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_auth0_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_id uuid NOT NULL,
    auth0_account_id uuid NOT NULL,
    tenant_id public.citext NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: auth0_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth0_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    uid character varying NOT NULL,
    email character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_authorization_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_authorization_tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    remote_id uuid,
    provider character varying,
    unique_id character varying,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_content_authorization_tags_provider CHECK (((provider)::text = ANY ((ARRAY['system'::character varying, 'idp'::character varying, 'ruler'::character varying])::text[])))
);


--
-- Name: COLUMN content_authorization_tags.remote_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.content_authorization_tags.remote_id IS 'DEPRECATED: External system ID for synchronization';


--
-- Name: COLUMN content_authorization_tags.provider; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.content_authorization_tags.provider IS 'Tag provider: system, idp, ruler, or NULL for custom';


--
-- Name: COLUMN content_authorization_tags.unique_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.content_authorization_tags.unique_id IS 'Unique identifier within provider scope';


--
-- Name: content_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    content_type_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_entry_authorizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_entry_authorizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    content_entry_id uuid NOT NULL,
    version integer NOT NULL,
    content_authorization_tag_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_entry_field_media_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_entry_field_media_assets (
    id bigint NOT NULL,
    tenant_id public.citext NOT NULL,
    media_type integer NOT NULL,
    media_asset_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_entry_field_media_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_entry_field_media_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_entry_field_media_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_entry_field_media_assets_id_seq OWNED BY public.content_entry_field_media_assets.id;


--
-- Name: content_entry_field_richtexts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_entry_field_richtexts (
    id bigint NOT NULL,
    value jsonb NOT NULL
);


--
-- Name: content_entry_field_richtexts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_entry_field_richtexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_entry_field_richtexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_entry_field_richtexts_id_seq OWNED BY public.content_entry_field_richtexts.id;


--
-- Name: content_entry_field_select_selections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_entry_field_select_selections (
    id bigint NOT NULL,
    content_entry_field_select_id bigint NOT NULL,
    option_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_entry_field_select_selections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_entry_field_select_selections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_entry_field_select_selections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_entry_field_select_selections_id_seq OWNED BY public.content_entry_field_select_selections.id;


--
-- Name: content_entry_field_selects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_entry_field_selects (
    id bigint NOT NULL,
    tenant_id public.citext NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_entry_field_selects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_entry_field_selects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_entry_field_selects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_entry_field_selects_id_seq OWNED BY public.content_entry_field_selects.id;


--
-- Name: content_entry_field_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_entry_field_texts (
    id bigint NOT NULL,
    value text NOT NULL
);


--
-- Name: content_entry_field_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_entry_field_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_entry_field_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_entry_field_texts_id_seq OWNED BY public.content_entry_field_texts.id;


--
-- Name: content_entry_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_entry_fields (
    id bigint NOT NULL,
    tenant_id public.citext NOT NULL,
    content_type_id uuid NOT NULL,
    content_entry_id uuid NOT NULL,
    version integer NOT NULL,
    content_type_field_id integer NOT NULL,
    field_type integer NOT NULL,
    text_id integer,
    richtext_id integer,
    media_asset_id integer,
    select_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_entry_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_entry_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_entry_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_entry_fields_id_seq OWNED BY public.content_entry_fields.id;


--
-- Name: content_entry_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_entry_versions (
    id bigint NOT NULL,
    tenant_id public.citext NOT NULL,
    content_type_id uuid NOT NULL,
    content_entry_id uuid NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    status integer NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    visibility integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    published_at timestamp(6) without time zone,
    unpublished_at timestamp(6) without time zone
);


--
-- Name: content_entry_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_entry_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_entry_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_entry_versions_id_seq OWNED BY public.content_entry_versions.id;


--
-- Name: content_type_field_media_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_type_field_media_assets (
    id bigint NOT NULL
);


--
-- Name: content_type_field_media_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_type_field_media_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_type_field_media_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_type_field_media_assets_id_seq OWNED BY public.content_type_field_media_assets.id;


--
-- Name: content_type_field_richtexts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_type_field_richtexts (
    id bigint NOT NULL
);


--
-- Name: content_type_field_richtexts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_type_field_richtexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_type_field_richtexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_type_field_richtexts_id_seq OWNED BY public.content_type_field_richtexts.id;


--
-- Name: content_type_field_select_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_type_field_select_options (
    id bigint NOT NULL,
    field_select_id bigint NOT NULL,
    unique_name character varying NOT NULL,
    display_name text NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    status smallint DEFAULT 1 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN content_type_field_select_options.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.content_type_field_select_options.status IS '0: disabled, 1: enabled';


--
-- Name: content_type_field_select_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_type_field_select_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_type_field_select_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_type_field_select_options_id_seq OWNED BY public.content_type_field_select_options.id;


--
-- Name: content_type_field_selects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_type_field_selects (
    id bigint NOT NULL,
    display_format integer DEFAULT 1 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_type_field_selects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_type_field_selects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_type_field_selects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_type_field_selects_id_seq OWNED BY public.content_type_field_selects.id;


--
-- Name: content_type_field_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_type_field_texts (
    id bigint NOT NULL
);


--
-- Name: content_type_field_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_type_field_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_type_field_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_type_field_texts_id_seq OWNED BY public.content_type_field_texts.id;


--
-- Name: content_type_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_type_fields (
    id bigint NOT NULL,
    tenant_id public.citext NOT NULL,
    content_type_id uuid NOT NULL,
    api_identifier text NOT NULL,
    label text NOT NULL,
    field_type integer NOT NULL,
    text_id integer,
    richtext_id integer,
    media_asset_id integer,
    select_id bigint,
    description text DEFAULT ''::text NOT NULL,
    required boolean DEFAULT false NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_type_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_type_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_type_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_type_fields_id_seq OWNED BY public.content_type_fields.id;


--
-- Name: content_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    is_collection boolean DEFAULT true NOT NULL,
    display_name text,
    unique_name text,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: media_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_assets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    media_type integer NOT NULL,
    mime_type character varying NOT NULL,
    file_size_bytes bigint NOT NULL,
    s3_object_path character varying NOT NULL,
    metadata jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: oauth_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying NOT NULL,
    kind character varying DEFAULT 'user'::character varying NOT NULL,
    client_id character varying NOT NULL,
    client_secret character varying,
    endpoint_base character varying NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    keypath_uid character varying,
    session_expires_in integer DEFAULT 7776000 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN oauth_providers.kind; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.oauth_providers.kind IS 'user or admin';


--
-- Name: COLUMN oauth_providers.keypath_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.oauth_providers.keypath_uid IS 'UIDを取得するためのkeypath (デフォルト: sub)';


--
-- Name: COLUMN oauth_providers.session_expires_in; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.oauth_providers.session_expires_in IS 'セッショントークンの有効期間 (90 days)';


--
-- Name: ruler_auth0_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ruler_auth0_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ruler_id uuid NOT NULL,
    auth0_account_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: rulers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rulers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: session_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_tokens (
    id character varying NOT NULL,
    tenant_id character varying NOT NULL,
    user_id uuid NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: site_custom_variables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_custom_variables (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying NOT NULL,
    unique_name character varying NOT NULL,
    variable_type smallint NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    boolean_value boolean,
    datetime_value timestamp(6) without time zone,
    text_value text,
    archived_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_site_custom_variables_boolean_consistency CHECK (((variable_type <> 1) OR ((boolean_value IS NOT NULL) AND (datetime_value IS NULL) AND (text_value IS NULL)))),
    CONSTRAINT chk_site_custom_variables_datetime_consistency CHECK (((variable_type <> 2) OR ((datetime_value IS NOT NULL) AND (boolean_value IS NULL) AND (text_value IS NULL)))),
    CONSTRAINT chk_site_custom_variables_text_consistency CHECK (((variable_type <> 3) OR ((text_value IS NOT NULL) AND (boolean_value IS NULL) AND (datetime_value IS NULL)))),
    CONSTRAINT chk_site_custom_variables_variable_type CHECK ((variable_type = ANY (ARRAY[1, 2, 3])))
);


--
-- Name: COLUMN site_custom_variables.variable_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.site_custom_variables.variable_type IS '1: boolean, 2: datetime, 3: text';


--
-- Name: tenant_site_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_site_settings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying NOT NULL,
    features jsonb DEFAULT '{}'::jsonb NOT NULL,
    landing jsonb DEFAULT '{}'::jsonb NOT NULL,
    footer_main_links jsonb DEFAULT '[]'::jsonb NOT NULL,
    footer_sub_links jsonb DEFAULT '[]'::jsonb NOT NULL,
    menu_items jsonb DEFAULT '[]'::jsonb NOT NULL,
    login_label character varying DEFAULT 'ログイン'::character varying NOT NULL,
    signup_label character varying DEFAULT '新規会員登録'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: tenant_themes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_themes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying NOT NULL,
    logo_media_asset_id uuid NOT NULL,
    page_background_color character varying DEFAULT '#FFFFFF'::character varying NOT NULL,
    general_text_color character varying DEFAULT '#000000'::character varying NOT NULL,
    general_font_family character varying DEFAULT '"Noto Sans JP", sans-serif'::character varying NOT NULL,
    border_color character varying DEFAULT '#E5E5E5'::character varying NOT NULL,
    title_text_color character varying DEFAULT '#000000'::character varying NOT NULL,
    title_font_family character varying DEFAULT '"Noto Serif JP", serif'::character varying NOT NULL,
    navigation_text_color character varying DEFAULT '#000000'::character varying NOT NULL,
    navigation_font_family character varying DEFAULT '"Noto Serif JP", serif'::character varying NOT NULL,
    link_text_color character varying DEFAULT '#0000FF'::character varying NOT NULL,
    link_underline boolean DEFAULT true NOT NULL,
    tab_font_family character varying DEFAULT '"Noto Sans JP", sans-serif'::character varying NOT NULL,
    tab_active_text_color character varying DEFAULT '#0000FF'::character varying NOT NULL,
    tab_active_underline_color character varying DEFAULT '#0000FF'::character varying NOT NULL,
    tab_inactive_text_color character varying DEFAULT '#666666'::character varying NOT NULL,
    tab_inactive_underline_color character varying DEFAULT '#FFFFFF'::character varying NOT NULL,
    caption_text_color character varying DEFAULT '#666666'::character varying NOT NULL,
    caption_font_family character varying DEFAULT '"Noto Sans JP", sans-serif'::character varying NOT NULL,
    label_background_color character varying DEFAULT '#0000FF'::character varying NOT NULL,
    label_text_color character varying DEFAULT '#FFFFFF'::character varying NOT NULL,
    label_font_family character varying DEFAULT '"Noto Sans JP", sans-serif'::character varying NOT NULL,
    button_font_family character varying DEFAULT '"Noto Sans JP", sans-serif'::character varying NOT NULL,
    button_primary_background_color character varying DEFAULT '#0000FF'::character varying NOT NULL,
    button_primary_text_color character varying DEFAULT '#FFFFFF'::character varying NOT NULL,
    button_secondary_border_color character varying DEFAULT '#0000FF'::character varying NOT NULL,
    button_secondary_background_color character varying DEFAULT '#FFFFFF'::character varying NOT NULL,
    button_secondary_text_color character varying DEFAULT '#0000FF'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_tenant_themes_border_color_format CHECK (((border_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_button_primary_background_color_format CHECK (((button_primary_background_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_button_primary_text_color_format CHECK (((button_primary_text_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_button_secondary_background_color_format CHECK (((button_secondary_background_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_button_secondary_border_color_format CHECK (((button_secondary_border_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_button_secondary_text_color_format CHECK (((button_secondary_text_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_caption_text_color_format CHECK (((caption_text_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_general_text_color_format CHECK (((general_text_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_label_background_color_format CHECK (((label_background_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_label_text_color_format CHECK (((label_text_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_link_text_color_format CHECK (((link_text_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_navigation_text_color_format CHECK (((navigation_text_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_page_background_color_format CHECK (((page_background_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_tab_active_text_color_format CHECK (((tab_active_text_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_tab_active_underline_color_format CHECK (((tab_active_underline_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_tab_inactive_text_color_format CHECK (((tab_inactive_text_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_tab_inactive_underline_color_format CHECK (((tab_inactive_underline_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text)),
    CONSTRAINT chk_tenant_themes_title_text_color_format CHECK (((title_text_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text))
);


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id character varying NOT NULL,
    name character varying,
    user_page_domain character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    user_id uuid NOT NULL,
    content_authorization_tag_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id public.citext NOT NULL,
    oauth_provider_id uuid NOT NULL,
    uid character varying NOT NULL,
    last_authenticated_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN users.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.uid IS 'IDP platform user ID';


--
-- Name: content_entry_field_media_assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_media_assets ALTER COLUMN id SET DEFAULT nextval('public.content_entry_field_media_assets_id_seq'::regclass);


--
-- Name: content_entry_field_richtexts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_richtexts ALTER COLUMN id SET DEFAULT nextval('public.content_entry_field_richtexts_id_seq'::regclass);


--
-- Name: content_entry_field_select_selections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_select_selections ALTER COLUMN id SET DEFAULT nextval('public.content_entry_field_select_selections_id_seq'::regclass);


--
-- Name: content_entry_field_selects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_selects ALTER COLUMN id SET DEFAULT nextval('public.content_entry_field_selects_id_seq'::regclass);


--
-- Name: content_entry_field_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_texts ALTER COLUMN id SET DEFAULT nextval('public.content_entry_field_texts_id_seq'::regclass);


--
-- Name: content_entry_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_fields ALTER COLUMN id SET DEFAULT nextval('public.content_entry_fields_id_seq'::regclass);


--
-- Name: content_entry_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_versions ALTER COLUMN id SET DEFAULT nextval('public.content_entry_versions_id_seq'::regclass);


--
-- Name: content_type_field_media_assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_media_assets ALTER COLUMN id SET DEFAULT nextval('public.content_type_field_media_assets_id_seq'::regclass);


--
-- Name: content_type_field_richtexts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_richtexts ALTER COLUMN id SET DEFAULT nextval('public.content_type_field_richtexts_id_seq'::regclass);


--
-- Name: content_type_field_select_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_select_options ALTER COLUMN id SET DEFAULT nextval('public.content_type_field_select_options_id_seq'::regclass);


--
-- Name: content_type_field_selects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_selects ALTER COLUMN id SET DEFAULT nextval('public.content_type_field_selects_id_seq'::regclass);


--
-- Name: content_type_field_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_texts ALTER COLUMN id SET DEFAULT nextval('public.content_type_field_texts_id_seq'::regclass);


--
-- Name: content_type_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_fields ALTER COLUMN id SET DEFAULT nextval('public.content_type_fields_id_seq'::regclass);


--
-- Name: admin_auth0_accounts admin_auth0_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_auth0_accounts
    ADD CONSTRAINT admin_auth0_accounts_pkey PRIMARY KEY (id);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: auth0_accounts auth0_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth0_accounts
    ADD CONSTRAINT auth0_accounts_pkey PRIMARY KEY (id);


--
-- Name: content_authorization_tags content_authorization_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_authorization_tags
    ADD CONSTRAINT content_authorization_tags_pkey PRIMARY KEY (id);


--
-- Name: content_entries content_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entries
    ADD CONSTRAINT content_entries_pkey PRIMARY KEY (id);


--
-- Name: content_entry_authorizations content_entry_authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_authorizations
    ADD CONSTRAINT content_entry_authorizations_pkey PRIMARY KEY (id);


--
-- Name: content_entry_field_media_assets content_entry_field_media_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_media_assets
    ADD CONSTRAINT content_entry_field_media_assets_pkey PRIMARY KEY (id);


--
-- Name: content_entry_field_richtexts content_entry_field_richtexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_richtexts
    ADD CONSTRAINT content_entry_field_richtexts_pkey PRIMARY KEY (id);


--
-- Name: content_entry_field_select_selections content_entry_field_select_selections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_select_selections
    ADD CONSTRAINT content_entry_field_select_selections_pkey PRIMARY KEY (id);


--
-- Name: content_entry_field_selects content_entry_field_selects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_selects
    ADD CONSTRAINT content_entry_field_selects_pkey PRIMARY KEY (id);


--
-- Name: content_entry_field_texts content_entry_field_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_texts
    ADD CONSTRAINT content_entry_field_texts_pkey PRIMARY KEY (id);


--
-- Name: content_entry_fields content_entry_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_fields
    ADD CONSTRAINT content_entry_fields_pkey PRIMARY KEY (id);


--
-- Name: content_entry_versions content_entry_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_versions
    ADD CONSTRAINT content_entry_versions_pkey PRIMARY KEY (id);


--
-- Name: content_type_field_media_assets content_type_field_media_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_media_assets
    ADD CONSTRAINT content_type_field_media_assets_pkey PRIMARY KEY (id);


--
-- Name: content_type_field_richtexts content_type_field_richtexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_richtexts
    ADD CONSTRAINT content_type_field_richtexts_pkey PRIMARY KEY (id);


--
-- Name: content_type_field_select_options content_type_field_select_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_select_options
    ADD CONSTRAINT content_type_field_select_options_pkey PRIMARY KEY (id);


--
-- Name: content_type_field_selects content_type_field_selects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_selects
    ADD CONSTRAINT content_type_field_selects_pkey PRIMARY KEY (id);


--
-- Name: content_type_field_texts content_type_field_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_texts
    ADD CONSTRAINT content_type_field_texts_pkey PRIMARY KEY (id);


--
-- Name: content_type_fields content_type_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_fields
    ADD CONSTRAINT content_type_fields_pkey PRIMARY KEY (id);


--
-- Name: content_types content_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_types
    ADD CONSTRAINT content_types_pkey PRIMARY KEY (id);


--
-- Name: media_assets media_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_assets
    ADD CONSTRAINT media_assets_pkey PRIMARY KEY (id);


--
-- Name: oauth_providers oauth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_providers
    ADD CONSTRAINT oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: ruler_auth0_accounts ruler_auth0_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruler_auth0_accounts
    ADD CONSTRAINT ruler_auth0_accounts_pkey PRIMARY KEY (id);


--
-- Name: rulers rulers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rulers
    ADD CONSTRAINT rulers_pkey PRIMARY KEY (id);


--
-- Name: session_tokens session_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_tokens
    ADD CONSTRAINT session_tokens_pkey PRIMARY KEY (id);


--
-- Name: site_custom_variables site_custom_variables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_custom_variables
    ADD CONSTRAINT site_custom_variables_pkey PRIMARY KEY (id);


--
-- Name: tenant_site_settings tenant_site_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_site_settings
    ADD CONSTRAINT tenant_site_settings_pkey PRIMARY KEY (id);


--
-- Name: tenant_themes tenant_themes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_themes
    ADD CONSTRAINT tenant_themes_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: user_tags user_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tags
    ADD CONSTRAINT user_tags_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_admin_auth0_accounts_admin_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_admin_auth0_accounts_admin_uniq ON public.admin_auth0_accounts USING btree (admin_id);


--
-- Name: idx_admin_auth0_accounts_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_auth0_accounts_tenant ON public.admin_auth0_accounts USING btree (tenant_id);


--
-- Name: idx_admins_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admins_tenant_id ON public.admins USING btree (tenant_id);


--
-- Name: idx_auth0_accounts_email_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_auth0_accounts_email_uniq ON public.auth0_accounts USING btree (email);


--
-- Name: idx_auth0_accounts_uid_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_auth0_accounts_uid_uniq ON public.auth0_accounts USING btree (uid);


--
-- Name: idx_field_select_selections_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_field_select_selections_unique ON public.content_entry_field_select_selections USING btree (content_entry_field_select_id, option_id);


--
-- Name: idx_on_content_type_id_api_identifier_0e95c10a8a; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_content_type_id_api_identifier_0e95c10a8a ON public.content_type_fields USING btree (content_type_id, api_identifier);


--
-- Name: idx_on_field_select_id_position_9d0ef88527; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_field_select_id_position_9d0ef88527 ON public.content_type_field_select_options USING btree (field_select_id, "position");


--
-- Name: idx_on_field_select_id_unique_name_47572cb0f7; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_field_select_id_unique_name_47572cb0f7 ON public.content_type_field_select_options USING btree (field_select_id, unique_name);


--
-- Name: idx_on_tenant_id_content_type_id_id_01457429a3; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_tenant_id_content_type_id_id_01457429a3 ON public.content_type_fields USING btree (tenant_id, content_type_id, id);


--
-- Name: idx_on_tenant_id_content_type_id_id_field_type_db01de1ec3; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_tenant_id_content_type_id_id_field_type_db01de1ec3 ON public.content_type_fields USING btree (tenant_id, content_type_id, id, field_type);


--
-- Name: idx_ruler_auth0_accounts_ruler_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_ruler_auth0_accounts_ruler_uniq ON public.ruler_auth0_accounts USING btree (ruler_id);


--
-- Name: idx_session_tokens_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_session_tokens_expires_at ON public.session_tokens USING btree (expires_at);


--
-- Name: idx_session_tokens_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_session_tokens_tenant_id ON public.session_tokens USING btree (tenant_id);


--
-- Name: idx_session_tokens_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_session_tokens_updated_at ON public.session_tokens USING btree (updated_at);


--
-- Name: idx_session_tokens_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_session_tokens_user_id ON public.session_tokens USING btree (user_id);


--
-- Name: idx_site_custom_variables_tenant_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_site_custom_variables_tenant_archived ON public.site_custom_variables USING btree (tenant_id, archived_at);


--
-- Name: idx_site_custom_variables_unique_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_site_custom_variables_unique_name ON public.site_custom_variables USING btree (tenant_id, unique_name) WHERE (archived_at IS NULL);


--
-- Name: index_admin_auth0_accounts_on_auth0_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_auth0_accounts_on_auth0_account_id ON public.admin_auth0_accounts USING btree (auth0_account_id);


--
-- Name: index_content_authorization_tags_on_provider_unique_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_authorization_tags_on_provider_unique_id ON public.content_authorization_tags USING btree (tenant_id, provider, unique_id) WHERE (provider IS NOT NULL);


--
-- Name: index_content_authorization_tags_on_tenant_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_authorization_tags_on_tenant_id_and_id ON public.content_authorization_tags USING btree (tenant_id, id);


--
-- Name: index_content_authorization_tags_on_tenant_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_authorization_tags_on_tenant_id_and_name ON public.content_authorization_tags USING btree (tenant_id, name);


--
-- Name: index_content_authorization_tags_on_tenant_id_and_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_authorization_tags_on_tenant_id_and_remote_id ON public.content_authorization_tags USING btree (tenant_id, remote_id) WHERE (remote_id IS NOT NULL);


--
-- Name: index_content_entries_on_tenant_id_and_content_type_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_entries_on_tenant_id_and_content_type_id_and_id ON public.content_entries USING btree (tenant_id, content_type_id, id);


--
-- Name: index_content_entries_on_tenant_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_entries_on_tenant_id_and_id ON public.content_entries USING btree (tenant_id, id);


--
-- Name: index_content_entry_authorizations_on_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_entry_authorizations_on_tag ON public.content_entry_authorizations USING btree (content_authorization_tag_id);


--
-- Name: index_content_entry_authorizations_on_tenant_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_entry_authorizations_on_tenant_id_and_id ON public.content_entry_authorizations USING btree (tenant_id, id);


--
-- Name: index_content_entry_authorizations_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_entry_authorizations_unique ON public.content_entry_authorizations USING btree (tenant_id, content_entry_id, version, content_authorization_tag_id);


--
-- Name: index_content_entry_field_media_assets_on_tenant_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_entry_field_media_assets_on_tenant_id_and_id ON public.content_entry_field_media_assets USING btree (tenant_id, id);


--
-- Name: index_content_entry_field_selects_on_tenant_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_entry_field_selects_on_tenant_id_and_id ON public.content_entry_field_selects USING btree (tenant_id, id);


--
-- Name: index_content_entry_versions_on_entry_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_entry_versions_on_entry_version ON public.content_entry_versions USING btree (content_entry_id, version);


--
-- Name: index_content_entry_versions_on_tenant_is_public; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_entry_versions_on_tenant_is_public ON public.content_entry_versions USING btree (tenant_id, is_public);


--
-- Name: index_content_entry_versions_on_tenant_type_entry_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_entry_versions_on_tenant_type_entry_version ON public.content_entry_versions USING btree (tenant_id, content_type_id, content_entry_id, version);


--
-- Name: index_content_entry_versions_on_tenant_visibility; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_entry_versions_on_tenant_visibility ON public.content_entry_versions USING btree (tenant_id, visibility);


--
-- Name: index_content_entry_versions_unique_draft_per_entry; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_entry_versions_unique_draft_per_entry ON public.content_entry_versions USING btree (content_entry_id) WHERE (status = 1);


--
-- Name: index_content_entry_versions_unique_published_per_entry; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_entry_versions_unique_published_per_entry ON public.content_entry_versions USING btree (content_entry_id) WHERE (status = 3);


--
-- Name: index_content_type_fields_on_content_type_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_type_fields_on_content_type_id_and_position ON public.content_type_fields USING btree (content_type_id, "position");


--
-- Name: index_content_types_on_id_and_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_types_on_id_and_tenant_id ON public.content_types USING btree (id, tenant_id);


--
-- Name: index_content_types_on_tenant_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_types_on_tenant_id_and_id ON public.content_types USING btree (tenant_id, id);


--
-- Name: index_media_assets_on_id_and_media_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_media_assets_on_id_and_media_type ON public.media_assets USING btree (id, media_type);


--
-- Name: index_media_assets_on_tenant_id_and_id_and_media_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_media_assets_on_tenant_id_and_id_and_media_type ON public.media_assets USING btree (tenant_id, id, media_type);


--
-- Name: index_media_assets_on_tenant_id_and_media_type_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_media_assets_on_tenant_id_and_media_type_and_id ON public.media_assets USING btree (tenant_id, media_type, id);


--
-- Name: index_oauth_providers_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_providers_on_tenant_id ON public.oauth_providers USING btree (tenant_id);


--
-- Name: index_oauth_providers_on_tenant_id_and_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_providers_on_tenant_id_and_kind ON public.oauth_providers USING btree (tenant_id, kind) WHERE ((kind)::text = 'user'::text);


--
-- Name: index_ruler_auth0_accounts_on_auth0_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ruler_auth0_accounts_on_auth0_account_id ON public.ruler_auth0_accounts USING btree (auth0_account_id);


--
-- Name: index_session_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_session_tokens_on_user_id ON public.session_tokens USING btree (user_id);


--
-- Name: index_tenant_site_settings_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tenant_site_settings_on_tenant_id ON public.tenant_site_settings USING btree (tenant_id);


--
-- Name: index_tenant_themes_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tenant_themes_on_tenant_id ON public.tenant_themes USING btree (tenant_id);


--
-- Name: index_user_tags_on_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tags_on_tag ON public.user_tags USING btree (content_authorization_tag_id);


--
-- Name: index_user_tags_on_tenant_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_tags_on_tenant_id_and_id ON public.user_tags USING btree (tenant_id, id);


--
-- Name: index_user_tags_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_tags_unique ON public.user_tags USING btree (tenant_id, user_id, content_authorization_tag_id);


--
-- Name: index_users_on_oauth_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_oauth_provider_id ON public.users USING btree (oauth_provider_id);


--
-- Name: index_users_on_tenant_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_tenant_id_and_id ON public.users USING btree (tenant_id, id);


--
-- Name: index_users_on_tenant_id_and_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_tenant_id_and_uid ON public.users USING btree (tenant_id, uid);


--
-- Name: admin_auth0_accounts fk_admin_auth0_accounts_admins; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_auth0_accounts
    ADD CONSTRAINT fk_admin_auth0_accounts_admins FOREIGN KEY (admin_id) REFERENCES public.admins(id);


--
-- Name: admin_auth0_accounts fk_admin_auth0_accounts_auth0_accounts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_auth0_accounts
    ADD CONSTRAINT fk_admin_auth0_accounts_auth0_accounts FOREIGN KEY (auth0_account_id) REFERENCES public.auth0_accounts(id);


--
-- Name: admin_auth0_accounts fk_admin_auth0_accounts_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_auth0_accounts
    ADD CONSTRAINT fk_admin_auth0_accounts_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: admins fk_admins_tenants; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT fk_admins_tenants FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: content_entry_authorizations fk_content_entry_authorizations_versions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_authorizations
    ADD CONSTRAINT fk_content_entry_authorizations_versions FOREIGN KEY (content_entry_id, version) REFERENCES public.content_entry_versions(content_entry_id, version);


--
-- Name: content_entry_field_media_assets fk_content_entry_field_media_assets_media_assets; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_media_assets
    ADD CONSTRAINT fk_content_entry_field_media_assets_media_assets FOREIGN KEY (tenant_id, media_type, media_asset_id) REFERENCES public.media_assets(tenant_id, media_type, id);


--
-- Name: content_entry_fields fk_content_entry_fields_content_entry_versions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_fields
    ADD CONSTRAINT fk_content_entry_fields_content_entry_versions FOREIGN KEY (tenant_id, content_type_id, content_entry_id, version) REFERENCES public.content_entry_versions(tenant_id, content_type_id, content_entry_id, version);


--
-- Name: content_entry_fields fk_content_entry_fields_content_type_fields; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_fields
    ADD CONSTRAINT fk_content_entry_fields_content_type_fields FOREIGN KEY (tenant_id, content_type_id, content_type_field_id, field_type) REFERENCES public.content_type_fields(tenant_id, content_type_id, id, field_type);


--
-- Name: content_entry_fields fk_content_entry_fields_media_assets; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_fields
    ADD CONSTRAINT fk_content_entry_fields_media_assets FOREIGN KEY (tenant_id, media_asset_id) REFERENCES public.content_entry_field_media_assets(tenant_id, id);


--
-- Name: content_entry_fields fk_content_entry_fields_selects; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_fields
    ADD CONSTRAINT fk_content_entry_fields_selects FOREIGN KEY (tenant_id, select_id) REFERENCES public.content_entry_field_selects(tenant_id, id);


--
-- Name: content_entry_versions fk_content_entry_versions_content_entries; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_versions
    ADD CONSTRAINT fk_content_entry_versions_content_entries FOREIGN KEY (tenant_id, content_type_id, content_entry_id) REFERENCES public.content_entries(tenant_id, content_type_id, id);


--
-- Name: oauth_providers fk_rails_024daef17e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_providers
    ADD CONSTRAINT fk_rails_024daef17e FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: content_entry_field_select_selections fk_rails_078150e814; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_select_selections
    ADD CONSTRAINT fk_rails_078150e814 FOREIGN KEY (option_id) REFERENCES public.content_type_field_select_options(id);


--
-- Name: content_type_fields fk_rails_0be4e1abaf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_fields
    ADD CONSTRAINT fk_rails_0be4e1abaf FOREIGN KEY (text_id) REFERENCES public.content_type_field_texts(id);


--
-- Name: users fk_rails_135c8f54b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_135c8f54b2 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: content_type_field_select_options fk_rails_25b1496600; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_field_select_options
    ADD CONSTRAINT fk_rails_25b1496600 FOREIGN KEY (field_select_id) REFERENCES public.content_type_field_selects(id);


--
-- Name: site_custom_variables fk_rails_28fd5e0209; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_custom_variables
    ADD CONSTRAINT fk_rails_28fd5e0209 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_tags fk_rails_2f428c3efb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tags
    ADD CONSTRAINT fk_rails_2f428c3efb FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: content_type_fields fk_rails_32a2d977e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_fields
    ADD CONSTRAINT fk_rails_32a2d977e0 FOREIGN KEY (select_id) REFERENCES public.content_type_field_selects(id);


--
-- Name: tenant_site_settings fk_rails_4c850b6370; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_site_settings
    ADD CONSTRAINT fk_rails_4c850b6370 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: content_type_fields fk_rails_56320489b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_fields
    ADD CONSTRAINT fk_rails_56320489b5 FOREIGN KEY (richtext_id) REFERENCES public.content_type_field_richtexts(id);


--
-- Name: content_entry_field_select_selections fk_rails_5b17e34e84; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_select_selections
    ADD CONSTRAINT fk_rails_5b17e34e84 FOREIGN KEY (content_entry_field_select_id) REFERENCES public.content_entry_field_selects(id);


--
-- Name: content_entry_authorizations fk_rails_656b6fcf2a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_authorizations
    ADD CONSTRAINT fk_rails_656b6fcf2a FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: content_entry_authorizations fk_rails_666125a13a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_authorizations
    ADD CONSTRAINT fk_rails_666125a13a FOREIGN KEY (content_authorization_tag_id) REFERENCES public.content_authorization_tags(id);


--
-- Name: session_tokens fk_rails_66eec3760e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_tokens
    ADD CONSTRAINT fk_rails_66eec3760e FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: session_tokens fk_rails_6ef0c8cde9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_tokens
    ADD CONSTRAINT fk_rails_6ef0c8cde9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: content_type_fields fk_rails_782051ab84; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_fields
    ADD CONSTRAINT fk_rails_782051ab84 FOREIGN KEY (tenant_id, content_type_id) REFERENCES public.content_types(tenant_id, id);


--
-- Name: tenant_themes fk_rails_79c1b773a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_themes
    ADD CONSTRAINT fk_rails_79c1b773a4 FOREIGN KEY (logo_media_asset_id) REFERENCES public.media_assets(id);


--
-- Name: content_types fk_rails_8c76f12b40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_types
    ADD CONSTRAINT fk_rails_8c76f12b40 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: content_entry_fields fk_rails_a74056eefd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_fields
    ADD CONSTRAINT fk_rails_a74056eefd FOREIGN KEY (richtext_id) REFERENCES public.content_entry_field_richtexts(id);


--
-- Name: content_entry_fields fk_rails_a931b93c01; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_fields
    ADD CONSTRAINT fk_rails_a931b93c01 FOREIGN KEY (text_id) REFERENCES public.content_entry_field_texts(id);


--
-- Name: users fk_rails_ae6de3e094; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_ae6de3e094 FOREIGN KEY (oauth_provider_id) REFERENCES public.oauth_providers(id);


--
-- Name: content_type_fields fk_rails_b2b0938bb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_fields
    ADD CONSTRAINT fk_rails_b2b0938bb1 FOREIGN KEY (media_asset_id) REFERENCES public.content_type_field_media_assets(id);


--
-- Name: content_entries fk_rails_c4760210c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entries
    ADD CONSTRAINT fk_rails_c4760210c1 FOREIGN KEY (tenant_id, content_type_id) REFERENCES public.content_types(tenant_id, id);


--
-- Name: content_authorization_tags fk_rails_da031a4616; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_authorization_tags
    ADD CONSTRAINT fk_rails_da031a4616 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_tags fk_rails_da7acba150; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tags
    ADD CONSTRAINT fk_rails_da7acba150 FOREIGN KEY (content_authorization_tag_id) REFERENCES public.content_authorization_tags(id);


--
-- Name: content_entry_field_selects fk_rails_dad78d0427; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_entry_field_selects
    ADD CONSTRAINT fk_rails_dad78d0427 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_themes fk_rails_ff24ac10ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_themes
    ADD CONSTRAINT fk_rails_ff24ac10ab FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: ruler_auth0_accounts fk_ruler_auth0_accounts_auth0_accounts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruler_auth0_accounts
    ADD CONSTRAINT fk_ruler_auth0_accounts_auth0_accounts FOREIGN KEY (auth0_account_id) REFERENCES public.auth0_accounts(id);


--
-- Name: ruler_auth0_accounts fk_ruler_auth0_accounts_rulers; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruler_auth0_accounts
    ADD CONSTRAINT fk_ruler_auth0_accounts_rulers FOREIGN KEY (ruler_id) REFERENCES public.rulers(id);


--
-- Name: user_tags fk_user_tags_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tags
    ADD CONSTRAINT fk_user_tags_users FOREIGN KEY (tenant_id, user_id) REFERENCES public.users(tenant_id, id);


--
-- PostgreSQL database dump complete
--

\unrestrict wYKYerOl20vG8HMj21M4LQwtQAmO5qquIW5eio75KbndhzVLqDjoc1BddgnNXhW

SET search_path TO "$user", public;

