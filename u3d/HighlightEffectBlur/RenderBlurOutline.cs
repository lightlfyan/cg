using UnityEngine;
using UnityEngine.Rendering;


[RequireComponent (typeof(Camera))]
public class RenderBlurOutline : MonoBehaviour
{
	public int blurIterCount = 1;
	public float blurScale = 1.0f;
	public Shader outlineShader;
	public Shader silhouetteShader;
	public Renderer[] silhouettes;

	public Color outlineColor = Color.red;

	public Color OutlineColor {
		get { return outlineColor; }
		set { outlineColor = value; }
	}

	Material outlineMaterial;
	Material silhouetteMaterial;
	Camera mCamera;
	CommandBuffer renderCommand;

	void Awake ()
	{
		outlineMaterial = new Material (outlineShader);
		silhouetteMaterial = new Material (silhouetteShader);
		renderCommand = new CommandBuffer ();
		renderCommand.name = "Render Solid Color Silhouette";
		mCamera = GetComponent<Camera> ();
	}

	void OnEnable ()
	{
		//顺序将渲染任务加入renderCommand中
		renderCommand.ClearRenderTarget (true, true, Color.clear);
		for (int i = 0; i < silhouettes.Length; ++i) {
			renderCommand.DrawRenderer (silhouettes [i], silhouetteMaterial);
		}
	}

	void OnDisable ()
	{
		renderCommand.Clear ();
	}

	void OnDestroy ()
	{
		renderCommand.Clear ();
	}

	void OnRenderImage (RenderTexture src, RenderTexture dest)
	{
		//1. Draw Solid Color Silhouette
		silhouetteMaterial.SetColor ("_Color", outlineColor);

		RenderTexture mSolidSilhouette = RenderTexture.GetTemporary (Screen.width, Screen.height);
		Graphics.SetRenderTarget (mSolidSilhouette);
		Graphics.ExecuteCommandBuffer (renderCommand);

		//2. Downscale 4x
		RenderTexture mBlurSilhouette = RenderTexture.GetTemporary (Screen.width >> 2, Screen.height >> 2);
		Graphics.Blit (mSolidSilhouette, mBlurSilhouette, outlineMaterial, 0);



		//3. Blur
		RenderTexture blurTemp = RenderTexture.GetTemporary (Screen.width >> 2, Screen.height >> 2);
//		outlineMaterial.SetColor ("g_BlurScale", blurScale);
		//outlineMaterial.SetColor ("offsets", new Color (blurScale, blurScale, blurScale, blurScale));

		for (int i = 0; i < blurIterCount; ++i) {
			Graphics.Blit (mBlurSilhouette, blurTemp, outlineMaterial, 1);//horizontal blur
			Graphics.Blit (blurTemp, mBlurSilhouette, outlineMaterial, 2);//vertical blur
		}

		//4. Combine
		outlineMaterial.SetTexture ("g_SolidSilhouette", mSolidSilhouette);
		outlineMaterial.SetTexture ("g_BlurSilhouette", mBlurSilhouette);

		Graphics.Blit (src, dest, outlineMaterial, 3);

		//release RT
		RenderTexture.ReleaseTemporary (mSolidSilhouette);
		RenderTexture.ReleaseTemporary (mBlurSilhouette);
		RenderTexture.ReleaseTemporary (blurTemp);
	}
}