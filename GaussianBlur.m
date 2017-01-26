function [ Ig ] =GaussianBlur( I,Sigma,SizeFilter )%UNTITLED Summary of this function goes here
%   Blur I withgaussian filter of size = [SizeFilter SizeFilter] and sigma = Sigma
%# Create the gaussian filter with hsize = [SizeFilter SizeFilter] and sigma = Sigma
if (nargin<3) Sigma=2;end;
if (nargin<4) SizeFilter=5;end;
  
G = fspecial('gaussian',[SizeFilter SizeFilter],Sigma);

%# Filter it
Ig = imfilter(I,G,'same');

end

