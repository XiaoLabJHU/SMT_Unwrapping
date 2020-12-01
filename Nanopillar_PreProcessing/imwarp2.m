function [movingReg,Rreg] = imwarp2(moving, tform)
%% modified imwarp from the imwarp for 2d transformation of a image
% Xinxing Yang 2015-03-29
% input: the image needs to be warpped: moving
%        the trnaformation matrix: affine2d class
% output: the transformed image: movingReg
%        the spatial reference of the image: imref2d type

%% check the imput argins
if nargin < 2
    error('Please input both image and tform!');
end

if ~isa(tform,'affine2d')
   error('Please input tform in affine2d class (affined2d.m can be used)!');
end 
%% get 
if (tform.Dimensionality == 2)
        Rmoving = imref2d(size(moving));
        Rfixed = imref2d(size(moving));
     else
         Rmoving = imref3d(size(moving));
         Rfixed = imref3d(size(moving));
end

%% transform the image
[movingReg,Rreg] = imwarp(moving,Rmoving,tform,'OutputView',Rfixed);