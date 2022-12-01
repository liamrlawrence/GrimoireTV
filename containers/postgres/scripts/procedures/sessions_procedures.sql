-- TODO: Allow more than one session to exist at a time per user
CREATE OR REPLACE PROCEDURE SP_Insert_Session(
    INOUT   _return_session_id      UUID,
    INOUT   _return_refresh_token   UUID,
            _user_id                BIGINT
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        sid         UUID;
        ref_token   UUID    := GEN_RANDOM_UUID();
        is_admin    BOOLEAN := EXISTS(SELECT user_id FROM users WHERE user_id = _user_id AND role = 'admin');
    BEGIN
        -- Remove the user's old session
        CALL SP_Delete_User_Sessions(_user_id);

        -- Create a new session
        INSERT INTO sessions(
            session_user_id,
            refresh_token_hash,
            admin
        ) VALUES(
            _user_id,
            CRYPT(ref_token, GEN_SALT('bf')),
            is_admin
        ) RETURNING session_id INTO sid;

        _return_session_id := sid;
        _return_refresh_token := ref_token;
    END;
$$;


CREATE OR REPLACE PROCEDURE SP_Refresh_Session(
            _session_id         UUID,
            _refresh_token      UUID,
    INOUT   _new_refresh_token  UUID
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        new_ref_token   UUID;
        ref_hash        TEXT;
        exp_time        TIMESTAMPTZ;
    BEGIN
        -- Validate refresh token and expiration time
        SELECT refresh_token_hash, refresh_expiration INTO ref_hash, exp_time FROM sessions
        WHERE session_id = _session_id;

        IF ref_hash IS NULL THEN
            RAISE EXCEPTION 'invalid session ID';
        ELSIF CRYPT(_refresh_token, GEN_SALT('bf')) <> ref_hash THEN
            -- TODO: Security concern. Log user out, delete all sessions, notify sysadmin, log network stats, etc...
            RAISE EXCEPTION 'invalid refresh token';
        ELSIF CLOCK_TIMESTAMP() >= exp_time THEN
            RAISE EXCEPTION 'session has expired';
        END IF;

        -- Return a new token and save the hash
        new_ref_token := GEN_RANDOM_UUID();
        UPDATE sessions
        SET
            refresh_token_hash = CRYPT(_new_refresh_token, GEN_SALT('bf')),
            session_expiration = DEFAULT,
            refresh_expiration = DEFAULT,
            times_refreshed = times_refreshed + 1,
            modified_date = CLOCK_TIMESTAMP()
        WHERE
            session_id = _session_id;

        _new_refresh_token := new_ref_token;
    END;
$$;


CREATE OR REPLACE PROCEDURE SP_Delete_Session(
    _session_id UUID
)
LANGUAGE PLPGSQL
AS $$
    BEGIN
        DELETE FROM sessions
        WHERE
            session_id = _session_id;
    END;
$$;


CREATE OR REPLACE PROCEDURE SP_Delete_User_Sessions(
    _user_id BIGINT
)
LANGUAGE PLPGSQL
AS $$
    BEGIN
        DELETE FROM sessions
        WHERE
            session_user_id = _user_id;
    END;
$$;
