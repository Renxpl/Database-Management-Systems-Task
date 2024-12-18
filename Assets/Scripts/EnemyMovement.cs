using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyMovement : MonoBehaviour
{
    [SerializeField] float moveSpeed = 2f;
    Rigidbody2D enemyRb;
    BoxCollider2D enemyBC;
    CapsuleCollider2D enemyCC;


    
    void Start()
    {
        enemyRb= GetComponent<Rigidbody2D>();
        enemyBC= GetComponent<BoxCollider2D>();
        enemyCC= GetComponent<CapsuleCollider2D>();
    }

    
    void Update()
    {
        enemyRb.velocity = new Vector2(moveSpeed,0);


    }


    private void OnTriggerEnter2D(Collider2D collision)
    {
        
        if (enemyBC.IsTouchingLayers(LayerMask.GetMask("Ground")))
        {
            transform.localScale = new Vector2(-(Mathf.Sign(enemyRb.velocity.x)), 1f);
            moveSpeed = -moveSpeed;
            //Debug.Log("Touching");
            
        }
        //Debug.Log("Trigger exit");
    }

}
