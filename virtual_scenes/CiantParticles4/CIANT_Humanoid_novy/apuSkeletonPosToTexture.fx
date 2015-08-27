// SkinnedMesh.fx
// Effect processing for skinned mesh
// from SlimDX


static const int MaxMatrices = 60;
float usedMatrices = 60;
float4x4 tW: WORLD;
float4x4 tVP : VIEWPROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

float vertexCount;
float vertexCountXCorrection = 2;;
float4x4 SkinningMatrices[MaxMatrices];



struct VSInput
{
	float4 Position			: POSITION;
	float4 BlendWeights		: BLENDWEIGHT;
	int4   BlendIndices		: BLENDINDICES;
	float3 Normal			: NORMAL;
	float3 TextureCoordinates	: TEXCOORD0;
	float3 VertexIndex		: TEXCOORD1;
};

struct VSOutput
{
	float4 Position			: POSITION;
	float4 Color			: COLOR0;
	//float4 Diffuse			: COLOR0;
	float2 TextureCoordinates	: TEXCOORD0;

};


VSOutput VS(VSInput input)
{
	VSOutput output = (VSOutput)0;

        //---------- Skinning ----------
	float4 blendWeights = input.BlendWeights;
	int4 indices = input.BlendIndices;
	//float indices = input.VertexIndex;
	float4 pos = 0; float3 norm = 0;
	
    for (int i = 0; i < 1; i++)   // only one, because of rigid skinning!
    {
        pos = pos + mul(input.Position, SkinningMatrices[indices[i]]) * blendWeights[i];
    	norm = norm + mul(input.Normal, SkinningMatrices[indices[i]]) * blendWeights[i];
    }
        //---------- InfoPixel Position ----------

	norm = normalize(norm);	// normal is not used
	pos.w= 1; pos.y-=5;
	//pos.x = indices[0]/15.0;
	//pos.y = 0;
	float4 pixelPosition=0;
	//pixelPosition.x=-1.0+2.0*indices[0]/(usedMatrices-1);
	float vertexCountSqrt = sqrt(vertexCount);
	pixelPosition.x=-1.0+vertexCountXCorrection* floor(input.VertexIndex/vertexCountSqrt)/vertexCountSqrt;
	pixelPosition.y=-1.0+2*(input.VertexIndex%vertexCountSqrt)/vertexCountSqrt;
	//pixelPosition.x=-1.0+2.6* floor(input.VertexIndex/100)/50;
	//pixelPosition.y=-1.0+(input.VertexIndex%100.0)/50.0;
	pixelPosition.w=1;
	output.Position = pixelPosition;
	output.Color = pos/10.0;
	output.Color.y +=0.5;
	//output.Color = float4(.7,.7,.7,5);
	//output.Color = float4(indices/15.0);//,indices/10.0,indices/10.0,indices/10.0);
	//output.Color.x = float(indices[0]/15.0);
	output.Color.a = 1;
	
	
	//output.Position = mul(pos, tWVP);
	//output.Diffuse.xyz = MaterialAmbient.xyz +  MaterialDiffuse.xyz;
	//output.Diffuse.w = 1.0f;
	output.TextureCoordinates = input.TextureCoordinates.xy;
/**/
	return output;
}

/*
float invlerp (float x, float SourceMin, float SourceMax)
{return (x - SourceMin) / (SourceMax - SourceMin);}
float3 invlerp (float3 x, float SourceMin, float SourceMax)
{return (x - SourceMin) / (SourceMax - SourceMin);}
*/

float4 PS(VSOutput pixelIN)  : COLOR
{

    //float4 col = tex2D(Samp, pixelIN.TextureCoordinates);
    //return mul(col, tColor);
    float4 col = pixelIN.Color;
	col.xyz *= 10.0;
    return col;
}

technique SkinnedMesh
{
	pass P0
	{
		//SetRenderState();
		VertexShader = compile vs_3_0 VS();
		FillMode = Point;
		PointSize = 5;
		PixelShader = compile ps_3_0 PS();
	}
}
