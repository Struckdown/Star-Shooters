using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

public class PlayerController : MonoBehaviour {

    public GameObject laser;
    public GameObject superLaser;
    public float fireRate = 0.5f;
    private float nextFire = 0.0f;


    public float speed = 5.0f;
    //float cameraSpeed = 1.0f; //Modifier to make player follow the camera object
    //public Transform cameraObject;
	
	// Update is called once per frame
	void Update () {

        if (Input.GetKeyDown(KeyCode.LeftShift))
            speed = 2.0f;
        if (Input.GetKeyUp(KeyCode.LeftShift))
            speed = 5.0f;


        var move = new Vector3(0, 0);
        var cameraPos = Camera.main.gameObject.transform.position;

        if (transform.position.x > 9)
            transform.position = new Vector3(9, transform.position.y); // comfirms object not off camera to right
        if (transform.position.x < -9)
            transform.position = new Vector3(-9, transform.position.y); // comfirms object not off camera to left
        if (cameraPos.y - transform.position.y >= 5)
            transform.position = new Vector3(transform.position.x, (cameraPos.y - 5)); // doesn't let object go below screen
        if (transform.position.y - cameraPos.y >= 5)
            transform.position = new Vector3(transform.position.x, (cameraPos.y + 5)); // doesn't let object go above screen

        if (transform.position.x >= 9 && (Input.GetAxis("Horizontal") == 1)) // doesn't allow movement to the right at screen edge
        {
            move = new Vector3(0, Input.GetAxis("Vertical"));
        }
        else if ((transform.position.x < -9) && (Input.GetAxis("Horizontal") == -1)) // doesn't allow movement to the left at screen edge
        {
            move = new Vector3(0, Input.GetAxis("Vertical"));
        }
        else
        {
            move = new Vector3(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical")); // else do normal movement
        }

        transform.position += move * speed * Time.deltaTime;
        //transform.position += new Vector3(0, cameraSpeed) * Time.deltaTime; // adjustment to follow the camera object at the same speed


        if (Input.GetKey(KeyCode.Z) && Time.time > nextFire)
        {
            nextFire = Time.time + fireRate;

            if (PowerManager.power >= 20)
            {
                Instantiate(laser, (GameObject.FindGameObjectWithTag("Player").transform.position + new Vector3(-0.1f,0)), Quaternion.identity);
                Instantiate(laser, GameObject.FindGameObjectWithTag("Player").transform.position + new Vector3(0.1f,0), Quaternion.identity);
                PowerManager.power -= 2;
            }

            else if (PowerManager.power > 0)
            {

                Instantiate(laser, GameObject.FindGameObjectWithTag("Player").transform.position, Quaternion.identity);
                PowerManager.power -= 1;
            }
            /*else
            {
                //Instantiate(laser, GameObject.FindGameObjectWithTag("Player").transform.position, Quaternion.identity);
            } Potential error message location, stating to the player how there is insufficient energy to fire the laser*/
        }

        if (Input.GetKey(KeyCode.X) && Time.time > nextFire && PowerManager.power >= 20)
        {
            Debug.Log("Super Laser Fired");
            nextFire = Time.time + fireRate;
            Instantiate(superLaser, GameObject.FindGameObjectWithTag("Player").transform.position, Quaternion.identity);
            PowerManager.power -= 20;
        }
    }
}
