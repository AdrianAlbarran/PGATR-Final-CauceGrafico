using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WireframeController : MonoBehaviour
{
    [Header("Materiales para cambiar")]
    public Material plane;
    public Material wifreframe;

    private MeshRenderer meshRenderer;
    private bool usingFirstMaterial = true;

    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        if (meshRenderer == null)
        {
            Debug.LogError("No se encontró un MeshRenderer en el objeto.");
            this.enabled = false;
        }

        // Establece el material inicial
        if (plane != null)
        {
            meshRenderer.material = plane;
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            ToggleMaterial();
        }
    }

    public void ToggleMaterial()
    {
        if (meshRenderer == null || plane == null || wifreframe == null) return;

        usingFirstMaterial = !usingFirstMaterial;
        meshRenderer.material = usingFirstMaterial ? plane : wifreframe;
    }
}
