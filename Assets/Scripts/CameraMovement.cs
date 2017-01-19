using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

public class CameraMovement : MonoBehaviour {

    // Note: Camera movement disabled at this time
    //float speed = 1.0f;
    

    // Update is called once per frame
    void Update() {
        //var move = new Vector3(0, 1, 0);
        //transform.position += move * speed * Time.deltaTime;
        if (Input.GetKeyUp(KeyCode.R))
        {
            string sceneName = "First Level";
            SceneManager.LoadScene(sceneName);
        }
    }
}
