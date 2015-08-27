// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

float4x4 tWVP: WORLDVIEWPROJECTION;

//texture
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

float4 PS_flowDivergence(vs2ps In): COLOR
{
   float4 vL = tex2D(velocity, float2(In.TexCd.x - 1./vFlowDims.x, In.TexCd.y)); 
   float4 vR = tex2D(velocity, float2(In.TexCd.x + 1./vFlowDims.x, In.TexCd.y)); 
   float4 vB = tex2D(velocity, float2(In.TexCd.x, In.TexCd.y - 1./vFlowDims.y)); 
   float4 vT = tex2D(velocity, float2(In.TexCd.x, In.TexCd.y + 1./vFlowDims.y)); 
   return 0.5 * ((vR.x - vL.x) + (vT.y - vB.y));
	
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique Divergence
{
    pass P0
    {        
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_2_0 PS_flowDivergence();
    	alphablendenable = false;    	
    }
}

