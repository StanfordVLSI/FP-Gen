function plot_for_fpgen(filename, bitwidth)
    
    fid = fopen(filename);
    data = {};
    headers = {};
    
    % load latency matrix
    LM = importdata('CFP2000_test_latency_matrix.csv');
    LM = LM.data;
    
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
        if ( isempty(idx_cost) && isempty(idx_perf)) % this is not a COST or PERF entry
            format = [format, '%s ']; % treat as a string type data
        else
            format = [format, '%f ']; % else treat as double type
        end
    end
        
    % read data
    data = textscan(fid, format, 'delimiter', ',', 'BufSize', 1000000000);
    fclose(fid);    
      
    % extract data from cell array C
    arch = data{strmatch('top_FPGen.FPGen.Architecture', headers)}; 
    FMA_BoothType = data{strmatch('top_FPGen.FPGen.FMA.MulShift.MUL0.BoothType', headers)};
    FMA_TreeType = data{strmatch('top_FPGen.FPGen.FMA.MulShift.MUL0.TreeType', headers)};
    FMA_PipelineDepth = data{strmatch('top_FPGen.FPGen.FMA.PipelineDepth', headers)}; 
    CMA_BoothType = data{strmatch('top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType', headers)};
    CMA_TreeType = data{strmatch('top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType', headers)};
    CMA_MulPipelineDepth = data{strmatch('top_FPGen.FPGen.CMA.MulPipelineDepth', headers)};    
    CMA_PipelineDepth = data{strmatch('top_FPGen.FPGen.CMA.PipelineDepth', headers)}; 
    DW_PipelineDepth = data{strmatch('top_FPGen.FPGen.DW_FMA.PipelineDepth', headers)}; 
    Vth = data{strmatch('TOP_VT', headers)};
    Vdd = data{strmatch('TOP_Voltage', headers)};
    
    COST_Mapped_Cell_Area_mmsq = data{strmatch('COST_Mapped_Cell_Area_mmsq', headers)};
    COST_Mapped_Clk_Period_nS = data{strmatch('COST_Mapped_Clk_Period_nS', headers)};
    
    COST_Mapped_Add_Dyn_Energy_pJ = data{strmatch('COST_Mapped_Add_Dyn_Energy_pJ', headers)};
    COST_Mapped_Add_Dyn_Power_mW = data{strmatch('COST_Mapped_Add_Dyn_Power_mW', headers)};
    COST_Mapped_Add_Leak_Power_mW = data{strmatch('COST_Mapped_Add_Leak_Power_mW', headers)};
    COST_Mapped_Avg_Dyn_Energy_pJ = data{strmatch('COST_Mapped_Avg_Dyn_Energy_pJ', headers)};
    COST_Mapped_Avg_Dyn_Power_mW = data{strmatch('COST_Mapped_Avg_Dyn_Power_mW', headers)};
    COST_Mapped_Avg_Leak_Power_mW = data{strmatch('COST_Mapped_Avg_Leak_Power_mW', headers)};
    COST_Mapped_MulAdd_Dyn_Energy_pJ = data{strmatch('COST_Mapped_MulAdd_Dyn_Energy_pJ', headers)};
    COST_Mapped_MulAdd_Dyn_Power_mW = data{strmatch('COST_Mapped_MulAdd_Dyn_Power_mW', headers)};
    COST_Mapped_MulAdd_Leak_Power_mW = data{strmatch('COST_Mapped_MulAdd_Leak_Power_mW', headers)};
    COST_Mapped_Mul_Dyn_Energy_pJ = data{strmatch('COST_Mapped_Mul_Dyn_Energy_pJ', headers)};
    COST_Mapped_Mul_Dyn_Power_mW = data{strmatch('COST_Mapped_Mul_Dyn_Power_mW', headers)};
    COST_Mapped_Mul_Leak_Power_mW = data{strmatch('COST_Mapped_Mul_Leak_Power_mW', headers)};
    
    index = [2:(length(arch) + 1)]';
    
    clear data;
    
    % re-scan the file for dumping csv file for frontiers
    fid = fopen(filename);
    i = 1;
    inputcsv = cell(length(arch) + 1, 1);
    inputcsv{1} = fgetl(fid);
    while ~feof(fid)
        i = i + 1;
        inputcsv{i} = fgetl(fid);
    end
    fclose(fid);
    
    % process the data
    Add_OpPerCyc = 1;
    Avg_OpPerCyc = 1.3;
    MulAdd_OpPerCyc = 2;
    Mul_OpPerCyc = 1;
    
    Mapped_Add_mWperGFLOPS = (COST_Mapped_Add_Dyn_Energy_pJ + COST_Mapped_Add_Leak_Power_mW .* COST_Mapped_Clk_Period_nS) ./ Add_OpPerCyc;
    Mapped_Avg_mWperGFLOPS = (COST_Mapped_Avg_Dyn_Energy_pJ + COST_Mapped_Avg_Leak_Power_mW .* COST_Mapped_Clk_Period_nS) ./ Avg_OpPerCyc;
    Mapped_MulAdd_mWperGFLOPS = (COST_Mapped_MulAdd_Dyn_Energy_pJ + COST_Mapped_MulAdd_Leak_Power_mW .* COST_Mapped_Clk_Period_nS) ./ MulAdd_OpPerCyc;
    Mapped_Mul_mWperGFLOPS = (COST_Mapped_Mul_Dyn_Energy_pJ + COST_Mapped_Mul_Leak_Power_mW .* COST_Mapped_Clk_Period_nS) ./ Mul_OpPerCyc;
    
    Mapped_Add_mmsqPerGFLOPS = COST_Mapped_Cell_Area_mmsq .* COST_Mapped_Clk_Period_nS ./ Add_OpPerCyc;
    Mapped_Avg_mmsqPerGFLOPS = COST_Mapped_Cell_Area_mmsq .* COST_Mapped_Clk_Period_nS ./ Avg_OpPerCyc;
    Mapped_MulAdd_mmsqPerGFLOPS = COST_Mapped_Cell_Area_mmsq .* COST_Mapped_Clk_Period_nS ./ MulAdd_OpPerCyc;
    Mapped_Mul_mmsqPerGFLOPS = COST_Mapped_Cell_Area_mmsq .* COST_Mapped_Clk_Period_nS ./ Mul_OpPerCyc;
    
    Delay = NaN(size(COST_Mapped_Clk_Period_nS));
    for i = 1:length(COST_Mapped_Clk_Period_nS) 
        % muladd_latency: pipe_depth-1 (FMA and CMA), pipe_depth (DW)
        % acc_latency is pipe_depth-1 (FMA),add_pipeline_depth(CMA, pipe_depth - 1 - mulpipe_depth), pipe_depth (DW)
        if (~isempty(regexp(arch(i), '\<FMA\>', 'once')))
            muladd_latency = str2double(FMA_PipelineDepth(i)) - 1;
            acc_latency = str2double(FMA_PipelineDepth(i)) - 1;
        elseif (~isempty(regexp(arch(i), '\<CMA\>', 'once')))           
            muladd_latency = str2double(CMA_PipelineDepth(i)) - 1;
            acc_latency = str2double(CMA_PipelineDepth(i)) - 1 - str2double(CMA_MulPipelineDepth(i));
        else
            muladd_latency = str2double(DW_PipelineDepth(i));
            acc_latency = str2double(DW_PipelineDepth(i));
        end               
        L = LatencyPenalty( LM, muladd_latency, acc_latency );
        Delay(i) = COST_Mapped_Clk_Period_nS(i) * (L + 1);
    end
    
    
    % filter data
    Mapped_data = {Mapped_Add_mmsqPerGFLOPS, Mapped_Add_mWperGFLOPS, ...
        Mapped_Avg_mmsqPerGFLOPS, Mapped_Avg_mWperGFLOPS, ...
        Mapped_Mul_mmsqPerGFLOPS, Mapped_Mul_mWperGFLOPS, ...
        Mapped_MulAdd_mmsqPerGFLOPS, Mapped_MulAdd_mWperGFLOPS, ...
        Mapped_Avg_mWperGFLOPS, Delay, ...
        FMA_PipelineDepth, CMA_PipelineDepth, DW_PipelineDepth, index};
    
    FMA_Mapped_data = filterCellArray(Mapped_data, arch, 'FMA');
    CMA_Mapped_data = filterCellArray(Mapped_data, arch, 'CMA');
    DW_Mapped_data = filterCellArray(Mapped_data, arch, 'DW_FMA');
    
    % Combine FMA and CMA data into one data set
    FPGen_Mapped_data = cell(size(FMA_Mapped_data));
    for i = 1:length(FPGen_Mapped_data)
        FPGen_Mapped_data{i} = [FMA_Mapped_data{i}; CMA_Mapped_data{i}];
    end
    
    FMA_pipeline = cell(12, 1);
    CMA_pipeline = cell(12, 1);
    DW_pipeline = cell(12, 1);
    for i = 1:12
        FMA_pipeline{i} = filterCellArray(FMA_Mapped_data, FMA_Mapped_data{11}, num2str(i));
        CMA_pipeline{i} = filterCellArray(CMA_Mapped_data, CMA_Mapped_data{12}, num2str(i));
        DW_pipeline{i} = filterCellArray(DW_Mapped_data, DW_Mapped_data{13}, num2str(i));
    end
    
    % Combine FMA and CMA data into one data set
    FPGen_pipeline = cell(size(FMA_pipeline));
    for i = 1:length(FPGen_pipeline)      
        FPGen_pipeline{i} = cell(size(FPGen_Mapped_data));
        for j = 1:length(FPGen_pipeline{i})
            if(~isempty(FMA_pipeline{i}{j}))
                FPGen_pipeline{i}{j} = [FPGen_pipeline{i}{j}; FMA_pipeline{i}{j}];
            end           
            if(~isempty(CMA_pipeline{i}{j}))
                FPGen_pipeline{i}{j} = [FPGen_pipeline{i}{j}; CMA_pipeline{i}{j}];
            end
        end
    end
    
    
    
    % get frontier
    for i = 1:2:10
        [FPGen_Mapped_data{i}, FPGen_Mapped_data{i+1}, index_FPen{i}] = getFrontier(FPGen_Mapped_data{i}, FPGen_Mapped_data{i+1});
        [FMA_Mapped_data{i}, FMA_Mapped_data{i+1}, index_FMA{i}] = getFrontier(FMA_Mapped_data{i}, FMA_Mapped_data{i+1});
        [CMA_Mapped_data{i}, CMA_Mapped_data{i+1}, index_CMA{i}] = getFrontier(CMA_Mapped_data{i}, CMA_Mapped_data{i+1});
        [DW_Mapped_data{i}, DW_Mapped_data{i+1}, index_DW{i}] = getFrontier(DW_Mapped_data{i}, DW_Mapped_data{i+1});
    end
    
    
    for i = 3:12
        for j = 1:2:10
        [FMA_pipeline{i}{j},  FMA_pipeline{i}{j+1}] = getFrontier(FMA_pipeline{i}{j},  FMA_pipeline{i}{j+1});          
        [CMA_pipeline{i}{j},  CMA_pipeline{i}{j+1}] = getFrontier(CMA_pipeline{i}{j},  CMA_pipeline{i}{j+1});  
        [FPGen_pipeline{i}{j},  FPGen_pipeline{i}{j+1}] = getFrontier(FPGen_pipeline{i}{j},  FPGen_pipeline{i}{j+1});        
        [DW_pipeline{i}{j},  DW_pipeline{i}{j+1}] = getFrontier(DW_pipeline{i}{j},  DW_pipeline{i}{j+1});
        end
    end
    
    
    % plot graphs
%     figure(1);
%     plot(FPGen_Mapped_data{1}, FPGen_Mapped_data{2},'-rx',...
%        FPGen_Mapped_data{3}, FPGen_Mapped_data{4},'-mo',...
%        FPGen_Mapped_data{5}, FPGen_Mapped_data{6},'-b^',...
%        FPGen_Mapped_data{7}, FPGen_Mapped_data{8},'-cs',...
%        DW_Mapped_data{3}, DW_Mapped_data{4},':ko',...
%        'LineWidth',2,'MarkerSize',9);
%    set(gca,'fontsize',12);
%    title(['Efficiency Frontier for both ', num2str(bitwidth), 'bit FMA and CMA'],'fontsize',18);
%    
%    xlabel('mm^2/GFLOPS','fontsize',18),grid
%    ylabel('mW/GFLOPS','fontsize',18)
%    legend('Add', ...
%        'Avg', ...
%        'Mul', ...
%        'MulAdd',...
%        'Avg (DW)');
%     saveas(gcf, ['FPGen_', num2str(bitwidth), '_figure1'], 'pdf');
    
    figure(2);
    plot(FMA_Mapped_data{3}, FMA_Mapped_data{4},'-bo',...
       CMA_Mapped_data{3}, CMA_Mapped_data{4},'-rs',...
       DW_Mapped_data{3}, DW_Mapped_data{4},'-m^',...
       'LineWidth',2,'MarkerSize',9);
   set(gca,'fontsize',12);
   title(['Efficiency Frontier for both ', num2str(bitwidth), 'bit FMA and CMA'],'fontsize',18);
   
   xlabel('mm^2/GFLOPS','fontsize',18),grid
   ylabel('mW/GFLOPS','fontsize',18)
   legend('FMA', ...
       'CMA', ...
       'DW');  
   
  % dump csv file for frontiers
   fid = fopen(['throughput_frontier_FMA_', num2str(bitwidth),'bit.csv'],'w');
   fprintf(fid, '%s\n', inputcsv{1});
   for i=1:length(FMA_Mapped_data{3})
       index_in_csv = FMA_Mapped_data{14}(index_FMA{3}(i));
       fprintf(fid, '%s\n', inputcsv{index_in_csv});
   end
   fclose(fid);
   
   fid = fopen(['throughput_frontier_CMA_', num2str(bitwidth),'bit.csv'],'w');
   fprintf(fid, '%s\n', inputcsv{1});
   for i=1:length(CMA_Mapped_data{3})
       index_in_csv = CMA_Mapped_data{14}(index_CMA{3}(i));
       fprintf(fid, '%s\n', inputcsv{index_in_csv});
   end
   fclose(fid);
   
   fid = fopen(['throughput_frontier_DW_', num2str(bitwidth),'bit.csv'],'w');
   fprintf(fid, '%s\n', inputcsv{1});
   for i=1:length(DW_Mapped_data{3})
       index_in_csv = DW_Mapped_data{14}(index_DW{3}(i));
       fprintf(fid, '%s\n', inputcsv{index_in_csv});
   end
   fclose(fid);
    saveas(gcf, ['FPGen_', num2str(bitwidth), '_figure2'], 'pdf');
        
%     figure(3);
%     loglog(FMA_Mapped_data{1}, FMA_Mapped_data{2},'-ro',...
%        FMA_Mapped_data{3}, FMA_Mapped_data{4},'-mo',...
%        FMA_Mapped_data{5}, FMA_Mapped_data{6},'-bo',...
%        FMA_Mapped_data{7}, FMA_Mapped_data{8},'-co',...
%        CMA_Mapped_data{1}, CMA_Mapped_data{2},'--rs',...
%        CMA_Mapped_data{3}, CMA_Mapped_data{4},'--ms',...
%        CMA_Mapped_data{5}, CMA_Mapped_data{6},'--bs',...
%        CMA_Mapped_data{7}, CMA_Mapped_data{8},'--cs',...
%        DW_Mapped_data{3}, DW_Mapped_data{4},':k^',...
%        'LineWidth',2,'MarkerSize',9);
%    set(gca,'fontsize',12);
%    title(['Efficiency Frontier for both ', num2str(bitwidth), 'bit FMA and CMA'],'fontsize',18);
%    
%    xlabel('mm^2/GFLOPS','fontsize',18),grid
%    ylabel('mW/GFLOPS','fontsize',18)
%    legend('Add (FMA)', ...
%        'Avg (FMA)', ...
%        'Mul (FMA)', ...
%        'MulAdd (FMA)',...
%        'Add (CMA)', ...
%        'Avg (CMA)', ...
%        'Mul (CMA)', ...
%        'MulAdd (CMA)',...
%        'Avg (DW)');  
%     saveas(gcf, ['FPGen_', num2str(bitwidth), '_figure3'], 'pdf');
%         
%     figure(4);
%     plot(FPGen_pipeline{3}{10}, FPGen_pipeline{3}{9},'-yx',...
%         FPGen_pipeline{4}{10}, FPGen_pipeline{4}{9},'-rx',...
%         FPGen_pipeline{5}{10}, FPGen_pipeline{5}{9},'-mo',...
%         FPGen_pipeline{6}{10}, FPGen_pipeline{6}{9},'-b.',...
%         FPGen_pipeline{7}{10}, FPGen_pipeline{7}{9},'-c^',...
%         FPGen_pipeline{8}{10}, FPGen_pipeline{8}{9},'-g*',...
%         DW_pipeline{4}{10}, DW_pipeline{4}{9},'-kx',...
%        'LineWidth',2,'MarkerSize',6);
%    set(gca,'fontsize',12);
%    title(['Delay vs Energy for FMA&CMA'],'fontsize',16);
%    
%    xlabel('Delay / ns','fontsize',16),grid
%    ylabel('Dynamic Energy / pJ','fontsize',16)
%    legend('Pipeline Depth = 3', ...
%        'Pipeline Depth = 4', ...
%        'Pipeline Depth = 5', ...
%        'Pipeline Depth = 6', ...
%        'Pipeline Depth = 7', ...
%        'Pipeline Depth = 8', ...
%        'Pipeline Depth = 4(DW)');
% 
%     figure(4);
%     semilogx(FPGen_pipeline{3}{10}, FPGen_pipeline{3}{9},'-y+',...
%         FPGen_pipeline{4}{10}, FPGen_pipeline{4}{9},'-ro',...
%         FPGen_pipeline{5}{10}, FPGen_pipeline{5}{9},'-mx',...
%         FPGen_pipeline{6}{10}, FPGen_pipeline{6}{9},'-bp',...
%         FPGen_pipeline{7}{10}, FPGen_pipeline{7}{9},'-c*',...
%         FPGen_pipeline{8}{10}, FPGen_pipeline{8}{9},'-g^',...
%         FPGen_pipeline{9}{10}, FPGen_pipeline{9}{9},'-y+',...
%         FPGen_pipeline{10}{10}, FPGen_pipeline{10}{9},'-bo',...
%         FPGen_pipeline{12}{10}, FPGen_pipeline{12}{9},'-rx',...        
%         DW_pipeline{3}{10}, DW_pipeline{3}{9},'--y',...       
%         DW_pipeline{4}{10}, DW_pipeline{4}{9},'--r',...       
%         DW_pipeline{5}{10}, DW_pipeline{5}{9},'--m',...       
%         DW_pipeline{10}{10}, DW_pipeline{10}{9},'--b',...
%        'LineWidth',2,'MarkerSize',6);
%    set(gca,'fontsize',12);
%    title(['Delay vs Power Efficiency(avg) for ', num2str(bitwidth), 'bit FMA&CMA'],'fontsize',16);
% 
%    xlabel('Average Delay (ns)','fontsize',16),grid
%    ylabel('Power Efficiency (mW/GFLOPS)','fontsize',16)
%    legend('Pipeline Depth = 3', ...
%        'Pipeline Depth = 4', ...
%        'Pipeline Depth = 5', ...
%        'Pipeline Depth = 6', ...
%        'Pipeline Depth = 7', ...
%        'Pipeline Depth = 8', ...
%        'Pipeline Depth = 9', ...
%        'Pipeline Depth = 10', ...
%        'Pipeline Depth = 12', ...
%        'Pipeline Depth = 3(DW)', ...
%        'Pipeline Depth = 4(DW)', ...
%        'Pipeline Depth = 5(DW)', ...
%        'Pipeline Depth = 10(DW)');
%     
%     saveas(gcf, ['FPGen_', num2str(bitwidth), '_figure4'], 'pdf');
    
    
    figure(5);
    plot(FMA_pipeline{3}{10}, FMA_pipeline{3}{9},'-.y+',...
        FMA_pipeline{4}{10}, FMA_pipeline{4}{9},'-.ro',...
        FMA_pipeline{5}{10}, FMA_pipeline{5}{9},'-.mx',...
        FMA_pipeline{6}{10}, FMA_pipeline{6}{9},'-.bp',...
        FMA_pipeline{7}{10}, FMA_pipeline{7}{9},'-.c*',...
        FMA_pipeline{8}{10}, FMA_pipeline{8}{9},'-.g^',...
        FMA_pipeline{9}{10}, FMA_pipeline{9}{9},'-.y+',...
        FMA_pipeline{10}{10}, FMA_pipeline{10}{9},'-.bo',...
        FMA_pipeline{12}{10}, FMA_pipeline{12}{9},'-.rx',...
        CMA_pipeline{5}{10}, CMA_pipeline{5}{9},'-mx',...
        CMA_pipeline{6}{10}, CMA_pipeline{6}{9},'-bp',...
        CMA_pipeline{7}{10}, CMA_pipeline{7}{9},'-c*',...
        CMA_pipeline{8}{10}, CMA_pipeline{8}{9},'-g^',...
        CMA_pipeline{9}{10}, CMA_pipeline{9}{9},'-y+',...
        CMA_pipeline{10}{10}, CMA_pipeline{10}{9},'-bo',...
        CMA_pipeline{12}{10}, CMA_pipeline{12}{9},'-rx',...         
        DW_pipeline{3}{10}, DW_pipeline{3}{9},'--y',...       
        DW_pipeline{4}{10}, DW_pipeline{4}{9},'--r',...       
        DW_pipeline{5}{10}, DW_pipeline{5}{9},'--m',...       
        DW_pipeline{10}{10}, DW_pipeline{10}{9},'--b',...
       'LineWidth',2,'MarkerSize',6);
   set(gca,'fontsize',12);
   title(['Delay vs Power Efficiency(avg) for ', num2str(bitwidth), 'bit FMA&CMA'],'fontsize',16);
    if(bitwidth == 32)
    elseif (bitwidth == 64)
        axis([0, 5, 10, 35]);
    end
   xlabel('Average Delay (ns)','fontsize',16),grid
   ylabel('Power Efficiency (mW/GFLOPS)','fontsize',16)
   legend('3(FMA)', ...
       '4(FMA)', ...
       '5(FMA)', ...
       '6(FMA)', ...
       '7(FMA)', ...
       '8(FMA)', ...
       '9(FMA)', ...
       '10(FMA)', ...
       '12(FMA)', ...
       '5(CMA)', ...
       '6(CMA)', ...
       '7(CMA)', ...
       '8(CMA)', ...
       '9(CMA)', ...
       '10(CMA)', ...
       '12(CMA)', ...
       '3(DW)', ...
       '4(DW)', ...
       '5(DW)', ...
       '10(DW)');
    
    saveas(gcf, ['FPGen_', num2str(bitwidth), '_figure5'], 'pdf');
    
    figure(6);   
    plot(FMA_Mapped_data{10}, FMA_Mapped_data{9}, '-ro',...
        CMA_Mapped_data{10}, CMA_Mapped_data{9}, '-bs',...   
        DW_Mapped_data{10}, DW_Mapped_data{9}, '-m^',...
       'LineWidth',2,'MarkerSize',6);
   set(gca,'fontsize',12);
   title(['Energy Efficiency vs Delay for ', num2str(bitwidth), 'bit FMA&CMA'],'fontsize',16);

   xlabel('Benchmarked Latency * Clock Period (ns)','fontsize',16),grid
   ylabel('Energy Efficiency (pJ/FLOP)','fontsize',16)
   legend('FMA frontier', ...          
       'CMA frontier', ...
       'DW frontier');
%    axis([0 4 10 45]);


    % start to tag the pipe depth for each data points on figure 6
    if(bitwidth == 32)
        margin = 0.5;  
    elseif (bitwidth == 64)
        margin = 0.5;
    end
    
    fid = fopen(['latency_frontier_FMA_', num2str(bitwidth),'bit.csv'],'w');
    fprintf(fid, '%s\n', inputcsv{1});
    j=1;
   for i=1:length(FMA_Mapped_data{10})
       index_in_csv = FMA_Mapped_data{14}(index_FMA{9}(i));
       fprintf(fid, '%s\n', inputcsv{index_in_csv});
       if(i>1 && FMA_Mapped_data{9}(i) < FMA_Mapped_data{9}(j)   + margin) 
           continue
       else
           j = i;
       end
       text(FMA_Mapped_data{10}(i),FMA_Mapped_data{9}(i), ...
           ['\leftarrow',FMA_Mapped_data{11}{index_FMA{9}(i)}],...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','left',...
           'FontSize',10, 'Color', [0.5, 0, 0]);
   end
   fclose(fid);
   
    fid = fopen(['latency_frontier_CMA_', num2str(bitwidth),'bit.csv'],'w');
    fprintf(fid, '%s\n', inputcsv{1});
    j=1;
   for i=1:length(CMA_Mapped_data{10})
       index_in_csv = CMA_Mapped_data{14}(index_CMA{9}(i));
       fprintf(fid, '%s\n', inputcsv{index_in_csv});
       if(i>1 && CMA_Mapped_data{9}(i) < CMA_Mapped_data{9}(j)   + margin) 
           continue
       else
           j = i;
       end
       text(CMA_Mapped_data{10}(i),CMA_Mapped_data{9}(i), ...
           [CMA_Mapped_data{12}{index_CMA{9}(i)}, '\rightarrow'],...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','right',...
           'FontSize',10, 'Color', [0, 0, 0.5]);
   end
   fclose(fid);
   
   fid = fopen(['latency_frontier_DW_', num2str(bitwidth),'bit.csv'],'w');
    fprintf(fid, '%s\n', inputcsv{1});
    j=1;
   for i=1:length(DW_Mapped_data{10})
       index_in_csv = DW_Mapped_data{14}(index_DW{9}(i));
       fprintf(fid, '%s\n', inputcsv{index_in_csv});
       if(i>1 && DW_Mapped_data{9}(i) < DW_Mapped_data{9}(j)   + margin) 
           continue
       else
           j = i;
       end
       text(DW_Mapped_data{10}(i),DW_Mapped_data{9}(i), ...
           [DW_Mapped_data{13}{index_DW{9}(i)}, '\rightarrow'],...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','right',...
           'FontSize',10, 'Color', [0.5, 0, 0.5]);
   end
   fclose(fid);
    saveas(gcf, ['FPGen_', num2str(bitwidth), '_figure6'], 'pdf');

end
