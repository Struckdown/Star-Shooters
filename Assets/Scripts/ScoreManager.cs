using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class ScoreManager : MonoBehaviour
{
    public static float score;        // The player's score.
    private Transform player;

    Text scoreText;                      // Reference to the Text component.

    void Awake()
    {
        // Set up the reference.
        scoreText = GetComponent<Text>();

        // Reset the score.
        score = 0;
    }


    void Update()
    {
        try
        {
            player = GameObject.FindWithTag("Player").transform;
        }

        catch
        {
            player = null;
        }

        // Set the displayed text to be the word "Score" followed by the score value.
        if (player != null)
        {
            score += Time.deltaTime;
            int showScore = (int)score;
            scoreText.text = "Score: " + showScore.ToString();
        }

    }

}