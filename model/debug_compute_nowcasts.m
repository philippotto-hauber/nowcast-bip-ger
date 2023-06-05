clear; close all; clc;

dir_root = 'C:\Users\Philipp\Desktop';
year_nowcast = '2023';
quarter_nowcast = '2';
switch_estimatemodels = '0';

compute_nowcasts(dir_root, year_nowcast, quarter_nowcast, switch_estimatemodels)