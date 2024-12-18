using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

public class GameSession : MonoBehaviour
{
    [SerializeField] int playerLives = 3;
    int scorePoint = 0;
    int totalScorePoint = 0;
    PlayerMovement playerScript;
    bool esc = false;

    [SerializeField] TextMeshProUGUI lives;
    [SerializeField] TextMeshProUGUI score;
    [SerializeField] TextMeshProUGUI xp;
    [SerializeField] TextMeshProUGUI totalScore;
    [SerializeField] GameObject inventoryScreen;

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
        
    }

    
    void Update()
    {
        xp.text = playerScript.xp.ToString();
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
        SceneManager.LoadScene(0);
        Destroy(gameObject);
    }

    private void TakeLife()
    {
        playerLives--;
        int currentSessionIndex = SceneManager.GetActiveScene().buildIndex;
        SceneManager.LoadScene(currentSessionIndex);
        lives.text = playerLives.ToString();
        
    }

    public void AddToScore(int point)
    {
        scorePoint += point;
        totalScorePoint += point; 
        score.text = scorePoint.ToString();
        totalScore.text = totalScorePoint.ToString();
    }

}
