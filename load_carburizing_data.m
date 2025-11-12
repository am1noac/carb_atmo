function dataset = load_carburizing_data()
% LOAD_CARBURIZING_DATA 加载所有碳化实验数据集
%
% 用法:
%   dataset = load_carburizing_data();
%
% 返回:
%   dataset - 包含15组数据的结构体数组

dataset = struct([]);

% ========== 数据集1：42分钟强渗 + 5分钟扩散 ==========
idx = 1;
dataset(idx).id = 'DS01';
dataset(idx).name = '42min强渗+5min扩散';
dataset(idx).depths = [0.075, 0.225, 0.375, 0.525, 0.675, 0.825, 0.975, 1.125, 1.275, 1.425];
dataset(idx).exp_values = [1.3, 1.04, 0.9, 0.76, 0.6, 0.48, 0.35, 0.28, 0.24, 0.22];
dataset(idx).carb_time = 42;
dataset(idx).diff_time = 5;
dataset(idx).total_time = 2820;
dataset(idx).process_type = 'carb_diff';

% ========== 数据集2：42分钟强渗 + 12分钟扩散 ==========
idx = idx + 1;
dataset(idx).id = 'DS02';
dataset(idx).name = '42min强渗+12min扩散';
dataset(idx).depths = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [1.24, 0.96, 0.85, 0.74, 0.61, 0.45, 0.31, 0.23, 0.21, 0.20];
dataset(idx).carb_time = 42;
dataset(idx).diff_time = 12;
dataset(idx).total_time = 3240;
dataset(idx).process_type = 'carb_diff';

% ========== 数据集3：24分钟强渗 ==========
idx = idx + 1;
dataset(idx).id = 'DS03';
dataset(idx).name = '24min强渗';
dataset(idx).depths = [0.075, 0.225, 0.375, 0.525, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [1.17, 1.06, 0.93, 0.74, 0.55, 0.32, 0.22, 0.21, 0.18, 0.2, 0.2];
dataset(idx).carb_time = 24;
dataset(idx).diff_time = 0;
dataset(idx).total_time = 1440;
dataset(idx).process_type = 'carb_only';

% ========== 数据集4：36分钟强渗 ==========
idx = idx + 1;
dataset(idx).id = 'DS04';
dataset(idx).name = '36min强渗';
dataset(idx).depths = [0.075, 0.225, 0.375, 0.525, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [1.26, 1.08, 0.95, 0.77, 0.56, 0.36, 0.25, 0.21, 0.19, 0.20, 0.19];
dataset(idx).carb_time = 36;
dataset(idx).diff_time = 0;
dataset(idx).total_time = 2160;
dataset(idx).process_type = 'carb_only';

% ========== 数据集5：42分钟强渗 ==========
idx = idx + 1;
dataset(idx).id = 'DS05';
dataset(idx).name = '42min强渗';
dataset(idx).depths = [0.075, 0.225, 0.375, 0.525, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [1.26, 1.09, 0.94, 0.79, 0.62, 0.45, 0.3, 0.24, 0.22, 0.2, 0.2];
dataset(idx).carb_time = 42;
dataset(idx).diff_time = 0;
dataset(idx).total_time = 2520;
dataset(idx).process_type = 'carb_only';

% ========== 数据集6：42分钟强渗 + 20分钟扩散 ==========
idx = idx + 1;
dataset(idx).id = 'DS06';
dataset(idx).name = '42min强渗+20min扩散';
dataset(idx).depths = [0.075, 0.225, 0.375, 0.525, 0.675, 0.825, 1, 1.2, 1.4, 1.6];
dataset(idx).exp_values = [1.3, 1.04, 0.91, 0.78, 0.66, 0.54, 0.42, 0.31, 0.25, 0.22];
dataset(idx).carb_time = 42;
dataset(idx).diff_time = 20;
dataset(idx).total_time = 3720;
dataset(idx).process_type = 'carb_diff';

% ========== 数据集7：42分钟强渗 + 40分钟扩散 ==========
idx = idx + 1;
dataset(idx).id = 'DS07';
dataset(idx).name = '42min强渗+40min扩散';
dataset(idx).depths = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [1.08, 0.94, 0.85, 0.73, 0.60, 0.48, 0.36, 0.28, 0.24, 0.22];
dataset(idx).carb_time = 42;
dataset(idx).diff_time = 40;
dataset(idx).total_time = 4920;
dataset(idx).process_type = 'carb_diff';

% ========== 数据集8：42分钟强渗 + 60分钟扩散 ==========
idx = idx + 1;
dataset(idx).id = 'DS08';
dataset(idx).name = '42min强渗+60min扩散';
dataset(idx).depths = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [0.87, 0.81, 0.76, 0.69, 0.61, 0.52, 0.43, 0.34, 0.27, 0.23];
dataset(idx).carb_time = 42;
dataset(idx).diff_time = 60;
dataset(idx).total_time = 6120;
dataset(idx).process_type = 'carb_diff';

% ========== 数据集9：42分钟强渗 + 80分钟扩散 ==========
idx = idx + 1;
dataset(idx).id = 'DS09';
dataset(idx).name = '42min强渗+80min扩散';
dataset(idx).depths = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [0.86, 0.82, 0.77, 0.7, 0.63, 0.54, 0.44, 0.37, 0.29, 0.24];
dataset(idx).carb_time = 42;
dataset(idx).diff_time = 80;
dataset(idx).total_time = 7320;
dataset(idx).process_type = 'carb_diff';

% ========== 数据集10：42分钟强渗 + 100分钟扩散 ==========
idx = idx + 1;
dataset(idx).id = 'DS10';
dataset(idx).name = '42min强渗+100min扩散';
dataset(idx).depths = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [0.73, 0.74, 0.72, 0.71, 0.62, 0.55, 0.48, 0.4, 0.33, 0.27];
dataset(idx).carb_time = 42;
dataset(idx).diff_time = 100;
dataset(idx).total_time = 8520;
dataset(idx).process_type = 'carb_diff';

% ========== 数据集11：42分钟强渗 + 114分钟扩散 ==========
idx = idx + 1;
dataset(idx).id = 'DS11';
dataset(idx).name = '42min强渗+114min扩散';
dataset(idx).depths = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [0.74, 0.71, 0.69, 0.66, 0.61, 0.55, 0.5, 0.43, 0.39, 0.32];
dataset(idx).carb_time = 42;
dataset(idx).diff_time = 114;
dataset(idx).total_time = 9360;
dataset(idx).process_type = 'carb_diff';

% ========== 数据集12：42分钟强渗 + 140分钟扩散 ==========
idx = idx + 1;
dataset(idx).id = 'DS12';
dataset(idx).name = '42min强渗+140min扩散';
dataset(idx).depths = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [0.71, 0.7, 0.69, 0.67, 0.63, 0.59, 0.55, 0.45, 0.41, 0.36];
dataset(idx).carb_time = 42;
dataset(idx).diff_time = 140;
dataset(idx).total_time = 10920;
dataset(idx).process_type = 'carb_diff';

% ========== 数据集13：2脉冲 (8.6分钟) ==========
idx = idx + 1;
dataset(idx).id = 'DS13';
dataset(idx).name = '2脉冲';
dataset(idx).depths = [0.075, 0.225, 0.375, 0.525, 0.675];
dataset(idx).exp_values = [1.17, 0.84, 0.52, 0.28, 0.2];
dataset(idx).carb_time = 8.6;
dataset(idx).diff_time = 0;
dataset(idx).total_time = 516;
dataset(idx).process_type = 'carb_only';
dataset(idx).pulse_count = 2;

% ========== 数据集14：3脉冲 (12.9分钟) ==========
idx = idx + 1;
dataset(idx).id = 'DS14';
dataset(idx).name = '3脉冲';
dataset(idx).depths = [0.075, 0.225, 0.375, 0.525, 0.675];
dataset(idx).exp_values = [1.31, 0.94, 0.59, 0.35, 0.27];
dataset(idx).carb_time = 12.9;
dataset(idx).diff_time = 0;
dataset(idx).total_time = 774;
dataset(idx).process_type = 'carb_only';
dataset(idx).pulse_count = 3;

% ========== 数据集15：48分钟强渗 ==========
idx = idx + 1;
dataset(idx).id = 'DS15';
dataset(idx).name = '48min强渗';
dataset(idx).depths = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
dataset(idx).exp_values = [1.26, 0.97, 0.85, 0.7, 0.54, 0.37, 0.28, 0.22, 0.21, 0.2];
dataset(idx).carb_time = 48;
dataset(idx).diff_time = 0;
dataset(idx).total_time = 2880;
dataset(idx).process_type = 'carb_only';

end