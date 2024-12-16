using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Deal : MonoBehaviour
{
    BoxCollider2D hit;
    void Start()
    {
        hit= GetComponent<BoxCollider2D>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.tag == "Player")
        {
            Debug.Log("Deal");
        }
    }
}
