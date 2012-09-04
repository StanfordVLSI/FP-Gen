LM = importdata('CFP2000_test_latency_matrix.csv');
LM = LM.data;

  for ii=1:19
      for jj=1:19
          L(ii,jj) = LatencyPenalty(LM,ii,jj);
      end
  end
  
  [C, h]= contour(L);
  clabel(C,h);