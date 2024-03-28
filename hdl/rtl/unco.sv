/* verilog_format: off */
`timescale 1ns / 1ns
`default_nettype none
/* verilog_format: on */

module unco (
    input      tri          aclk,
    input      tri          arst_n,
    input      tri   [31:0] phase_shift,
    input      tri          dither_enable,
    input      tri   [31:0] s_axis_data_tdata,
    input      tri          s_axis_data_tvalid,
    output var logic        s_axis_data_tready,
    output var logic [15:0] m_axis_data_tdata,
    output var logic        m_axis_data_tvalid
);

  localparam integer ACC_INT_WIDTH = 8;
  localparam integer ACC_FRAC_WIDTH = 24;
  localparam integer WIDTH = 16;

  // phase accumulator widths
  localparam integer ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;


  // sin_lut generator signals
  logic [         WIDTH-1:0] sin_lut         [0:2**ACC_INT_WIDTH-1];
  logic [         WIDTH-1:0] current_sin_lut;


  // phase accumulator
  logic [     ACC_WIDTH-1:0] current_phase;
  logic [     ACC_WIDTH-1:0] dithered_phase;


  // phase dither with lfsr prn generator
  logic [ACC_FRAC_WIDTH-1:0] dither;
  logic                      feedback;


  // NCO operation
  always_ff @(posedge aclk) begin
    if (~arst_n) begin
      current_phase <= phase_shift;
      dither <= 0;
      m_axis_data_tdata <= 0;
      current_sin_lut <= 0;
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
    case (dither_enable)
      default: dithered_phase = current_phase + dither;
      1'b0: dithered_phase = current_phase;
    endcase

    feedback = dither[23] ^~ dither[22] ^~ dither[21] ^~ dither[16];
  end

  // depth is 2^ACC_INT_WIDTH
  initial begin
    sin_lut[0]   = 16585;
    sin_lut[1]   = 16987;
    sin_lut[2]   = 17388;
    sin_lut[3]   = 17789;
    sin_lut[4]   = 18189;
    sin_lut[5]   = 18588;
    sin_lut[6]   = 18986;
    sin_lut[7]   = 19382;
    sin_lut[8]   = 19777;
    sin_lut[9]   = 20169;
    sin_lut[10]  = 20559;
    sin_lut[11]  = 20947;
    sin_lut[12]  = 21331;
    sin_lut[13]  = 21713;
    sin_lut[14]  = 22092;
    sin_lut[15]  = 22467;
    sin_lut[16]  = 22838;
    sin_lut[17]  = 23206;
    sin_lut[18]  = 23570;
    sin_lut[19]  = 23929;
    sin_lut[20]  = 24283;
    sin_lut[21]  = 24633;
    sin_lut[22]  = 24978;
    sin_lut[23]  = 25318;
    sin_lut[24]  = 25652;
    sin_lut[25]  = 25981;
    sin_lut[26]  = 26304;
    sin_lut[27]  = 26621;
    sin_lut[28]  = 26932;
    sin_lut[29]  = 27236;
    sin_lut[30]  = 27534;
    sin_lut[31]  = 27825;
    sin_lut[32]  = 28110;
    sin_lut[33]  = 28387;
    sin_lut[34]  = 28657;
    sin_lut[35]  = 28920;
    sin_lut[36]  = 29175;
    sin_lut[37]  = 29422;
    sin_lut[38]  = 29662;
    sin_lut[39]  = 29893;
    sin_lut[40]  = 30117;
    sin_lut[41]  = 30332;
    sin_lut[42]  = 30538;
    sin_lut[43]  = 30737;
    sin_lut[44]  = 30926;
    sin_lut[45]  = 31107;
    sin_lut[46]  = 31279;
    sin_lut[47]  = 31442;
    sin_lut[48]  = 31596;
    sin_lut[49]  = 31740;
    sin_lut[50]  = 31876;
    sin_lut[51]  = 32002;
    sin_lut[52]  = 32119;
    sin_lut[53]  = 32226;
    sin_lut[54]  = 32324;
    sin_lut[55]  = 32412;
    sin_lut[56]  = 32490;
    sin_lut[57]  = 32559;
    sin_lut[58]  = 32618;
    sin_lut[59]  = 32667;
    sin_lut[60]  = 32707;
    sin_lut[61]  = 32736;
    sin_lut[62]  = 32756;
    sin_lut[63]  = 32766;
    sin_lut[64]  = 32766;
    sin_lut[65]  = 32756;
    sin_lut[66]  = 32736;
    sin_lut[67]  = 32707;
    sin_lut[68]  = 32667;
    sin_lut[69]  = 32618;
    sin_lut[70]  = 32559;
    sin_lut[71]  = 32490;
    sin_lut[72]  = 32412;
    sin_lut[73]  = 32324;
    sin_lut[74]  = 32226;
    sin_lut[75]  = 32119;
    sin_lut[76]  = 32002;
    sin_lut[77]  = 31876;
    sin_lut[78]  = 31740;
    sin_lut[79]  = 31596;
    sin_lut[80]  = 31442;
    sin_lut[81]  = 31279;
    sin_lut[82]  = 31107;
    sin_lut[83]  = 30926;
    sin_lut[84]  = 30737;
    sin_lut[85]  = 30538;
    sin_lut[86]  = 30332;
    sin_lut[87]  = 30117;
    sin_lut[88]  = 29893;
    sin_lut[89]  = 29662;
    sin_lut[90]  = 29422;
    sin_lut[91]  = 29175;
    sin_lut[92]  = 28920;
    sin_lut[93]  = 28657;
    sin_lut[94]  = 28387;
    sin_lut[95]  = 28110;
    sin_lut[96]  = 27825;
    sin_lut[97]  = 27534;
    sin_lut[98]  = 27236;
    sin_lut[99]  = 26932;
    sin_lut[100] = 26621;
    sin_lut[101] = 26304;
    sin_lut[102] = 25981;
    sin_lut[103] = 25652;
    sin_lut[104] = 25318;
    sin_lut[105] = 24978;
    sin_lut[106] = 24633;
    sin_lut[107] = 24283;
    sin_lut[108] = 23929;
    sin_lut[109] = 23570;
    sin_lut[110] = 23206;
    sin_lut[111] = 22838;
    sin_lut[112] = 22467;
    sin_lut[113] = 22092;
    sin_lut[114] = 21713;
    sin_lut[115] = 21331;
    sin_lut[116] = 20947;
    sin_lut[117] = 20559;
    sin_lut[118] = 20169;
    sin_lut[119] = 19777;
    sin_lut[120] = 19382;
    sin_lut[121] = 18986;
    sin_lut[122] = 18588;
    sin_lut[123] = 18189;
    sin_lut[124] = 17789;
    sin_lut[125] = 17388;
    sin_lut[126] = 16987;
    sin_lut[127] = 16585;
    sin_lut[128] = 16182;
    sin_lut[129] = 15780;
    sin_lut[130] = 15379;
    sin_lut[131] = 14978;
    sin_lut[132] = 14578;
    sin_lut[133] = 14179;
    sin_lut[134] = 13781;
    sin_lut[135] = 13385;
    sin_lut[136] = 12990;
    sin_lut[137] = 12598;
    sin_lut[138] = 12208;
    sin_lut[139] = 11820;
    sin_lut[140] = 11436;
    sin_lut[141] = 11054;
    sin_lut[142] = 10675;
    sin_lut[143] = 10300;
    sin_lut[144] = 9929;
    sin_lut[145] = 9561;
    sin_lut[146] = 9197;
    sin_lut[147] = 8838;
    sin_lut[148] = 8484;
    sin_lut[149] = 8134;
    sin_lut[150] = 7789;
    sin_lut[151] = 7449;
    sin_lut[152] = 7115;
    sin_lut[153] = 6786;
    sin_lut[154] = 6463;
    sin_lut[155] = 6146;
    sin_lut[156] = 5835;
    sin_lut[157] = 5531;
    sin_lut[158] = 5233;
    sin_lut[159] = 4942;
    sin_lut[160] = 4657;
    sin_lut[161] = 4380;
    sin_lut[162] = 4110;
    sin_lut[163] = 3847;
    sin_lut[164] = 3592;
    sin_lut[165] = 3345;
    sin_lut[166] = 3105;
    sin_lut[167] = 2874;
    sin_lut[168] = 2650;
    sin_lut[169] = 2435;
    sin_lut[170] = 2229;
    sin_lut[171] = 2030;
    sin_lut[172] = 1841;
    sin_lut[173] = 1660;
    sin_lut[174] = 1488;
    sin_lut[175] = 1325;
    sin_lut[176] = 1171;
    sin_lut[177] = 1027;
    sin_lut[178] = 891;
    sin_lut[179] = 765;
    sin_lut[180] = 648;
    sin_lut[181] = 541;
    sin_lut[182] = 443;
    sin_lut[183] = 355;
    sin_lut[184] = 277;
    sin_lut[185] = 208;
    sin_lut[186] = 149;
    sin_lut[187] = 100;
    sin_lut[188] = 60;
    sin_lut[189] = 31;
    sin_lut[190] = 11;
    sin_lut[191] = 1;
    sin_lut[192] = 1;
    sin_lut[193] = 11;
    sin_lut[194] = 31;
    sin_lut[195] = 60;
    sin_lut[196] = 100;
    sin_lut[197] = 149;
    sin_lut[198] = 208;
    sin_lut[199] = 277;
    sin_lut[200] = 355;
    sin_lut[201] = 443;
    sin_lut[202] = 541;
    sin_lut[203] = 648;
    sin_lut[204] = 765;
    sin_lut[205] = 891;
    sin_lut[206] = 1027;
    sin_lut[207] = 1171;
    sin_lut[208] = 1325;
    sin_lut[209] = 1488;
    sin_lut[210] = 1660;
    sin_lut[211] = 1841;
    sin_lut[212] = 2030;
    sin_lut[213] = 2229;
    sin_lut[214] = 2435;
    sin_lut[215] = 2650;
    sin_lut[216] = 2874;
    sin_lut[217] = 3105;
    sin_lut[218] = 3345;
    sin_lut[219] = 3592;
    sin_lut[220] = 3847;
    sin_lut[221] = 4110;
    sin_lut[222] = 4380;
    sin_lut[223] = 4657;
    sin_lut[224] = 4942;
    sin_lut[225] = 5233;
    sin_lut[226] = 5531;
    sin_lut[227] = 5835;
    sin_lut[228] = 6146;
    sin_lut[229] = 6463;
    sin_lut[230] = 6786;
    sin_lut[231] = 7115;
    sin_lut[232] = 7449;
    sin_lut[233] = 7789;
    sin_lut[234] = 8134;
    sin_lut[235] = 8484;
    sin_lut[236] = 8838;
    sin_lut[237] = 9197;
    sin_lut[238] = 9561;
    sin_lut[239] = 9929;
    sin_lut[240] = 10300;
    sin_lut[241] = 10675;
    sin_lut[242] = 11054;
    sin_lut[243] = 11436;
    sin_lut[244] = 11820;
    sin_lut[245] = 12208;
    sin_lut[246] = 12598;
    sin_lut[247] = 12990;
    sin_lut[248] = 13385;
    sin_lut[249] = 13781;
    sin_lut[250] = 14179;
    sin_lut[251] = 14578;
    sin_lut[252] = 14978;
    sin_lut[253] = 15379;
    sin_lut[254] = 15780;
    sin_lut[255] = 16182;
  end
endmodule

`resetall
