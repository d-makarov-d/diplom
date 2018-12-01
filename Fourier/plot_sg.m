function [] = plot_sg(x,t,n,s);
%function [] = plot_sg(x,t,n,s);
%plots x as function of t by n lines with distance s between

if nargin<4, s = 0; if nargin<3, n = 7; end,end,
if nargin<1, disp('no data - no plot'),return,end,
l = length(x);
if nargin<2, t = (0:length(x)-1); else, t=t-t(1); end,

stp = fix(l/n);
L = stp*n;
x = x(1:L); t = t(1:L);
if s==0, s = 7*std(x); end,
st = 1; en = stp;
plot(t(st:en),x(st:en)+(n-1)*s);
if ~ishold, hold on, end,
for i=n-1:-1:1,
    st = en;    en = st+stp;
    plot(t(st:en)-t(st),x(st:en)+(i-1)*s),
end,
if ishold, hold off, end,

%EOJ