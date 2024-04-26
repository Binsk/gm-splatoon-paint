uniform vec3 u_vColor;

varying vec2 v_vTexcoord;

void main()
{
    gl_FragColor = vec4(u_vColor.rgb, 1.0) * texture2D( gm_BaseTexture, v_vTexcoord );
}
