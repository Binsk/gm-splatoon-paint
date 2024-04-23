varying vec2 v_vTexcoord;

uniform vec3 u_vColorA;  // Team A color
uniform vec3 u_vColorB;  // Team B color

void main()
{
    int iTeam = int(texture2D(gm_BaseTexture, v_vTexcoord).r * 2.f);
    vec4 vColor = vec4(0, 0, 0, 0);
    if (iTeam > 0){ // If 0, no team was specified; only blend if there is a team
        if (iTeam == 1)
            vColor.rgb = u_vColorA;
        else
            vColor.rgb = u_vColorB;
        
        vColor.a = 1.0;
    }
    gl_FragColor = vColor;
}
