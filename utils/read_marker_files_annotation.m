%%%%%%% function to read marker and marker names file. These files specify
%%%%%%% the green channel neuron positions and names obtained by annotating
%%%%%%% in Vaa3D
%%%%%% Inputs - 1. input_2 variable specifying folder path where 'marker'
%%%%%%             and 'marker_names.xlsx' are present. Specify it in
%%%%%%             terminal not in the code since this code is used in
%%%%%%             other codes as well.

function [X,Y,Z,marker_name,marker_index] = read_marker_files_annotation(in_direc, annotator)
    %%% read neuron positions
    filename= [in_direc,'/markers'];
    delimiter = ',';
    startRow = 2;
    formatSpec = '%f%f%f%f%f%s%s%f%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    markers = table(dataArray{1:end-1}, 'VariableNames', {'x','y','z','radius','shape','name','comment','color_r','color_g','color_b'});
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    X = table2array(markers(:,1));
    Y = table2array(markers(:,2));
    Z = table2array(markers(:,3)); 
    
    %%% correct for Z due to inverted reading of images (similar to
    %%% annotation code)
%     num_z_planes = size(dir([in_direc,'\index_images']),1) - 2;
%     Z = num_z_planes - Z;
%     mu_marker = [X,Y,Z];

    %%% read neuron names
    opts = spreadsheetImportOptions("NumVariables", 2);
    opts.Sheet = "Sheet1";
    opts.DataRange = "A2:B150";
    opts.VariableNames = ["Marker", "Name"];
    opts.VariableTypes = ["double", "string"];
    opts = setvaropts(opts, 2, "WhitespaceRule", "preserve");
    opts = setvaropts(opts, 2, "EmptyFieldRule", "auto");
   
    %added 20211027 to combine my annotation with jingting's
   if strcmp(annotator, 'jingting')
        disp('using Jingting marker file');
        markernames = readtable([in_direc,'/marker_names.xlsx'], opts, "UseExcel", false);
   elseif strcmp(annotator, 'me')
         disp('using my marker file');
        markernames = readtable([in_direc,'\marker_names_mine.xlsx'], opts, "UseExcel", false);
   elseif strcmp(annotator, 'myung')
         disp('using myung marker file');
        markernames = readtable([in_direc,'\marker_names_myung.xlsx'], opts, "UseExcel", false);
   end
    %markernames = readtable([in_direc,'\marker_names.xlsx'], opts, "UseExcel", false);
    clear opts

    marker_index = table2array(markernames(:,1));
    marker_name = cellstr(table2cell(markernames(:,2)));
    empty_index = find(strcmp('',marker_name(:,1)));
    marker_name(empty_index,:) = [];
    marker_index(empty_index,:) = [];
end