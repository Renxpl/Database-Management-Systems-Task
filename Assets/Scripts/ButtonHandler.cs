using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
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

    SQL mySql;


    // Start is called before the first frame update
    void Start()
    {
        if (registerScreen != null) registerScreen.SetActive(false);
        if (mainScreen != null) mainScreen.SetActive(true);
        if (loginScreen != null) loginScreen.SetActive(false);
        mySql = FindObjectOfType<SQL>();

    }

    // Update is called once per frame
    void Update()
    {
        
    }



    public void ToLoginScreen()
    {
        if (registerScreen != null) registerScreen.SetActive(false);
        if (mainScreen != null) mainScreen.SetActive(false);
        if (loginScreen != null) loginScreen.SetActive(true);
        if(extra1!=null && !mySql.AbilityControl()) extra1.SetActive(true);
        else if(mySql.AbilityControl()) extra1.SetActive(false);
        if (text != null) { text.text = "XP Potion--Kalan Kullaným: " + mySql.ItemCount(1).ToString(); }
        if (text2 != null) { text2.text = "HP Potion--Kalan Kullaným: " + mySql.ItemCount(2).ToString(); }

    }
    public void Login()
    {
        mySql.TestLogin(forUserName.text,forPassword.text);


    }
    public void Register()
    {
        mySql.CreateAccount(forUserName.text, forPassword.text);
        mySql.FirstSetUp(forUserName.text);


    }
    public void ToRegisterScreen()
    {
       if(registerScreen!= null) registerScreen.SetActive(true);
        if (mainScreen != null) mainScreen.SetActive(false);
        if (loginScreen != null) loginScreen.SetActive(false);
        if(text != null)
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
        mySql.NewAbility();
        this.gameObject.SetActive(false);
    }



    public void Quit()
    {
       //çýkýþ

    }

    public void ItemIncrement(int id)
    {
        mySql.CollectibleIncrement(id);
        if (text != null)
        {
            if (id == 1)
            {
                text.text = "XP Potion--Kalan Kullaným: " + mySql.ItemCount(id).ToString();
            }
            else if (id == 2)
            {
                text.text = "HP Potion--Kalan Kullaným: " + mySql.ItemCount(id).ToString();

            }
        }

    }

    public void DecrementIncrement(int id)
    {
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
                text.text = "HP Potion--Kalan Kullaným: " + mySql.ItemCount(id).ToString();

            }
        }


    }

}
