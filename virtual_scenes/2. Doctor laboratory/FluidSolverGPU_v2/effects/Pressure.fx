// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

float4x4 tWVP: WORLDVIEWPROJECTION;

texture DivTex <string uiname="Divergence";>;
sampler divergence = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (DivTex);          //apply a texture to the sampler
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

	Out.Pos = mul(PosO, tWVP);
	Out.TexCd = mul(TexCd, tTex);
	
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
float2 vFlowDims;


float4 PS_flowPressure(vs2ps In): COLOR
{

  	float bCenter = tex2D(divergence, In.TexCd).x;

  	float xL = tex2D(pressure, float2(In.TexCd.x - 1./vFlowDims.x, In.TexCd.y)).x; 
  	float xR = tex2D(pressure, float2(In.TexCd.x + 1./vFlowDims.x, In.TexCd.y)).x; 
  	float xB = tex2D(pressure, float2(In.TexCd.x,     In.TexCd.y - 1./vFlowDims.y)).x; 
  	float xT = tex2D(pressure, float2(In.TexCd.x,     In.TexCd.y + 1./vFlowDims.y)).x; 
  
	float result = (xL + xR + xB + xT - bCenter) * 0.25;
	
	return result;
	
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique Pressure
{
    pass P0
    {        
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_2_0 PS_flowPressure();
    	alphablendenable = false;    	
    }
}

