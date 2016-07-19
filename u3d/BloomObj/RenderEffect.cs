using UnityEngine;

public class RenderEffect : MonoBehaviour
{
	public RenderTexture RenderTex;
	private GameObject customCam;

	public Material fastBloomMaterial;
	public Material combinematerial;

	private Camera camera;

	[Range (0, 10)]
	public float _BloomFactor;

	public enum Resolution
	{
		Low = 0,
		High = 1,
	}

	public enum BlurType
	{
		Standard = 0,
		Sgx = 1,
	}

	[Range (0.0f, 1.5f)]
	public float threshold = 0.25f;
	[Range (0.0f, 2.5f)]
	public float intensity = 0.75f;

	[Range (0.25f, 5.5f)]
	public float blurSize = 1.0f;

	Resolution resolution = Resolution.Low;
	[Range (1, 4)]
	public int blurIterations = 1;

	public BlurType blurType = BlurType.Standard;

	void Start ()
	{
		camera = GetComponent<Camera> ();
	}

	void CleanUpTextures ()
	{
		if (RenderTex) {
			RenderTexture.ReleaseTemporary (RenderTex);
			RenderTex = null;
		}
	}

	void OnPreRender ()
	{
		if (!enabled || !gameObject.active)
			return;

		CleanUpTextures ();

		float screenAspect = (float)(Screen.width) / Screen.height;
		////Debug.Log (screenAspect);
		int height = 400;
		int width = (int)(height * screenAspect);

//		RenderTex = RenderTexture.GetTemporary((int)camera.pixelWidth,(int)camera.pixelHeight, 16, RenderTextureFormat.ARGB32);
		RenderTex = RenderTexture.GetTemporary (width, height, 16, RenderTextureFormat.ARGB32);


		if (!customCam) {
			customCam = new GameObject ("bloomCamera");
			customCam.AddComponent<Camera> ();
			customCam.GetComponent<Camera> ().enabled = false;
			customCam.hideFlags = HideFlags.HideAndDontSave;
		}
		customCam.GetComponent<Camera> ().CopyFrom (camera);
		customCam.GetComponent<Camera> ().backgroundColor = new Color (0, 0, 0, 0);
		customCam.GetComponent<Camera> ().clearFlags = CameraClearFlags.SolidColor;

		/*
		customCam.GetComponent<Camera>().cullingMask = 1 << LayerMask.NameToLayer("Character1") |
		1 << LayerMask.NameToLayer("Character2");
		*/

		customCam.GetComponent<Camera> ().targetTexture = RenderTex;
		customCam.GetComponent<Camera> ().RenderWithShader (
			Shader.Find ("Custom/BloomTexture"), "RenderType");
		//customCam.GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
	}

	void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		/*
		material.SetTexture("_DepthNormal", _depthNormalTex);
		ImageEffects.BlitWithMaterial(material, source, destination);
		CleanUpTextures();
		*/
		//Graphics.Blit(source, destination, material);

		int divider = resolution == Resolution.Low ? 4 : 2;
		float widthMod = resolution == Resolution.Low ? 0.5f : 1.0f;

		fastBloomMaterial.SetVector ("_Parameter", new Vector4 (blurSize * widthMod, 0.0f, threshold, intensity));
		RenderTex.filterMode = FilterMode.Bilinear;

		var rtW = RenderTex.width / divider;
		var rtH = RenderTex.height / divider;

		// downsample
		RenderTexture rt = RenderTexture.GetTemporary (rtW, rtH, 0, RenderTex.format);
		rt.filterMode = FilterMode.Bilinear;
		Graphics.Blit (RenderTex, rt, fastBloomMaterial, 1);

		var passOffs = blurType == BlurType.Standard ? 0 : 2;

		for (int i = 0; i < blurIterations; i++) {
			fastBloomMaterial.SetVector ("_Parameter", new Vector4 (blurSize * widthMod + (i * 1.0f), 0.0f, threshold, intensity));

			// vertical blur
			RenderTexture rt2 = RenderTexture.GetTemporary (rtW, rtH, 0, RenderTex.format);
			rt2.filterMode = FilterMode.Bilinear;
			Graphics.Blit (rt, rt2, fastBloomMaterial, 2 + passOffs);
			RenderTexture.ReleaseTemporary (rt);
			rt = rt2;

			// horizontal blur
			rt2 = RenderTexture.GetTemporary (rtW, rtH, 0, RenderTex.format);
			rt2.filterMode = FilterMode.Bilinear;
			Graphics.Blit (rt, rt2, fastBloomMaterial, 3 + passOffs);
			RenderTexture.ReleaseTemporary (rt);
			rt = rt2;
		}

		fastBloomMaterial.SetTexture ("_Bloom", rt);

		Graphics.Blit (RenderTex, RenderTex, fastBloomMaterial, 0);


		combinematerial.SetTexture ("_BloomTex", RenderTex);
		combinematerial.SetFloat ("_BloomFactor", _BloomFactor);
		Graphics.Blit (source, destination, combinematerial);

		RenderTexture.ReleaseTemporary (rt);
	}

	new void OnDisable ()
	{
		if (customCam) {
			DestroyImmediate (customCam);
		}
	}
}