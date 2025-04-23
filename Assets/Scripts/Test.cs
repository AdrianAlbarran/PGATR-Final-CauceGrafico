using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    void Start() {
        // Crear mesh con un solo vértice
        Mesh mesh = new Mesh();
        mesh.vertices = new Vector3[] { Vector3.zero };
        mesh.SetIndices(new int[] { 0 }, MeshTopology.Points, 0);

        GetComponent<MeshFilter>().mesh = mesh;
        GetComponent<MeshRenderer>().material = new Material(Shader.Find("Custom/SeagullGeometry"));
    }
}
