// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

float4x4 tWVP: WORLDVIEWPROJECTION;

//texture
texture VTex <string uiname="Velocity";>;
sampler velocity = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (VTex);          //apply a texture to the sampler
    MipFilter = linear;         //sampler states
    MinFilter = linear;
    MagFilter = linear;
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
float dissipation;
float timestep;

float4 PS_flowAdvect(vs2ps In): COLOR
{
  	
	float2 pos    = In.TexCd;
  	float4 v      = tex2D(velocity, pos); 
  	pos += timestep * v.xy / vFlowDims;
  	float4 newValue = tex2D(velocity, pos);  
	newValue *= dissipation;	
	
	return newValue;
	
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique Advection
{
    pass P0
    {        
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_2_0 PS_flowAdvect();
    	alphablendenable = false;    	
    }
}

