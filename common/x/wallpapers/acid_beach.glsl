
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec3 col;
    float t;
    
    for(int c=0;c<3;c++){
	    vec2 uv = (fragCoord*50.0-iResolution.xy)/iResolution.y;
        t = iTime;
        for(int i=0;i<10;i++)
        {
            uv /= 1.5;
            uv += sin(col.yx);
        	uv += float(i) + (sin(uv.x)*cos(uv.y)+sin(uv.y)*cos(iTime)+sin(iTime)*cos(uv.x));
        }
     col[c] = (sin(uv.x+uv.y+iTime));
	}
    
    fragColor = vec4(col,1.0);
    
}

