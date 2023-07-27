function y = GrayLevel2Lum(x,Cg,gam,b0)

y = Cg*x.^gam + b0;