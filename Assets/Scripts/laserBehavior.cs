using UnityEngine;
using System.Collections;

public class laserBehavior : MonoBehaviour {

    public float lifetime = 2.0f;
    public float speed = 2.0f;
    public bool piercing = false;

    // Use this for initialization
    void Start() {
    }

    // Update is called once per frame
    void FixedUpdate() {
        transform.Translate(0, speed, 0);
    }

    void Awake()
    {
        Destroy(gameObject, lifetime);
    }

    void OnCollisionEnter2D(Collision2D coll)
    {
        if (coll.gameObject.tag == "Enemy")
        {

            Destroy(coll.gameObject);
            if (!piercing)
            {
                Destroy(gameObject);
                ScoreManager.score += 30;
            }
            else
            {
                ScoreManager.score += 10;
            }
        }
    }
}
