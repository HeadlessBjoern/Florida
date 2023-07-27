function y = Lum2GrayLevel(x,Cg,gam,b0)

y = round(((x-b0)./Cg).^(1/gam));