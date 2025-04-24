Shader "PGATR/Fishes"
{
    Properties
    {
        _PlaneSize ("Tamanno del Plano", Float) = 1.0
		_Color("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Textura", 2D) = "white" {}
        _SwingSpeed ("Swing Speed", Range(0, 10)) = 4
        _SwingIntensityEdge ("Swing Intensity Edge", Range(0, 1)) = 0.3
        _SwingIntensityMiddle ("Swing Intensity Middle", Range(0, 1)) = 0.2
        _FishHeight ("Fish Height", Range(0, 2)) = 1
    }

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "Autolight.cginc"
	
	////////////////////////////////////////////////////////////////////
    ///// GLOBALS
    ////////////////////////////////////////////////////////////////////
	float _PlaneSize;
    sampler2D _MainTex;
    float4 _Color;
    float _SwingSpeed;
    float _SwingIntensityEdge;
    float _SwingIntensityMiddle;
    float _FishHeight;

	////////////////////////////////////////////////////////////////////
    ///// STRUCTS
    ////////////////////////////////////////////////////////////////////
	struct	vertexInput
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float2 uv : TEXCOORD0;
	};

	struct	vertexOutput
	{
		float4 vertex : SV_POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float2 uv : TEXCOORD0;
	};

	struct	geometryOutput
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	////////////////////////////////////////////////////////////////////
    ///// AUX FUNCS
    ////////////////////////////////////////////////////////////////////
	float rand(float3 co)
	{
		return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
	}

	float3x3 AngleAxis3x3(float angle, float3 axis)
	{
		float c, s;
		sincos(angle, s, c);

		float t = 1 - c;
		float x = axis.x;
		float y = axis.y;
		float z = axis.z;

		return float3x3(
			t * x * x + c, t * x * y - s * z, t * x * z + s * y,
			t * x * y + s * z, t * y * y + c, t * y * z - s * x,
			t * x * z - s * y, t * y * z + s * x, t * z * z + c
			);
	}

	////////////////////////////////////////////////////////////////////
    ///// MAIN FUNCS
    ////////////////////////////////////////////////////////////////////
	vertexOutput vert(vertexInput v)
	{
		vertexOutput o;
		o.vertex = v.vertex;
		o.normal = v.normal;
		o.tangent = v.tangent;
		o.uv = v.uv;
		return o;
	}

	geometryOutput VertexOutput(float3 pos, float2 uv)
	{
		geometryOutput aux;
		aux.pos = UnityObjectToClipPos(pos);
		aux.uv = uv;
		return aux;
	}

	[maxvertexcount(8)]
	void geo(triangle vertexOutput IN[3], inout TriangleStream<geometryOutput> triStream)
	{
		float halfSize = _PlaneSize * 0.5;

		geometryOutput o;
		float3 pos = IN[0].vertex.xyz;
		
        float randomOffset = rand(pos); 
        float time = _Time.y + randomOffset * 6.28;

		float height = (randomOffset * 2.0 - 1.0) * _FishHeight;

        float y2 =  _PlaneSize + height;

        float swingEdge = sin(time * _SwingSpeed) * _SwingIntensityEdge - 0.03 ;
        float swingMiddle = sin(time * _SwingSpeed) * _SwingIntensityMiddle - 0.03 ;

		triStream.Append(VertexOutput(pos + float4(-halfSize, height, 0, 1), float2(0, 0)));
		triStream.Append(VertexOutput(pos + float4(-halfSize, y2, 0, 1), float2(0, 1)));
		
		triStream.Append(VertexOutput(pos + float4(0, height, swingMiddle, 1), float2(0.5, 0)));
		triStream.Append(VertexOutput(pos + float4(0, y2, swingMiddle, 1), float2(0.5, 1)));

		triStream.Append(VertexOutput(pos + float4(halfSize * 0.5, height, swingMiddle, 1), float2(0.75, 0)));
		triStream.Append(VertexOutput(pos + float4(halfSize * 0.5, y2, swingMiddle, 1), float2(0.75, 1)));
		triStream.Append(VertexOutput(pos + float4(halfSize, height, swingEdge, 1), float2(1,0)));
		triStream.Append(VertexOutput(pos + float4(halfSize, y2, swingEdge, 1), float2(1, 1)));

	}
		
	ENDCG

    SubShader
    {
		Cull Off
		Tags {"RenderType" = "Opaque" "LightMode" = "ForwardBase"}

        Pass
        {

            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #pragma geometry geo
			#pragma target 4.6

			float4 frag(geometryOutput i) : SV_Target {
				float4 color = tex2D(_MainTex, i.uv);
        
				if(color.a < 0.01)
				{
					discard;
				}
				return tex2D(_MainTex, i.uv);
			}

            ENDCG
        }
    }
}