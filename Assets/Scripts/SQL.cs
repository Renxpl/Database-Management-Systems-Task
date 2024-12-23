using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Npgsql;
using System;
using System.Data;

public class SQL : MonoBehaviour
{
    int? userId = null;
    bool? success= null;
    string message = "";
    NpgsqlConnection conn;
    // Start is called before the first frame update
    private string connectionString = "Host=localhost;User Id=postgres;Password=123456;Database=deneme";

    public bool giris = false;

    PlayerMovement playerScript;

    private void Awake()
    {

        int numGameSessions = FindObjectsOfType<GameSession>().Length;
        if (numGameSessions > 1)
        {
            Destroy(gameObject);
        }

        else
        {
            DontDestroyOnLoad(gameObject);
            conn = new NpgsqlConnection(connectionString);
            conn.Open();
        }


    }
    void Start()
    {
        //TestConnection();
        //TestAccount();
        //CreateAccount("yenikullanici", "123");
        
        //TestLogin("usernamekismii", "2");
        //TestLogin("testuser", "hashedpassword");
        //TestLogin("usernamekismi", "1");
        //CreateAccount("yeni", "yenisifre");
        playerScript = FindObjectOfType<PlayerMovement>();

    }


    void TestConnection()
    {
        try
        {
            using (var conn = new NpgsqlConnection(connectionString))
            {
                conn.Open();
                Debug.Log("Veritabanýna baðlanýldý.");

                // Örnek bir veri çekme iþlemi
                using (var cmd = new NpgsqlCommand("SELECT * FROM users", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        // Örneðin, ilk sütunu string olarak al
                        string data = reader.GetString(0);
                        Debug.Log("Veri: " + data);
                    }
                }

                // Örnek bir veri ekleme iþlemi
                using (var cmd = new NpgsqlCommand("INSERT INTO users (userid,username,passwordhash) VALUES (@userid,@username,@passwordhash)", conn))
                {
                    cmd.Parameters.AddWithValue("userid", 1);
                    cmd.Parameters.AddWithValue("username", "usernamekismi");
                    cmd.Parameters.AddWithValue("passwordhash", "1");
                    int result = cmd.ExecuteNonQuery();
                    Debug.Log("Ekleme iþlemi sonucu: " + result);
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogError("Baðlantý Hatasý: " + e.Message);
        }
    }

    public void TestAccount()
    {
        try
        {
            using (var conn = new NpgsqlConnection(connectionString))
            {
                conn.Open();
                Debug.Log("Veritabanýna baðlanýldý.");

                // Örnek bir veri çekme iþlemi
               

                // Örnek bir veri ekleme iþlemi
                using (var cmd = new NpgsqlCommand("Call CreatingAccount(@userid,@username,@passwordhash)", conn))
                {
                    cmd.Parameters.AddWithValue("userid", 2);
                    cmd.Parameters.AddWithValue("username", "usernamekismii");
                    cmd.Parameters.AddWithValue("passwordhash", "2");
                    int result = cmd.ExecuteNonQuery();
                    Debug.Log("Ekleme iþlemi sonucu: " + result);
                }
            }
        }
        catch (Exception e)
        {
            //Debug.LogError("Baðlantý Hatasý: " + e.Message);
        }
    }
    //Ýþlev kullanan login 
    public void TestLogin(string username, string password)
    {

        using (var cmd = new NpgsqlCommand("SELECT LoginUser(@username, @passwordHash)", conn))
        {
            Debug.Log("Veritabanýna baðlanýldý.");

            cmd.Parameters.AddWithValue("username", username);
            cmd.Parameters.AddWithValue("passwordHash", password);

           

            // Saklý yordamý çalýþtýrýn
            object result = cmd.ExecuteScalar();
            userId=Convert.ToInt32(result);
            if (userId!=null)
            {
                //kontrol amaçlý
                Debug.Log($"Giriþ baþarýlý. UserID: {userId}");
                giris = true;
               
            }
            else
            {
                Debug.LogWarning("Giriþ baþarýsýz. Kullanýcý adý veya þifre yanlýþ.");
            }
        }

    }

    public void DeleteAccount(string username)
    {

        using (var cmd = new NpgsqlCommand("SELECT delete_user(@username)", conn))
        {
            
            cmd.Parameters.AddWithValue("username", username);



            // Saklý yordamý çalýþtýrýn
            object result = cmd.ExecuteScalar();
            
        }




    }

    public void CreateAccount(string username, string password)
    {
        using (var cmd = new NpgsqlCommand("CALL CreateAccount(@username, @passwordHash, @userid)", conn))
        {
            cmd.Parameters.AddWithValue("username", username);
            cmd.Parameters.AddWithValue("passwordhash", password);

            // OUTPUT parametresi için NpgsqlDbType belirlenmesi


            
            var userIdParam = new NpgsqlParameter("userid", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = 0
            };
            cmd.Parameters.Add(userIdParam);
            cmd.ExecuteNonQuery();
            

            if (userIdParam.Value != DBNull.Value)
            {
                userId = Convert.ToInt32(userIdParam.Value);
                Debug.Log($"Hesap oluþturuldu. Kullanýcý ID: {userId}");
                giris = true;
                
            }
            else
            {
                Debug.LogWarning("Hesap oluþturma baþarýsýz.");
               
            }
        }
    }

    public void FirstSetUp(string username)
    {




    }

    public void InventoryControl()
    {
        //Debug.Log("Envanter Kontrolü");
    }

    public void IngameUpdate(int levelid ,int basehp,int xp, int gold)
    {
        using (var cmd = new NpgsqlCommand("CALL sync_user_ingame_data(@uid, @iid,@bhp , @xp, @g, @dir)", conn))
        {
            cmd.Parameters.AddWithValue("uid", userId);


            var l = new NpgsqlParameter("iid", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = levelid
            };
            var bhp = new NpgsqlParameter("bhp", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = basehp
            };
            var x = new NpgsqlParameter("xp", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = xp
            };
            var g = new NpgsqlParameter("g", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = gold
            };
            cmd.Parameters.Add(l);
            cmd.Parameters.Add(bhp);
            cmd.Parameters.Add(x);
            cmd.Parameters.Add(g);

            cmd.Parameters.AddWithValue("dir", "from_game");

            cmd.ExecuteNonQuery();

            
            
          
        }



    }

    public void GameUpdate(out int levelid,out int basehp,out int xp,out int gold)
    {
        
        using (var cmd = new NpgsqlCommand("CALL sync_user_ingame_data(@uid, @iid,@bhp , @xp, @g, @dir)", conn))
        {
            cmd.Parameters.AddWithValue("uid", userId);


            var l = new NpgsqlParameter("iid", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = 0
            };
            var bhp = new NpgsqlParameter("bhp", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = 0
            };
            var x = new NpgsqlParameter("xp", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = 0
            };
            var g = new NpgsqlParameter("g", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = 0
            };
            cmd.Parameters.Add(l);
            cmd.Parameters.Add(bhp);
            cmd.Parameters.Add(x);
            cmd.Parameters.Add(g);

            cmd.Parameters.AddWithValue("dir", "to_game");

            cmd.ExecuteNonQuery();


            levelid = Convert.ToInt32(l.Value);
            basehp = Convert.ToInt32(bhp.Value);
            xp = Convert.ToInt32(x.Value);
            gold = Convert.ToInt32(g.Value);
        }


    }

    public void Leaderboard(int increase)
    {
        using (var cmd = new NpgsqlCommand("CALL increment_leaderboard_score(@uid, @inc)", conn))
        {
            cmd.Parameters.AddWithValue("uid", userId);
            cmd.Parameters.AddWithValue("inc", increase);

            cmd.ExecuteNonQuery();
        }

    }

    public void AddFriend(string name)
    {
        using (var cmd = new NpgsqlCommand("SELECT AddFriend(@user_id, @friend_username)", conn))
        {
            cmd.Parameters.AddWithValue("user_id", userId);
            cmd.Parameters.AddWithValue("friend_username", name);
            Debug.Log(name);

            try
            {
                cmd.ExecuteNonQuery();
                // Baþarýlý ise herhangi bir istisna atýlmaz.
            }
            catch (NpgsqlException ex)
            {
                // Eðer friend_id users tablosunda yok ise hata burada yakalanýr.
                Console.WriteLine("Hata: " + ex.Message);
            }
        }
    }

    public string UpdateFriendList()
    {
        using (var cmd = new NpgsqlCommand("SELECT friendstext(@p_user_id)", conn))
        {
            cmd.Parameters.AddWithValue("p_user_id", userId);

            var result = cmd.ExecuteScalar();
            string friendsText = result == DBNull.Value ? "Arkadaþ bulunamadý" : (string)result;

            // Unity tarafýnda bir UI Text bileþenine friendsText deðerini atayabilirsiniz:
            return friendsText;
        }
    }
    public void NewAbility()
    {
        using (var cmd = new NpgsqlCommand("CALL check_or_insert_user_skill_relation(@u, @i)", conn))
        {
            cmd.Parameters.AddWithValue("u", userId);
            cmd.Parameters.AddWithValue("i", 1);

            // inserted parametresini InputOutput olarak ayarlýyoruz

            cmd.ExecuteNonQuery();
        }

    }
    public bool AbilityControl()
    {

        using (var cmd = new NpgsqlCommand("SELECT user_skill_relation_exists(@uid, @iid)", conn))
        {
            cmd.Parameters.AddWithValue("uid", userId);
            cmd.Parameters.AddWithValue("iid", 1);

            bool exists = (bool)cmd.ExecuteScalar();
            return exists;
        }


    }
    public void ResetLeaderboard()
    {
        using (var cmd = new NpgsqlCommand("SELECT reset_leaderboard_score(@uid)", conn))
        {
            cmd.Parameters.AddWithValue("uid", userId);

            // Fonksiyon VOID döndürdüðü için ExecuteScalar, ExecuteNonQuery fark etmez,
            // Ancak SELECT ile çaðýrdýðýmýz için ExecuteScalar kullanabiliriz (deðer dönmez, null döner)
            cmd.ExecuteScalar();
        }
    }

    public bool GunControl()
    {
        using (var cmd = new NpgsqlCommand("SELECT check_collectible_three_bool(@uid)", conn))
        {
            cmd.Parameters.AddWithValue("uid", userId);

            object result = cmd.ExecuteScalar();
            // Fonksiyon BOOLEAN döndürdüðü için result'ý bool'a cast edebiliriz
            bool hasCollectible = (bool)result;
            return hasCollectible;
        }


    }

    public void CollectibleIncrement(int collectibleid)
    {
        using (var cmd = new NpgsqlCommand("SELECT increment_user_collectible_count(@uid, @cid)", conn))
        {
            cmd.Parameters.AddWithValue("uid", userId);
            cmd.Parameters.AddWithValue("cid", collectibleid);
            cmd.ExecuteNonQuery();
        }

    }
    public void CollectibleDecrement(int collectibleid)
    {
        using (var cmd = new NpgsqlCommand("SELECT decrement_user_collectible_count(@uid, @cid)", conn))
        {
            cmd.Parameters.AddWithValue("uid", userId);
            cmd.Parameters.AddWithValue("cid", collectibleid);
            cmd.ExecuteNonQuery();
        }

    }

    public int ItemCount(int collectibleid)
    {
        using (var cmd = new NpgsqlCommand("SELECT get_user_collectible_count(@uid, @cid)", conn))
        {
            cmd.Parameters.AddWithValue("uid", userId);
            cmd.Parameters.AddWithValue("cid", collectibleid);

            object result = cmd.ExecuteScalar();
            return Convert.ToInt32(result);
        }

        

    }
    public void GetLevelAtt(int level,out int extrahp, out int ceilxp)
    {
        using (var cmd = new NpgsqlCommand("CALL get_level_info_proc(@lid, @ehp, @cxp)", conn))
        {
            // levelid parametresi
            cmd.Parameters.AddWithValue("lid", level);

            // extrahp parametresi (INOUT)

            var extrahpParam = new NpgsqlParameter("ehp", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = 0
            };
            var ceilxpParam = new NpgsqlParameter("cxp", NpgsqlTypes.NpgsqlDbType.Integer)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = 0
            };
            cmd.Parameters.Add(extrahpParam);
            cmd.Parameters.Add(ceilxpParam);
            cmd.ExecuteNonQuery();

            extrahp = (int)extrahpParam.Value;
            ceilxp = (int)ceilxpParam.Value;

            Console.WriteLine($"Level 5 için extrahp={extrahp}, ceilxp={ceilxp}");
        }
    }



    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnApplicationQuit()
    {
        conn.Close();
    }

}
