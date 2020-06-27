% Kristina Anderson-Teixeira
% quick script to plot tree-ring data
% June 2020

%% INITIATE
clear all; clf; clc; clear; close all;

%% SETTINGS
%%% Directories
data_dir='/Users/kteixeira/Dropbox (Smithsonian)/GitHub/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree_cores/cross-dated_cores_CSVformat';
trees_to_plot=[202029; 80746; 141255; 111227; 111166; 101075]; 


%% READ IN DATA & pull out variables
cd(data_dir)
table1=readtable('all_core_chronologies.csv');
year=str2num(cell2mat(table2cell(table1(1,5:end))'));
table=readtable('all_core_chronologies.csv','ReadVariableNames',true,'TreatAsEmpty',["MAP","SETTINGS","NA"]);
tag=cell2mat(table2cell(table(:,1)));


for n=1:length(trees_to_plot)
    ind=find (tag== trees_to_plot(n));
    radial_inc=cell2mat(table2cell(table(ind,5:end)))';
    
    figure (n)
    plot(year,radial_inc)
    title(num2str(trees_to_plot(n)))
    xlabel('year')
    ylabel('radial increment (mm)')
    
end