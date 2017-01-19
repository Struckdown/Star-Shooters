using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class PowerManager : MonoBehaviour
{
    public static float power;        // The player's power.
    private Transform player;

    Text powerText;                      // Reference to the Text component.

    void Awake()
    {
        // Set up the reference.
        powerText = GetComponent<Text>();

        // Reset the Power.
        power = 0;
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

        // Set the displayed text to be the word "Power" followed by the power value.
        if (player != null)
        {
            int showPower = (int)power;
            powerText.text = "Power: " + showPower.ToString();
        }

    }

}