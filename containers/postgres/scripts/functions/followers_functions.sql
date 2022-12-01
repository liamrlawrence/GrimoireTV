-- Get the users.user_id of the followers of _user_id
CREATE OR REPLACE FUNCTION FN_Get_Followers(
    _user_id BIGINT
) RETURNS TABLE(follower_user_id BIGINT)
LANGUAGE SQL
AS $$
    SELECT follower_user_id FROM followers
    WHERE followed_user_id = _user_id;
$$;


-- Get the users.user_id of everyone _user_id is following
CREATE OR REPLACE FUNCTION FN_Get_Following(
    _user_id BIGINT
) RETURNS TABLE(following_user_id BIGINT)
LANGUAGE SQL
AS $$
    SELECT followed_user_id FROM followers
    WHERE follower_user_id = _user_id;
$$;


-- Returns TRUE if the follower is following followed
CREATE OR REPLACE FUNCTION FN_Is_Following(
    _follower_user_id   BIGINT,
    _followed_user_id   BIGINT
) RETURNS BOOLEAN
LANGUAGE PLPGSQL
AS $$
    BEGIN
        RETURN EXISTS(
            SELECT followed_user_id FROM followers
            WHERE
                followed_user_id = _followed_user_id
                AND follower_user_id = _follower_user_id
                AND following = TRUE
        );
    END;
$$;
