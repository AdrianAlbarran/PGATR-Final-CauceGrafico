Shader "Custom/SeagullGeometry"
{
    Properties
    {
        _PlaneSize ("Tamaño del Plano", Float) = 1.0
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Textura", 2D) = "white" {}
        _FlapSpeed ("Flap Speed", Range(0, 1)) = 0.3
    }

    CGINCLUDE
	#include "UnityCG.cginc"
	#include "Autolight.cginc"
   
    ////////////////////////////////////////////////////////////////////
    ///// STRUCTS
    ////////////////////////////////////////////////////////////////////
    struct appData {
        float4 vertex : POSITION;
    };

    struct vert2geom {
        float4 pos : SV_POSITION;
    };

    struct geom2frag {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    ////////////////////////////////////////////////////////////////////
    ///// GLOBALS
    ////////////////////////////////////////////////////////////////////

    float _PlaneSize;
    sampler2D _MainTex;
    float4 _Color;
    float _FlapSpeed;


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

	vert2geom vert(appData vertex) : SV_POSITION
	{
        vert2geom o;
        o.pos = vertex.vertex;
		return o;
	}

    [maxvertexcount(4)]
    void geom(point vert2geom IN[1], inout TriangleStream<geom2frag> triStream)
    {
        // Vectores para billboarding
        float halfSize = _PlaneSize * 0.5;

        // Flap Animation
        // float randomSeed = length(mul(unity_ObjectToWorld, IN[0].pos).xyz);
        // float flapAngle = sin(_Time.y * _FlapSpeed + randomSeed * _RandomOffset) * _FlapIntensity * 0.5;

        geom2frag o;
        float3 pos = IN[0].pos.xyz; 
        // Generate all 4 vertex
        o.pos = UnityObjectToClipPos(pos + float4(halfSize, 0, 0, 1));
        o.uv = float2(0, 0);
        triStream.Append(o);

        o.pos = UnityObjectToClipPos(pos + float4(-halfSize, 0, 0, 1));
        o.uv = float2(1, 0);
        triStream.Append(o);

        o.pos = UnityObjectToClipPos(pos + float4(halfSize, _PlaneSize, 0, 1));
        o.uv = float2(0, 1);
        triStream.Append(o);

        o.pos = UnityObjectToClipPos(pos + float4(-halfSize, _PlaneSize, 0, 1));
        o.uv = float2(1, 1);
        triStream.Append(o);
    }

    float4 frag(geom2frag i) : SV_Target {
        float4 color = tex2D(_MainTex, i.uv);
        
        if(color.a < 0.01)
        {
            discard;
        }
        return tex2D(_MainTex, i.uv);
    }

    ENDCG

    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }

        


        Pass { 

            CGPROGRAM
            #pragma vertex   vert
            #pragma geometry geom
            #pragma fragment frag
			#pragma target 4.6
            

            ENDCG
        }
    }
}
