using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CoinScript : MonoBehaviour
{

    [SerializeField] AudioClip coinnn;
    [SerializeField] int pointsfor = 100;
    SQL mySql;

    bool wasCollected = false;
    void Start()
    {
        mySql= new SQL();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if(collision.tag == "Player" && !wasCollected)
        {
            wasCollected= true;
            AudioSource.PlayClipAtPoint(coinnn, Camera.main.transform.position);
            FindObjectOfType<GameSession>().AddToScore(pointsfor);
        
            Destroy(gameObject);
        }
    }

}
