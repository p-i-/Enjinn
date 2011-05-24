//
//  Shader.fsh
//  helloGL
//
//  Created by Pi on 17/02/2011.
//

// NOTE: could maybe optimize
// vec3 constantList = vec3(gem, sparkle, 0.0); 
// gl_FragColor = V1_color_RGBA.rgba * constantList.xxxz + constantList.zzzy;

precision mediump float;

// alpha-only textures of gem in dull & sparkling state
// images here: http://stackoverflow.com/questions/5833835/ios-smooth-button-glow-effect-by-blending-between-images
// gem from: http://www.turbosquid.com/FullPreview/Index.cfm/ID/253657
// blue & green: http://www.turbosquid.com/FullPreview/Index.cfm/ID/477361
// many cuts: http://www.turbosquid.com/FullPreview/Index.cfm?id=547841
// FREE: http://www.turbosquid.com/FullPreview/Index.cfm/ID/554455

uniform lowp sampler2D U1_sampId_Gem;             
uniform lowp sampler2D U2_sampId_Sparkle;             

// 0 => no-glow, 1 => full glow
uniform mediump float U3_glowFactor;

varying mediump vec2 V0_texture_ST;   
varying mediump	vec4 V1_color_RGBA;                

void main( void )                       
{    
    float GEM       = texture2D( U1_sampId_Gem,     V0_texture_ST ).a;
    float SPARKLE   = texture2D( U2_sampId_Sparkle, V0_texture_ST ).a;
    
    float FAC       = SPARKLE * U3_glowFactor  +  GEM * ( 1. - U3_glowFactor ) ;
    
    // WORKS NICELY
    gl_FragColor.rgb = V1_color_RGBA.rgb * FAC  +  .4 * SPARKLE * U3_glowFactor ;
    gl_FragColor.a  = ( SPARKLE > 0.03 ) ? 1. : 0.;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


    //sparkle *= U3_glowFactor;
    
    //sparkle = .5;
    
    //    // move gem colour towards white everywhere it sparkles
    //    gl_FragColor.rgb = V1_color_RGBA.rgb * gem  +  0.6 * sparkle;
    //    
    //    // if gem > 0.,  this pixel is in the body of the gem, ie totally opaque
    //    //  otherwise, there is some chance of catching some glow/sparkle nearby the perimeter
    //    gl_FragColor.a = ( gem > 0.05 ) ? 1. : sparkle ;
    
    
//    vec3 rgb = V1_color_RGBA.rgb; 
//    float alph = 1.;
//    
//    // interpolate between "if not-glowing, fac = gem" & "if glowing, fac = sparkle"
//    float fac = sparkle * U3_glowFactor  +  gem * ( 1. - U3_glowFactor ) ;
//    rgb *= fac;
//    
//    // move gem colour towards white everywhere it sparkles (move more, the more it is glowing)
//    rgb +=  .4 * sparkle * U3_glowFactor;
//    
//    // solid fill i.e. totally opaque
//    alph = 1.;
    
//#define THRESH .03
//    
//    // WORKS NICELY
//    gl_FragColor.rgb = V1_color_RGBA.rgb * fac  +  .4 * sparkle * U3_glowFactor;
//    gl_FragColor.a  = (/*gem > THRESH || */ sparkle > THRESH) ? 1. : 0.;
    
    //    // bleh
//    if (fac > THRESH)
//    {
//        gl_FragColor.rgb = V1_color_RGBA.rgb * fac  +  .4 * sparkle * U3_glowFactor;
//        gl_FragColor.a  = 1.;
//    }
//    else
//    {
//        gl_FragColor.rgb = V1_color_RGBA.rgb  +  .4 * sparkle * U3_glowFactor;
//        gl_FragColor.a  = fac;
//    }
//}
//
//void main( void )                       
//{    
//    float gem       = texture2D(  U1_sampId_Gem,      V0_texture_ST ).a;
//    float sparkle   = texture2D(  U2_sampId_Sparkle,  V0_texture_ST ).a;
//    
//    sparkle *= U3_glowFactor;
//    
//    //sparkle = .5;
//    
//    //    // move gem colour towards white everywhere it sparkles
//    //    gl_FragColor.rgb = V1_color_RGBA.rgb * gem  +  0.6 * sparkle;
//    //    
//    //    // if gem > 0.,  this pixel is in the body of the gem, ie totally opaque
//    //    //  otherwise, there is some chance of catching some glow/sparkle nearby the perimeter
//    //    gl_FragColor.a = ( gem > 0.05 ) ? 1. : sparkle ;
//    
//    
//    vec3 rgb; float alph;
//    
//    // if inside gem OR on antialiased edge...
//    if (gem > 0.015)
//    {
//        float fac = sparkle * ( U3_glowFactor )  +  gem * ( 1. - U3_glowFactor ) ;
//        
//        // move gem colour towards white everywhere it sparkles
//        rgb = V1_color_RGBA.rgb * fac  +  .4 * sparkle;
//        
//        // solid fill i.e. totally opaque
//        alph = 1.;
//    }
//    else
//    {
//        rgb = V1_color_RGBA.rgb * ( gem  +  2. * sparkle );
//        alph = sparkle * 3.;
//    }
//    
//    gl_FragColor.rgb = rgb;
//    gl_FragColor.a  = alph;
//}

