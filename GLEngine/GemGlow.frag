//
//  Shader.fsh
//  helloGL
//
//  Created by Pi on 17/02/2011.
//


precision mediump float;

// alpha-only textures of gem in dull & sparkling state
// images here: 
// http://stackoverflow.com/questions/5833835/ios-smooth-button-glow-effect-by-blending-between-images
//
uniform lowp sampler2D U1_sampId_Gem;             
uniform lowp sampler2D U2_sampId_Sparkle;             

// 0 => no-glow, 1 => full glow
uniform mediump float U3_glowFactor;

varying mediump vec2 V0_texture_ST;   
varying mediump	vec4 V1_color_RGBA;                

void main( void )                       
{    
    float gem       = texture2D(  U1_sampId_Gem,      V0_texture_ST ).a;
    float sparkle   = texture2D(  U2_sampId_Sparkle,  V0_texture_ST ).a;
        
    sparkle *= U3_glowFactor;
    
    //sparkle = .5;

//    // move gem colour towards white everywhere it sparkles
//    gl_FragColor.rgb = V1_color_RGBA.rgb * gem  +  0.6 * sparkle;
//    
//    // if gem > 0.,  this pixel is in the body of the gem, ie totally opaque
//    //  otherwise, there is some chance of catching some glow/sparkle nearby the perimeter
//    gl_FragColor.a = ( gem > 0.05 ) ? 1. : sparkle ;
    

    vec3 rgb; float alph;
    
    if (gem > 0.05)
    {
        // inside gem
        float fac = sparkle * ( U3_glowFactor )  +  gem * ( 1. - U3_glowFactor ) ;
        
        //float fac = gem * ( 1. - glow_factor/2.) ;
        rgb = V1_color_RGBA.rgb * fac + sparkle * .4;
        alph = 1.;
//        rgb = vec3(0.);
//        alph = 0.;
    }
    else
    {
       rgb = V1_color_RGBA.rgb * 3.; // rgb = vec3(1);
       alph = sparkle * 3.;
    }
    
    gl_FragColor.rgb = rgb;
    gl_FragColor.a  = alph;
    
    //test : gl_FragColor = vec4( sparkle );
    
    // could maybe optimize
    //vec3 constantList = vec3(gem, sparkle, 0.0); 
    //gl_FragColor = V1_color_RGBA.rgba * constantList.xxxz + constantList.zzzy;
}

