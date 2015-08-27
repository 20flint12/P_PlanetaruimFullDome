// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

float4x4 tWVP: WORLDVIEWPROJECTION;

texture Tex <string uiname="InkTexture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = linear;         //sampler states
    MinFilter = linear;
    MagFilter = linear;
};

float4 color : COLOR <String uiname="Color";>  = {1, 1, 1, 1};

float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    vs2ps Out;

	Out.Pos = mul(PosO, tWVP);
	Out.TexCd = mul(TexCd, tTex);

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
float2 vFlowDims;
float fRadius;
float2 mouse;
float init;

float gaussian(float d2, float radius)
{
  return exp(-d2 / radius);
}

float4 PS_flowAddImpulse(vs2ps In): COLOR
{
	mouse.y = 1-mouse.y;
    float2 pos = mouse - In.TexCd;	
	float4 tex = tex2D(Samp, In.TexCd);	
	float3 result = min(.8f, init * color.rgb * tex.rgb * gaussian(dot(pos, pos), fRadius));
	
	return float4(result.xyz,gaussian(dot(pos, pos), fRadius));
	
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TSimpleShader
{
    pass P0
    {
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_2_0 PS_flowAddImpulse();    	
    }
}

