LM = importdata('CFP2000_test_latency_matrix.csv');
LM = LM.data;

  for ii=1:19
      for jj=1:19
          L(ii,jj) = LatencyPenalty(LM,ii,jj);
      end
  end
  
  [C, h]= contour(L+1, 'LineWidth',2);
  clabel(C,h);
  xlabel('MulAdd Latency','fontsize',16);
  ylabel('Accumulation Latency','fontsize',16);
  title('Effective Latency of SPEC CFP2000 Benchmark','fontsize',16);
  grid on;