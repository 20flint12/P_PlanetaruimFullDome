// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------
//transforms
float4x4 tWVP: WORLDVIEWPROJECTION;

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
float2 MousePos;
float2 LastMousePos;
int init;

float gaussian(float d2, float radius)
{
  return exp(-d2 / radius);
}

float4 PS_flowAddImpulse(vs2ps In): COLOR
{
	MousePos.y = 1-MousePos.y;
	LastMousePos.y = 1-LastMousePos.y;
	float3 mouseVector = float3(vFlowDims.xy,1) * float3( ( MousePos.x - LastMousePos.x ), ( MousePos.y) - LastMousePos.y, 1 ); 
  	mouseVector = -max(-1., min(1., mouseVector));	
    float2 pos = MousePos - In.TexCd;
	float3 result = min(.8f,init * mouseVector.xyzz * gaussian(dot(pos, pos), fRadius));
	
	return float4(result.xyz*1,gaussian(dot(pos, pos), fRadius));
	
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique AddVelocity
{
    pass P0
    {        
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_2_0 PS_flowAddImpulse();    
    }
}

