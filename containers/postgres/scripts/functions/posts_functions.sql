-- Get the contents of a post
CREATE OR REPLACE FUNCTION FN_Get_Post(
    _session_id UUID,
    _post_id BIGINT
) RETURNS TABLE(post_content JSONB)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        uid                 BIGINT;
        user_role           USER_ROLES_E;
        poster_visibility   USER_VIS_E;
        poster_uid          BIGINT;
        post_deleted        BOOLEAN;
    BEGIN
        -- Get the current user's id and role based on the session
        SELECT ut.user_id, ut.role INTO uid, user_role FROM users ut
            LEFT JOIN sessions st ON st.session_user_id = ut.user_id
        WHERE st.session_id = _session_id;

        -- Get the  poster's visibility, the poster's user_id, and the post's status
        SELECT ut.visibility, pt.poster_user_id, pt.deleted INTO poster_visibility, poster_uid, post_deleted
        FROM posts pt
            LEFT JOIN users ut ON ut.user_id = pt.poster_user_id
        WHERE pt.post_id = _post_id;

        -- Validate that the user has permissions to view the post
        IF user_role NOT IN ('admin', 'debug', 'bot') THEN
            IF post_deleted = TRUE THEN
                RAISE EXCEPTION 'post is deleted';
            ELSIF poster_visibility = 'hidden' THEN
                RAISE EXCEPTION 'user is hidden';
            ELSIF poster_visibility = 'private' AND FN_Is_Following(uid, poster_uid) = FALSE THEN
                RAISE EXCEPTION 'user is private and you are not following them';
            END IF;
        END IF;

        RETURN QUERY SELECT content FROM posts WHERE post_id = _post_id;
    END;
$$;
