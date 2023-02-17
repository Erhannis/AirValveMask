/**
Run get_deps.sh to clone dependencies into a linked folder in your home directory.
*/

use <deps.link/BOSL/nema_steppers.scad>
use <deps.link/BOSL/joiners.scad>
use <deps.link/BOSL/shapes.scad>
use <deps.link/erhannisScad/misc.scad>
use <deps.link/erhannisScad/auto_lid.scad>
use <deps.link/scadFluidics/common.scad>
use <deps.link/quickfitPlate/blank_plate.scad>
use <deps.link/getriebe/Getriebe.scad>
use <deps.link/gearbox/gearbox.scad>

$FOREVER = 1000;
DUMMY = false;
$fn = DUMMY ? 10 : 100;

TUBE_D_1 = 31.5;
TUBE_D_2 = 30.5;
TUBE_L = 25.4;

CHAMBER_D = TUBE_D_2 + 10;

LIP_R = 2;
LIP_T = 3;

BRIDGE_W = 2;
BRIDGE_T = LIP_T;
SCREW_D = 3;
SCREW_WALL_T = 2;

WALL_T = 3;
WALL_H = 25.4;

echo(CHAMBER_D+2*WALL_T);

*union() { // Valve
    // Bridge support - hopefully center breaks out ok
    tz(-0.5) cube([CHAMBER_D,BRIDGE_W,1],center=true);
    difference() { // Bridge
        union() {
            crotate([0,0,90]) {
                tz(BRIDGE_T/2) cube([CHAMBER_D,BRIDGE_W,BRIDGE_T],center=true);
            }
            cylinder(d=SCREW_D+2*SCREW_WALL_T,h=BRIDGE_T);
        }
        cylinder(d=SCREW_D,h=$FOREVER,center=true);
    }
    difference() { // Lip
        cylinder(d=CHAMBER_D+2*WALL_T,h=LIP_T);
        cylinder(d=TUBE_D_2-2*LIP_R,h=LIP_T);
    }
    difference() { // Main tube
        tz(-TUBE_L) cylinder(d=CHAMBER_D+2*WALL_T,h=TUBE_L+LIP_T+WALL_H);
        cylinder(d=CHAMBER_D,h=$FOREVER);
        tz(-TUBE_L) cylinder(d1=TUBE_D_1, d2=TUBE_D_2, h=TUBE_L);
        //OYp();
    }
    OVERHANG_SZ = 7;
    tz(LIP_T) difference() {
        cylinder(d=CHAMBER_D+2*WALL_T,h=TUBE_L+OVERHANG_SZ);
        tz(OVERHANG_SZ) cylinder(d1=TUBE_D_2, d2=TUBE_D_1, h=TUBE_L);
        cylinder(d1=CHAMBER_D, d2=TUBE_D_2, h=OVERHANG_SZ);
        //OXp();
    }
}

*tx(2*TUBE_D_1) union() {
    // Flap stencil
    difference() {
        cylinder(d=TUBE_D_2,h=2.5);
        cylinder(d=SCREW_D,h=$FOREVER,center=true);
    }
}

TUBE_TILT = -10;
ADAPTER_DX = (CHAMBER_D+2*WALL_T)+1.5;
*difference() {
    rx(-TUBE_TILT) union() { // Mask mount
        HOLE_D = 13;
        HOLE_L = 100;
        TX = 3;
        TY = 31;
        RX = -43;
        // Face mold
        difference() {
            rx(90) intersection() {
                translate([-41.5,-20,200]) import("../../models/face_repaired_2.stl", convexity = 10);
                cylinder(d=60,h=200,center=true);
//                OZm(); // #1 alternate
            }
            ty(TY) tx(TX) rz(20) rx(RX) tz(-HOLE_L-5) cylinder(d=HOLE_D,h=HOLE_L);
            ty(TY) tx(-TX) rz(-20) rx(RX) tz(-HOLE_L-5) cylinder(d=HOLE_D,h=HOLE_L);
            
            tz(-19) ty(19) rx(-20) scale([1.2,1.5,0.9]) sphere(d=12);
            
// #1 alternate
            tz(-16) difference() {
                rx(45+TUBE_TILT) difference() {
                    //tx(-10) cube([60, 15, 15]);
                    translate([-30,2.5,2.5]) cube([60, 10, 10]);
                }
                OYp();
            }            
        }
        
        // Nose tubes
        SHORT_L = 15;
        difference() {
            union() {
                ty(TY) tx(TX) rz(20) rx(RX) tz(-SHORT_L-29.5) cylinder(d=HOLE_D+2*WALL_T,h=SHORT_L);
                ty(TY) tx(-TX) rz(-20) rx(RX) tz(-SHORT_L-29.5) cylinder(d=HOLE_D+2*WALL_T,h=SHORT_L);
            }
            ty(TY) tx(TX) rz(20) rx(RX) tz(-HOLE_L-5) cylinder(d=HOLE_D,h=HOLE_L);
            ty(TY) tx(-TX) rz(-20) rx(RX) tz(-HOLE_L-5) cylinder(d=HOLE_D,h=HOLE_L);
        }
            
        // #1 alternate
//        // Strap hole
//        tz(-20) difference() {
//            rx(45+TUBE_TILT) difference() {
//                tx(-10) cube([20, 15, 15]);
//                translate([-10,2.5,2.5]) cube([20, 10, 10]);
//            }
//            OYp();
//        }
        
        // Adapter tubes
        tz(-50) rx(TUBE_TILT) tz(-TUBE_L) ctranslate([-ADAPTER_DX,0,0]) tx(ADAPTER_DX/2) difference() { // Tubes
            cylinder(d=(TUBE_D_1+TUBE_D_2)/2,h=TUBE_L);
            cylinder(d=(TUBE_D_1+TUBE_D_2)/2-2*WALL_T,h=TUBE_L);
        }

        /* Center cubes
        translate(ftranslate([TX,TY,0], frotate([0,0,20], frotate([RX,0,0], [0,0,-SHORT_L-29.5])))) cube(center=true);
        translate(ftranslate([-TX,TY,0], frotate([0,0,-20], frotate([RX,0,0], [0,0,-SHORT_L-29.5])))) cube(center=true);

        translate(ftranslate([0,0,-50], frotate([TUBE_TILT,0,0], ftranslate([ADAPTER_DX/2,0,-TUBE_L], [0,0,TUBE_L])))) cube(center=true);
        translate(ftranslate([0,0,-50], frotate([TUBE_TILT,0,0], ftranslate([-ADAPTER_DX/2,0,-TUBE_L], [0,0,TUBE_L])))) cube(center=true);
        */

        cmirror([1,0,0]) difference() {
            p1 = ftranslate([TX,TY,0], frotate([0,0,20], frotate([RX,0,0], [0,0,-SHORT_L-29.5])));
            p2 = ftranslate([0,0,-50], frotate([TUBE_TILT,0,0], ftranslate([ADAPTER_DX/2,0,-TUBE_L], [0,0,TUBE_L])));
            omnicone(p1,[RX,0,20],HOLE_D+2*WALL_T,p2,[TUBE_TILT,0,0],(TUBE_D_1+TUBE_D_2)/2);
            omnicone(p1,[RX,0,20],HOLE_D,p2,[TUBE_TILT,0,0],(TUBE_D_1+TUBE_D_2)/2-2*WALL_T,pad=0.0001);
        }
    }
    //OYm([0,14,0]);
}

// Heat exchanger
tz(25) difference() {
union() {
    CELL_NX = 10;
    CELL_NY = 4;
    CELL_SX = 10;
    CELL_SY = 10;
    CELL_SZ = 80;
    CELL_WALL_T = 0.6;
    
    STRAW_WALL_T = 2*CELL_WALL_T;
    
    SHELL_WALL_T = WALL_T;
    
    FLOOR_T = 1;
    
    SUPPORT_BRIDGE_T = FLOOR_T+2*CELL_WALL_T;
    
    ANTECHAMBER_H = 10;
    
    RED = "#FF0000";
    BLUE = "#0000FF";
    GREEN = "#00FF00";
    
    // Cells
    tz(3*ANTECHAMBER_H+CELL_SZ/2) {
        for (iy = [1:CELL_NY]) {
            for (ix = [1:CELL_NX]) {
                //color(((ix + iy) % 2 == 0) ? RED : BLUE) ty((((CELL_NY+1)/2)-iy)*CELL_SY) tx((((CELL_NX+1)/2)-ix)*CELL_SX) cube(center=true);
                color(((ix + iy) % 2 == 0) ? RED : BLUE) ty((((CELL_NY+1)/2)-iy)*CELL_SY) tx((((CELL_NX+1)/2)-ix)*CELL_SX) difference() {
                    cube([CELL_SX+CELL_WALL_T-0.01, CELL_SY+CELL_WALL_T-0.01, CELL_SZ], center=true);
                    cube([CELL_SX-CELL_WALL_T, CELL_SY-CELL_WALL_T, $FOREVER], center=true);
                }
            }
        }
    }
    
    // Shell
    tz((CELL_SZ+6*ANTECHAMBER_H)/2) difference() {
        cube([CELL_NX*CELL_SX+STRAW_WALL_T,CELL_NY*CELL_SY+STRAW_WALL_T,CELL_SZ+6*ANTECHAMBER_H],center=true);
        cube([CELL_NX*CELL_SX+STRAW_WALL_T-2*SHELL_WALL_T,CELL_NY*CELL_SY+STRAW_WALL_T-2*SHELL_WALL_T,$FOREVER],center=true);
    }
    
    // Cell straws
    // ...This looks like the Widget of Zillyhoo.
    for (tb = [false,true]) {
        around([0,0,3*ANTECHAMBER_H+CELL_SZ/2], [tb ? 180 : 0,0,0]) {
            difference() {
                tz(2*ANTECHAMBER_H) {
                    // Straws, mostly
                    for (iy = [1:CELL_NY]) {
                        for (ix = [1:CELL_NX]) {
                            color(((ix + iy) % 2 == (tb ? 1 : 0)) ? RED : BLUE) {
                                IS_RED = ((ix + iy) % 2 == 0);
                                IS_BLUE = !IS_RED;
                                //if (((ix + iy) % 2 == 1) == (ix > CELL_NX/2)) {
                                //if ((ix + iy) % 2 == 0) {
                                ty((((CELL_NY+1)/2)-iy)*CELL_SY) tx((((CELL_NX+1)/2)-ix)*CELL_SX) {
                                    if (IS_BLUE && (ix <= CELL_NX/2)) {
                                        // Flat floor
                                        cube([CELL_SX+STRAW_WALL_T,CELL_SY+STRAW_WALL_T,FLOOR_T],center=true);
                                    } else {
                                        // Straw
                                        tz(IS_RED ? 0 : (-ANTECHAMBER_H)) {
                                            difference() {
                                                FW = sqrt(1/2);
                                                //FW = 1/2;
                                                // Note 1: may not play well with non-equal sx/sy
                                                // Note 2: I threw the extra *2 in there so the overhang on the upper corner-edges isn't so steep
                                                CAP_H = 2*(CELL_SX+STRAW_WALL_T)*(1-FW)/2;
                                                union() {
                                                    cmirror([0,0,1],[0,0,ANTECHAMBER_H/2]) linear_extrude(height=CAP_H,scale=FW) {
                                                        square([CELL_SX+STRAW_WALL_T, CELL_SY+STRAW_WALL_T], center=true);
                                                    }
                                                    tz(ANTECHAMBER_H/2) cube([(CELL_SX+STRAW_WALL_T)*FW,(CELL_SY+STRAW_WALL_T)*FW,ANTECHAMBER_H-2*CAP_H],center=true);
                                                }
                                                union() {
                                                    cmirror([0,0,1],[0,0,ANTECHAMBER_H/2]) linear_extrude(height=CAP_H,scale=FW*0.947121) { // This constant is because the scale makes the thickness different, and I didn't feel like doing the math, so I brute forced it
                                                        square([CELL_SX-STRAW_WALL_T, CELL_SY-STRAW_WALL_T], center=true);
                                                    }
                                                    tz(ANTECHAMBER_H/2) cube([(CELL_SX+STRAW_WALL_T)*FW-2*STRAW_WALL_T,(CELL_SY+STRAW_WALL_T)*FW-2*STRAW_WALL_T,ANTECHAMBER_H-2*CAP_H],center=true);
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Lower floor
                                    if (ix <= CELL_NX/2) {
                                        // Flat floor
                                        tz(-ANTECHAMBER_H) cube([CELL_SX+STRAW_WALL_T,CELL_SY+STRAW_WALL_T,FLOOR_T],center=true);
                                    } else {
                                        if (IS_RED) {
                                            tz(-ANTECHAMBER_H) cube([CELL_SX+STRAW_WALL_T,CELL_SY+STRAW_WALL_T,FLOOR_T],center=true);
                                        }
                                    }
                                    
                                    // Lowest floor
                                    tz(-2*ANTECHAMBER_H) cube([CELL_SX+STRAW_WALL_T,CELL_SY+STRAW_WALL_T,FLOOR_T],center=true);
                                }
                            }
                        }
                    }
                }
                
                // Tube holes
                union() {
                    tx(ADAPTER_DX/2) cylinder(d=(TUBE_D_1+TUBE_D_2)/2-2*WALL_T,h=ANTECHAMBER_H*3,center=true);
                    tx(-ADAPTER_DX/2) cylinder(d=(TUBE_D_1+TUBE_D_2)/2-2*WALL_T,h=ANTECHAMBER_H,center=true);
                }
            }
            // Printing-support bridges
            tz(2*ANTECHAMBER_H) for (iz = [0:2]) {
                tz(-iz*ANTECHAMBER_H) for (ix = [0:CELL_NX]) {
                    tx((((CELL_NX)/2)-ix)*CELL_SX) color(GREEN) cube([STRAW_WALL_T,40,SUPPORT_BRIDGE_T],center=true);
                }
            }
        }
    }
    
    // External adapter tubes
    tz(-TUBE_L) {
        color(BLUE) translate([-ADAPTER_DX,0,0]) tx(ADAPTER_DX/2) difference() {
            cylinder(d=(TUBE_D_1+TUBE_D_2)/2,h=TUBE_L);
            cylinder(d=(TUBE_D_1+TUBE_D_2)/2-2*WALL_T,h=$FOREVER,center=true);
        }
        color(RED) tx(ADAPTER_DX/2) difference() {
            cylinder(d=(TUBE_D_1+TUBE_D_2)/2,h=TUBE_L+ANTECHAMBER_H);
            cylinder(d=(TUBE_D_1+TUBE_D_2)/2-2*WALL_T,h=$FOREVER,center=true);
        }
    }
    around([0,0,3*ANTECHAMBER_H+CELL_SZ/2], [180,0,0]) tz(-TUBE_L) {
        color(RED) translate([-ADAPTER_DX,0,0]) tx(ADAPTER_DX/2) difference() {
            cylinder(d=(TUBE_D_1+TUBE_D_2)/2,h=TUBE_L);
            cylinder(d=(TUBE_D_1+TUBE_D_2)/2-2*WALL_T,h=$FOREVER,center=true);
        }
        color(BLUE) tx(ADAPTER_DX/2) difference() {
            cylinder(d=(TUBE_D_1+TUBE_D_2)/2,h=TUBE_L+ANTECHAMBER_H);
            cylinder(d=(TUBE_D_1+TUBE_D_2)/2-2*WALL_T,h=$FOREVER,center=true);
        }
    }
    
    // Floors
    *difference() {
        crotate([180,0,0],center=[0,0,3*ANTECHAMBER_H+CELL_SZ/2]) ctranslate([0,0,ANTECHAMBER_H]) cube([CELL_NX*CELL_SX,CELL_NY*CELL_SY,FLOOR_T],center=true);
        crotate([180,0,0],center=[0,0,3*ANTECHAMBER_H+CELL_SZ/2]) {
            tx(ADAPTER_DX/2) cylinder(d=(TUBE_D_1+TUBE_D_2)/2-2*WALL_T,h=ANTECHAMBER_H*3,center=true);
            tx(-ADAPTER_DX/2) cylinder(d=(TUBE_D_1+TUBE_D_2)/2-2*WALL_T,h=ANTECHAMBER_H,center=true);
        }
    }
}
//rz(70) OXp();
}