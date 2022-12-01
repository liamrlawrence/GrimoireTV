-- TODO: prefix with Auth.
CREATE OR REPLACE FUNCTION FN_User_Code_to_ID(
    _user_code TEXT
) RETURNS BIGINT
LANGUAGE PLPGSQL
AS $$
    DECLARE
        uid BIGINT;
    BEGIN
        SELECT user_id INTO uid FROM users WHERE user_code = _user_code;

        CASE
            WHEN uid IS NULL THEN
                RAISE EXCEPTION 'invalid user code';
            ELSE
                RETURN uid;
        END CASE;
    END;
$$;


CREATE OR REPLACE FUNCTION FN_User_Login(
    _username   TEXT,
    _password   TEXT
) RETURNS BIGINT
LANGUAGE PLPGSQL
AS $$
    DECLARE
        uid             BIGINT;
        phash           TEXT;
        active          BOOLEAN;
        passwords_match BOOLEAN;
    BEGIN
        SELECT user_id, password, is_active INTO uid, phash, active FROM users
        WHERE
            username = _username;
        passwords_match = (CRYPT(_password, phash) = phash)::BOOLEAN;

        CASE
            WHEN active = TRUE AND passwords_match = TRUE THEN
                RETURN uid;
            WHEN active = TRUE AND passwords_match = FALSE THEN
                RAISE EXCEPTION 'incorrect username or password';
            WHEN active = FALSE THEN
                RAISE EXCEPTION 'account has been deactivated';
            ELSE
                RAISE EXCEPTION 'unknown error in fn_user_login, debug: %', active;
        END CASE;
    END;
$$;
