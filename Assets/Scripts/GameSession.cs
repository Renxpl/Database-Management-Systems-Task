using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;
using static Cinemachine.DocumentationSortingAttribute;

public class GameSession : MonoBehaviour
{
    [SerializeField] int playerLives;
    int scorePoint = 0;
    int totalScorePoint = 0;
    PlayerMovement playerScript;
    bool esc = false;
    SQL mySql;
    [SerializeField] TextMeshProUGUI lives;
    [SerializeField] TextMeshProUGUI score;
    [SerializeField] TextMeshProUGUI xp;
    [SerializeField] TextMeshProUGUI totalScore;
    [SerializeField] GameObject inventoryScreen;
    int xpInt;
    int scoreInt;
    int ceilxp;
    int level;
    int maxLife;

    private void Awake()
    {
        int numGameSessions = FindObjectsOfType<GameSession>().Length;
        if(numGameSessions > 1)
        {
            Destroy(gameObject);
        }

        else
        {
            DontDestroyOnLoad(gameObject);
        }
    }
    void Start()
    {
        lives.text = playerLives.ToString();
        score.text = scorePoint.ToString();
        playerScript = FindObjectOfType<PlayerMovement>();
        inventoryScreen.SetActive(false);
        mySql = FindObjectOfType<SQL>();
        mySql.GameUpdate(out level,out playerLives,out xpInt, out scorePoint);
        lives.text = "lives: " + playerLives.ToString();
        xp.text = "xp: " + xpInt.ToString();
        score.text = "gold: " + scorePoint.ToString();
       

    }

    
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if(esc) esc= false;
            else esc= true;
        }


        if (esc) 
        {
            inventoryScreen.SetActive(true);
        }
        else
        {
            inventoryScreen.SetActive(false);
        }
        if (level < 1)
        {
            level = 1;
            mySql.GetLevelAtt(level, out maxLife, out ceilxp);
            playerLives = maxLife;
            lives.text = "lives: " + playerLives.ToString();

        }
        mySql.IngameUpdate(level, playerLives, xpInt, scorePoint);
        mySql.GetLevelAtt(level, out maxLife, out ceilxp);
        if(ceilxp <= xpInt)
        {
            xpInt= 0;
            level += 1;
            playerLives = maxLife;
            mySql.GetLevelAtt(level, out maxLife, out ceilxp);

        }
        

    }

    public void ProcessPlayerDeath()
    {
        if (playerLives > 1)
        {
            TakeLife();
        }
        else
        {
            ResetGameSession();
        }
    }

    private void ResetGameSession()
    {
        SceneManager.LoadScene(01);
        mySql.IngameUpdate(1, 3, 0, 0);
        mySql.ResetLeaderboard();
        Destroy(gameObject);
        while (mySql.ItemCount(1) != 0)
        {
            mySql.CollectibleDecrement(1);
        }
        while (mySql.ItemCount(2) != 0)
        {
            mySql.CollectibleDecrement(2);
        }
        while (mySql.ItemCount(3) != 0)
        {
            mySql.CollectibleDecrement(3);
        }
    }

    private void TakeLife()
    {
        playerLives--;
        int currentSessionIndex = SceneManager.GetActiveScene().buildIndex;
        SceneManager.LoadScene(currentSessionIndex);
        lives.text = "lives: "+ playerLives.ToString();
        
    }

    public void IncreaseXp()
    {
        xpInt += 10; 
        xp.text = "xp: " + xpInt.ToString();




    }

    public void IncreaseHp()
    {
        if(maxLife>playerLives) playerLives += 1;
        lives.text = "lives: " + playerLives.ToString();




    }

    public void AddToScore(int point)
    {
        scorePoint += point;
        mySql.Leaderboard(point);
        score.text = "gold: "+ scorePoint.ToString();
       
    }

    public void Purchase(int price)
    {
        scorePoint -= price;
        score.text = "gold: " + scorePoint.ToString();

    }

    public int GoldDon()
    {
        return scorePoint;
    }

}
