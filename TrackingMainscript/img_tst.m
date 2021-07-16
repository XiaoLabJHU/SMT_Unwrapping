
%ImOn = ones(100, 'logical');   %For you, imread('lamp_on.png');
ImOn = imread(DFT_path, 'tif');
ImOff = zeros(100, 'logical'); %For you, imread('lamp_off.png');
Ion = imshow(ImOn);
hold on
Ioff = imshow(ImOff);
Ioff.Visible = 'off';
hold off
for j = 1:10
    if strcmpi(Ion.Visible, 'on')
        Ion.Visible = 'off';
        Ioff.Visible = 'on';
    else
        Ion.Visible = 'on';
        Ioff.Visible = 'off';
    end
    pause(5);
end