float4 Light1_Color; float Velvet_Exponent; float PI;
float rho_pi;
float A;
float B;
float4 Light_Velvet(float3 Normal, float3 EyeVect, float3 LightDir, float4 LightColor)
{
// calculate all the dot products float NdotL = dot(Normal, LightDir); float NdotE = dot(Normal, EyeVect);
// calculate the zenith angles
float sinTheta_r = length(cross(EyeVect,Normal)); float cosTheta_r = max(NdotE,0.001);
float sinTheta_i = length(cross(LightDir,Normal)); float cosTheta_i = max(NdotL,0.001);
float tanTheta_i = sinTheta_i / cosTheta_i;
float tanTheta_r = sinTheta_r / cosTheta_r;
// calculate the azimuth angles
float3 E_p = normalize(EyeVect-NdotE*Normal); float3 L_p = normalize(LightDir-NdotL*Normal); float cosAzimuth = dot(E_p, L_p);
// Compute final lighting
float inten = rho_pi * cosTheta_i *(A + B * max(0, cosAzimuth) * max(sinTheta_r, sinTheta_i) * min(tanTheta_i, tanTheta_r)); 
return LightColor * clamp(inten,0,1);
}
