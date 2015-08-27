
// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

float4x4 tWVP: WORLDVIEWPROJECTION;

//texture
texture FTex <string uiname="FlowTexture";>;
sampler FSamp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (FTex);          //apply a texture to the sampler
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
float scale;

float4 PS(vs2ps In): COLOR
{
   
  	float2 tc = In.TexCd;
     if(tc.x <  1.0f/vFlowDims.x)
        tc.x += 1.0/vFlowDims.x;
     else if(tc.y < 1.0f/vFlowDims.y)
        tc.y += 1.0f/vFlowDims.y;
     else if(tc.x >  (vFlowDims.x - 1.0f)/vFlowDims.x)
        tc.x -= 1.f/vFlowDims.x;
     else if(tc.y >  (vFlowDims.y - 1.0f)/vFlowDims.y)
        tc.y -= 1.f/vFlowDims.y;
     else
        clip(-1.);     
	
	return scale * tex2D(FSamp, tc);
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique BoundaryConditions
{
    pass P0
    {        
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_2_0 PS();
    	Alphablendenable = false;    	
    }
	
}

