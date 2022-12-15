using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveWorld : MonoBehaviour
{
    [SerializeField] private Renderer dissolveRenderer;
    private Material material;

    void Start()
    {
        material = dissolveRenderer.material;
    }

    void Update()
    {
        material.SetVector("_PlaneOrigin", transform.position);
        material.SetVector("_PlaneNormal", transform.up);
    }
}
