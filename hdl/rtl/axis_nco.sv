// `default_nettype none

module axis_nco (
    input aclk,
    input arst_n,

    input [31:0] phase_shift,

    input [31:0] s_axis_data_tdata,
    input        s_axis_data_tvalid,

    output logic s_axis_data_tready,

    output logic signed [15:0] m_axis_data_tdata,
    output logic               m_axis_data_tvalid
);

  localparam ACC_INT_WIDTH = 8;
  localparam ACC_FRAC_WIDTH = 24;
  localparam WIDTH = 16;

  // phase accumulator widths
  localparam ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;


  // sin_lut generator signals
  logic signed [         WIDTH-1:0] sin_lut         [0:2**ACC_INT_WIDTH-1];
  logic signed [         WIDTH-1:0] current_sin_lut;


  // phase accumulator
  logic        [     ACC_WIDTH-1:0] current_phase;
  logic        [     ACC_WIDTH-1:0] dithered_phase;


  // phase dither with lfsr prn generator
  logic        [ACC_FRAC_WIDTH-1:0] dither;
  logic                             feedback;


  // NCO operation
  always_ff @(posedge aclk) begin
    if (~arst_n) begin
      current_phase <= phase_shift;
      dither <= 0;
      m_axis_data_tdata <= 0;
      m_axis_data_tvalid <= 0;
    end else begin
      // phase accumulator logic
      dither <= {dither[ACC_FRAC_WIDTH-2:0], feedback};
      current_phase <= current_phase + s_axis_data_tdata;  // phi[n] = phi[n-1] + 2^W * f/fs

      // if tvalid is high this means a new frequency
      // has been received and we need to update the step
      // if tready is high this means we have a new sample
      if (s_axis_data_tready && s_axis_data_tvalid) begin
        // phase to amplitude lut 
        m_axis_data_tdata <= sin_lut[dithered_phase[ACC_WIDTH-1:ACC_FRAC_WIDTH]];
        current_sin_lut <= sin_lut[current_phase[ACC_WIDTH-1:ACC_FRAC_WIDTH]];
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
    sin_lut[0]   = 302;
    sin_lut[1]   = 905;
    sin_lut[2]   = 1507;
    sin_lut[3]   = 2108;
    sin_lut[4]   = 2709;
    sin_lut[5]   = 3307;
    sin_lut[6]   = 3904;
    sin_lut[7]   = 4498;
    sin_lut[8]   = 5090;
    sin_lut[9]   = 5678;
    sin_lut[10]  = 6263;
    sin_lut[11]  = 6845;
    sin_lut[12]  = 7422;
    sin_lut[13]  = 7995;
    sin_lut[14]  = 8562;
    sin_lut[15]  = 9125;
    sin_lut[16]  = 9682;
    sin_lut[17]  = 10234;
    sin_lut[18]  = 10779;
    sin_lut[19]  = 11318;
    sin_lut[20]  = 11850;
    sin_lut[21]  = 12375;
    sin_lut[22]  = 12892;
    sin_lut[23]  = 13401;
    sin_lut[24]  = 13903;
    sin_lut[25]  = 14396;
    sin_lut[26]  = 14881;
    sin_lut[27]  = 15356;
    sin_lut[28]  = 15822;
    sin_lut[29]  = 16279;
    sin_lut[30]  = 16726;
    sin_lut[31]  = 17163;
    sin_lut[32]  = 17589;
    sin_lut[33]  = 18005;
    sin_lut[34]  = 18410;
    sin_lut[35]  = 18804;
    sin_lut[36]  = 19187;
    sin_lut[37]  = 19558;
    sin_lut[38]  = 19917;
    sin_lut[39]  = 20264;
    sin_lut[40]  = 20600;
    sin_lut[41]  = 20922;
    sin_lut[42]  = 21232;
    sin_lut[43]  = 21530;
    sin_lut[44]  = 21814;
    sin_lut[45]  = 22085;
    sin_lut[46]  = 22343;
    sin_lut[47]  = 22587;
    sin_lut[48]  = 22818;
    sin_lut[49]  = 23035;
    sin_lut[50]  = 23239;
    sin_lut[51]  = 23428;
    sin_lut[52]  = 23603;
    sin_lut[53]  = 23764;
    sin_lut[54]  = 23910;
    sin_lut[55]  = 24042;
    sin_lut[56]  = 24160;
    sin_lut[57]  = 24263;
    sin_lut[58]  = 24352;
    sin_lut[59]  = 24426;
    sin_lut[60]  = 24485;
    sin_lut[61]  = 24529;
    sin_lut[62]  = 24559;
    sin_lut[63]  = 24573;
    sin_lut[64]  = 24573;
    sin_lut[65]  = 24559;
    sin_lut[66]  = 24529;
    sin_lut[67]  = 24485;
    sin_lut[68]  = 24426;
    sin_lut[69]  = 24352;
    sin_lut[70]  = 24263;
    sin_lut[71]  = 24160;
    sin_lut[72]  = 24042;
    sin_lut[73]  = 23910;
    sin_lut[74]  = 23764;
    sin_lut[75]  = 23603;
    sin_lut[76]  = 23428;
    sin_lut[77]  = 23239;
    sin_lut[78]  = 23035;
    sin_lut[79]  = 22818;
    sin_lut[80]  = 22587;
    sin_lut[81]  = 22343;
    sin_lut[82]  = 22085;
    sin_lut[83]  = 21814;
    sin_lut[84]  = 21530;
    sin_lut[85]  = 21232;
    sin_lut[86]  = 20922;
    sin_lut[87]  = 20600;
    sin_lut[88]  = 20264;
    sin_lut[89]  = 19917;
    sin_lut[90]  = 19558;
    sin_lut[91]  = 19187;
    sin_lut[92]  = 18804;
    sin_lut[93]  = 18410;
    sin_lut[94]  = 18005;
    sin_lut[95]  = 17589;
    sin_lut[96]  = 17163;
    sin_lut[97]  = 16726;
    sin_lut[98]  = 16279;
    sin_lut[99]  = 15822;
    sin_lut[100] = 15356;
    sin_lut[101] = 14881;
    sin_lut[102] = 14396;
    sin_lut[103] = 13903;
    sin_lut[104] = 13401;
    sin_lut[105] = 12892;
    sin_lut[106] = 12375;
    sin_lut[107] = 11850;
    sin_lut[108] = 11318;
    sin_lut[109] = 10779;
    sin_lut[110] = 10234;
    sin_lut[111] = 9682;
    sin_lut[112] = 9125;
    sin_lut[113] = 8562;
    sin_lut[114] = 7995;
    sin_lut[115] = 7422;
    sin_lut[116] = 6845;
    sin_lut[117] = 6263;
    sin_lut[118] = 5678;
    sin_lut[119] = 5090;
    sin_lut[120] = 4498;
    sin_lut[121] = 3904;
    sin_lut[122] = 3307;
    sin_lut[123] = 2709;
    sin_lut[124] = 2108;
    sin_lut[125] = 1507;
    sin_lut[126] = 905;
    sin_lut[127] = 302;
    sin_lut[128] = -302;
    sin_lut[129] = -905;
    sin_lut[130] = -1507;
    sin_lut[131] = -2108;
    sin_lut[132] = -2709;
    sin_lut[133] = -3307;
    sin_lut[134] = -3904;
    sin_lut[135] = -4498;
    sin_lut[136] = -5090;
    sin_lut[137] = -5678;
    sin_lut[138] = -6263;
    sin_lut[139] = -6845;
    sin_lut[140] = -7422;
    sin_lut[141] = -7995;
    sin_lut[142] = -8562;
    sin_lut[143] = -9125;
    sin_lut[144] = -9682;
    sin_lut[145] = -10234;
    sin_lut[146] = -10779;
    sin_lut[147] = -11318;
    sin_lut[148] = -11850;
    sin_lut[149] = -12375;
    sin_lut[150] = -12892;
    sin_lut[151] = -13401;
    sin_lut[152] = -13903;
    sin_lut[153] = -14396;
    sin_lut[154] = -14881;
    sin_lut[155] = -15356;
    sin_lut[156] = -15822;
    sin_lut[157] = -16279;
    sin_lut[158] = -16726;
    sin_lut[159] = -17163;
    sin_lut[160] = -17589;
    sin_lut[161] = -18005;
    sin_lut[162] = -18410;
    sin_lut[163] = -18804;
    sin_lut[164] = -19187;
    sin_lut[165] = -19558;
    sin_lut[166] = -19917;
    sin_lut[167] = -20264;
    sin_lut[168] = -20600;
    sin_lut[169] = -20922;
    sin_lut[170] = -21232;
    sin_lut[171] = -21530;
    sin_lut[172] = -21814;
    sin_lut[173] = -22085;
    sin_lut[174] = -22343;
    sin_lut[175] = -22587;
    sin_lut[176] = -22818;
    sin_lut[177] = -23035;
    sin_lut[178] = -23239;
    sin_lut[179] = -23428;
    sin_lut[180] = -23603;
    sin_lut[181] = -23764;
    sin_lut[182] = -23910;
    sin_lut[183] = -24042;
    sin_lut[184] = -24160;
    sin_lut[185] = -24263;
    sin_lut[186] = -24352;
    sin_lut[187] = -24426;
    sin_lut[188] = -24485;
    sin_lut[189] = -24529;
    sin_lut[190] = -24559;
    sin_lut[191] = -24573;
    sin_lut[192] = -24573;
    sin_lut[193] = -24559;
    sin_lut[194] = -24529;
    sin_lut[195] = -24485;
    sin_lut[196] = -24426;
    sin_lut[197] = -24352;
    sin_lut[198] = -24263;
    sin_lut[199] = -24160;
    sin_lut[200] = -24042;
    sin_lut[201] = -23910;
    sin_lut[202] = -23764;
    sin_lut[203] = -23603;
    sin_lut[204] = -23428;
    sin_lut[205] = -23239;
    sin_lut[206] = -23035;
    sin_lut[207] = -22818;
    sin_lut[208] = -22587;
    sin_lut[209] = -22343;
    sin_lut[210] = -22085;
    sin_lut[211] = -21814;
    sin_lut[212] = -21530;
    sin_lut[213] = -21232;
    sin_lut[214] = -20922;
    sin_lut[215] = -20600;
    sin_lut[216] = -20264;
    sin_lut[217] = -19917;
    sin_lut[218] = -19558;
    sin_lut[219] = -19187;
    sin_lut[220] = -18804;
    sin_lut[221] = -18410;
    sin_lut[222] = -18005;
    sin_lut[223] = -17589;
    sin_lut[224] = -17163;
    sin_lut[225] = -16726;
    sin_lut[226] = -16279;
    sin_lut[227] = -15822;
    sin_lut[228] = -15356;
    sin_lut[229] = -14881;
    sin_lut[230] = -14396;
    sin_lut[231] = -13903;
    sin_lut[232] = -13401;
    sin_lut[233] = -12892;
    sin_lut[234] = -12375;
    sin_lut[235] = -11850;
    sin_lut[236] = -11318;
    sin_lut[237] = -10779;
    sin_lut[238] = -10234;
    sin_lut[239] = -9682;
    sin_lut[240] = -9125;
    sin_lut[241] = -8562;
    sin_lut[242] = -7995;
    sin_lut[243] = -7422;
    sin_lut[244] = -6845;
    sin_lut[245] = -6263;
    sin_lut[246] = -5678;
    sin_lut[247] = -5090;
    sin_lut[248] = -4498;
    sin_lut[249] = -3904;
    sin_lut[250] = -3307;
    sin_lut[251] = -2709;
    sin_lut[252] = -2108;
    sin_lut[253] = -1507;
    sin_lut[254] = -905;
    sin_lut[255] = -302;
  end
endmodule

// `default_nettype wire
