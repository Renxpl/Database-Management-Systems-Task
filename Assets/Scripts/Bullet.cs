using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    Rigidbody2D bulletRb;
    [SerializeField] GameObject player;
    float xSpeed;
    [SerializeField] float bulletSpeed = 10f;

    private void Start()
    {
        bulletRb= GetComponent<Rigidbody2D>();
        xSpeed = player.transform.localScale.x * bulletSpeed;
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
        }
        Destroy(gameObject);
    }


    private void OnCollisionEnter2D(Collision2D collision)
    {
       Destroy(gameObject);
    }

}
