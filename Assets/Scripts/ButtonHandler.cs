using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class ButtonHandler : MonoBehaviour
{
    public TMP_InputField forUserName;
    public TMP_InputField forPassword;
    public GameObject loginScreen;
    public GameObject registerScreen;
    public GameObject mainScreen;
    public TextMeshProUGUI text;
    public TextMeshProUGUI text2;
    public GameObject extra1;
    public GameObject extra2;
    GameSession session;
    public GameObject deleteScreen;

    SQL mySql;
    

    // Start is called before the first frame update
    void Start()
    {
        if (registerScreen != null) registerScreen.SetActive(false);
        if (mainScreen != null) mainScreen.SetActive(true);
        if (loginScreen != null) loginScreen.SetActive(false);
        if (deleteScreen != null) deleteScreen.SetActive(false);
        mySql = FindObjectOfType<SQL>();
        session = FindObjectOfType<GameSession>();

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void ToDeleteScreen()
    {
        if (registerScreen != null) registerScreen.SetActive(false);
        if (mainScreen != null) mainScreen.SetActive(false);
        if (loginScreen != null) loginScreen.SetActive(false);
        if (deleteScreen != null) deleteScreen.SetActive(true);
        if (extra1 != null && !mySql.AbilityControl()) extra1.SetActive(true);
        else if (mySql.AbilityControl()) extra1.SetActive(false);
        if (extra2 != null && !mySql.GunControl()) extra2.SetActive(true);
        else if (mySql.GunControl()) extra2.SetActive(false);
        if (text != null) { text.text = "XP Potion--Kalan Kullaným: " + mySql.ItemCount(1).ToString(); }
        if (text2 != null) { text2.text = "HP Potion--Kalan Kullaným: " + mySql.ItemCount(2).ToString(); }

    }

    public void ToLoginScreen()
    {
        if (registerScreen != null) registerScreen.SetActive(false);
        if (mainScreen != null) mainScreen.SetActive(false);
        if (deleteScreen != null) deleteScreen.SetActive(false);
        if (loginScreen != null) loginScreen.SetActive(true);
        if(extra1!=null && !mySql.AbilityControl()) extra1.SetActive(true);
        else if(mySql.AbilityControl()) extra1.SetActive(false);
        if (extra2 != null && !mySql.GunControl()) extra2.SetActive(true);
        else if(mySql.GunControl()) extra2.SetActive(false);
        if (text != null) { text.text = "XP Potion--Kalan Kullaným: " + mySql.ItemCount(1).ToString(); }
        if (text2 != null) { text2.text = "HP Potion--Kalan Kullaným: " + mySql.ItemCount(2).ToString(); }

    }

    public void DeleteAccount()
    {


        mySql.DeleteAccount(forUserName.text);


    }
    public void Login()
    {
        mySql.TestLogin(forUserName.text,forPassword.text);
        if (mySql.giris)
        {
            SceneManager.LoadScene(1);
            mySql.giris = false;
        }


    }
    public void Register()
    {
        mySql.CreateAccount(forUserName.text, forPassword.text);
        mySql.FirstSetUp(forUserName.text);
        if (mySql.giris)
        {
            SceneManager.LoadScene(1);
            mySql.giris = false;
        }


    }
    public void ToRegisterScreen()
    {
        if(registerScreen!= null) registerScreen.SetActive(true);
        if (deleteScreen != null) deleteScreen.SetActive(false);
        if (mainScreen != null) mainScreen.SetActive(false);
        if (loginScreen != null) loginScreen.SetActive(false);
        if (text != null)
        {
            Debug.Log(text.text);
            text.text = mySql.UpdateFriendList();
        }


    }
    public void ToMainScreen()
    {
        if (registerScreen != null) registerScreen.SetActive(false);
        if (mainScreen != null) mainScreen.SetActive(true);
        if (loginScreen != null) loginScreen.SetActive(false);
        if (deleteScreen != null) deleteScreen.SetActive(false);


    }
    public void ArkadasEkle()
    {
        mySql.AddFriend(forUserName.text);
        if (text != null)
        { 
            text.text = mySql.UpdateFriendList();
        }
    }
    
    public void YetenekAc()
    {
        //Debug.Log(mySql.AbilityControl());
        if(session.GoldDon() >= 200)
        {
            mySql.NewAbility();
            session.Purchase(200);

            extra1.SetActive(false);
        }
        
    }



    public void Quit()
    {
        //çýkýþ
        Application.Quit();

    }

    public void ItemIncrement(int id)
    {
       
        if (text != null)
        {
            if (id == 1 && session.GoldDon()>=50)
            {
                mySql.CollectibleIncrement(id);
                text.text = "XP Potion--Kalan Kullaným: " + mySql.ItemCount(id).ToString();
                session.Purchase(50);
                
            }
            else if (id == 2 && session.GoldDon() >= 50)
            {
                mySql.CollectibleIncrement(id);
                text2.text = "HP Potion--Kalan Kullaným: " + mySql.ItemCount(id).ToString();
                session.Purchase(50);
            }
            
        }

        if (id == 3 && session.GoldDon() >= 400)
        {
            mySql.CollectibleIncrement(id);
            session.Purchase(400);

            extra2.SetActive(false);
        }

    }

    public void DecrementIncrement(int id)
    {
        if (id == 1)
        {
            session.IncreaseXp();
        }
        if(id == 2)
        {
            session.IncreaseHp();
        }


        if(id!= 3)
        mySql.CollectibleDecrement(id);

    }

    public void ItemSayisi(int id)
    {
        if(text!= null)
        {
            if (id == 1)
            {
                text.text =  "XP Potion--Kalan Kullaným: " + mySql.ItemCount(id).ToString();
            }
            else if (id == 2)
            {
                text2.text = "HP Potion--Kalan Kullaným: " + mySql.ItemCount(id).ToString();

            }
        }


    }

}
