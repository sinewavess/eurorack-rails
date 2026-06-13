//                                    __ __        
//                       .----.---.-.|__|  |.-----.
//                       |   _|  _  ||  |  ||__ --|
//                       |__| |___._||__|__||_____|                    
//   parametric eurorack rails made in openscad (https://openscad.org/)
//                               MIT license                             


// TODO: clean up the code. the model works fine so i will probably not do that.


// _  _ ____ ____ _ ____ ___  _    ____ ____ 
// |  | |__| |__/ | |__| |__] |    |___ [__  
//  \/  |  | |  \ | |  | |__] |___ |___ ___] 

// please use factors of the width for the number of divisions

width           = 84;   // total width of the rails, in HP

divisions       = 3;    // number of parts to divide the rail in
dividers        = 1;    // 1: dovetail connectors, 2: simple cuts 
spacing         = 5;    // space between the segments of the rail 

screws          = 3;    // diameter of the front screw holes (M3)
sscrews         = 5;    // diameter of the side screw holes (M5)
ssdepth         = 40;   // depth of the side screws holes

notch_depth     = 2.8;  // depth of the notch above the front holes 
notch_height    = 1.7;  // height of the notch

dovetail_width  = 7;    // short side of the dovetail connector
dovetail_width2 = 12;   // long side of the dovetail connector
dovetail_lenght = 11;   // depth of the dovetail connector 


hp              = 5.08; // equivalent of 1mm in hp
depth           = 27.4; // total depth of the rail without the notch
height          = 10;   // total height of the rail


$fn = 128; // circle resolution

segment_width = width / divisions; // total width of each segment in hp
swidthmm = segment_width * hp;     // total width of each segment in mm
widthmm = width * hp;              // total width of the rail in mm




// _  _ ____ ___  _  _ _    ____ ____ 
// |\/| |  | |  \ |  | |    |___ [__  
// |  | |__| |__/ |__| |___ |___ ___] 

// rail itself
module rail() {
    difference(){
    
        // base
        cube([swidthmm, depth, height]);
        
        // holes
        translate([hp / 2, depth + 0.5, height / 2]) {
            rotate([90, 0, 0]){
                for (i = [0 : segment_width - 1]) {
                    translate([i * hp, 0, 0])
                        cylinder(r = screws / 2, h = depth + 1);
                }
            }
        }   
    }
    
    // top notch
    translate([0, - notch_depth, height - notch_height]) {
        cube([swidthmm, notch_depth, notch_height]);
    }
}


// dovetail connectors
module dovetail(dvheight) {
    linear_extrude(height = dvheight)
        polygon(points = [
            [0, 0],
            [dovetail_width, 0],
            [( dovetail_width + dovetail_width2 ) / 2, dovetail_lenght],
            [( dovetail_width - dovetail_width2 ) / 2, dovetail_lenght]
        ]);
}


// _  _ ____ _ _  _    ___  ____ ____ ___ 
// |\/| |__| | |\ |    |__] |__| |__/  |  
// |  | |  | | | \|    |    |  | |  \  |  

// screw / dovetail subtraction
difference() {

    // rail segment(s) creation
    for (n = [0 : divisions - 1]) {
        translate([0, n * ( depth + notch_depth + spacing ), 0]) {
            rail();
        }
    }

    // side screw 1
    translate([-1, depth / 2, height / 2]) {
        rotate([90, 0, 90]) {
            cylinder(h = ssdepth + 1, r = sscrews / 2, true);
        }
    }
    
    // side screw 2 
    translate([swidthmm + 1, ( depth / 2 ) + (divisions - 1) * ( depth + notch_depth + spacing ), height / 2]) {
        rotate([90, 0, 90]) {
            cylinder(h = ssdepth + 1, r = sscrews / 2, center = true);
        }
    }
    
    // female dovetail 
    if(dividers == 1) {
        if(divisions != 1) {
            for (n = [0 : divisions - 2]) {
                translate([swidthmm + 1, depth / 2 - dovetail_width / 2 + n * (depth + notch_depth + spacing), -0.5]) {
                    rotate([0, 0, 90]) {
                        dovetail(height + 1);
                    }
                }
            }
        }
    }
}

// male dovetail
if(dividers == 1) {
    if(divisions != 1) {
        for (n = [0 : divisions - 2]) {
                translate([1, depth / 2 - dovetail_width / 2 + ( n + 1 ) * (depth + notch_depth + spacing), 0]) {
                    rotate([0, 0, 90]) {
                    dovetail(height);
                }
            }
        }
    }
}
