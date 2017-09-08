using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class PowerManager : MonoBehaviour
{
    public static float currentPower;        // The player's power.
    public static int maxPower = 100;
    private Transform player;
    public Image powerBar;

    Text powerText;                      // Reference to the Text component.

    void Awake()
    {
        // Set up the reference.
        powerText = GetComponent<Text>();

        // Reset the Power.
        currentPower = 0;
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
            int showPower = (int)currentPower;
            powerText.text = "Power: " + showPower.ToString();
            powerUpdate();
        }

    }

    private void powerUpdate()
    {
        powerBar.transform.localScale = new Vector3(powerBar.transform.localScale.x, Mathf.Clamp((float)(currentPower / maxPower), 0, 1), powerBar.transform.localScale.z);
    }
    
}