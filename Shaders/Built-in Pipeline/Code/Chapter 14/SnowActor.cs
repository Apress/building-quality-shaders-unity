using UnityEngine;

public class SnowActor : MonoBehaviour
{
    public Transform groundAnchor;
    private CapsuleCollider capsuleCollider;

    private Vector3 lastFramePos = Vector3.zero;
    private bool isMoving;

    private void Start()
    {
        capsuleCollider = GetComponent<CapsuleCollider>();
    }

    public Vector3 GetGroundPos()
    {
        return groundAnchor.position;
    }

    public float GetRadius()
    {
        Vector3 localScale = transform.localScale;
        float scaleRadius = Mathf.Max(localScale.x, localScale.z);
        return capsuleCollider.radius * scaleRadius;
    }

    private void Update()
    {
        isMoving = (transform.position != lastFramePos);
        lastFramePos = transform.position;
    }

    public bool IsMoving()
    {
        return isMoving;
    }
}
