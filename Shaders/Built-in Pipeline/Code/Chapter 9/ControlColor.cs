using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControlColor : MonoBehaviour
{
    private Material material;

    void Start()
    {
        material = GetComponent<Renderer>().material;
    }
    
    void Update()
    {
        var color = material.GetColor("_BaseColor");
        float hue, sat, val;
        Color.RGBToHSV(color, out hue, out sat, out val);

        hue = (Time.time * 0.25f) % 1.0f;

        color = Color.HSVToRGB(hue, sat, val);
        material.SetColor("_BaseColor", color);
    }
}
