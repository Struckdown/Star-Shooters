using UnityEngine;
using System.Collections;
using System;

public class Enemy1Behavior : MonoBehaviour {

    public Transform target;
    public float moveSpeed;
    public int rotationSpeed;
    public float enemyLifeTime = 15f;
    //NavMeshAgent nav;               // Reference to the nav mesh agent.
    public GameObject laser;
    public float fireRate = 0.5f;
    private float nextFire = 0.0f;


    // Use this for initialization
    void Awake () {
        moveSpeed = UnityEngine.Random.Range(1f, 3f);
        try
        {
            target = GameObject.FindWithTag("Player").transform;
        }
        catch
        {
            target = null;
        }
        //nav = GetComponent<NavMeshAgent>();
        Destroy(gameObject, enemyLifeTime);
    }

	// Update is called once per frame
	void Update () {
        try
        {
            Vector3 dir = target.position - transform.position;
            dir.z = 0.0f;
            // Only needed if objects don't share 'z' value.
            if (dir != Vector3.zero)
                transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.FromToRotation(Vector3.up, dir), rotationSpeed * Time.deltaTime);

            if (Time.time > nextFire)
            {
                fireRate += UnityEngine.Random.Range(0.75f, 1.25f);
                nextFire = Time.time + fireRate;
                Instantiate(laser, transform.position, Quaternion.Slerp(transform.rotation, Quaternion.FromToRotation(Vector3.up, dir), rotationSpeed * Time.deltaTime));
            }
        }
        catch (Exception)
        {
            Vector3 dir = transform.position;
            dir.z = 0.0f;
            // Only needed if objects don't share 'z' value.
            if (dir != Vector3.zero)
                transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.FromToRotation(Vector3.up, dir), rotationSpeed * Time.deltaTime);

            if (Time.time > nextFire)
            {
                fireRate += UnityEngine.Random.Range(-0.5f, 0.5f);
                nextFire = Time.time + fireRate;
                Instantiate(laser, transform.position, Quaternion.Slerp(transform.rotation, Quaternion.FromToRotation(Vector3.up, dir), rotationSpeed * Time.deltaTime));
            }
        }
        
        // move downwards
        transform.position += new Vector3(0, -1) * moveSpeed * Time.deltaTime;

    }
}
