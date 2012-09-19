
filename_mp='~/runMake/tmp_mp_mode0-all_b1-3/depot/rollup/rollup_MultP_MP_DC_ICC_v1_2012_09_18_16_36.csv';
filename='~/FPGen_Mult_Results/rollup_MultP64_DC_ICC_v1_2012_09_04_02_50.csv';
bitwidth=53;








%
%==================================
%



    fid = fopen(filename);
    data = {};
    headers = {};
    
    % read the headers
    textline = fgetl(fid);
    firstline = textscan(textline, '%s', 'delimiter', ',');
    headers = firstline{1};
    
    
    % parse the headers to generate the format to read data
    format = [];
    for i = 1:length(headers)
        header = headers{i};
        idx_cost = strfind(header, 'COST');
        idx_perf = strfind(header, 'PERF');
        if ( isempty(idx_cost) & isempty(idx_perf)) % this is not a COST or PERF entry
            format = [format, '%s ']; % treat as a string type data
        else
            format = [format, '%f ']; % else treat as double type
        end
    end
        
    % read data
    data = textscan(fid, format, 'delimiter', ',', 'BufSize', 1000000000);
    fclose(fid);    
      
    % extract data from cell array C
    BoothType = data{strmatch('top_MultiplierP.MultiplierP.BoothType', headers)};
    TreeType = data{strmatch('top_MultiplierP.MultiplierP.TreeType', headers)};
    Designware = data{strmatch('top_MultiplierP.MultiplierP.Designware_MODE', headers)};
    Vth = data{strmatch('TOP_VT', headers)};
    Vdd = data{strmatch('TOP_Voltage', headers)};
    
    COST_Mapped_Clk_Period_nS = data{strmatch('COST_Mapped_Clk_Period_nS', headers)};
    COST_Mapped_Avg_Dyn_Energy_pJ = data{strmatch('COST_Mapped_Avg_Dyn_Energy_pJ', headers)};
    
    COST_Optimized_Clk_Period_nS = data{strmatch('COST_Optimized_Clk_Period_nS', headers)};
    COST_Optimized_Avg_Dyn_Energy_pJ = data{strmatch('COST_Optimized_Avg_Dyn_Energy_pJ', headers)};
    
    COST_Routed_Clk_Period_nS = data{strmatch('COST_Routed_Clk_Period_nS', headers)};
    COST_Routed_Avg_Dyn_Energy_pJ = data{strmatch('COST_Routed_Avg_Dyn_Energy_pJ', headers)};
    
    clear data;
      
    % filter data
    ED_data = {COST_Mapped_Clk_Period_nS, COST_Mapped_Avg_Dyn_Energy_pJ, ...
        COST_Routed_Clk_Period_nS, COST_Routed_Avg_Dyn_Energy_pJ, ...
        COST_Optimized_Clk_Period_nS, COST_Optimized_Avg_Dyn_Energy_pJ, ...
        Vth, Vdd, TreeType, BoothType, Designware};
    
    Designware_data = filterCellArray(ED_data, ED_data{11}, 'ON');
    OurDesign_data = filterCellArray(ED_data, ED_data{11}, 'OFF');  
    
    OurDesign_Booth = cell(4, 1);
    for i = 1:4
        OurDesign_Booth{i} = filterCellArray(OurDesign_data, OurDesign_data{10}, num2str(i));
    end
    
    Wallace = filterCellArray(OurDesign_data, OurDesign_data{9}, 'Wallace');
    OS1 = filterCellArray(OurDesign_data, OurDesign_data{9}, 'OS1');
    Array = filterCellArray(OurDesign_data, OurDesign_data{9}, 'Array');
	ZM = filterCellArray(OurDesign_data, OurDesign_data{9}, 'ZM');
    
    Wallace_Booth = cell(4, 1);
    OS1_Booth = cell(4, 1);
    for i = 1:4
        Wallace_Booth{i} = filterCellArray(Wallace, Wallace{10}, num2str(i));
        OS1_Booth{i} = filterCellArray(OS1, OS1{10}, num2str(i));
    end
    
    % filter vt and vdd, just for sanity check
    Designware_lvt_0v9 = filterCellArray(Designware_data, Designware_data{7},'lvt', Designware_data{8},  '0.9');   
    Wallace_lvt_0v9 = filterCellArray(OurDesign_data, OurDesign_data{7},'lvt', OurDesign_data{8},  '0.9', OurDesign_data{9}, 'Wallace');   
    Wallace_lvt_0v9_Booth = cell(4, 1);
    OS1_lvt_0v9 = filterCellArray(OurDesign_data, OurDesign_data{7},'lvt', OurDesign_data{8},  '0.9', OurDesign_data{9}, 'OS1');   
    OS1_lvt_0v9_Booth = cell(4, 1);
    for i = 1:4
        Wallace_lvt_0v9_Booth{i} = filterCellArray(Wallace_lvt_0v9, Wallace_lvt_0v9{10}, num2str(i));
        OS1_lvt_0v9_Booth{i} = filterCellArray(OS1_lvt_0v9, OS1_lvt_0v9{10}, num2str(i));
    end
    
    % get frontier
    for i = 1:2:6
        [Designware_data{i}, Designware_data{i+1}] = getFrontier(Designware_data{i}, Designware_data{i+1});
        [OurDesign_data{i}, OurDesign_data{i+1}] = getFrontier(OurDesign_data{i}, OurDesign_data{i+1});
        [Wallace{i}, Wallace{i+1}] = getFrontier(Wallace{i}, Wallace{i+1});
        [OS1{i}, OS1{i+1}] = getFrontier(OS1{i}, OS1{i+1});
        [Array{i}, Array{i+1}] = getFrontier(Array{i}, Array{i+1});
        [ZM{i}, ZM{i+1}] = getFrontier(ZM{i}, ZM{i+1});
        [Designware_lvt_0v9{i}, Designware_lvt_0v9{i+1}] = getFrontier(Designware_lvt_0v9{i}, Designware_lvt_0v9{i+1});
        [Wallace_lvt_0v9{i}, Wallace_lvt_0v9{i+1}] = getFrontier(Wallace_lvt_0v9{i}, Wallace_lvt_0v9{i+1});
    end
    
    for i = 1:4
        for j = 1:2:6
        [OurDesign_Booth{i}{j},  OurDesign_Booth{i}{j+1}] = getFrontier(OurDesign_Booth{i}{j},  OurDesign_Booth{i}{j+1});
        [Wallace_Booth{i}{j},  Wallace_Booth{i}{j+1}] = getFrontier(Wallace_Booth{i}{j},  Wallace_Booth{i}{j+1});        
        [OS1_Booth{i}{j},  OS1_Booth{i}{j+1}] = getFrontier(OS1_Booth{i}{j},  OS1_Booth{i}{j+1});        
        [Wallace_lvt_0v9_Booth{i}{j},  Wallace_lvt_0v9_Booth{i}{j+1}] = getFrontier(Wallace_lvt_0v9_Booth{i}{j},  Wallace_lvt_0v9_Booth{i}{j+1});
        end
    end
    
   


%
%===============================
%








    fid = fopen(filename_mp);
    data = {};
    headers = {};
    
    % read the headers
    textline  = fgetl(fid);
    textline2 = fgetl(fid);
    firstline = textscan(textline, '%s', 'delimiter', ',');
    secondline = textscan(textline2, '%s', 'delimiter', ',');
    first_data = secondline{1};
    headers = firstline{1};
    
    
    % parse the headers to generate the format to read data
    format = [];
    for i = 1:length(headers)
        header = headers{i};
        idx_cost = strfind(header, 'COST');
        idx_perf = strfind(header, 'PERF');
        if ( isempty(idx_cost) & isempty(idx_perf)) % this is not a COST or PERF entry
            format = [format, '%s ']; % treat as a string type data
        else
            format = [format, '%f ']; % else treat as double type
        end
    end
        
    % read data
    data = textscan(fid, format, 'delimiter', ',', 'BufSize', 1000000000);
    fclose(fid);
    
    
    % extract data from cell array C
    %BoothType = data{strmatch('top_MultiplierP.MultiplierP.BoothType', headers)};
    %TreeType = data{strmatch('top_MultiplierP.MultiplierP.TreeType', headers)};
    %Designware = data{strmatch('top_MultiplierP.MultiplierP.Designware_MODE', headers)};
    Vth = data{strmatch('TOP_VT', headers)};
    Vdd = data{strmatch('TOP_Voltage', headers)};
    
    LOG_design = data{strmatch('LOG_design', headers)};
    BoothType = Vdd;
    TreeType = Vdd;
    Designware = Vdd;
    for i = 1:size(data{1,88},1)
        [v1 v2 v3 v4 v5] = regexp(char(data{1,88}(i)), '''top_MultiplierP.MultiplierP.BoothType'': ([0-9])');
        BoothType{i} = char(v5{1});
        [v1 v2 v3 v4 v5] = regexp(char(data{1,88}(i)),  '''top_MultiplierP.MultiplierP.TreeType'': ''([a-zA-Z0-9]+)''');
        TreeType{i} = char(v5{1});
        [v1 v2 v3 v4 v5] = regexp(char(data{1,88}(i)),  '''top_MultiplierP.MultiplierP.Designware_MODE'': ''([a-zA-Z]+)''');
        Designware{i} = char(v5{1});
    end
    
    Vth = data{strmatch('TOP_VT', headers)};
    Vdd = data{strmatch('TOP_Voltage', headers)};
    
    COST_Mapped_Clk_Period_nS = data{strmatch('COST_Mapped_Clk_Period_nS', headers)};
    COST_Mapped_Avg_Dyn_Energy_pJ = data{strmatch('COST_Mapped_Avg_Dyn_Energy_pJ', headers)};
    
    COST_Optimized_Clk_Period_nS = data{strmatch('COST_Optimized_Clk_Period_nS', headers)};
    COST_Optimized_Avg_Dyn_Energy_pJ = data{strmatch('COST_Optimized_Avg_Dyn_Energy_pJ', headers)};
    
    COST_Routed_Clk_Period_nS = data{strmatch('COST_Routed_Clk_Period_nS', headers)};
    COST_Routed_Avg_Dyn_Energy_pJ = data{strmatch('COST_Routed_Avg_Dyn_Energy_pJ', headers)};
    
    clear data;
      
    % filter data
    ED_data = {COST_Mapped_Clk_Period_nS, COST_Mapped_Avg_Dyn_Energy_pJ, ...
        COST_Routed_Clk_Period_nS, COST_Routed_Avg_Dyn_Energy_pJ, ...
        COST_Optimized_Clk_Period_nS, COST_Optimized_Avg_Dyn_Energy_pJ, ...
        Vth, Vdd, TreeType, BoothType, Designware};
    
    %Designware_data = filterCellArray(ED_data, ED_data{11}, 'ON');
    OurDesign_data = ED_data;
    %filterCellArray(ED_data, ED_data{11}, 'OFF');  
    
        OurDesign_Booth = cell(4, 1);
    for i = 1:4
        OurDesign_Booth{i} = filterCellArray(OurDesign_data, OurDesign_data{10}, num2str(i));
    end

     
    Wallace_MP = filterCellArray(OurDesign_data, OurDesign_data{9}, 'Wallace');
    OS1_MP     = filterCellArray(OurDesign_data, OurDesign_data{9}, 'OS1');
    Array_MP   = filterCellArray(OurDesign_data, OurDesign_data{9}, 'Array');
	ZM_MP      = filterCellArray(OurDesign_data, OurDesign_data{9}, 'ZM');
    
    Wallace_Booth_MP = cell(4, 1);
    OS1_Booth_MP = cell(4, 1);
    for i = 1:3
        Wallace_Booth_MP{i} = filterCellArray(Wallace_MP, Wallace_MP{10}, num2str(i));
        OS1_Booth_MP{i} = filterCellArray(OS1_MP, OS1_MP{10}, num2str(i));
    end
    
    % filter vt and vdd, just for sanity check
    Wallace_lvt_0v9_MP = filterCellArray(OurDesign_data, OurDesign_data{7},'lvt', OurDesign_data{8},  '0.9', OurDesign_data{9}, 'Wallace');   
    Wallace_lvt_0v9_Booth_MP = cell(4, 1);
    OS1_lvt_0v9_MP = filterCellArray(OurDesign_data, OurDesign_data{7},'lvt', OurDesign_data{8},  '0.9', OurDesign_data{9}, 'OS1');   
    OS1_lvt_0v9_Booth_MP = cell(4, 1);
    
    for i = 1:3
        Wallace_lvt_0v9_Booth_MP{i} = filterCellArray(Wallace_lvt_0v9_MP, Wallace_lvt_0v9_MP{10}, num2str(i));
        OS1_lvt_0v9_Booth_MP{i} = filterCellArray(OS1_lvt_0v9_MP, OS1_lvt_0v9_MP{10}, num2str(i));
    end
    
    % get frontier
    for i = 1:2:6
        [OurDesign_data{i}, OurDesign_data{i+1}] = getFrontier(OurDesign_data{i}, OurDesign_data{i+1});
        [Wallace_MP{i}, Wallace_MP{i+1}] = getFrontier(Wallace_MP{i}, Wallace_MP{i+1});
        [OS1_MP{i}, OS1_MP{i+1}] = getFrontier(OS1_MP{i}, OS1_MP{i+1});
        [Array_MP{i}, Array_MP{i+1}] = getFrontier(Array_MP{i}, Array_MP{i+1});
        [ZM_MP{i}, ZM_MP{i+1}] = getFrontier(ZM_MP{i}, ZM_MP{i+1});
        [Wallace_lvt_0v9_MP{i}, Wallace_lvt_0v9_MP{i+1}] = getFrontier(Wallace_lvt_0v9_MP{i}, Wallace_lvt_0v9_MP{i+1});
    end
    
    for i = 1:3
        for j = 1:2:6
        [OurDesign_Booth{i}{j},  OurDesign_Booth{i}{j+1}] = getFrontier(OurDesign_Booth{i}{j},  OurDesign_Booth{i}{j+1});
        [Wallace_Booth_MP{i}{j},  Wallace_Booth_MP{i}{j+1}] = getFrontier(Wallace_Booth_MP{i}{j},  Wallace_Booth_MP{i}{j+1});        
        [OS1_Booth_MP{i}{j},  OS1_Booth_MP{i}{j+1}] = getFrontier(OS1_Booth_MP{i}{j},  OS1_Booth_MP{i}{j+1});        
        [Wallace_lvt_0v9_Booth_MP{i}{j},  Wallace_lvt_0v9_Booth_MP{i}{j+1}] = getFrontier(Wallace_lvt_0v9_Booth_MP{i}{j},  Wallace_lvt_0v9_Booth_MP{i}{j+1});
        [OS1_lvt_0v9_Booth_MP{i}{j},  OS1_lvt_0v9_Booth_MP{i}{j+1}] = getFrontier(OS1_lvt_0v9_Booth_MP{i}{j},  OS1_lvt_0v9_Booth_MP{i}{j+1});
        end
    end
    
      
    % plot graphs
    enrj_ind = 6; % uninformed 4, informed 6
    time_ind = 5; % uninformed 3, informed 5
    
    
    figure(2);
    
    plot(Wallace_Booth{2}{time_ind}, Wallace_Booth{2}{enrj_ind},'--m*',...
        Wallace_Booth_MP{2}{time_ind}, Wallace_Booth_MP{2}{enrj_ind},'-bo',...
        Wallace_Booth{3}{time_ind}, Wallace_Booth{3}{enrj_ind},'--c+',...
        Wallace_Booth_MP{3}{time_ind}, Wallace_Booth_MP{3}{enrj_ind},'-r^',...
       'LineWidth',2,'MarkerSize',9);
    
   
   set(gca,'fontsize',12);
   %title(['Overhead of Multi-precision Multipliers with Wallace tree'],'fontsize',18);
     
   xlabel('Delay (ns)','fontsize',18),grid
   ylabel('Dynamic Energy (pJ)','fontsize',18)

   legend('Booth 2 Double precision only',...
          'Booth 2 Multi-precision',...
          'Booth 3 Double precision only',...
          'Booth 3 Multi-precision',...
          'fontsize',14);

   saveas(gcf, ['MultP_MP_', num2str(bitwidth), '_Wlc'], 'pdf');
    
   
       
   figure(4);
   plot(OS1_Booth{2}{time_ind}   , OS1_Booth{2}{enrj_ind}   ,'--m*',...
        Xi                       , OS_2_i                   ,'-.m>',...
        OS1_Booth_MP{2}{time_ind}, OS1_Booth_MP{2}{enrj_ind},'-bo',...
        OS1_Booth{3}{time_ind}   , OS1_Booth{3}{enrj_ind}   ,'--c+',...
        OS1_Booth_MP{3}{time_ind}, OS1_Booth_MP{3}{enrj_ind},'-r^',...
       'LineWidth',2,'MarkerSize',9);
   set(gca,'fontsize',12);
   %title(['Overhead of Multi-precision Multipliers with OS1 tree'],'fontsize',18);
   
  
   xlabel('Delay (ns)','fontsize',18),grid
   ylabel('Dynamic Energy (pJ)','fontsize',18)
   legend('Booth 2 Double precision only',...
          'Booth 2 Double precision Interpolate',...
          'Booth 2 Multi-precision',...
          'Booth 3 Double precision only',...
          'Booth 3 Multi-precision',...
          'fontsize',14);
   saveas(gcf, ['MultP_MP_', num2str(bitwidth), '_OS1'], 'pdf');


   
   Xi = 1.6:-0.1:0.9;

   Wallace_2_err = getError (Xi, Wallace_Booth_MP{2}{time_ind}, Wallace_Booth_MP{2}{enrj_ind}, Wallace_Booth{2}{time_ind}, Wallace_Booth{2}{enrj_ind});
   Wallace_3_err = getError (Xi, Wallace_Booth_MP{3}{time_ind}, Wallace_Booth_MP{3}{enrj_ind}, Wallace_Booth{3}{time_ind}, Wallace_Booth{3}{enrj_ind});
   OS_2_err = getError (Xi, OS1_Booth_MP{2}{time_ind}, OS1_Booth_MP{2}{enrj_ind}, OS1_Booth{2}{time_ind}, OS1_Booth{2}{enrj_ind});
   OS_3_err = getError (Xi, OS1_Booth_MP{3}{time_ind}, OS1_Booth_MP{3}{enrj_ind}, OS1_Booth{3}{time_ind}, OS1_Booth{3}{enrj_ind});
   
    
   figure(5);
   plot(Xi, OS_2_err     ,'--m*',...
        Xi, Wallace_2_err,'-g+',...
        Xi, OS_3_err     ,'--b^',...
        Xi, Wallace_3_err,'-co',...
       'LineWidth',2,'MarkerSize',9);
   set(gca,'fontsize',12);
   title('Relative Overhead of Multi-precision Multipliers','fontsize',18);
 
  
   xlabel('Delay (ns)','fontsize',18),grid
   ylabel('Energy Overhead (%)','fontsize',18)
   legend('OS Booth 2 ',...
          'Wallace Booth 2 ',...
          'OS Booth 3 ',...
          'WallaceBooth 3 ',...
          'fontsize',14);
        
    