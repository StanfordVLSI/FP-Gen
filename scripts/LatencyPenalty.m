function L = LatencyPenalty( latency_matrix, muladd_latency, acc_latency )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
  L = 0;
  for ii=1:size(latency_matrix,1)
      for jj=1:size(latency_matrix,2)
          L = L + latency_matrix(ii,jj) * max([0, muladd_latency-ii, acc_latency-jj]);
      end
  end
end

