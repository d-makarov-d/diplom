function [t,f,sw] = svan (y, f0, wn, owl);
%function [t,f,sw] = svan (y, f0, wn, owl)
%IN: y - input vector; f0 - sample frequency;
%wn - windows number; owl - windows owerlap in percents.
%OUT: f - spectrum frequensy vector; t - time vector;
%sw - output matrix.

%recurce
rl = length(y);                     %rec.len  
step = fix(rl/wn);                  %time step ow = fix(wl*owl/100);     
winl = fix(step*(1+owl/100));       %windows length
pw = 2^fix(log10(winl)/log10(2));   % spectrum parameter  
sw = [];

w = barthannwin(length(y(1:fix(winl*(1-owl/100)))));
[a,f] = periodogram(y(1:fix(winl*(1-owl/100))),w,pw,f0);
%[a,f] = pwelch(y(1:fix(winl*(1-owl/100))),w,[],pw,f0);

sw(:,1) = a(:,1);
t(1) = step/f0;

w = barthannwin(winl+1);

for s = 2:wn-1,
   medipoint = fix((s-1)*step+step/2);
   st = medipoint-fix(winl/2);
   en = st+winl;
   t(s) = medipoint/f0;
%    [a,f] = periodogram(y(st:en),w,pw,f0);
   [a,f] = pwelch(y(st:en),w,[],pw,f0);
   sw(:,s) = a(:,1);
   medipoint = medipoint+step;
end,

w = barthannwin(length(y(rl-fix(winl*(1+owl/100)):rl)));
 [a,f] = periodogram(y(rl-fix(winl*(1+owl/100)):rl),w,pw,f0);
%[a,f] = pwelch(y(rl-fix(winl*(1+owl/100)):rl),w,[],pw,f0);
sw(:,wn) = a(:,1);
t(wn) = (rl-step)/f0;

%EOJ
