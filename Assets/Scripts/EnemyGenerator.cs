using UnityEngine;
using System.Collections;

public class EnemyGenerator : MonoBehaviour {

    public GameObject enemy1;
    public GameObject enemy2;
    public float spawnTime = 3f;
    private float waves = 0f;
    private float enemyCount = 0f;
    private int enemyTypeToSpawn = 1;
    

    // Use this for initialization
    void Start ()
    {
        InvokeRepeating("SpawnFirstSet", spawnTime, spawnTime);
	}
	
	void SpawnFirstSet () {
        var cameraPos = Camera.main.gameObject.transform.position;
        waves++;
        if (waves >= 7  )
        {
            enemyCount = Random.Range(4, 8);
        }
        else
        {
            enemyCount = Random.Range(1, 3);
        }
        
        for (int i = 1;i <= enemyCount; i++)
        {
            enemyTypeToSpawn = Random.Range(1, 3);
            if (enemyTypeToSpawn == 1)
            {
                Instantiate(enemy1, new Vector3(Random.Range(-8, 8), Random.Range(cameraPos.y + 6, cameraPos.y + 9)), Quaternion.Euler(0, 0, 180)); // spawns the enemy above the camera, facing down
            }
            else
            {
                Instantiate(enemy2, new Vector3(Random.Range(-8, 8), Random.Range(cameraPos.y + 6, cameraPos.y + 9)), Quaternion.Euler(0, 0, 180)); // spawns the enemy above the camera, facing down
            }
        }
        if (waves == 9)
        {
            CancelInvoke();
            waves = 0;
            Debug.Log("You have entered Stage 2");
            InvokeRepeating("SpawnSecondSet", spawnTime, spawnTime);
        }
    }

    void SpawnSecondSet()
    {
        var cameraPos = Camera.main.gameObject.transform.position;
        waves++;
        enemyCount = Random.Range(1, 8);
        for (int i = 1; i <= enemyCount; i++)
        {
            Instantiate(enemy1, new Vector3(Random.Range(-8, 8), Random.Range(cameraPos.y + 6, cameraPos.y + 9)), Quaternion.Euler(0, 0, 180)); // spawns the enemy above the camera, facing down
        }
        if (waves == 5)
        {
            CancelInvoke();
            waves = 0;
            Debug.Log("You have entered Stage 3");
            Invoke("SpawnGrowingSet", spawnTime);
        }
    }

    void SpawnGrowingSet()
    {
        var cameraPos = Camera.main.gameObject.transform.position;
        waves++;
        float randomTime = Random.Range(1, 5); // random delay between invoking this method
        enemyCount = Random.Range(1, Time.time % 2);
        for (int i = 1; i <= enemyCount; i++)
        {
            Instantiate(enemy1, new Vector3(Random.Range(-8, 8), Random.Range(cameraPos.y + 6, cameraPos.y + 10)), Quaternion.Euler(0, 0, 180)); // spawns the enemy above the camera, facing down
        }
        if (GameObject.FindWithTag("Player") != null)
            {
            Invoke("SpawnGrowingSet", randomTime);
            }
    }
}
