// `default_nettype none

module axis_nco 
(
    input                                                   aclk,
    input                                                   arst_n,

    input               [31:0]                              phase_shift,

    input               [31:0]                              s_axis_data_tdata,
    input                                                   s_axis_data_tvalid,

    output logic                                            s_axis_data_tready,

    output logic signed [15:0]                              m_axis_data_tdata,
    output logic                                            m_axis_data_tvalid
);
    
    localparam  ACC_INT_WIDTH = 8;
    localparam  ACC_FRAC_WIDTH = 24;
    localparam  WIDTH = 16;

    // phase accumulator widths
    localparam  ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;


    // sin_lut generator signals
    logic signed [WIDTH-1:0]            sin_lut [0:2**ACC_INT_WIDTH-1];
    logic signed [WIDTH-1:0]            current_sin_lut;


    // phase accumulator
    logic [ACC_WIDTH-1:0]   current_phase;
    logic [ACC_WIDTH-1:0]   dithered_phase;

    
    // phase dither with lfsr prn generator
    logic         [ACC_FRAC_WIDTH-1:0]            dither;
    logic                                       feedback;


    // NCO operation
    always_ff @(posedge aclk) begin
        if (~arst_n) begin
            current_phase <= phase_shift;
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
       sin_lut[0]   =      402;
       sin_lut[1]   =     1206;
       sin_lut[2]   =     2009;
       sin_lut[3]   =     2811;
       sin_lut[4]   =     3612;
       sin_lut[5]   =     4410;
       sin_lut[6]   =     5205;
       sin_lut[7]   =     5998;
       sin_lut[8]   =     6786;
       sin_lut[9]   =     7571;
       sin_lut[10]   =     8351;
       sin_lut[11]   =     9126;
       sin_lut[12]   =     9896;
       sin_lut[13]   =    10659;
       sin_lut[14]   =    11417;
       sin_lut[15]   =    12167;
       sin_lut[16]   =    12910;
       sin_lut[17]   =    13645;
       sin_lut[18]   =    14372;
       sin_lut[19]   =    15090;
       sin_lut[20]   =    15800;
       sin_lut[21]   =    16499;
       sin_lut[22]   =    17189;
       sin_lut[23]   =    17869;
       sin_lut[24]   =    18537;
       sin_lut[25]   =    19195;
       sin_lut[26]   =    19841;
       sin_lut[27]   =    20475;
       sin_lut[28]   =    21096;
       sin_lut[29]   =    21705;
       sin_lut[30]   =    22301;
       sin_lut[31]   =    22884;
       sin_lut[32]   =    23452;
       sin_lut[33]   =    24007;
       sin_lut[34]   =    24547;
       sin_lut[35]   =    25072;
       sin_lut[36]   =    25582;
       sin_lut[37]   =    26077;
       sin_lut[38]   =    26556;
       sin_lut[39]   =    27019;
       sin_lut[40]   =    27466;
       sin_lut[41]   =    27896;
       sin_lut[42]   =    28310;
       sin_lut[43]   =    28706;
       sin_lut[44]   =    29085;
       sin_lut[45]   =    29447;
       sin_lut[46]   =    29791;
       sin_lut[47]   =    30117;
       sin_lut[48]   =    30424;
       sin_lut[49]   =    30714;
       sin_lut[50]   =    30985;
       sin_lut[51]   =    31237;
       sin_lut[52]   =    31470;
       sin_lut[53]   =    31685;
       sin_lut[54]   =    31880;
       sin_lut[55]   =    32057;
       sin_lut[56]   =    32213;
       sin_lut[57]   =    32351;
       sin_lut[58]   =    32469;
       sin_lut[59]   =    32567;
       sin_lut[60]   =    32646;
       sin_lut[61]   =    32705;
       sin_lut[62]   =    32745;
       sin_lut[63]   =    32765;
       sin_lut[64]   =    32765;
       sin_lut[65]   =    32745;
       sin_lut[66]   =    32705;
       sin_lut[67]   =    32646;
       sin_lut[68]   =    32567;
       sin_lut[69]   =    32469;
       sin_lut[70]   =    32351;
       sin_lut[71]   =    32213;
       sin_lut[72]   =    32057;
       sin_lut[73]   =    31880;
       sin_lut[74]   =    31685;
       sin_lut[75]   =    31470;
       sin_lut[76]   =    31237;
       sin_lut[77]   =    30985;
       sin_lut[78]   =    30714;
       sin_lut[79]   =    30424;
       sin_lut[80]   =    30117;
       sin_lut[81]   =    29791;
       sin_lut[82]   =    29447;
       sin_lut[83]   =    29085;
       sin_lut[84]   =    28706;
       sin_lut[85]   =    28310;
       sin_lut[86]   =    27896;
       sin_lut[87]   =    27466;
       sin_lut[88]   =    27019;
       sin_lut[89]   =    26556;
       sin_lut[90]   =    26077;
       sin_lut[91]   =    25582;
       sin_lut[92]   =    25072;
       sin_lut[93]   =    24547;
       sin_lut[94]   =    24007;
       sin_lut[95]   =    23452;
       sin_lut[96]   =    22884;
       sin_lut[97]   =    22301;
       sin_lut[98]   =    21705;
       sin_lut[99]   =    21096;
       sin_lut[100]   =    20475;
       sin_lut[101]   =    19841;
       sin_lut[102]   =    19195;
       sin_lut[103]   =    18537;
       sin_lut[104]   =    17869;
       sin_lut[105]   =    17189;
       sin_lut[106]   =    16499;
       sin_lut[107]   =    15800;
       sin_lut[108]   =    15090;
       sin_lut[109]   =    14372;
       sin_lut[110]   =    13645;
       sin_lut[111]   =    12910;
       sin_lut[112]   =    12167;
       sin_lut[113]   =    11417;
       sin_lut[114]   =    10659;
       sin_lut[115]   =     9896;
       sin_lut[116]   =     9126;
       sin_lut[117]   =     8351;
       sin_lut[118]   =     7571;
       sin_lut[119]   =     6786;
       sin_lut[120]   =     5998;
       sin_lut[121]   =     5205;
       sin_lut[122]   =     4410;
       sin_lut[123]   =     3612;
       sin_lut[124]   =     2811;
       sin_lut[125]   =     2009;
       sin_lut[126]   =     1206;
       sin_lut[127]   =      402;
       sin_lut[128]   =     -402;
       sin_lut[129]   =    -1206;
       sin_lut[130]   =    -2009;
       sin_lut[131]   =    -2811;
       sin_lut[132]   =    -3612;
       sin_lut[133]   =    -4410;
       sin_lut[134]   =    -5205;
       sin_lut[135]   =    -5998;
       sin_lut[136]   =    -6786;
       sin_lut[137]   =    -7571;
       sin_lut[138]   =    -8351;
       sin_lut[139]   =    -9126;
       sin_lut[140]   =    -9896;
       sin_lut[141]   =   -10659;
       sin_lut[142]   =   -11417;
       sin_lut[143]   =   -12167;
       sin_lut[144]   =   -12910;
       sin_lut[145]   =   -13645;
       sin_lut[146]   =   -14372;
       sin_lut[147]   =   -15090;
       sin_lut[148]   =   -15800;
       sin_lut[149]   =   -16499;
       sin_lut[150]   =   -17189;
       sin_lut[151]   =   -17869;
       sin_lut[152]   =   -18537;
       sin_lut[153]   =   -19195;
       sin_lut[154]   =   -19841;
       sin_lut[155]   =   -20475;
       sin_lut[156]   =   -21096;
       sin_lut[157]   =   -21705;
       sin_lut[158]   =   -22301;
       sin_lut[159]   =   -22884;
       sin_lut[160]   =   -23452;
       sin_lut[161]   =   -24007;
       sin_lut[162]   =   -24547;
       sin_lut[163]   =   -25072;
       sin_lut[164]   =   -25582;
       sin_lut[165]   =   -26077;
       sin_lut[166]   =   -26556;
       sin_lut[167]   =   -27019;
       sin_lut[168]   =   -27466;
       sin_lut[169]   =   -27896;
       sin_lut[170]   =   -28310;
       sin_lut[171]   =   -28706;
       sin_lut[172]   =   -29085;
       sin_lut[173]   =   -29447;
       sin_lut[174]   =   -29791;
       sin_lut[175]   =   -30117;
       sin_lut[176]   =   -30424;
       sin_lut[177]   =   -30714;
       sin_lut[178]   =   -30985;
       sin_lut[179]   =   -31237;
       sin_lut[180]   =   -31470;
       sin_lut[181]   =   -31685;
       sin_lut[182]   =   -31880;
       sin_lut[183]   =   -32057;
       sin_lut[184]   =   -32213;
       sin_lut[185]   =   -32351;
       sin_lut[186]   =   -32469;
       sin_lut[187]   =   -32567;
       sin_lut[188]   =   -32646;
       sin_lut[189]   =   -32705;
       sin_lut[190]   =   -32745;
       sin_lut[191]   =   -32765;
       sin_lut[192]   =   -32765;
       sin_lut[193]   =   -32745;
       sin_lut[194]   =   -32705;
       sin_lut[195]   =   -32646;
       sin_lut[196]   =   -32567;
       sin_lut[197]   =   -32469;
       sin_lut[198]   =   -32351;
       sin_lut[199]   =   -32213;
       sin_lut[200]   =   -32057;
       sin_lut[201]   =   -31880;
       sin_lut[202]   =   -31685;
       sin_lut[203]   =   -31470;
       sin_lut[204]   =   -31237;
       sin_lut[205]   =   -30985;
       sin_lut[206]   =   -30714;
       sin_lut[207]   =   -30424;
       sin_lut[208]   =   -30117;
       sin_lut[209]   =   -29791;
       sin_lut[210]   =   -29447;
       sin_lut[211]   =   -29085;
       sin_lut[212]   =   -28706;
       sin_lut[213]   =   -28310;
       sin_lut[214]   =   -27896;
       sin_lut[215]   =   -27466;
       sin_lut[216]   =   -27019;
       sin_lut[217]   =   -26556;
       sin_lut[218]   =   -26077;
       sin_lut[219]   =   -25582;
       sin_lut[220]   =   -25072;
       sin_lut[221]   =   -24547;
       sin_lut[222]   =   -24007;
       sin_lut[223]   =   -23452;
       sin_lut[224]   =   -22884;
       sin_lut[225]   =   -22301;
       sin_lut[226]   =   -21705;
       sin_lut[227]   =   -21096;
       sin_lut[228]   =   -20475;
       sin_lut[229]   =   -19841;
       sin_lut[230]   =   -19195;
       sin_lut[231]   =   -18537;
       sin_lut[232]   =   -17869;
       sin_lut[233]   =   -17189;
       sin_lut[234]   =   -16499;
       sin_lut[235]   =   -15800;
       sin_lut[236]   =   -15090;
       sin_lut[237]   =   -14372;
       sin_lut[238]   =   -13645;
       sin_lut[239]   =   -12910;
       sin_lut[240]   =   -12167;
       sin_lut[241]   =   -11417;
       sin_lut[242]   =   -10659;
       sin_lut[243]   =    -9896;
       sin_lut[244]   =    -9126;
       sin_lut[245]   =    -8351;
       sin_lut[246]   =    -7571;
       sin_lut[247]   =    -6786;
       sin_lut[248]   =    -5998;
       sin_lut[249]   =    -5205;
       sin_lut[250]   =    -4410;
       sin_lut[251]   =    -3612;
       sin_lut[252]   =    -2811;
       sin_lut[253]   =    -2009;
       sin_lut[254]   =    -1206;
       sin_lut[255]   =     -402;
    end
endmodule

// `default_nettype wire
