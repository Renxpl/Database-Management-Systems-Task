using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    Rigidbody2D bulletRb;
    [SerializeField] GameObject player;
    float xSpeed;
    [SerializeField] float bulletSpeed = 10f;
    PlayerMovement playerScript;
    SQL mySql;
    int counter = 1;

    private void Start()
    {
        bulletRb= GetComponent<Rigidbody2D>();
        xSpeed = player.transform.localScale.x * bulletSpeed;
        playerScript= player.GetComponent<PlayerMovement>();
        mySql= FindObjectOfType<SQL>();
    }

    private void Update()
    {
        bulletRb.velocity = new Vector2(xSpeed, 0f);
        

    }



    private void OnTriggerEnter2D(Collider2D collision)
    {
        if(collision.tag == "Enemy")
        {
            Destroy(collision.gameObject);
           
            
            if (counter == 1)
            {
                playerScript.xp += 10;
                counter -= 1;
            }


        }
        Destroy(gameObject);
    }
    private void OnTriggerExit2D(Collider2D collision)
    {
        if (collision.tag == "Enemy")
        {
            Destroy(collision.gameObject);
            
            counter = 1;


        }
        Destroy(gameObject);
    }


    private void OnCollisionEnter2D(Collision2D collision)
    {
       Destroy(gameObject);
    }

}
