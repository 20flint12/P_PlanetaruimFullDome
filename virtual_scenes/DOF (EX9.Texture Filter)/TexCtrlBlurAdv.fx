//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (EX9)
float4x4 tWVP: WORLDVIEWPROJECTION;

float blur <string uiname="Blur Amount";> =0.0250;
float bal  <string uiname="Brightness Balance";> =0.0000;






texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};


texture ctTex <string uiname="Control Texture";>;
sampler ctSamp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (ctTex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos : POSITION;
    float4 TexCd : TEXCOORD0;
};


// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

vs2ps VS(
    float4 Pos : POSITION,
    float4 TexCd : TEXCOORD0)
{
    vs2ps Out = (vs2ps)0;
    Out.Pos = mul(Pos, tWVP);
    Out.TexCd = mul(TexCd, tTex);
    return Out;
}
// PIXELSHADERS:
//------------------------------------------------------------
float4 showorig(vs2ps In): COLOR
{
   float4 orig = tex2D(Samp, In.TexCd);
   return orig;
}
//------------------------------------------------------------
float4 showct(vs2ps In): COLOR
{
   float4 ctrl = tex2D(ctSamp, In.TexCd);
   return ctrl;
}
//------------------------------------------------------------
float4 blackblur(vs2ps In): COLOR
{
   float4 col = tex2D(Samp, In.TexCd);
   float4 orig = col;
   float4 ctrl = tex2D(ctSamp, In.TexCd);
   half2 offset[13] =
   {    0,     0, -0.75,-0.75,   -1,     0, -0.75, 0.75,
        0,    -1,     0,    1, 0.75, -0.75,     1,    0,
     0.75,  0.75,  -1.6,    0,  1.6,     0,     0, -1.6,
        0,   1.6
   };
   int weight[13] = {4, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1};
    col.rgb = 0;
    blur /= 2;

    for(int i=0; i<13; i++)
    {
    col += tex2D(Samp, In.TexCd + offset[i] * blur * (1-ctrl)) * weight[i] / 21;
    }
    //col= col *(1-ctrl)*(1-bal) + orig * ctrl*(1+bal);
   return col;
}
//------------------------------------------------------------
float4 whiteblur(vs2ps In): COLOR
{
   float4 col = tex2D(Samp, In.TexCd);
   float4 orig = col;
   float4 ctrl = tex2D(ctSamp, In.TexCd);
   half2 offset[13] =
   {    0,     0, -0.75,-0.75,   -1,     0, -0.75, 0.75,
        0,    -1,     0,    1, 0.75, -0.75,     1,    0,
     0.75,  0.75,  -1.6,    0,  1.6,     0,     0, -1.6,
        0,   1.6
   };
   int weight[13] = {4, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1};
    col.rgb = 0;
    blur /= 2;
    for(int i=0; i<13; i++)
    {
    col += tex2D(Samp, In.TexCd + offset[i] * blur * ctrl) * weight[i] / 21;
    }
    //col= col * ctrl * (1+bal) + orig * (1-ctrl)*(1-bal);
   return col;
}
//---------------------------------------------------------------------
float4 blackblur_2a(vs2ps In): COLOR
{
   float4 col = tex2D(Samp, In.TexCd);
   float4 orig = col;
   float4 ctrl = tex2D(ctSamp, In.TexCd);

   half2 offset[24] =
   {
 0.5000, 0.0000, 0.4830, 0.1294, 0.4330, 0.2500, 0.3536, 0.3536,
 0.2500, 0.4330, 0.1294, 0.4830, 0.0000, 0.5000,-0.1294, 0.4830,
-0.2500, 0.4330,-0.3536, 0.3536,-0.4330, 0.2500,-0.4830, 0.1294,
-0.5000, 0.0000,-0.4830,-0.1294,-0.4330,-0.2500,-0.3536,-0.3536,
-0.2500,-0.4330,-0.1294,-0.4830, 0.0000,-0.5000, 0.1294,-0.4830,
 0.2500,-0.4330, 0.3536,-0.3536, 0.4330,-0.2500, 0.4830,-0.1294,
   };

   half weight[24] =
   {
       2,1,2,1,2,1,2,1,
       2,1,2,1,2,1,2,1,
       2,1,2,1,2,1,2,1,

   };
   
    col.rgb = 0;

    for(int i=0; i<24; i++)
    {

   col += tex2D(Samp, In.TexCd + offset[i] * blur * (1-ctrl)) *weight[i] / 36;  // divide through sum of all weights
             
    }
    //col= col *(1-ctrl)*(1-bal) + orig * ctrl*(1+bal);
   return col;
}
//------------------------------------------------------------
float4 whiteblur_2a(vs2ps In): COLOR
{
   float4 col = tex2D(Samp, In.TexCd);
   float4 orig = col;
   float4 ctrl = tex2D(ctSamp, In.TexCd);

   half2 offset[24] =
   {
 0.5000, 0.0000, 0.4830, 0.1294, 0.4330, 0.2500, 0.3536, 0.3536,
 0.2500, 0.4330, 0.1294, 0.4830, 0.0000, 0.5000,-0.1294, 0.4830,
-0.2500, 0.4330,-0.3536, 0.3536,-0.4330, 0.2500,-0.4830, 0.1294,
-0.5000, 0.0000,-0.4830,-0.1294,-0.4330,-0.2500,-0.3536,-0.3536,
-0.2500,-0.4330,-0.1294,-0.4830, 0.0000,-0.5000, 0.1294,-0.4830,
 0.2500,-0.4330, 0.3536,-0.3536, 0.4330,-0.2500, 0.4830,-0.1294,
   };

   half weight[24] =
   {
       2,1,2,1,2,1,2,1,
       2,1,2,1,2,1,2,1,
       2,1,2,1,2,1,2,1,

   };

    col.rgb = 0;

    for(int i=0; i<24; i++)
    {

   col += tex2D(Samp, In.TexCd + offset[i] * blur * ctrl) *weight[i] / 36;  // divide through sum of all weights

    }
    //col= col * ctrl * (1+bal) + orig * (1-ctrl)*(1-bal);
   return col;
}

//---------------------------------------------------------------------
float4 blackspiral(vs2ps In): COLOR
{
   float4 col = tex2D(Samp, In.TexCd);
   float4 orig = col;
   float4 ctrl = tex2D(ctSamp, In.TexCd);

   half2 offset[24] =
         {
          0.0101, 0.0027, 0.0221, 0.0221, 0.0135, 0.0503,-0.0189, 0.0704,
         -0.0663, 0.0663,-0.1107, 0.0297,-0.1308,-0.0350,-0.1105,-0.1105,
         -0.0458,-0.1710, 0.0512,-0.1912, 0.1547,-0.1547, 0.2314,-0.0620,
          0.2515, 0.0674, 0.1989, 0.1989, 0.0782, 0.2918,-0.0836, 0.3119,
         -0.2431, 0.2431,-0.3522, 0.0944,-0.3723,-0.0998,-0.2873,-0.2873,
         -0.1105,-0.4125, 0.1159,-0.4327, 0.3315,-0.3315, 0.4729,-0.1267,
         };

   half weight[24] =
   {
      8, 8, 8, 7, 7, 7, 6, 6,
      6, 5, 5, 5, 4, 4, 4, 3,
      3, 3, 2, 2, 2, 2, 2, 2,

   };

    col.rgb = 0;
    blur *= 2;
    for(int i=0; i<24; i++)
    {
   col += tex2D(Samp, In.TexCd + offset[i] * blur * (1-ctrl)) *weight[i] / 111;  // divide through sum of all weights
    }
    //col= col *(1-ctrl)*(1-bal) + orig * ctrl*(1+bal);
   return col;
}
//------------------------------------------------------------
float4 whitespiral(vs2ps In): COLOR
{
   float4 col = tex2D(Samp, In.TexCd);
   float4 orig = col;
   float4 ctrl = tex2D(ctSamp, In.TexCd);

   half2 offset[24] =
   {
     0.0101, 0.0027, 0.0221, 0.0221, 0.0135, 0.0503,-0.0189, 0.0704,
    -0.0663, 0.0663,-0.1107, 0.0297,-0.1308,-0.0350,-0.1105,-0.1105,
    -0.0458,-0.1710, 0.0512,-0.1912, 0.1547,-0.1547, 0.2314,-0.0620,
     0.2515, 0.0674, 0.1989, 0.1989, 0.0782, 0.2918,-0.0836, 0.3119,
    -0.2431, 0.2431,-0.3522, 0.0944,-0.3723,-0.0998,-0.2873,-0.2873,
    -0.1105,-0.4125, 0.1159,-0.4327, 0.3315,-0.3315, 0.4729,-0.1267,
   };

   half weight[24] =
        {
        8, 8, 8, 7, 7, 7, 6, 6,
        6, 5, 5, 5, 4, 4, 4, 3,
        3, 3, 2, 2, 2, 2, 2, 2,
        };

    col.rgb = 0;
    blur *= 2;
    for(int i=0; i<24; i++)
    {

   col += tex2D(Samp, In.TexCd + offset[i] * blur * ctrl) *weight[i] / 111;  // divide through sum of all weights

    }
    //col= col * ctrl * (1+bal) + orig * (1-ctrl)*(1-bal);
   return col;
}
 //---------------------------------------------------------------------
float4 gausblackspiral(vs2ps In): COLOR
{
   float4 col = tex2D(Samp, In.TexCd);
   float4 orig = col;
   float4 ctrl = tex2D(ctSamp, In.TexCd);

   half2 offset[24] =
         {
         -0.4359, 0.1607, 0.1664, 0.5123, 0.3133, 0.3036,-0.1008, 0.4993,
         -0.3530, 0.1366, 0.3797, 0.2241, 0.1543,-0.3514, 0.1237, 0.4231,
          0.0219,-0.2624,-0.4057, 0.0491, 0.0495, 0.4009,-0.3441, 0.0879,
          0.0414, 0.1031, 0.5815,-0.0840, 0.4988,-0.2451, 0.0952, 0.2564,
         -0.3005,-0.3880,-0.1673, 0.0923, 0.0785,-0.5410,-0.2227,-0.0161,
          0.3025,-0.1511, 0.2928, 0.1136, 0.0747,-0.3719,-0.0444, 0.2673,
         };

    col.rgb = 0;

    for(int i=0; i<24; i++)
    {
   col += tex2D(Samp, In.TexCd + offset[i] * blur * (1-ctrl))  / 24;  // divide through sum of all weights
    }
    //col= col *(1-ctrl)*(1-bal) + orig * ctrl*(1+bal);
   return col;
}
//------------------------------------------------------------
float4 gauswhitespiral(vs2ps In): COLOR
{
   float4 col = tex2D(Samp, In.TexCd);
   float4 orig = col;
   float4 ctrl = tex2D(ctSamp, In.TexCd);

   half2 offset[24] =
         {
         -0.4359, 0.1607, 0.1664, 0.5123, 0.3133, 0.3036,-0.1008, 0.4993,
         -0.3530, 0.1366, 0.3797, 0.2241, 0.1543,-0.3514, 0.1237, 0.4231,
          0.0219,-0.2624,-0.4057, 0.0491, 0.0495, 0.4009,-0.3441, 0.0879,
          0.0414, 0.1031, 0.5815,-0.0840, 0.4988,-0.2451, 0.0952, 0.2564,
         -0.3005,-0.3880,-0.1673, 0.0923, 0.0785,-0.5410,-0.2227,-0.0161,
          0.3025,-0.1511, 0.2928, 0.1136, 0.0747,-0.3719,-0.0444, 0.2673,
         };

    col.rgb = 0;

    for(int i=0; i<24; i++)
    {
   col += tex2D(Samp, In.TexCd + offset[i] * blur * ctrl)/24;  // divide through sum of all weights
    }
    //col= col * ctrl * (1+bal) + orig * (1-ctrl)*(1-bal);
   return col;
}
 //---------------------------------------------------------------------
// TECHNIQUES:
technique ShowControlTextureOnly
{
    pass P0
    {
        WorldTransform[0]   = (tW);
        ViewTransform       = (tV);
        ProjectionTransform = (tP);

        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 showct();
    }


}
technique SimpleBlurWhite
{
    pass P0
    {
        WorldTransform[0]   = (tW);
        ViewTransform       = (tV);
        ProjectionTransform = (tP);

        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 whiteblur();
    }


}
technique RadialBlurWhite
{
    pass P0
    {
        WorldTransform[0]   = (tW);
        ViewTransform       = (tV);
        ProjectionTransform = (tP);

        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 whiteblur_2a();
    }


}
technique SpiralBlurWhite
{
    pass P0
    {
        WorldTransform[0]   = (tW);
        ViewTransform       = (tV);
        ProjectionTransform = (tP);

        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 whitespiral();
    }


}
technique GaussianSpiralBlurWhite
{
    pass P0
    {
        WorldTransform[0]   = (tW);
        ViewTransform       = (tV);
        ProjectionTransform = (tP);

        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 gauswhitespiral();
    }


}
