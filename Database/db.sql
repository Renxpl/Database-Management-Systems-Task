PGDMP                      |            deneme    17.0    17.0 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            �           1262    16738    deneme    DATABASE     �   CREATE DATABASE deneme WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE deneme;
                     postgres    false            �            1255    16970 (   add_user_collectibles_trigger_function()    FUNCTION     �  CREATE FUNCTION public.add_user_collectibles_trigger_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO user_collectible_relations (user_id, collectible_id, collectiblecount)
    SELECT NEW.userid, c.collectibleid, 0
    FROM collectibles c
    WHERE NOT EXISTS (
        SELECT 1 FROM user_collectible_relations ucr
        WHERE ucr.user_id = NEW.userid AND ucr.collectible_id = c.collectibleid
    );

    RETURN NEW;
END;
$$;
 ?   DROP FUNCTION public.add_user_collectibles_trigger_function();
       public               postgres    false            
           1255    16945    addfriend(integer, text)    FUNCTION     u  CREATE FUNCTION public.addfriend(user_id integer, friend_username text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    friend_id INT;
BEGIN
    -- friend_username e karşılık gelen friend_id'yi alalım
    SELECT userid INTO friend_id 
    FROM users 
    WHERE username = friend_username 
    LIMIT 1;

    -- Eğer friend_id bulunamadıysa hata ver
    IF friend_id IS NULL THEN
        RAISE EXCEPTION 'Hata: Kullanici adi % ile eslesen bir id bulunamadi.', friend_username;
    END IF;

    -- Eğer bulunduysa socials tablosuna ekle
    INSERT INTO socials(userid, friendid) VALUES (user_id, friend_id);
END;
$$;
 G   DROP FUNCTION public.addfriend(user_id integer, friend_username text);
       public               postgres    false            �            1255    16994 %   check_collectible_three_bool(integer)    FUNCTION     )  CREATE FUNCTION public.check_collectible_three_bool(_user_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    c INT;
BEGIN
    SELECT collectiblecount INTO c
    FROM user_collectible_relations
    WHERE user_id = _user_id AND collectible_id = 3;

    RETURN (c > 0); 
END;
$$;
 E   DROP FUNCTION public.check_collectible_three_bool(_user_id integer);
       public               postgres    false            �            1255    16958 5   check_or_insert_user_skill_relation(integer, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.check_or_insert_user_skill_relation(IN user_id integer, IN skill_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    
    IF NOT EXISTS (
        SELECT 1 FROM user_skill_relations
        WHERE user_id = userid AND skill_id = skillid
    ) THEN
        INSERT INTO user_skill_relations (userid, skillid)
        VALUES (user_id, skill_id);
        
      
    END IF;
END;
$$;
 d   DROP PROCEDURE public.check_or_insert_user_skill_relation(IN user_id integer, IN skill_id integer);
       public               postgres    false                       1255    16977 #   create_ingame_record_for_new_user()    FUNCTION     �   CREATE FUNCTION public.create_ingame_record_for_new_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO ingame (userid, levelid, basehp, xp, gold )
    VALUES (NEW.userid, 0, 0,0,0);
    RETURN NEW;
END;
$$;
 :   DROP FUNCTION public.create_ingame_record_for_new_user();
       public               postgres    false            	           1255    16758 <   createaccount(character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.createaccount(IN p_username character varying, IN p_password_hash character varying, INOUT p_user_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_max_id INTEGER;
BEGIN
    -- Kullanıcı adı var mı kontrol et
    IF EXISTS (SELECT 1 FROM users WHERE username = p_username) THEN
        RAISE EXCEPTION 'Username already exists.';
    END IF;
    
    -- Mevcut en yüksek ID'yi al
    SELECT COALESCE(MAX(userid), 0) INTO v_max_id FROM users;
    
    -- Yeni ID'yi belirle
    p_user_id := v_max_id + 1;
    
    -- Yeni kullanıcıyı ekle
    INSERT INTO users (userid, username, passwordhash) VALUES (p_user_id, p_username, p_password_hash);
END;
$$;
 �   DROP PROCEDURE public.createaccount(IN p_username character varying, IN p_password_hash character varying, INOUT p_user_id integer);
       public               postgres    false            �            1255    16973 2   decrement_user_collectible_count(integer, integer)    FUNCTION     P  CREATE FUNCTION public.decrement_user_collectible_count(_user_id integer, _collectible_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE user_collectible_relations
    SET collectiblecount = collectiblecount - 1
    WHERE user_id = _user_id AND collectible_id = _collectible_id AND collectiblecount > 0;
END;
$$;
 b   DROP FUNCTION public.decrement_user_collectible_count(_user_id integer, _collectible_id integer);
       public               postgres    false                        1255    16974 !   enforce_collectible3_limit_auto()    FUNCTION     "  CREATE FUNCTION public.enforce_collectible3_limit_auto() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.collectible_id = 3 AND NEW.collectiblecount > 1 THEN
        NEW.collectiblecount := 1; -- Count'u otomatik olarak 1'e sabitliyoruz
    END IF;
    RETURN NEW;
END;
$$;
 8   DROP FUNCTION public.enforce_collectible3_limit_auto();
       public               postgres    false                       1255    16946    friendstext(integer)    FUNCTION     �  CREATE FUNCTION public.friendstext(p_user_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    friend_list TEXT;
BEGIN
    SELECT string_agg(u.username, ', ') INTO friend_list
    FROM socials s
    JOIN users u ON s.friendid = u.userid
    WHERE s.userid = p_user_id;

    IF friend_list IS NULL THEN
        RETURN 'Arkadaş bulunamadı';
    ELSE
        RETURN friend_list;
    END IF;
END;
$$;
 5   DROP FUNCTION public.friendstext(p_user_id integer);
       public               postgres    false                       1255    16993 .   get_level_info_proc(integer, integer, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.get_level_info_proc(IN _levelid integer, INOUT _extrahp integer, INOUT _ceilxp integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    SELECT extrahp, ceilxp
    INTO _extrahp, _ceilxp
    FROM level_attributes
    WHERE levelid = _levelid;

    -- Eğer kayıt bulunamazsa:
    IF NOT FOUND THEN
        -- İsterseniz hata fırlatabilir veya default değer atayabilirsiniz
        _extrahp := NULL;
        _ceilxp := NULL;
    END IF;
END;
$$;
 o   DROP PROCEDURE public.get_level_info_proc(IN _levelid integer, INOUT _extrahp integer, INOUT _ceilxp integer);
       public               postgres    false                       1255    16976 ,   get_user_collectible_count(integer, integer)    FUNCTION     T  CREATE FUNCTION public.get_user_collectible_count(_user_id integer, _collectible_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    c INT;
BEGIN
    SELECT COALESCE(collectiblecount, 0) INTO c
    FROM user_collectible_relations
    WHERE user_id = _user_id AND collectible_id = _collectible_id;

    RETURN c;
END;
$$;
 \   DROP FUNCTION public.get_user_collectible_count(_user_id integer, _collectible_id integer);
       public               postgres    false                       1255    16990    get_user_scene(integer)    FUNCTION     !  CREATE FUNCTION public.get_user_scene(_user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    saved_scene INT;
BEGIN
    SELECT scene_id INTO saved_scene
    FROM user_saves
    WHERE user_id = _user_id;

    RETURN saved_scene;  -- Kayıt yoksa NULL döner.
END;
$$;
 7   DROP FUNCTION public.get_user_scene(_user_id integer);
       public               postgres    false                       1255    16983 -   increment_leaderboard_score(integer, integer) 	   PROCEDURE     6  CREATE PROCEDURE public.increment_leaderboard_score(IN _user_id integer, IN _incrementi integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE leaderboard
    SET score = score + _incrementi
    WHERE userid = _user_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'User % does not exist in the leaderboard', _user_id;
        -- İsteğe bağlı olarak burada ek bir işlem yapabilirsiniz:
        -- Örneğin, eğer kullanıcı yoksa onu eklemek isterseniz:
        -- INSERT INTO leaderboard (user_id, score) VALUES (_user_id, _increment);
    END IF;
END;
$$;
 `   DROP PROCEDURE public.increment_leaderboard_score(IN _user_id integer, IN _incrementi integer);
       public               postgres    false            �            1255    16972 2   increment_user_collectible_count(integer, integer)    FUNCTION     7  CREATE FUNCTION public.increment_user_collectible_count(_user_id integer, _collectible_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE user_collectible_relations
    SET collectiblecount = collectiblecount + 1
    WHERE user_id = _user_id AND collectible_id = _collectible_id;
END;
$$;
 b   DROP FUNCTION public.increment_user_collectible_count(_user_id integer, _collectible_id integer);
       public               postgres    false                       1255    16979    insert_user_into_leaderboard()    FUNCTION     �   CREATE FUNCTION public.insert_user_into_leaderboard() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO leaderboard (userid, score)
    VALUES (NEW.userid, 0);
    RETURN NEW;
END;
$$;
 5   DROP FUNCTION public.insert_user_into_leaderboard();
       public               postgres    false            �            1255    16756 /   loginuser(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.loginuser(p_username character varying, p_password_hash character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user_id INTEGER;
BEGIN
    SELECT userid INTO v_user_id FROM users
    WHERE username = p_username AND passwordhash = p_password_hash;

    IF FOUND THEN
        RETURN v_user_id;
    ELSE
        RAISE EXCEPTION 'Kullanıcı adı veya şifre yanlış.';
    END IF;
END;
$$;
 a   DROP FUNCTION public.loginuser(p_username character varying, p_password_hash character varying);
       public               postgres    false                       1255    16754 2   registeruser(character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.registeruser(IN p_username character varying, IN p_passwordhash character varying, OUT p_success boolean, OUT p_message character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Kullanıcı adının var olup olmadığını kontrol et
    IF EXISTS (SELECT 1 FROM Users WHERE Username = p_username) THEN
        p_success := FALSE;
        p_message := 'Bu kullanıcı adı zaten mevcut.';
    ELSE
        -- Yeni UserID'yi hesapla
        INSERT INTO Users (UserID, Username, PasswordHash)
        VALUES (
            COALESCE((SELECT MAX(UserID) FROM Users), 0) + 1,
            p_username,
            p_passwordHash
        );
        p_success := TRUE;
        p_message := 'Kullanıcı başarıyla eklendi.';
    END IF;
END;
$$;
 �   DROP PROCEDURE public.registeruser(IN p_username character varying, IN p_passwordhash character varying, OUT p_success boolean, OUT p_message character varying);
       public               postgres    false            �            1255    16995     reset_leaderboard_score(integer)    FUNCTION     �   CREATE FUNCTION public.reset_leaderboard_score(_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE leaderboard
    SET score = 0
    WHERE userid = _user_id;
END;
$$;
 @   DROP FUNCTION public.reset_leaderboard_score(_user_id integer);
       public               postgres    false                       1255    16989 !   save_user_scene(integer, integer) 	   PROCEDURE     N  CREATE PROCEDURE public.save_user_scene(IN _user_id integer, IN _scene_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE user_saves
    SET scene_id = _scene_id
    WHERE user_id = _user_id;

    IF NOT FOUND THEN
        INSERT INTO user_saves (user_id, scene_id)
        VALUES (_user_id, _scene_id);
    END IF;
END;
$$;
 R   DROP PROCEDURE public.save_user_scene(IN _user_id integer, IN _scene_id integer);
       public               postgres    false                       1255    16991    set_initial_scene()    FUNCTION     �   CREATE FUNCTION public.set_initial_scene() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO user_saves (user_id, scene_id)
    VALUES (NEW.userid, 1);

    RETURN NEW;
END;
$$;
 *   DROP FUNCTION public.set_initial_scene();
       public               postgres    false                       1255    16982 H   sync_user_ingame_data(integer, integer, integer, integer, integer, text) 	   PROCEDURE     R  CREATE PROCEDURE public.sync_user_ingame_data(IN _user_id integer, INOUT _levelid integer, INOUT _basehp integer, INOUT _xp integer, INOUT _gold integer, IN _direction text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF _direction = 'from_game' THEN
        -- Oyun tarafı sayıyı gönderiyor, veritabanında güncelle
        UPDATE ingame
        SET levelid = _levelid 
        WHERE userid = _user_id;

		UPDATE ingame
        SET basehp = _basehp 
        WHERE userid = _user_id;
		
		UPDATE ingame
        SET xp = _xp 
        WHERE userid = _user_id;
		
		UPDATE ingame
        SET gold = _gold 
        WHERE userid = _user_id;

        -- Eğer güncelleme yapılmadıysa (kayıt yoksa), ekleme yapabilirsiniz (opsiyonel):
        IF NOT FOUND THEN
            INSERT INTO ingame(userid, levelid, basehp,xp,gold)
            VALUES (_user_id, _levelid, _basehp, _xp,_gold);
        END IF;

    ELSIF _direction = 'to_game' THEN
        -- Veritabanından sayıyı çek ve _count parametresine ata
        SELECT levelid, basehp,xp,gold INTO _levelid, _basehp,_xp,_gold 
        FROM ingame
        WHERE userid = _user_id ;

        -- Eğer kayıt yoksa varsayılan olarak 0 döndürelim
        IF NOT FOUND THEN
            
        END IF;
    ELSE
        RAISE EXCEPTION 'Invalid direction. Use "from_game" or "to_game".';
    END IF;
END;
$$;
 �   DROP PROCEDURE public.sync_user_ingame_data(IN _user_id integer, INOUT _levelid integer, INOUT _basehp integer, INOUT _xp integer, INOUT _gold integer, IN _direction text);
       public               postgres    false            �            1255    16963 ,   user_skill_relation_exists(integer, integer)    FUNCTION     e  CREATE FUNCTION public.user_skill_relation_exists(user_id integer, skill_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    relation_exists BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM user_skill_relations
        WHERE userid = user_id AND skillid = skill_id
    ) INTO relation_exists;

    RETURN relation_exists;
END;
$$;
 T   DROP FUNCTION public.user_skill_relation_exists(user_id integer, skill_id integer);
       public               postgres    false            �            1259    16774    skills    TABLE     �   CREATE TABLE public.skills (
    skillid integer NOT NULL,
    skillname character varying(255) NOT NULL,
    skilltype character varying(255) NOT NULL
);
    DROP TABLE public.skills;
       public         heap r       postgres    false            �            1259    16796    active_skills    TABLE     �   CREATE TABLE public.active_skills (
    skillid integer,
    skillname character varying(255),
    skilltype character varying(255),
    goldcost integer NOT NULL
)
INHERITS (public.skills);
 !   DROP TABLE public.active_skills;
       public         heap r       postgres    false    224            �            1259    16795    active_skills_skillid_seq    SEQUENCE     �   CREATE SEQUENCE public.active_skills_skillid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.active_skills_skillid_seq;
       public               postgres    false    228            �           0    0    active_skills_skillid_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.active_skills_skillid_seq OWNED BY public.active_skills.skillid;
          public               postgres    false    227            �            1259    16807    collectibles    TABLE     �   CREATE TABLE public.collectibles (
    collectibleid integer NOT NULL,
    collectiblename character varying(255) NOT NULL,
    collectibletype character varying(255) NOT NULL
);
     DROP TABLE public.collectibles;
       public         heap r       postgres    false            �            1259    16806    collectibles_collectibleid_seq    SEQUENCE     �   CREATE SEQUENCE public.collectibles_collectibleid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.collectibles_collectibleid_seq;
       public               postgres    false    230            �           0    0    collectibles_collectibleid_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.collectibles_collectibleid_seq OWNED BY public.collectibles.collectibleid;
          public               postgres    false    229            �            1259    16829    consumables    TABLE     �   CREATE TABLE public.consumables (
    collectibleid integer,
    collectiblename character varying(255),
    collectibletype character varying(255),
    goldcost integer NOT NULL
)
INHERITS (public.collectibles);
    DROP TABLE public.consumables;
       public         heap r       postgres    false    230            �            1259    16828    consumables_collectibleid_seq    SEQUENCE     �   CREATE SEQUENCE public.consumables_collectibleid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.consumables_collectibleid_seq;
       public               postgres    false    234            �           0    0    consumables_collectibleid_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.consumables_collectibleid_seq OWNED BY public.consumables.collectibleid;
          public               postgres    false    233            �            1259    16938    enemies    TABLE     �   CREATE TABLE public.enemies (
    enemyid integer NOT NULL,
    enemytype character varying(255) NOT NULL,
    dmg integer NOT NULL,
    hp integer NOT NULL
);
    DROP TABLE public.enemies;
       public         heap r       postgres    false            �            1259    16937    enemies_enemyid_seq    SEQUENCE     �   CREATE SEQUENCE public.enemies_enemyid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.enemies_enemyid_seq;
       public               postgres    false    240            �           0    0    enemies_enemyid_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.enemies_enemyid_seq OWNED BY public.enemies.enemyid;
          public               postgres    false    239            �            1259    16760    ingame    TABLE     �   CREATE TABLE public.ingame (
    userid integer NOT NULL,
    levelid integer NOT NULL,
    basehp integer NOT NULL,
    xp integer NOT NULL,
    gold integer NOT NULL
);
    DROP TABLE public.ingame;
       public         heap r       postgres    false            �            1259    16759    ingame_userid_seq    SEQUENCE     �   CREATE SEQUENCE public.ingame_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.ingame_userid_seq;
       public               postgres    false    220            �           0    0    ingame_userid_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.ingame_userid_seq OWNED BY public.ingame.userid;
          public               postgres    false    219            �            1259    16901    leaderboard    TABLE     ]   CREATE TABLE public.leaderboard (
    userid integer NOT NULL,
    score integer NOT NULL
);
    DROP TABLE public.leaderboard;
       public         heap r       postgres    false            �            1259    16900    leaderboard_userid_seq    SEQUENCE     �   CREATE SEQUENCE public.leaderboard_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.leaderboard_userid_seq;
       public               postgres    false    236            �           0    0    leaderboard_userid_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.leaderboard_userid_seq OWNED BY public.leaderboard.userid;
          public               postgres    false    235            �            1259    16767    level_attributes    TABLE     �   CREATE TABLE public.level_attributes (
    levelid integer NOT NULL,
    extrahp integer NOT NULL,
    ceilxp integer NOT NULL
);
 $   DROP TABLE public.level_attributes;
       public         heap r       postgres    false            �            1259    16766    level_attributes_levelid_seq    SEQUENCE     �   CREATE SEQUENCE public.level_attributes_levelid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.level_attributes_levelid_seq;
       public               postgres    false    222            �           0    0    level_attributes_levelid_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.level_attributes_levelid_seq OWNED BY public.level_attributes.levelid;
          public               postgres    false    221            �            1259    16785    passive_skills    TABLE     �   CREATE TABLE public.passive_skills (
    skillid integer,
    skillname character varying(255),
    skilltype character varying(255),
    goldcost integer NOT NULL
)
INHERITS (public.skills);
 "   DROP TABLE public.passive_skills;
       public         heap r       postgres    false    224            �            1259    16784    passive_skills_skillid_seq    SEQUENCE     �   CREATE SEQUENCE public.passive_skills_skillid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.passive_skills_skillid_seq;
       public               postgres    false    226            �           0    0    passive_skills_skillid_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.passive_skills_skillid_seq OWNED BY public.passive_skills.skillid;
          public               postgres    false    225            �            1259    16773    skills_skillid_seq    SEQUENCE     �   CREATE SEQUENCE public.skills_skillid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.skills_skillid_seq;
       public               postgres    false    224            �           0    0    skills_skillid_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.skills_skillid_seq OWNED BY public.skills.skillid;
          public               postgres    false    223            �            1259    16926    socials    TABLE     \   CREATE TABLE public.socials (
    userid integer NOT NULL,
    friendid integer NOT NULL
);
    DROP TABLE public.socials;
       public         heap r       postgres    false            �            1259    16925    socials_userid_seq    SEQUENCE     �   CREATE SEQUENCE public.socials_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.socials_userid_seq;
       public               postgres    false    238            �           0    0    socials_userid_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.socials_userid_seq OWNED BY public.socials.userid;
          public               postgres    false    237            �            1259    16964    user_collectible_relations    TABLE     �   CREATE TABLE public.user_collectible_relations (
    user_id integer NOT NULL,
    collectible_id integer NOT NULL,
    collectiblecount integer DEFAULT 0 NOT NULL
);
 .   DROP TABLE public.user_collectible_relations;
       public         heap r       postgres    false            �            1259    16984 
   user_saves    TABLE     `   CREATE TABLE public.user_saves (
    user_id integer NOT NULL,
    scene_id integer NOT NULL
);
    DROP TABLE public.user_saves;
       public         heap r       postgres    false            �            1259    16947    user_skill_relations    TABLE     h   CREATE TABLE public.user_skill_relations (
    userid integer NOT NULL,
    skillid integer NOT NULL
);
 (   DROP TABLE public.user_skill_relations;
       public         heap r       postgres    false            �            1259    16740    users    TABLE     �   CREATE TABLE public.users (
    userid integer NOT NULL,
    username character varying(50) NOT NULL,
    passwordhash character varying(255) NOT NULL,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.users;
       public         heap r       postgres    false            �            1259    16739    users_userid_seq    SEQUENCE     �   CREATE SEQUENCE public.users_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.users_userid_seq;
       public               postgres    false    218            �           0    0    users_userid_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.users_userid_seq OWNED BY public.users.userid;
          public               postgres    false    217            �            1259    16818    weapons    TABLE     �   CREATE TABLE public.weapons (
    collectibleid integer,
    collectiblename character varying(255),
    collectibletype character varying(255),
    goldcost integer NOT NULL
)
INHERITS (public.collectibles);
    DROP TABLE public.weapons;
       public         heap r       postgres    false    230            �            1259    16817    weapons_collectibleid_seq    SEQUENCE     �   CREATE SEQUENCE public.weapons_collectibleid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.weapons_collectibleid_seq;
       public               postgres    false    232            �           0    0    weapons_collectibleid_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.weapons_collectibleid_seq OWNED BY public.weapons.collectibleid;
          public               postgres    false    231            �           2604    16799    active_skills skillid    DEFAULT     ~   ALTER TABLE ONLY public.active_skills ALTER COLUMN skillid SET DEFAULT nextval('public.active_skills_skillid_seq'::regclass);
 D   ALTER TABLE public.active_skills ALTER COLUMN skillid DROP DEFAULT;
       public               postgres    false    228    227    228            �           2604    16810    collectibles collectibleid    DEFAULT     �   ALTER TABLE ONLY public.collectibles ALTER COLUMN collectibleid SET DEFAULT nextval('public.collectibles_collectibleid_seq'::regclass);
 I   ALTER TABLE public.collectibles ALTER COLUMN collectibleid DROP DEFAULT;
       public               postgres    false    230    229    230            �           2604    16832    consumables collectibleid    DEFAULT     �   ALTER TABLE ONLY public.consumables ALTER COLUMN collectibleid SET DEFAULT nextval('public.consumables_collectibleid_seq'::regclass);
 H   ALTER TABLE public.consumables ALTER COLUMN collectibleid DROP DEFAULT;
       public               postgres    false    233    234    234            �           2604    16941    enemies enemyid    DEFAULT     r   ALTER TABLE ONLY public.enemies ALTER COLUMN enemyid SET DEFAULT nextval('public.enemies_enemyid_seq'::regclass);
 >   ALTER TABLE public.enemies ALTER COLUMN enemyid DROP DEFAULT;
       public               postgres    false    239    240    240            �           2604    16763    ingame userid    DEFAULT     n   ALTER TABLE ONLY public.ingame ALTER COLUMN userid SET DEFAULT nextval('public.ingame_userid_seq'::regclass);
 <   ALTER TABLE public.ingame ALTER COLUMN userid DROP DEFAULT;
       public               postgres    false    220    219    220            �           2604    16904    leaderboard userid    DEFAULT     x   ALTER TABLE ONLY public.leaderboard ALTER COLUMN userid SET DEFAULT nextval('public.leaderboard_userid_seq'::regclass);
 A   ALTER TABLE public.leaderboard ALTER COLUMN userid DROP DEFAULT;
       public               postgres    false    235    236    236            �           2604    16770    level_attributes levelid    DEFAULT     �   ALTER TABLE ONLY public.level_attributes ALTER COLUMN levelid SET DEFAULT nextval('public.level_attributes_levelid_seq'::regclass);
 G   ALTER TABLE public.level_attributes ALTER COLUMN levelid DROP DEFAULT;
       public               postgres    false    221    222    222            �           2604    16788    passive_skills skillid    DEFAULT     �   ALTER TABLE ONLY public.passive_skills ALTER COLUMN skillid SET DEFAULT nextval('public.passive_skills_skillid_seq'::regclass);
 E   ALTER TABLE public.passive_skills ALTER COLUMN skillid DROP DEFAULT;
       public               postgres    false    226    225    226            �           2604    16777    skills skillid    DEFAULT     p   ALTER TABLE ONLY public.skills ALTER COLUMN skillid SET DEFAULT nextval('public.skills_skillid_seq'::regclass);
 =   ALTER TABLE public.skills ALTER COLUMN skillid DROP DEFAULT;
       public               postgres    false    223    224    224            �           2604    16929    socials userid    DEFAULT     p   ALTER TABLE ONLY public.socials ALTER COLUMN userid SET DEFAULT nextval('public.socials_userid_seq'::regclass);
 =   ALTER TABLE public.socials ALTER COLUMN userid DROP DEFAULT;
       public               postgres    false    238    237    238            �           2604    16743    users userid    DEFAULT     l   ALTER TABLE ONLY public.users ALTER COLUMN userid SET DEFAULT nextval('public.users_userid_seq'::regclass);
 ;   ALTER TABLE public.users ALTER COLUMN userid DROP DEFAULT;
       public               postgres    false    217    218    218            �           2604    16821    weapons collectibleid    DEFAULT     ~   ALTER TABLE ONLY public.weapons ALTER COLUMN collectibleid SET DEFAULT nextval('public.weapons_collectibleid_seq'::regclass);
 D   ALTER TABLE public.weapons ALTER COLUMN collectibleid DROP DEFAULT;
       public               postgres    false    231    232    232            �          0    16796    active_skills 
   TABLE DATA           P   COPY public.active_skills (skillid, skillname, skilltype, goldcost) FROM stdin;
    public               postgres    false    228   f�       �          0    16807    collectibles 
   TABLE DATA           W   COPY public.collectibles (collectibleid, collectiblename, collectibletype) FROM stdin;
    public               postgres    false    230   ��       �          0    16829    consumables 
   TABLE DATA           `   COPY public.consumables (collectibleid, collectiblename, collectibletype, goldcost) FROM stdin;
    public               postgres    false    234   ��       �          0    16938    enemies 
   TABLE DATA           >   COPY public.enemies (enemyid, enemytype, dmg, hp) FROM stdin;
    public               postgres    false    240   �       �          0    16760    ingame 
   TABLE DATA           C   COPY public.ingame (userid, levelid, basehp, xp, gold) FROM stdin;
    public               postgres    false    220   �       �          0    16901    leaderboard 
   TABLE DATA           4   COPY public.leaderboard (userid, score) FROM stdin;
    public               postgres    false    236   n�       �          0    16767    level_attributes 
   TABLE DATA           D   COPY public.level_attributes (levelid, extrahp, ceilxp) FROM stdin;
    public               postgres    false    222   ��       �          0    16785    passive_skills 
   TABLE DATA           Q   COPY public.passive_skills (skillid, skillname, skilltype, goldcost) FROM stdin;
    public               postgres    false    226   ��       �          0    16774    skills 
   TABLE DATA           ?   COPY public.skills (skillid, skillname, skilltype) FROM stdin;
    public               postgres    false    224   �       �          0    16926    socials 
   TABLE DATA           3   COPY public.socials (userid, friendid) FROM stdin;
    public               postgres    false    238   *�       �          0    16964    user_collectible_relations 
   TABLE DATA           _   COPY public.user_collectible_relations (user_id, collectible_id, collectiblecount) FROM stdin;
    public               postgres    false    242   Q�       �          0    16984 
   user_saves 
   TABLE DATA           7   COPY public.user_saves (user_id, scene_id) FROM stdin;
    public               postgres    false    243   ��       �          0    16947    user_skill_relations 
   TABLE DATA           ?   COPY public.user_skill_relations (userid, skillid) FROM stdin;
    public               postgres    false    241   ��       �          0    16740    users 
   TABLE DATA           J   COPY public.users (userid, username, passwordhash, createdat) FROM stdin;
    public               postgres    false    218   �       �          0    16818    weapons 
   TABLE DATA           \   COPY public.weapons (collectibleid, collectiblename, collectibletype, goldcost) FROM stdin;
    public               postgres    false    232   A�       �           0    0    active_skills_skillid_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.active_skills_skillid_seq', 1, false);
          public               postgres    false    227            �           0    0    collectibles_collectibleid_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.collectibles_collectibleid_seq', 1, false);
          public               postgres    false    229            �           0    0    consumables_collectibleid_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.consumables_collectibleid_seq', 1, false);
          public               postgres    false    233            �           0    0    enemies_enemyid_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.enemies_enemyid_seq', 1, false);
          public               postgres    false    239            �           0    0    ingame_userid_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.ingame_userid_seq', 1, false);
          public               postgres    false    219            �           0    0    leaderboard_userid_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.leaderboard_userid_seq', 1, false);
          public               postgres    false    235            �           0    0    level_attributes_levelid_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.level_attributes_levelid_seq', 1, false);
          public               postgres    false    221            �           0    0    passive_skills_skillid_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.passive_skills_skillid_seq', 1, false);
          public               postgres    false    225            �           0    0    skills_skillid_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.skills_skillid_seq', 1, false);
          public               postgres    false    223            �           0    0    socials_userid_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.socials_userid_seq', 1, false);
          public               postgres    false    237            �           0    0    users_userid_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.users_userid_seq', 1, false);
          public               postgres    false    217            �           0    0    weapons_collectibleid_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.weapons_collectibleid_seq', 1, false);
          public               postgres    false    231            �           2606    16803     active_skills active_skills_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.active_skills
    ADD CONSTRAINT active_skills_pkey PRIMARY KEY (skillid);
 J   ALTER TABLE ONLY public.active_skills DROP CONSTRAINT active_skills_pkey;
       public                 postgres    false    228            �           2606    16805 )   active_skills active_skills_skillname_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.active_skills
    ADD CONSTRAINT active_skills_skillname_key UNIQUE (skillname);
 S   ALTER TABLE ONLY public.active_skills DROP CONSTRAINT active_skills_skillname_key;
       public                 postgres    false    228            �           2606    16816 -   collectibles collectibles_collectiblename_key 
   CONSTRAINT     s   ALTER TABLE ONLY public.collectibles
    ADD CONSTRAINT collectibles_collectiblename_key UNIQUE (collectiblename);
 W   ALTER TABLE ONLY public.collectibles DROP CONSTRAINT collectibles_collectiblename_key;
       public                 postgres    false    230            �           2606    16814    collectibles collectibles_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.collectibles
    ADD CONSTRAINT collectibles_pkey PRIMARY KEY (collectibleid);
 H   ALTER TABLE ONLY public.collectibles DROP CONSTRAINT collectibles_pkey;
       public                 postgres    false    230            �           2606    16838 +   consumables consumables_collectiblename_key 
   CONSTRAINT     q   ALTER TABLE ONLY public.consumables
    ADD CONSTRAINT consumables_collectiblename_key UNIQUE (collectiblename);
 U   ALTER TABLE ONLY public.consumables DROP CONSTRAINT consumables_collectiblename_key;
       public                 postgres    false    234            �           2606    16836    consumables consumables_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.consumables
    ADD CONSTRAINT consumables_pkey PRIMARY KEY (collectibleid);
 F   ALTER TABLE ONLY public.consumables DROP CONSTRAINT consumables_pkey;
       public                 postgres    false    234            �           2606    16943    enemies enemies_enemytype_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.enemies
    ADD CONSTRAINT enemies_enemytype_key UNIQUE (enemytype);
 G   ALTER TABLE ONLY public.enemies DROP CONSTRAINT enemies_enemytype_key;
       public                 postgres    false    240            �           2606    16765    ingame ingame_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.ingame
    ADD CONSTRAINT ingame_pkey PRIMARY KEY (userid);
 <   ALTER TABLE ONLY public.ingame DROP CONSTRAINT ingame_pkey;
       public                 postgres    false    220            �           2606    16906    leaderboard leaderboard_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.leaderboard
    ADD CONSTRAINT leaderboard_pkey PRIMARY KEY (userid);
 F   ALTER TABLE ONLY public.leaderboard DROP CONSTRAINT leaderboard_pkey;
       public                 postgres    false    236            �           2606    16772 &   level_attributes level_attributes_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.level_attributes
    ADD CONSTRAINT level_attributes_pkey PRIMARY KEY (levelid);
 P   ALTER TABLE ONLY public.level_attributes DROP CONSTRAINT level_attributes_pkey;
       public                 postgres    false    222            �           2606    16792 "   passive_skills passive_skills_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.passive_skills
    ADD CONSTRAINT passive_skills_pkey PRIMARY KEY (skillid);
 L   ALTER TABLE ONLY public.passive_skills DROP CONSTRAINT passive_skills_pkey;
       public                 postgres    false    226            �           2606    16794 +   passive_skills passive_skills_skillname_key 
   CONSTRAINT     k   ALTER TABLE ONLY public.passive_skills
    ADD CONSTRAINT passive_skills_skillname_key UNIQUE (skillname);
 U   ALTER TABLE ONLY public.passive_skills DROP CONSTRAINT passive_skills_skillname_key;
       public                 postgres    false    226            �           2606    16781    skills skills_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (skillid);
 <   ALTER TABLE ONLY public.skills DROP CONSTRAINT skills_pkey;
       public                 postgres    false    224            �           2606    16783    skills skills_skillname_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_skillname_key UNIQUE (skillname);
 E   ALTER TABLE ONLY public.skills DROP CONSTRAINT skills_skillname_key;
       public                 postgres    false    224            �           2606    16931    socials socials_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.socials
    ADD CONSTRAINT socials_pkey PRIMARY KEY (userid, friendid);
 >   ALTER TABLE ONLY public.socials DROP CONSTRAINT socials_pkey;
       public                 postgres    false    238    238            �           2606    16969 :   user_collectible_relations user_collectible_relations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.user_collectible_relations
    ADD CONSTRAINT user_collectible_relations_pkey PRIMARY KEY (user_id, collectible_id);
 d   ALTER TABLE ONLY public.user_collectible_relations DROP CONSTRAINT user_collectible_relations_pkey;
       public                 postgres    false    242    242            �           2606    16988    user_saves user_saves_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.user_saves
    ADD CONSTRAINT user_saves_pkey PRIMARY KEY (user_id);
 D   ALTER TABLE ONLY public.user_saves DROP CONSTRAINT user_saves_pkey;
       public                 postgres    false    243            �           2606    16951 .   user_skill_relations user_skill_relations_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY public.user_skill_relations
    ADD CONSTRAINT user_skill_relations_pkey PRIMARY KEY (userid, skillid);
 X   ALTER TABLE ONLY public.user_skill_relations DROP CONSTRAINT user_skill_relations_pkey;
       public                 postgres    false    241    241            �           2606    16746    users users_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (userid);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public                 postgres    false    218            �           2606    16748    users users_username_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_username_key;
       public                 postgres    false    218            �           2606    16827 #   weapons weapons_collectiblename_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.weapons
    ADD CONSTRAINT weapons_collectiblename_key UNIQUE (collectiblename);
 M   ALTER TABLE ONLY public.weapons DROP CONSTRAINT weapons_collectiblename_key;
       public                 postgres    false    232            �           2606    16825    weapons weapons_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.weapons
    ADD CONSTRAINT weapons_pkey PRIMARY KEY (collectibleid);
 >   ALTER TABLE ONLY public.weapons DROP CONSTRAINT weapons_pkey;
       public                 postgres    false    232            �           2620    16978    users add_ingame_record_trigger    TRIGGER     �   CREATE TRIGGER add_ingame_record_trigger AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.create_ingame_record_for_new_user();
 8   DROP TRIGGER add_ingame_record_trigger ON public.users;
       public               postgres    false    218    269            �           2620    16971 #   users add_user_collectibles_trigger    TRIGGER     �   CREATE TRIGGER add_user_collectibles_trigger AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.add_user_collectibles_trigger_function();
 <   DROP TRIGGER add_user_collectibles_trigger ON public.users;
       public               postgres    false    250    218            �           2620    16980 %   users add_user_to_leaderboard_trigger    TRIGGER     �   CREATE TRIGGER add_user_to_leaderboard_trigger AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.insert_user_into_leaderboard();
 >   DROP TRIGGER add_user_to_leaderboard_trigger ON public.users;
       public               postgres    false    218    270            �           2620    16975 =   user_collectible_relations enforce_collectible3_limit_trigger    TRIGGER     �   CREATE TRIGGER enforce_collectible3_limit_trigger BEFORE INSERT OR UPDATE ON public.user_collectible_relations FOR EACH ROW EXECUTE FUNCTION public.enforce_collectible3_limit_auto();
 V   DROP TRIGGER enforce_collectible3_limit_trigger ON public.user_collectible_relations;
       public               postgres    false    256    242            �           2620    16992    users set_initial_scene_trigger    TRIGGER     �   CREATE TRIGGER set_initial_scene_trigger AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_initial_scene();
 8   DROP TRIGGER set_initial_scene_trigger ON public.users;
       public               postgres    false    274    218            �           2606    16907 #   leaderboard leaderboard_userid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.leaderboard
    ADD CONSTRAINT leaderboard_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid);
 M   ALTER TABLE ONLY public.leaderboard DROP CONSTRAINT leaderboard_userid_fkey;
       public               postgres    false    218    236    4799            �           2606    16932    socials socials_userid_fkey    FK CONSTRAINT     }   ALTER TABLE ONLY public.socials
    ADD CONSTRAINT socials_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid);
 E   ALTER TABLE ONLY public.socials DROP CONSTRAINT socials_userid_fkey;
       public               postgres    false    4799    218    238            �   %   x�3�,-K,�I��M�LL.�,K�420������ ��M      �      x������ � �      �   +   x�3���/����L��+.�ML�I�45�2��.���� �P�      �      x�3�LIMK,�)�4�4����� 3?F      �   @   x�=���0߰K*pR5ݥ��;�*��,���@����B�_��=�S�w�������6
�      �   (   x���4�24 ��@�!�!�2�4QƜf@*F��� y<�      �   "   x�3�4�42�2�4�41�2�4�45������ .8Z      �   %   x�3��(��K.J�M�+�,H,.�,K�4������ ���      �      x������ � �      �      x�3�4�2�4bC�=... A      �   R   x�5���@�PL�f%�����1�g,Ǳ0�m�"�C�K����KFL����gĬ�Ș�-�dv�
ϻ�B����/9��      �      x���4�24 � �D�=... 9��      �      x�3�4�2a#a$b���� #h�      �   *  x�m�Mr�0�u
.�ǒ%����@\�&���u`Q�l����IFu�y�s>�z.
�-����dl��'�E/�$q����\�uB�z�����{���!�D>�h�X��ܞZ>��DcB��jg�����dS���=s���0��RvC^�($�76�$�����*�mx�O�&+	��h�!j�]������{��'=�v��j��&��d�ٜ��ШC�K����Ŷ@Z+�(��GK��qǜ�kc� R;����4���/1Q[���hU�w�Û�M�U��:�� ��<��      �      x�3�L/��,OM,���410������ H�i     