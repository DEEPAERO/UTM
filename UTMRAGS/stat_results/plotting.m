clear all
close all
clc
%%

NSAMPLES = sqrt(2);

blind = [];
weight = [];
xweight = [];
multi = [];

for i=0:99
    blind = [blind; load(sprintf('blind_reward-%i.txt',i))];
    weight = [weight; load(sprintf('weighted_reward-%i.txt',i))];
    xweight = [xweight; load(sprintf('crossweighted_reward-%i.txt',i))];
    multi = [multi; load(sprintf('multimind_reward-%i.txt',i))];
end


%%
stdb = std(blind(:,1:10:100))/NSAMPLES;
stdw = std(weight(:,1:10:100))/NSAMPLES;
stdx = std(xweight(:,1:10:100))/NSAMPLES;
stdm = std(multi(:,1:10:100))/NSAMPLES;

m_blind = mean(blind);
m_weight = mean(weight);
m_xweight = mean(xweight);
m_multi = mean(multi);

hold on
plot(m_blind,'b') ;
plot(m_weight,'k') ;
plot(m_xweight,'c') ;
plot(m_multi,'m') ;

errorbar(1:10:100,m_blind(1:10:100), stdb,'b+');
errorbar(1:10:100,m_weight(1:10:100), stdw,'k+');
errorbar(1:10:100,m_xweight(1:10:100), stdx, 'c+');
errorbar(1:10:100,m_multi(1:10:100), stdm, 'm+');

legend('blind','weighted','xweight','multi');
%legend('blind','weighted','multi');
%axis([0 50 -12000 -9000])