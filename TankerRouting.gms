$Title  Heterogenous tanker fleet inventory and routing scheduling

$onText
        Continuous-time formulation for a routing problem with inventory constraints. Models below are those in:
        "Maritime Inventory Routing with Speed Optimization: A MIQCP Formulation for a Tanker Fleet Servicing FPSO Units"
        paper submitted to Computers & Chemical Engineering on February 8, 2024 and revised in September 2024.

        The problem definition is taken from Applied Energy 334 (2023) 120354, which I reviewed.
        Reduces gap but makes model slower:SUM((V,N,C)$(ACTV(V) and ACTN(N) and ENLN(C,N)),YF(V,C,T))=g=1;                

        WHATM=  1   Minimize lower bound of total operational cost including fuel and renting EQ37 (MIP)
                2   Similar to 1 but objective function includes a term to minimize waiting times EQ39 (MIP) 
                3   Minimize total operational cost including fuel and renting without tightening constraint (MIQCP)
                4   Minimize total operational cost including fuel and renting with tightening constraint in EQ38 (MIQCP)
                5   Decomposition strategy, with MIP for deciding the connections then QCP (not part of CACE paper)
                
        Started 18/07/2023.
$offText

Sets
T   Time points /T1*T5/
N   Nodes (port and FPSOs)   /N0*N10/
C   Maritime lines connecting two nodes /C1*C110/
V   Tanker vessel  /V1*V8/
CP  Chart points /CP1*CP100/
ACTN(N) Active nodes
PORT(N) Port nodes
FPSO(N) FPSO nodes
ACTC(C) Active connections
PORTC(C)    Connections ending with a port node
FPSOC(C)    Connections ending with a FPSO node
ACTV(V) Active tanker vessel
ACTCP(CP)   Active chart points
IDV(V,V)    Identical vessels
INICIO(T)   First event point
FIM(T)      Last event point
STLN(C,N)   For connection C N is the start node
ENLN(C,N)   For connection C N is the end node
LINK(C,N,N) Connection C starts at node N and ends at node NL 
;

Alias(N,NL);Alias(V,VL);ALIAS(T,TL);

Scalar
WHATM   What model  /1/
STRESS  Stress factor for changing production rate /1/
DISTMIN Minimum distance covered in one time slot (km)   /10/
SPDCNV  Speed conversion factor from knots to km*day-1 /44.448/
FILFAC  Minimum fraction of vessel capacity filled during a time slot /0.20/
CURRC   Current connection /1/
EXITL   Exit loop auxiliary parameter /0/
H   Time horizon (days)
TMIN    Minimum filling time during a time slot (days)
MAXVP   Maximum volume initially available and produced by FPSOs (kton)
PTDIST  Total distance covered during time horizon (km)
PTPVOL  Total volume discharged to port (kton)
PTRENT  Total rental cost (k$)
PTFUEL  Total fuel cost (k$)
TCOST   Real total cost (k$)
; 

Parameters
NODES(N)    Problem nodes
XCN(N)  x-axis coordinate of node N (km) /N0 0,N1 900,N2 585,N3 1093,N4 1074,N5 312,N6 1189,N7 1657,N8 75,N9 705,N10 1186/
YCN(N)  y-axis coordinate of node N (km) /N0 694,N1 1242,N2 842,N3 1620,N4 985,N5 1523,N6 1672,N7 1775,N8 585,N9 1768,N10 487/
CAPN(N) Storage capacity of node N (kton) /N1 110,N2 220,N3 160,N4 220,N5 250,N6 201,N7 137,N8 123,N9 175,N10 113/
CAP0N(N)    Initial capacity of node N (kton) /N1 90,N2 92,N3 55,N4 65,N5 50,N6 24,N7 59,N8 52,N9 51,N10 64/
PRATE(N)    Production rate of node N (kton*day-1) /N1 5,N2 11,N3 8,N4 12,N5 13,N6 9,N7 8,N8 6,N9 11,N10 7/
URATEN(N)   Unloading rate of node N to shuttle tanker (kton*day-1) /N1*N10 333.3/
VESSELS(V)  Problem vessels
CAPV(V) Storage capacity of tanker vessel V (kton) /V1 60,V2 120,V3 180,V4 220,V5 60,V6 120,V7 180,V8 220/
CAP0V(V)    Initial capacity of vessel V (kton) /V1*V8 0/
URATEV(V)   Unloading rate of tanker vessel V to port (kton*day-1) /V1*V8 200/
SPDMIN(V)   Minimum speed for shuttle tanker V (knots) /V1 7,V2 6,V3 5,V4 5,V5 7,V6 6,V7 5,V8 5/
SPDMAX(V)   Maximum speed for shuttle tanker V (knots) /V1 19,V2 17,V3 16,V4 15,V5 19,V6 17,V7 16,V8 15/
RENTAL(V)   Rental cost for tanker V (k$*day-1) /V1 36.5,V2*V4 45,V5 36.5,V6*V8 45/
FCP0(V) Fixed term of fuel cost parameter (k$*km-1) /V1 0.178,V2 0.359,V3 0.530,V4 0.862,V5 0.178,V6 0.359,V7 0.530,V8 0.862/
FCP1(V) Linear term of fuel cost parameter (k$*km-1*knots-1) /V1 0.0838,V2 0.0699,V3 0.0729,V4 0.0082,V5 0.0838,V6 0.0699,V7 0.0729,V8 0.0082/
FCP2(V) Quadratic term of fuel cost parameter (k$*km-1*knots-2) /V1 -0.000882,V2 0.000476,V3 0.000770,V4 0.005012,V5 -0.000882,V6 0.000476,V7 0.000770,V8 0.005012/
LOCAT0(V,N) Vessel tanker V is initially located at node N
DIST(C) Travelling distance of connection C (km)
SLWT(C) Slowest time to complete travel on connection C (day)
FSTT(C) Fastest time to complete travel on connection C (day)
FLWR(V,C)   Discharge flowrate from to vessel V at the end of connection C (kton*day-1)
TFMAX(V,C)  Maximum filling time to or from vessel V at the end of connection C (days)
PYT(V,N,N,T)    Tanker vessel V is traveling from node N to NL during slot T    
PYF(V,N,T)  Tanker vessel V is filling or discharging at node N during slot T
TSWAUX(T)   Starting of waiting time during slot T (days)
TSTAUX(V,T) Starting of travelling time for vessel V during slot T (days)
TSFAUX(V,T) Starting of filling or discharging time for vessel V during slot T (days)
TSFN(N,T)   Starting of filling or discharging time for node N during slot T (days)
TSCP(CP)    Starting time of chart point CP (days)
SPDCP(V,CP) Speed of vessel V at chart point CP (knots)
MNCP(N,CP)  Mass of node N at chart point CP (ton)
MVCP(V,CP)  Mass of vessel V at chart point CP (ton)
;

$include C:\Users\Castro\Documents\GAMS files\Logistics\Data Files\TankerFPSO_Ex1.txt

PRATE(N)=STRESS*PRATE(N);
PORT(N)=yes$(ord(N) EQ 1);
FPSO(N)=yes$(ord(N) GT 1 and NODES(N) EQ 1);
ACTN(N)=yes$(PORT(N) or FPSO(N));
ACTV(V)=yes$(VESSELS(V) EQ 1);
LOCAT0(V,N)$(PORT(N) and ACTV(V))=1;
IDV(V,VL)$(ACTV(V) and ACTV(VL))=yes$(ord(VL) EQ ord(V)+4);

loop(N$(ACTN(N)),
    loop(NL$(ACTN(NL) and ord(NL) NE ord(N)),
        loop(C$(ord(C) EQ CURRC),
        PORTC(C)=yes$(PORT(NL));
        FPSOC(C)=yes$(FPSO(NL));
        STLN(C,N)=yes;
        ENLN(C,NL)=yes;
        LINK(C,N,NL)=yes;
        DIST(C)=round(sqrt(sqr(XCN(N)-XCN(NL))+sqr(YCN(N)-YCN(NL))),1);
        FLWR(V,C)$(ACTV(V))=URATEN(NL)$(FPSO(NL))+URATEV(V)$(PORT(NL));
        );
    CURRC=CURRC+1;
    );
);
ACTC(C)=yes$(ord(C) LT CURRC);
INICIO(T)=yes$(ord(T) EQ 1);
FIM(T)=yes$(ord(T) EQ card(T));
CAPN(N)$(PORT(N))=SUM(NL$(FPSO(NL)),CAP0N(NL)+PRATE(NL)*H)+SUM(V$(ACTV(V)),CAP0V(V));
SLWT(C)$(ACTC(C))=DIST(C)/SMIN(V$(ACTV(V)),SPDMIN(V))/SPDCNV;
FSTT(C)$(ACTC(C))=DIST(C)/SMAX(V$(ACTV(V)),SPDMAX(V))/SPDCNV;
TMIN=FILFAC*SMIN((V,C)$(ACTV(V) and ACTC(C)),CAPV(V)/FLWR(V,C));
TFMAX(V,C)$(ACTV(V) and ACTC(C))=(MIN(SUM(N$(ENLN(C,N)),CAPN(N))/FLWR(V,C),CAPV(V)/FLWR(V,C)))$(FPSOC(C))+(CAPV(V)/FLWR(V,C))$(PORTC(C));
MAXVP=SUM(N$(FPSO(N)),CAP0N(N)+PRATE(N)*H);

display PORT,FPSO,ACTN,CAPN,ACTV,IDV,ACTC,PORTC,FPSOC,DIST,SLWT,FSTT,LINK,STLN,ENLN,FLWR,TMIN,TFMAX,MAXVP;

Binary variables
Z(V)    Tanker vessel V is rented
YF(V,C,T)   Tanker vessel V is filling or discharging at the end of connection C during slot T
YT(V,C,T)   Tanker vessel V is traveling in connection C during slot T
XN(V,N,T)   Tanker vessel V just finished charging or discharging at node N and time point T and is ready to leave

Positive variables
TT(T)   Absolute time of event point T (days)
L(T)    Lenght of time slot T (days)
LF(V,T) Time that vessel V is filling or discharging during slot T (days)
LT(V,T) Time that vessel V is traveling during slot T (days)
LW(V,T) Time that vessel V is waiting during slot T (days)
SPD(V,T)    Speed of vessel V during slot T (knots)
LFD(V,C,T)  Time that vessel V is filling or discharging at the end of connection C during slot T (days)
AD(V,T) Accumulated distance to line origin covered by tanker vessel V at time T (km)
D(V,T)  Distance covered by tanker vessel V during slot T (km)
R(V,T)  Reset variable for accumulated distance of tanker vessel V during slot T (km)
FN(N,T) Mass of crude oil entering or leaving node N during slot T (kton)
FIN(V,T)    Mass of crude oil entering tanker vessel V during slot T (kton)
FOUT(V,T)   Mass of crude oil leaving tanker vessel V during slot T (kton)
MV(V,T) Mass of crude oil inside tanker vessel V at time T (kton)
MN(N,T) Mass of crude oil available at node N at time T (kton)
MNE(N,T)    Mass of crude oil available at node N slot T just before the start of filling or discharge phase (kton)
FUELCR(V,T) Fuel consumption rate of vessel V during slot T (k$*km-1)
FUELCE(V,C,T)   Estimated fuel consumption considering minimum speed of vessel V in connetion C slot T (k$*km-1)

Variables
OPCOSTQ Quadratic operating cost (k$)
OPCOSTL Linear operating cost (k$)

Equations
OBJEQ37 Objective function for MIP formulation estimating total fuel and rental costs
OBJEQ39 Objective function for MIP formulation estimating total fuel and rental costs and minimizing waiting times
OBJEQ35 Objective function for MIQCP formulation defining total fuel and rental costs
EQ2(T)  Duration of slot T is equal to the difference of the times of its boundary event points
EQ3(V,T)    For vessel V the duration of slot T is equal to the sum of waiting traveling and charging or discharging times
EQ4L(V,T)   The traveling time of vessel V during slot T is greater than the distance divided by the maximum speed
EQ4U(V,T)   The traveling time of vessel V during slot T is lower than the distance divided by the minimum speed
EQ14(V,T)   Filling time of vessel V during slot T is equal to the sum of its disaggregated variables
EQ15L(V,C,T)    Disaggregated variable for filling time of vessel V in connection C during slot T is greater than minimum filling time
EQ15U(V,C,T)    Disaggregated variable for filling time of vessel V in connection C during slot T is lower than time horizon
EQ5(V,T)    Calculation of speed of vessel V during slot T
EQ11U(V,T)  Upper bound of speed of vessel V during slot T
EQ11L(V,T)  Lower bound of speed of vessel V during slot T
EQ34(V,T)   Fuel consumption rate of vessel V during slot T
EQ36(V,C,T) Estimate of fuel consumption rate of vessel V traveling in connection C during slot T
EQ38(V) Tightening constraint for MIQCP model
EQ6(V,T)    Definition of accumulated distance of tanker vessel T at time T (km)
EQ10L(V,T)  If tanker vessel V is traveling on a connection during slot T there should be a minimum distance covered
EQ10U(V,T)  If tanker vessel V is traveling on a connection during slot T then the maximum distance covered is the line's distance
EQ13L(V,T)  Lower bound on the accumulated distance of vessel V at time T
EQ13U(V,T)  Upper bound on the accumulated distance of vessel V at time T
EQ12(V,T)   The reset variable of tanker vessel V discharging during slot T is equal to the line distance
EQ16(V,T)   Flow into tanker vessel V during slot T is given by the FPSO discharge flowrate multiplied by the disaggregated filling time
EQ17(V,T)   Flow into tanker vessel V during slot T is given by the vessel discharge flowrate multiplied by the disaggregated filling time
EQ26(N,T)   Flow into or out of node N during slot T is given by the sum of filling or discharge flowrate multiplied by the disaggregated filling time
EQ29(V,T)   Mass balance for tanker vessel V at time T (kton)
EQ28(N,T)   Mass balance for node N at time T (kton)
EQ27(N,T)   Mass balance for node N at the end of slot T (kton)
EQ7(V,T)    Tanker vessel V during slot T is traveling at most one connection
EQ8(V,T)    Tanker vessel V during slot T is filling or discharging at the end of at most one connection
EQ18(V,C,T) If tanker vessel V is filling or discharging crude in connection C during slot T then it must be travelling that connection
EQ9(V,T)    Tanker vessel V at time point T is ready to leave at most one node
EQ21(V,C,N,T)   If tanker vessel V is traveling connection C during a slot then it was either ready to leave its starting node at T or was already travelling during the previous slot
EQ22(V,N,T)     If tanker vessel V is ready to leave node N at time T then it was already ready to leave (only for ports) or it was previously discharging
EQ19(V,C,N,T)   If tanker vessel V is filling the node at the end of connection C node N during slot T then it must be ready to leave the node next
EQ23(V,N,T)     If tanker vessel V is ready to leave node N at time T then it will be leaving the node or still be ready to leave at the next time point (only for ports)
EQ20(N,T)   At most one vessel can be filling or discharging at node N during slot T
EQ24(V,N,T) Sets initial location of vessel V to node N at first event point
EQ25(V,V)   If vessel V is identical to VL then the former should be used before
;


OBJEQ37.. OPCOSTL=e=SUM(V$(ACTV(V)),RENTAL(V)*H*Z(V))+SUM((V,C,T)$(ACTV(V) and ACTC(C) and not FIM(T)),FUELCE(V,C,T)*DIST(C));
OBJEQ39.. OPCOSTL=e=SUM(V$(ACTV(V)),RENTAL(V)*H*Z(V))+SUM((V,T)$(ACTV(V) and not FIM(T)),0.1*RENTAL(V)*LW(V,T))+SUM((V,C,T)$(ACTV(V) and ACTC(C) and not FIM(T)),FUELCE(V,C,T)*DIST(C));
OBJEQ35.. OPCOSTQ=e=SUM(V$(ACTV(V)),RENTAL(V)*H*Z(V))+SUM((V,T)$(ACTV(V) and not FIM(T)),FUELCR(V,T)*D(V,T));

EQ2(T)$(not FIM(T)).. TT(T+1)=e=TT(T)+L(T);
EQ3(V,T)$(ACTV(V) and not FIM(T)).. L(T)=e=LW(V,T)+LT(V,T)+LF(V,T);          
EQ4L(V,T)$(ACTV(V) and not FIM(T))..    LT(V,T)=g=D(V,T)/SPDMAX(V)/SPDCNV;          
EQ4U(V,T)$(ACTV(V) and not FIM(T))..    LT(V,T)=l=D(V,T)/SPDMIN(V)/SPDCNV;          
EQ14(V,T)$(ACTV(V) and not FIM(T))..    LF(V,T)=e=SUM(C$(ACTC(C)),LFD(V,C,T));
EQ15L(V,C,T)$(ACTV(V) and ACTC(C) and not FIM(T))..   LFD(V,C,T)=g=TMIN*YF(V,C,T);
EQ15U(V,C,T)$(ACTV(V) and ACTC(C) and not FIM(T))..   LFD(V,C,T)=l=TFMAX(V,C)*YF(V,C,T);
EQ5(V,T)$(ACTV(V) and not FIM(T)).. SPD(V,T)*LT(V,T)=e=D(V,T)/SPDCNV;
EQ11U(V,T)$(ACTV(V) and not FIM(T))..   SPD(V,T)=l=SPDMAX(V)*SUM(C$(ACTC(C)),YT(V,C,T));      
EQ11L(V,T)$(ACTV(V) and not FIM(T))..   SPD(V,T)=g=SPDMIN(V)*SUM(C$(ACTC(C)),YT(V,C,T));
EQ34(V,T)$(ACTV(V) and not FIM(T))..    FUELCR(V,T)=e=FCP0(V)*SUM(C$(ACTC(C)),YT(V,C,T))+FCP1(V)*SPD(V,T)+FCP2(V)*sqr(SPD(V,T));      
EQ36(V,C,T)$(ACTV(V) and ACTC(C) and not FIM(T))..    FUELCE(V,C,T)=e=YF(V,C,T)*(FCP0(V)+FCP1(V)*SPDMIN(V)+FCP2(V)*sqr(SPDMIN(V)));      
EQ38(V)$(ACTV(V))..   SUM(T$(not FIM(T)),FUELCR(V,T))=g=SUM((C,T)$(ACTC(C) and not FIM(T)),YF(V,C,T)*(FCP0(V)+FCP1(V)*SPDMIN(V)+FCP2(V)*sqr(SPDMIN(V))));   

EQ6(V,T)$(ACTV(V))..    AD(V,T)=e=AD(V,T-1)+D(V,T-1)-R(V,T-1);
EQ10L(V,T)$(ACTV(V) and not FIM(T)).. D(V,T)=g=DISTMIN*SUM(C$(ACTC(C)),YT(V,C,T));
EQ10U(V,T)$(ACTV(V) and not FIM(T)).. D(V,T)=l=SUM(C$(ACTC(C)),DIST(C)*YT(V,C,T));
EQ13L(V,T)$(ACTV(V))..    AD(V,T)=g=DISTMIN*(Z(V)-SUM(N$(ACTN(N)),XN(V,N,T)));
EQ13U(V,T)$(ACTV(V))..    AD(V,T)=l=SMAX(C$(ACTC(C)),DIST(C))*(Z(V)-SUM(N$(ACTN(N)),XN(V,N,T)));
EQ12(V,T)$(ACTV(V) and not FIM(T)).. R(V,T)=e=SUM(C$(ACTC(C)),DIST(C)*YF(V,C,T));

EQ16(V,T)$(ACTV(V) and not FIM(T))..   FIN(V,T)=e=SUM(C$(FPSOC(C)),FLWR(V,C)*LFD(V,C,T));
EQ17(V,T)$(ACTV(V) and not FIM(T))..   FOUT(V,T)=e=SUM(C$(PORTC(C)),FLWR(V,C)*LFD(V,C,T));
EQ26(N,T)$(ACTN(N) and not FIM(T))..   FN(N,T)=e=SUM((V,C)$(ACTV(V) and ENLN(C,N)),FLWR(V,C)*LFD(V,C,T));

EQ29(V,T)$(ACTV(V))..    MV(V,T)=e=CAP0V(V)$(INICIO(T))+MV(V,T-1)+FIN(V,T-1)-FOUT(V,T-1);
EQ28(N,T)$(ACTN(N))..    MN(N,T)=e=CAP0N(N)$(INICIO(T))+MNE(N,T-1)+(PRATE(N)*SUM((V,C)$(ACTV(V) and ENLN(C,N)),LFD(V,C,T-1))-FN(N,T-1))$(FPSO(N))+FN(N,T-1)$(PORT(N));
EQ27(N,T)$(ACTN(N) and not FIM(T)).. MNE(N,T)=e=MN(N,T)+(PRATE(N)*(L(T)-SUM((V,C)$(ACTV(V) and ENLN(C,N)),LFD(V,C,T))))$(FPSO(N));

EQ7(V,T)$(ACTV(V) and not FIM(T))..  SUM(C$(ACTC(C)),YT(V,C,T))=l=Z(V);
EQ8(V,T)$(ACTV(V) and not FIM(T))..  SUM(C$(ACTC(C)),YF(V,C,T))=l=Z(V);
EQ18(V,C,T)$(ACTV(V) and ACTC(C) and not FIM(T))..    YF(V,C,T)=l=YT(V,C,T);
EQ9(V,T)$(ACTV(V)).. SUM(N$(ACTN(N)),XN(V,N,T))=l=Z(V);
EQ21(V,C,N,T)$(ACTV(V) and ACTC(C) and STLN(C,N) and not FIM(T))..    YT(V,C,T)=l=YT(V,C,T-1)+XN(V,N,T);
EQ22(V,N,T)$(ACTV(V) and ACTN(N) and not INICIO(T)).. XN(V,N,T)=l=XN(V,N,T-1)$(PORT(N))+SUM(C$(ENLN(C,N)),YF(V,C,T-1));
EQ19(V,C,N,T)$(ACTV(V) and ACTC(C) and ENLN(C,N) and not FIM(T))..    YF(V,C,T)=l=XN(V,N,T+1);
EQ23(V,N,T)$(ACTV(V) and ACTN(N) and not FIM(T))..    XN(V,N,T)=l=XN(V,N,T+1)$(PORT(N))+SUM(C$(STLN(C,N)),YT(V,C,T));
EQ20(N,T)$(ACTN(N) and not FIM(T))..  SUM((V,C)$(ACTV(V) and ENLN(C,N)),YF(V,C,T))=l=1;
EQ24(V,N,T)$(ACTV(V) and ACTN(N) and INICIO(T))..    XN(V,N,T)=e=LOCAT0(V,N)*Z(V);
EQ25(V,VL)$(IDV(V,VL))..  Z(VL)=l=Z(V);


Z.up(V)$(ACTV(V))=1;
TT.up(T)=H;
TT.fx(T)$(FIM(T))=H;
TT.fx(T)$(INICIO(T))=0;
MN.up(N,T)=CAPN(N);MNE.up(N,T)=CAPN(N);MN.up(N,T)$(FPSO(N) and FIM(T))=CAP0N(N);
MV.up(V,T)=CAPV(V);MV.up(V,T)$(FIM(T))=0;

OPTION optcr=1E-6;
OPTION limrow=0;
OPTION limcol=0;
OPTION Solprint=Off;
OPTION reslim=18000;
OPTION threads=0;
OPTION MIP=GUROBI;OPTION MIQCP=GUROBI;OPTION RMIQCP=GUROBI;

Model MIPEQ37 using /OBJEQ37,EQ2,EQ3,EQ4L,EQ4U,EQ14,EQ15L,EQ15U,EQ36,EQ6,EQ10L,EQ10U,EQ13L,EQ13U,EQ12,EQ16,EQ17,EQ26,EQ29,EQ28,EQ27,EQ7,EQ8,EQ18,EQ9,EQ21,EQ22,EQ19,EQ23,EQ20,EQ24,EQ25/;
Model MIPEQ39 using /OBJEQ39,EQ2,EQ3,EQ4L,EQ4U,EQ14,EQ15L,EQ15U,EQ36,EQ6,EQ10L,EQ10U,EQ13L,EQ13U,EQ12,EQ16,EQ17,EQ26,EQ29,EQ28,EQ27,EQ7,EQ8,EQ18,EQ9,EQ21,EQ22,EQ19,EQ23,EQ20,EQ24,EQ25/;
Model MIQCPnoT using /OBJEQ35,EQ2,EQ3,EQ4L,EQ4U,EQ14,EQ15L,EQ15U,EQ5,EQ11U,EQ11L,EQ34,EQ6,EQ10L,EQ10U,EQ13L,EQ13U,EQ12,EQ16,EQ17,EQ26,EQ29,EQ28,EQ27,EQ7,EQ8,EQ18,EQ9,EQ21,EQ22,EQ19,EQ23,EQ20,EQ24,EQ25/;
Model MIQCPEQ38 using /OBJEQ35,EQ2,EQ3,EQ4L,EQ4U,EQ14,EQ15L,EQ15U,EQ5,EQ11U,EQ11L,EQ34,EQ38,EQ6,EQ10L,EQ10U,EQ13L,EQ13U,EQ12,EQ16,EQ17,EQ26,EQ29,EQ28,EQ27,EQ7,EQ8,EQ18,EQ9,EQ21,EQ22,EQ19,EQ23,EQ20,EQ24,EQ25/;

if(WHATM LE 2,
    if(WHATM EQ 1,Solve MIPEQ37 using MIP minimizing OPCOSTL;);
    if(WHATM EQ 2,Solve MIPEQ39 using MIP minimizing OPCOSTL;);
*Need to eliminate travelling tasks without an actual transfer in the end (to avoid overestimating real cost)
YT.l(V,C,T)$(ACTV(V) and ACTC(C) and not FIM(T) and SUM(TL$(ord(TL) GE ord(T)),YF.l(V,C,TL)) EQ 0)=0;
SPD.l(V,T)$(ACTV(V) and not FIM(T) and SUM(C$(ACTC(C)),YT.l(V,C,T)) EQ 1)=(D.l(V,T)/LT.l(V,T)/SPDCNV)$(LT.l(V,T) GT 0);
FUELCR.l(V,T)$(ACTV(V) and not FIM(T))=FCP0(V)*SUM(C$(ACTC(C)),YT.l(V,C,T))+FCP1(V)*SPD.l(V,T)+FCP2(V)*sqr(SPD.l(V,T));
);
if(WHATM GE 3 and WHATM LE 4,
        if(WHATM EQ 3,MIQCPnoT.optfile=2;Solve MIQCPnoT using MIQCP minimizing OPCOSTQ;);
        if(WHATM EQ 4,MIQCPEQ38.optfile=2;Solve MIQCPEQ38 using MIQCP minimizing OPCOSTQ;);        
);
if(WHATM EQ 5,
OPTION reslim=3600;
Solve MIPEQ39 using MIP minimizing OPCOSTL;
ACTC(C)=yes$(SUM((V,T)$(ACTV(V) and not FIM(T)),YT.l(V,C,T)) GE 1);
PORTC(C)$(not ACTC(C))=no;
FPSOC(C)$(not ACTC(C))=no;
STLN(C,N)$(not ACTC(C))=no;
ENLN(C,NL)$(not ACTC(C))=no;
MIQCPEQ38.optfile=2;
OPTION reslim=14400;
Solve MIQCPEQ38 using MIQCP minimizing OPCOSTQ;
);

PYT(V,N,NL,T)=SUM(C$(LINK(C,N,NL)),YT.l(V,C,T));
PYF(V,N,T)=SUM(C$(ENLN(C,N)),YF.l(V,C,T));
PTDIST=SUM((V,T)$(ACTV(V)),D.l(V,T));
PTPVOL=SUM((N,T)$(PORT(N) and FIM(T)),MN.l(N,T));
PTRENT=SUM(V$(ACTV(V)),RENTAL(V)*H*Z.l(V));
PTFUEL=SUM((V,T)$(ACTV(V) and not FIM(T)),FUELCR.l(V,T)*D.l(V,T));
TCOST=PTRENT+PTFUEL;

Display Z.l,PYT,PYF,XN.l,SPD.l,FUELCR.l,TT.l,L.l,LW.l,LT.l,LF.l,LFD.l,D.l,AD.l,R.l,MV.l,FIN.l,FOUT.l,MN.l,MNE.l,FN.l,PTDIST,PTPVOL,PTRENT,PTFUEL,TCOST;


*Ordering events for chart construction
ACTV(V)=yes$(Z.l(V) EQ 1);
TSWAUX(T)$(not FIM(T))=round(TT.l(T),3);
TSTAUX(V,T)$(ACTV(V) and not FIM(T))=round(TT.l(T)+LW.l(V,T),3);
TSFAUX(V,T)$(ACTV(V) and not FIM(T))=round(TT.l(T)+LW.l(V,T)+LT.l(V,T),3);
TSFN(N,T)$(ACTN(N) and not FIM(T))=round(SUM(V$(PYF(V,N,T)),TT.l(T)+LW.l(V,T)+LT.l(V,T)),3);

loop(CP$(EXITL=0),
TSCP(CP)=MIN(SMIN(T$(not FIM(T)),TSWAUX(T)),SMIN((V,T)$(ACTV(V) and not FIM(T)),TSTAUX(V,T)),SMIN((V,T)$(ACTV(V) and not FIM(T)),TSFAUX(V,T)));
    if(TSCP(CP) EQ 1E9,
    TSCP(CP)=0;
    EXITL=1;
    );
    loop(T$(not FIM(T) and EXITL=0),
        if(TSWAUX(T) EQ TSCP(CP),
        TSWAUX(T)=1E9;
        SPDCP(V,CP)=0;
        MNCP(N,CP)$(ACTN(N))=MN.l(N,T);
        MVCP(V,CP)$(ACTV(V))=MV.l(V,T)
        );
            loop(V$(ACTV(V) and EXITL=0),
                if(TSTAUX(V,T) EQ TSCP(CP),
                SPDCP(V,CP)=SPD.l(V,T);
                SPDCP(VL,CP)$(ACTV(VL) and ord(V) NE ord(VL))=SPD.l(VL,T)$(round(TT.l(T)+LW.l(VL,T),3) LE TSCP(CP) and round(TT.l(T)+LW.l(VL,T)+LT.l(VL,T),3) GT TSCP(CP));
                MNCP(N,CP)$(ACTN(N))=MN.l(N,T)+PRATE(N)*(TSCP(CP)-TT.l(T))$(FPSO(N))+SUM(VL$(PYF(VL,N,T) and TSCP(CP) GT TSFN(N,T)),(URATEV(VL)*(TSCP(CP)-TSFN(N,T)))$(PORT(N))-(URATEN(N)*(TSCP(CP)-TSFN(N,T)))$(FPSO(N)));                
                MVCP(VL,CP)$(ACTV(VL))=MV.l(VL,T)+SUM(N$(PYF(VL,N,T) and TSCP(CP) GT TSFN(N,T)),-(URATEV(VL)*(TSCP(CP)-TSFN(N,T)))$(PORT(N))+(URATEN(N)*(TSCP(CP)-TSFN(N,T)))$(FPSO(N)));                
                TSTAUX(V,T)=1E9;
                );
                if(TSFAUX(V,T) EQ TSCP(CP),
                SPDCP(V,CP)=0;
                SPDCP(VL,CP)$(ACTV(VL) and ord(V) NE ord(VL))=SPD.l(VL,T)$(round(TT.l(T)+LW.l(VL,T),3) LT TSCP(CP) and round(TT.l(T)+LW.l(VL,T)+LT.l(VL,T),3) GT TSCP(CP));
                MNCP(N,CP)$(ACTN(N))=MN.l(N,T)+PRATE(N)*(TSCP(CP)-TT.l(T))$(FPSO(N))+SUM(VL$(PYF(VL,N,T) and TSCP(CP) GT TSFN(N,T)),(URATEV(VL)*(TSCP(CP)-TSFN(N,T)))$(PORT(N))-(URATEN(N)*(TSCP(CP)-TSFN(N,T)))$(FPSO(N)));                
                MVCP(VL,CP)$(ACTV(VL))=MV.l(VL,T)+SUM(N$(PYF(VL,N,T) and TSCP(CP) GT TSFN(N,T)),-(URATEV(VL)*(TSCP(CP)-TSFN(N,T)))$(PORT(N))+(URATEN(N)*(TSCP(CP)-TSFN(N,T)))$(FPSO(N)));                
                TSFAUX(V,T)=1E9;
                );
            );
    );
    loop(T$(FIM(T) and TT.l(T) EQ TSCP(CP) and EXITL=0),
    MNCP(N,CP)$(ACTN(N))=MN.l(N,T);
    MVCP(V,CP)$(ACTV(V))=MV.l(V,T)
    );
);
ACTCP(CP)=yes$(ord(CP) EQ 1 or TSCP(CP) GT 0);

*Output results for chart construction in Excel
file      Results   /C:\Users\Castro\Documents\My Data Sources\GAMS Output\FPSOs.txt/;
Results.pw=700;
put       Results;
Results.pc=6;

put 'ChartData','Results Tanker Vessels','Obj (k$)=',if(WHATM EQ 1,put TCOST; else put OPCOSTQ.l;); put /;
put 'Task durations for Gantt chart' /;
put 'Vessels', loop(T$(not FIM(T)), put "Wait", put "Travel", put "Transfer"); put /;
loop(V$(ACTV(V)),
put V.te(V);
    loop(T$(not FIM(T)),
    put (LW.l(V,T)):7:3, put (LT.l(V,T)):7:3, put (LF.l(V,T)):7:3;
    );
put /;
);
put #13 'Nodes', loop(T$(not FIM(T)), put "Wait", put "Transfer"); put /;
loop(N$(ACTN(N)),
put N.te(N);
    loop(T$(not FIM(T)),
        if(SUM((V,C)$(ENLN(C,N) and ACTV(V)),YF.l(V,C,T)) GT 0.999,
            loop((V,C)$(ENLN(C,N) and YF.l(V,C,T) GT 0.999),
            put (LW.l(V,T)+LT.l(V,T)):7:3, put (LF.l(V,T)):7:3;
            );
        else
        put L.l(T), put '';
        );
    );
put /;
);
put #26 'Routes' /;
loop(V$(ACTV(V)),
put V.te(V);
    loop(T$(not FIM(T)),
        loop(C$(YT.l(V,C,T) GT 0.999),
            loop(N$(STLN(C,N)),
            put N.tl;
            );
        );
    );
put 'N0';put /;
);

put #36 'Speed Profiles (knots)';loop(V,put ''); put 'Inventory profiles (ton)';loop(V,put ''); put 'Inventory profiles (ton)'; put /;
put 'Time (days)';loop(V$(ACTV(V)),put V.te(V));loop(V$(not ACTV(V)),put '');loop(V$(ACTV(V)),put V.te(V));loop(V$(not ACTV(V)),put '');loop(N$(ACTN(N)),put N.te(N)); put /;
loop(CP$(ACTCP(CP)),
put (TSCP(CP)):7:3;loop(V$(ACTV(V)),put (SPDCP(V,CP)):7:3);loop(V$(not ACTV(V)),put '');loop(V$(ACTV(V)),put (MVCP(V,CP)):7:3);loop(V$(not ACTV(V)),put '');loop(N$(ACTN(N)),put (MNCP(N,CP)):7:3); put /;
    if(ord(CP) LT card(ACTCP),
    put (TSCP(CP+1)):7:3;loop(V$(ACTV(V)),put (SPDCP(V,CP)):7:3);loop(V$(not ACTV(V)),put '');loop(V$(ACTV(V)),put (MVCP(V,CP+1)):7:3);loop(V$(not ACTV(V)),put '');loop(N$(ACTN(N)),put (MNCP(N,CP+1)):7:3); put /;
    );
);

