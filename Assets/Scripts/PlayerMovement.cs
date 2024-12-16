using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{

    [SerializeField] GameObject bullet;
    [SerializeField] Transform gun;

    [SerializeField] float runSpeed = 10f;
    [SerializeField] float jumpSpeed = 10f;
    [SerializeField] float climbSpeed = 4f;

    float gravityScaleAtStart;
    Rigidbody2D myRigidbody;

    Vector2 moveInput;

    Animator myAnimator;

    CapsuleCollider2D myCapsuleCollider;

    BoxCollider2D myBoxCollider;

    bool isAlive = true;

    void Start()
    {
        myRigidbody= GetComponent<Rigidbody2D>();
        myAnimator= GetComponent<Animator>();
        myCapsuleCollider = GetComponent<CapsuleCollider2D>();
        gravityScaleAtStart = myRigidbody.gravityScale;
        myBoxCollider = GetComponent<BoxCollider2D>();
    }

    
    void Update()
    {
        if(!isAlive) return;
        Run();
        FlipSprite();
        Climbladder();
        Die();
    }

    private void Die()
    {
        if(myCapsuleCollider.IsTouchingLayers(LayerMask.GetMask("Enemy", "Hazards"))) 
        {
            isAlive= false;
            myAnimator.SetTrigger("Dying");
            myRigidbody.velocity = new Vector2(50f, 50f);
            FindObjectOfType<GameSession>().ProcessPlayerDeath();
        }
    }

    void OnMove(InputValue value)
    {
        if (!isAlive) return;
        moveInput = value.Get<Vector2>();
        Debug.Log(moveInput);

    }

    void Run()
    {
        if (!isAlive) return;
        Vector2 playerVelocity = new Vector2(moveInput.x * runSpeed, myRigidbody.velocity.y);

        myRigidbody.velocity = playerVelocity;
        bool hasHorizontalSpeed = Mathf.Abs(myRigidbody.velocity.x) > Mathf.Epsilon;
        myAnimator.SetBool("isRunning", hasHorizontalSpeed);
    }

    void FlipSprite()
    {
        bool hasHorizontalSpeed = Mathf.Abs(myRigidbody.velocity.x) > Mathf.Epsilon;
        if (hasHorizontalSpeed)
        {
            transform.localScale = new Vector2(Mathf.Sign(myRigidbody.velocity.x), 1f);
        }


    }

    void OnJump(InputValue value)
    {
        if (!isAlive) return;
        if (myBoxCollider.IsTouchingLayers(LayerMask.GetMask("Ground")))
        {
            if (value.isPressed)
            {
                myRigidbody.velocity = new Vector2(0f, jumpSpeed);
            }
        }
    }

    void Climbladder()
    {
        if (!isAlive) return;
        if (myBoxCollider.IsTouchingLayers(LayerMask.GetMask("Ladder")))
        {
            Vector2 climbVelocity = new Vector2(myRigidbody.velocity.x, moveInput.y * climbSpeed);
            
            myRigidbody.velocity = climbVelocity;
            myRigidbody.gravityScale = 0f;
            bool hasVerticalSpeed = Mathf.Abs(myRigidbody.velocity.y) > Mathf.Epsilon;
            myAnimator.SetBool("isClimbing", hasVerticalSpeed);
        }
        else 
        { 
            myRigidbody.gravityScale = gravityScaleAtStart;
            myAnimator.SetBool("isClimbing", false);
        }
        
    }

    void OnFire(InputValue value)
    {
        if (!isAlive) return;
        if (value.isPressed)
        {
            Instantiate(bullet, gun.position, transform.rotation);
        }
    }


}
