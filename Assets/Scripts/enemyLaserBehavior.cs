using UnityEngine;
using System.Collections;

public class enemyLaserBehavior : MonoBehaviour{

    public float lifetime = 2.0f;
    public float speed = 3.0f;
    //public int rotationSpeed; // not used in this simple laser
    public Transform target;
    public Color color = Color.gray; // color
    public Renderer rend; // for color manipulation
    //NavMeshAgent nav;               // Reference to the nav mesh agent. This is beyond me.
    private bool active = true; // whether the bullet will hurt you or not

    void Awake()
    {
        try
        {
            target = GameObject.FindWithTag("Player").transform;
        }

        catch
        {
            target = null;
        }
        //nav = GetComponent<NavMeshAgent>();
        Destroy(gameObject, lifetime);
    }

    void Update()
    {
        transform.Translate(Vector3.up * speed * Time.deltaTime);

    }

    void OnCollisionEnter2D(Collision2D coll) // hits core of ship
    {
        if (coll.gameObject.tag == "Player" && active == true)
        {

            Debug.Log("Core Hit");
            Destroy(coll.gameObject);
            Destroy(gameObject);
        }
    }

    void OnTriggerExit2D(Collider2D coll) // hits player but not core
    {
        if (coll.gameObject.tag == "Player")
        {
            Debug.Log("Contact made");
            rend = GetComponent<Renderer>();
            rend.material.color = color;
            active = false;
            GetComponent<Collider2D>().isTrigger = true;
            PowerManager.power += 5;
        }
    }
}
