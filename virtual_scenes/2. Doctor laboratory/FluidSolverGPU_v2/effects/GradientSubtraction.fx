// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

float4x4 tWVP: WORLDVIEWPROJECTION;

texture VTex <string uiname="Velocity";>;
sampler velocity = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (VTex);          //apply a texture to the sampler
    MipFilter = point;         //sampler states
    MinFilter = point;
    MagFilter = point;
	AddressU = clamp;
	AddressV = clamp;
};

texture PTex <string uiname="Pressure";>;
sampler pressure = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (PTex);          //apply a texture to the sampler
    MipFilter = point;         //sampler states
    MinFilter = point;
    MagFilter = point;
	AddressU = clamp;
	AddressV = clamp;
};

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

	PosO.xy *= 2;
	Out.Pos = mul(PosO, tWVP);
	Out.TexCd = mul(TexCd, tTex);

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
float2 vFlowDims;

float4 PS_flowGradient(vs2ps In): COLOR
{
  	float pL = tex2D(pressure, float2(In.TexCd.x - 1./vFlowDims.x, In.TexCd.y)).x; 
  	float pR = tex2D(pressure, float2(In.TexCd.x + 1./vFlowDims.x, In.TexCd.y)).x; 
  	float pB = tex2D(pressure, float2(In.TexCd.x, In.TexCd.y - 1./vFlowDims.y)).x; 
  	float pT = tex2D(pressure, float2(In.TexCd.x, In.TexCd.y + 1./vFlowDims.y)).x; 

  	float2 grad = float2(pR - pL, pT - pB) * 0.5;

  	float4 v = tex2D(velocity, In.TexCd);
  	v.xy -= grad;
	
  	return v;
	
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique GradientSubtraction
{
    pass P0
    {       
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_2_0 PS_flowGradient();
  	 	alphablendenable = false;    	
    } 
}

