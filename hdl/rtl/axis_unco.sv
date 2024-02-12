`timescale 1ns/1ps

// unsigned nco
module axis_unco 
(
    input                                                   aclk,
    input                                                   arst_n,

    input               [31:0]                              s_axis_data_tdata,
    input                                                   s_axis_data_tvalid,

    output logic                                            s_axis_data_tready,

    output logic        [15:0]                              m_axis_data_tdata,
    output logic                                            m_axis_data_tvalid
);
    
    localparam  ACC_INT_WIDTH = 8;
    localparam  ACC_FRAC_WIDTH = 24;
    localparam  WIDTH = 16;

    // phase accumulator widths
    localparam  ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;


    // sin_lut generator signals
    logic  [WIDTH-1:0]            sin_lut [0:2**ACC_INT_WIDTH-1];
    logic  [WIDTH-1:0]            current_sin_lut;


    // phase accumulator
    logic [ACC_WIDTH-1:0]   current_phase;
    logic [ACC_WIDTH-1:0]   dithered_phase;

    
    // phase dither with lfsr prn generator
    logic         [ACC_FRAC_WIDTH-1:0]            dither;
    logic                                       feedback;


    // NCO operation
    always_ff @(posedge aclk) begin
        if (~arst_n) begin
            current_phase <= 0;
            dither <= 0;
            m_axis_data_tdata <= 0;
            m_axis_data_tvalid <= 0;
        end
        else begin
            // phase accumulator logic
            dither <= {dither[ACC_FRAC_WIDTH-2:0], feedback};
            current_phase <= current_phase + s_axis_data_tdata; // phi[n] = phi[n-1] + 2^W * f/fs

            // if tvalid is high this means a new frequency
            // has been received and we need to update the step
            // if tready is high this means we have a new sample
            if(s_axis_data_tready && s_axis_data_tvalid) begin
                // phase to amplitude lut 
                m_axis_data_tdata <= sin_lut[dithered_phase[ACC_WIDTH-1:ACC_FRAC_WIDTH]];
                current_sin_lut   <= sin_lut[current_phase[ACC_WIDTH-1:ACC_FRAC_WIDTH]];
                m_axis_data_tvalid <= 1'b1;
            end
        end
    end


    always_comb begin
        s_axis_data_tready = 1'b1;

        // dither logic
        // dithered_phase = current_phase + dither;
        dithered_phase = current_phase; 
        feedback = dither[23] ^~ dither[22] ^~ dither[21] ^~ dither[16];
    end

    // depth is 2^ACC_INT_WIDTH
    initial begin
        sin_lut[0]   =    33169;
        sin_lut[1]   =    33973;
        sin_lut[2]   =    34776;
        sin_lut[3]   =    35578;
        sin_lut[4]   =    36379;
        sin_lut[5]   =    37177;
        sin_lut[6]   =    37972;
        sin_lut[7]   =    38765;
        sin_lut[8]   =    39553;
        sin_lut[9]   =    40338;
        sin_lut[10]   =    41118;
        sin_lut[11]   =    41893;
        sin_lut[12]   =    42663;
        sin_lut[13]   =    43426;
        sin_lut[14]   =    44184;
        sin_lut[15]   =    44934;
        sin_lut[16]   =    45677;
        sin_lut[17]   =    46412;
        sin_lut[18]   =    47139;
        sin_lut[19]   =    47857;
        sin_lut[20]   =    48567;
        sin_lut[21]   =    49266;
        sin_lut[22]   =    49956;
        sin_lut[23]   =    50636;
        sin_lut[24]   =    51304;
        sin_lut[25]   =    51962;
        sin_lut[26]   =    52608;
        sin_lut[27]   =    53242;
        sin_lut[28]   =    53863;
        sin_lut[29]   =    54472;
        sin_lut[30]   =    55068;
        sin_lut[31]   =    55651;
        sin_lut[32]   =    56219;
        sin_lut[33]   =    56774;
        sin_lut[34]   =    57314;
        sin_lut[35]   =    57839;
        sin_lut[36]   =    58349;
        sin_lut[37]   =    58844;
        sin_lut[38]   =    59323;
        sin_lut[39]   =    59786;
        sin_lut[40]   =    60233;
        sin_lut[41]   =    60663;
        sin_lut[42]   =    61077;
        sin_lut[43]   =    61473;
        sin_lut[44]   =    61852;
        sin_lut[45]   =    62214;
        sin_lut[46]   =    62558;
        sin_lut[47]   =    62884;
        sin_lut[48]   =    63191;
        sin_lut[49]   =    63481;
        sin_lut[50]   =    63752;
        sin_lut[51]   =    64004;
        sin_lut[52]   =    64237;
        sin_lut[53]   =    64452;
        sin_lut[54]   =    64647;
        sin_lut[55]   =    64824;
        sin_lut[56]   =    64980;
        sin_lut[57]   =    65118;
        sin_lut[58]   =    65236;
        sin_lut[59]   =    65334;
        sin_lut[60]   =    65413;
        sin_lut[61]   =    65472;
        sin_lut[62]   =    65512;
        sin_lut[63]   =    65532;
        sin_lut[64]   =    65532;
        sin_lut[65]   =    65512;
        sin_lut[66]   =    65472;
        sin_lut[67]   =    65413;
        sin_lut[68]   =    65334;
        sin_lut[69]   =    65236;
        sin_lut[70]   =    65118;
        sin_lut[71]   =    64980;
        sin_lut[72]   =    64824;
        sin_lut[73]   =    64647;
        sin_lut[74]   =    64452;
        sin_lut[75]   =    64237;
        sin_lut[76]   =    64004;
        sin_lut[77]   =    63752;
        sin_lut[78]   =    63481;
        sin_lut[79]   =    63191;
        sin_lut[80]   =    62884;
        sin_lut[81]   =    62558;
        sin_lut[82]   =    62214;
        sin_lut[83]   =    61852;
        sin_lut[84]   =    61473;
        sin_lut[85]   =    61077;
        sin_lut[86]   =    60663;
        sin_lut[87]   =    60233;
        sin_lut[88]   =    59786;
        sin_lut[89]   =    59323;
        sin_lut[90]   =    58844;
        sin_lut[91]   =    58349;
        sin_lut[92]   =    57839;
        sin_lut[93]   =    57314;
        sin_lut[94]   =    56774;
        sin_lut[95]   =    56219;
        sin_lut[96]   =    55651;
        sin_lut[97]   =    55068;
        sin_lut[98]   =    54472;
        sin_lut[99]   =    53863;
        sin_lut[100]   =    53242;
        sin_lut[101]   =    52608;
        sin_lut[102]   =    51962;
        sin_lut[103]   =    51304;
        sin_lut[104]   =    50636;
        sin_lut[105]   =    49956;
        sin_lut[106]   =    49266;
        sin_lut[107]   =    48567;
        sin_lut[108]   =    47857;
        sin_lut[109]   =    47139;
        sin_lut[110]   =    46412;
        sin_lut[111]   =    45677;
        sin_lut[112]   =    44934;
        sin_lut[113]   =    44184;
        sin_lut[114]   =    43426;
        sin_lut[115]   =    42663;
        sin_lut[116]   =    41893;
        sin_lut[117]   =    41118;
        sin_lut[118]   =    40338;
        sin_lut[119]   =    39553;
        sin_lut[120]   =    38765;
        sin_lut[121]   =    37972;
        sin_lut[122]   =    37177;
        sin_lut[123]   =    36379;
        sin_lut[124]   =    35578;
        sin_lut[125]   =    34776;
        sin_lut[126]   =    33973;
        sin_lut[127]   =    33169;
        sin_lut[128]   =    32365;
        sin_lut[129]   =    31561;
        sin_lut[130]   =    30758;
        sin_lut[131]   =    29956;
        sin_lut[132]   =    29155;
        sin_lut[133]   =    28357;
        sin_lut[134]   =    27562;
        sin_lut[135]   =    26769;
        sin_lut[136]   =    25981;
        sin_lut[137]   =    25196;
        sin_lut[138]   =    24416;
        sin_lut[139]   =    23641;
        sin_lut[140]   =    22871;
        sin_lut[141]   =    22108;
        sin_lut[142]   =    21350;
        sin_lut[143]   =    20600;
        sin_lut[144]   =    19857;
        sin_lut[145]   =    19122;
        sin_lut[146]   =    18395;
        sin_lut[147]   =    17677;
        sin_lut[148]   =    16967;
        sin_lut[149]   =    16268;
        sin_lut[150]   =    15578;
        sin_lut[151]   =    14898;
        sin_lut[152]   =    14230;
        sin_lut[153]   =    13572;
        sin_lut[154]   =    12926;
        sin_lut[155]   =    12292;
        sin_lut[156]   =    11671;
        sin_lut[157]   =    11062;
        sin_lut[158]   =    10466;
        sin_lut[159]   =     9883;
        sin_lut[160]   =     9315;
        sin_lut[161]   =     8760;
        sin_lut[162]   =     8220;
        sin_lut[163]   =     7695;
        sin_lut[164]   =     7185;
        sin_lut[165]   =     6690;
        sin_lut[166]   =     6211;
        sin_lut[167]   =     5748;
        sin_lut[168]   =     5301;
        sin_lut[169]   =     4871;
        sin_lut[170]   =     4457;
        sin_lut[171]   =     4061;
        sin_lut[172]   =     3682;
        sin_lut[173]   =     3320;
        sin_lut[174]   =     2976;
        sin_lut[175]   =     2650;
        sin_lut[176]   =     2343;
        sin_lut[177]   =     2053;
        sin_lut[178]   =     1782;
        sin_lut[179]   =     1530;
        sin_lut[180]   =     1297;
        sin_lut[181]   =     1082;
        sin_lut[182]   =      887;
        sin_lut[183]   =      710;
        sin_lut[184]   =      554;
        sin_lut[185]   =      416;
        sin_lut[186]   =      298;
        sin_lut[187]   =      200;
        sin_lut[188]   =      121;
        sin_lut[189]   =       62;
        sin_lut[190]   =       22;
        sin_lut[191]   =        2;
        sin_lut[192]   =        2;
        sin_lut[193]   =       22;
        sin_lut[194]   =       62;
        sin_lut[195]   =      121;
        sin_lut[196]   =      200;
        sin_lut[197]   =      298;
        sin_lut[198]   =      416;
        sin_lut[199]   =      554;
        sin_lut[200]   =      710;
        sin_lut[201]   =      887;
        sin_lut[202]   =     1082;
        sin_lut[203]   =     1297;
        sin_lut[204]   =     1530;
        sin_lut[205]   =     1782;
        sin_lut[206]   =     2053;
        sin_lut[207]   =     2343;
        sin_lut[208]   =     2650;
        sin_lut[209]   =     2976;
        sin_lut[210]   =     3320;
        sin_lut[211]   =     3682;
        sin_lut[212]   =     4061;
        sin_lut[213]   =     4457;
        sin_lut[214]   =     4871;
        sin_lut[215]   =     5301;
        sin_lut[216]   =     5748;
        sin_lut[217]   =     6211;
        sin_lut[218]   =     6690;
        sin_lut[219]   =     7185;
        sin_lut[220]   =     7695;
        sin_lut[221]   =     8220;
        sin_lut[222]   =     8760;
        sin_lut[223]   =     9315;
        sin_lut[224]   =     9883;
        sin_lut[225]   =    10466;
        sin_lut[226]   =    11062;
        sin_lut[227]   =    11671;
        sin_lut[228]   =    12292;
        sin_lut[229]   =    12926;
        sin_lut[230]   =    13572;
        sin_lut[231]   =    14230;
        sin_lut[232]   =    14898;
        sin_lut[233]   =    15578;
        sin_lut[234]   =    16268;
        sin_lut[235]   =    16967;
        sin_lut[236]   =    17677;
        sin_lut[237]   =    18395;
        sin_lut[238]   =    19122;
        sin_lut[239]   =    19857;
        sin_lut[240]   =    20600;
        sin_lut[241]   =    21350;
        sin_lut[242]   =    22108;
        sin_lut[243]   =    22871;
        sin_lut[244]   =    23641;
        sin_lut[245]   =    24416;
        sin_lut[246]   =    25196;
        sin_lut[247]   =    25981;
        sin_lut[248]   =    26769;
        sin_lut[249]   =    27562;
        sin_lut[250]   =    28357;
        sin_lut[251]   =    29155;
        sin_lut[252]   =    29956;
        sin_lut[253]   =    30758;
        sin_lut[254]   =    31561;
        sin_lut[255]   =    32365;
    end
endmodule
