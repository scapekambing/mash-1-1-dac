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
    sin_lut[0]   = 32969;
    sin_lut[1]   = 33371;
    sin_lut[2]   = 33772;
    sin_lut[3]   = 34173;
    sin_lut[4]   = 34573;
    sin_lut[5]   = 34972;
    sin_lut[6]   = 35370;
    sin_lut[7]   = 35766;
    sin_lut[8]   = 36161;
    sin_lut[9]   = 36553;
    sin_lut[10]  = 36943;
    sin_lut[11]  = 37331;
    sin_lut[12]  = 37715;
    sin_lut[13]  = 38097;
    sin_lut[14]  = 38476;
    sin_lut[15]  = 38851;
    sin_lut[16]  = 39223;
    sin_lut[17]  = 39590;
    sin_lut[18]  = 39954;
    sin_lut[19]  = 40313;
    sin_lut[20]  = 40667;
    sin_lut[21]  = 41017;
    sin_lut[22]  = 41362;
    sin_lut[23]  = 41702;
    sin_lut[24]  = 42036;
    sin_lut[25]  = 42365;
    sin_lut[26]  = 42688;
    sin_lut[27]  = 43005;
    sin_lut[28]  = 43316;
    sin_lut[29]  = 43620;
    sin_lut[30]  = 43918;
    sin_lut[31]  = 44210;
    sin_lut[32]  = 44494;
    sin_lut[33]  = 44771;
    sin_lut[34]  = 45041;
    sin_lut[35]  = 45304;
    sin_lut[36]  = 45559;
    sin_lut[37]  = 45806;
    sin_lut[38]  = 46046;
    sin_lut[39]  = 46277;
    sin_lut[40]  = 46501;
    sin_lut[41]  = 46716;
    sin_lut[42]  = 46923;
    sin_lut[43]  = 47121;
    sin_lut[44]  = 47310;
    sin_lut[45]  = 47491;
    sin_lut[46]  = 47663;
    sin_lut[47]  = 47826;
    sin_lut[48]  = 47980;
    sin_lut[49]  = 48125;
    sin_lut[50]  = 48260;
    sin_lut[51]  = 48386;
    sin_lut[52]  = 48503;
    sin_lut[53]  = 48610;
    sin_lut[54]  = 48708;
    sin_lut[55]  = 48796;
    sin_lut[56]  = 48874;
    sin_lut[57]  = 48943;
    sin_lut[58]  = 49002;
    sin_lut[59]  = 49051;
    sin_lut[60]  = 49091;
    sin_lut[61]  = 49120;
    sin_lut[62]  = 49140;
    sin_lut[63]  = 49150;
    sin_lut[64]  = 49150;
    sin_lut[65]  = 49140;
    sin_lut[66]  = 49120;
    sin_lut[67]  = 49091;
    sin_lut[68]  = 49051;
    sin_lut[69]  = 49002;
    sin_lut[70]  = 48943;
    sin_lut[71]  = 48874;
    sin_lut[72]  = 48796;
    sin_lut[73]  = 48708;
    sin_lut[74]  = 48610;
    sin_lut[75]  = 48503;
    sin_lut[76]  = 48386;
    sin_lut[77]  = 48260;
    sin_lut[78]  = 48125;
    sin_lut[79]  = 47980;
    sin_lut[80]  = 47826;
    sin_lut[81]  = 47663;
    sin_lut[82]  = 47491;
    sin_lut[83]  = 47310;
    sin_lut[84]  = 47121;
    sin_lut[85]  = 46923;
    sin_lut[86]  = 46716;
    sin_lut[87]  = 46501;
    sin_lut[88]  = 46277;
    sin_lut[89]  = 46046;
    sin_lut[90]  = 45806;
    sin_lut[91]  = 45559;
    sin_lut[92]  = 45304;
    sin_lut[93]  = 45041;
    sin_lut[94]  = 44771;
    sin_lut[95]  = 44494;
    sin_lut[96]  = 44210;
    sin_lut[97]  = 43918;
    sin_lut[98]  = 43620;
    sin_lut[99]  = 43316;
    sin_lut[100] = 43005;
    sin_lut[101] = 42688;
    sin_lut[102] = 42365;
    sin_lut[103] = 42036;
    sin_lut[104] = 41702;
    sin_lut[105] = 41362;
    sin_lut[106] = 41017;
    sin_lut[107] = 40667;
    sin_lut[108] = 40313;
    sin_lut[109] = 39954;
    sin_lut[110] = 39590;
    sin_lut[111] = 39223;
    sin_lut[112] = 38851;
    sin_lut[113] = 38476;
    sin_lut[114] = 38097;
    sin_lut[115] = 37715;
    sin_lut[116] = 37331;
    sin_lut[117] = 36943;
    sin_lut[118] = 36553;
    sin_lut[119] = 36161;
    sin_lut[120] = 35766;
    sin_lut[121] = 35370;
    sin_lut[122] = 34972;
    sin_lut[123] = 34573;
    sin_lut[124] = 34173;
    sin_lut[125] = 33772;
    sin_lut[126] = 33371;
    sin_lut[127] = 32969;
    sin_lut[128] = 32566;
    sin_lut[129] = 32164;
    sin_lut[130] = 31763;
    sin_lut[131] = 31362;
    sin_lut[132] = 30962;
    sin_lut[133] = 30563;
    sin_lut[134] = 30165;
    sin_lut[135] = 29769;
    sin_lut[136] = 29374;
    sin_lut[137] = 28982;
    sin_lut[138] = 28592;
    sin_lut[139] = 28204;
    sin_lut[140] = 27820;
    sin_lut[141] = 27438;
    sin_lut[142] = 27059;
    sin_lut[143] = 26684;
    sin_lut[144] = 26312;
    sin_lut[145] = 25945;
    sin_lut[146] = 25581;
    sin_lut[147] = 25222;
    sin_lut[148] = 24868;
    sin_lut[149] = 24518;
    sin_lut[150] = 24173;
    sin_lut[151] = 23833;
    sin_lut[152] = 23499;
    sin_lut[153] = 23170;
    sin_lut[154] = 22847;
    sin_lut[155] = 22530;
    sin_lut[156] = 22219;
    sin_lut[157] = 21915;
    sin_lut[158] = 21617;
    sin_lut[159] = 21325;
    sin_lut[160] = 21041;
    sin_lut[161] = 20764;
    sin_lut[162] = 20494;
    sin_lut[163] = 20231;
    sin_lut[164] = 19976;
    sin_lut[165] = 19729;
    sin_lut[166] = 19489;
    sin_lut[167] = 19258;
    sin_lut[168] = 19034;
    sin_lut[169] = 18819;
    sin_lut[170] = 18612;
    sin_lut[171] = 18414;
    sin_lut[172] = 18225;
    sin_lut[173] = 18044;
    sin_lut[174] = 17872;
    sin_lut[175] = 17709;
    sin_lut[176] = 17555;
    sin_lut[177] = 17410;
    sin_lut[178] = 17275;
    sin_lut[179] = 17149;
    sin_lut[180] = 17032;
    sin_lut[181] = 16925;
    sin_lut[182] = 16827;
    sin_lut[183] = 16739;
    sin_lut[184] = 16661;
    sin_lut[185] = 16592;
    sin_lut[186] = 16533;
    sin_lut[187] = 16484;
    sin_lut[188] = 16444;
    sin_lut[189] = 16415;
    sin_lut[190] = 16395;
    sin_lut[191] = 16385;
    sin_lut[192] = 16385;
    sin_lut[193] = 16395;
    sin_lut[194] = 16415;
    sin_lut[195] = 16444;
    sin_lut[196] = 16484;
    sin_lut[197] = 16533;
    sin_lut[198] = 16592;
    sin_lut[199] = 16661;
    sin_lut[200] = 16739;
    sin_lut[201] = 16827;
    sin_lut[202] = 16925;
    sin_lut[203] = 17032;
    sin_lut[204] = 17149;
    sin_lut[205] = 17275;
    sin_lut[206] = 17410;
    sin_lut[207] = 17555;
    sin_lut[208] = 17709;
    sin_lut[209] = 17872;
    sin_lut[210] = 18044;
    sin_lut[211] = 18225;
    sin_lut[212] = 18414;
    sin_lut[213] = 18612;
    sin_lut[214] = 18819;
    sin_lut[215] = 19034;
    sin_lut[216] = 19258;
    sin_lut[217] = 19489;
    sin_lut[218] = 19729;
    sin_lut[219] = 19976;
    sin_lut[220] = 20231;
    sin_lut[221] = 20494;
    sin_lut[222] = 20764;
    sin_lut[223] = 21041;
    sin_lut[224] = 21325;
    sin_lut[225] = 21617;
    sin_lut[226] = 21915;
    sin_lut[227] = 22219;
    sin_lut[228] = 22530;
    sin_lut[229] = 22847;
    sin_lut[230] = 23170;
    sin_lut[231] = 23499;
    sin_lut[232] = 23833;
    sin_lut[233] = 24173;
    sin_lut[234] = 24518;
    sin_lut[235] = 24868;
    sin_lut[236] = 25222;
    sin_lut[237] = 25581;
    sin_lut[238] = 25945;
    sin_lut[239] = 26312;
    sin_lut[240] = 26684;
    sin_lut[241] = 27059;
    sin_lut[242] = 27438;
    sin_lut[243] = 27820;
    sin_lut[244] = 28204;
    sin_lut[245] = 28592;
    sin_lut[246] = 28982;
    sin_lut[247] = 29374;
    sin_lut[248] = 29769;
    sin_lut[249] = 30165;
    sin_lut[250] = 30563;
    sin_lut[251] = 30962;
    sin_lut[252] = 31362;
    sin_lut[253] = 31763;
    sin_lut[254] = 32164;
    sin_lut[255] = 32566;
  end
endmodule

`resetall
