// this is a very basic template. use it to start writing your own effects.
// if you want effects with lighting start from one of the GouraudXXXX or PhongXXXX effects

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------
float4x4 tWVP: WORLDVIEWPROJECTION;
struct vs2ps
{
   float4 Pos: POSITION;
   float4 TexCd: TEXCOORD0;
};
float focus = 0;
float dof = 1;

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS_ZBuffer(float4 Pos: POSITION)
{
   vs2ps Out = (vs2ps) 0;
   Out.Pos = mul(Pos, tWVP);
   Out.TexCd = Out.Pos;
   
   return Out;
}


// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
struct col2 {
	float4 c1 : COLOR;
	float4 c2 : COLOR1;
};
col2 PS(vs2ps In)
{
	col2 c;
    float aio = abs(In.TexCd.z-focus)*dof;
    float frg0 = max(-1*(In.TexCd.z-focus)*dof,0);
	c.c2 = float4(aio.xxx, 1);
	c.c1 = float4(frg0.xxx, 1);
    return c;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique AllInOne
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS_ZBuffer();
        PixelShader  = compile ps_3_0 PS();
    }
}
