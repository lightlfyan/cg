using UnityEngine;
using System.Collections;

public class RenderTypeChange : MonoBehaviour
{

	// Use this for initialization
	void Start()
	{
		GetComponent<Renderer>().material.SetOverrideTag("RenderType", "Bloom");
	
	}
	
	// Update is called once per frame
	void Update()
	{
	
	}
}
