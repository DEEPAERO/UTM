clear all
close all
clc
%%

NSAMPLES = sqrt(2);

blind = [];
weight = [];
xweight = [];
multi = [];

for i=0:1
    blind = [blind; load(sprintf('blind_reward-%i.txt',i))];
    weight = [weight; load(sprintf('weighted_reward-%i.txt',i))];
    xweight = [xweight; load(sprintf('crossweighted_reward-%i.txt',i))];
    multi = [multi; load(sprintf('multimind_reward-%i.txt',i))];
end


%%
stdb = std(blind)/NSAMPLES;
stdw = std(weight)/NSAMPLES;
stdx = std(xweight)/NSAMPLES;
stdm = std(multi)/NSAMPLES;

blind = mean(blind);
weight = mean(weight);
xweight = mean(xweight);
multi = mean(multi);

hold on
errorbar(blind, stdb,'b');
errorbar(weight, stdw,'k');
%errorbar(xweight, stdx, 'c');
errorbar(multi, stdm, 'm');

%legend('blind','weighted','xweight','multi');
legend('blind','weighted','multi');
%axis([0 50 -12000 -9000])