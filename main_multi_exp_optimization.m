%% ===============================
% COMSOL多实验数据碳扩散参数优化主程序
% 功能：使用遗传算法基于多组实验数据优化COMSOL模型参数
% 修改：支持多时间点、多深度的实验数据
% 作者：参数优化系统
% 日期：2025年
%% ===============================

function main_multi_exp_optimization()
    %% 全局设置
    clc;
    clear;
    fprintf('===============================\n');
    fprintf('COMSOL多实验数据碳扩散参数优化程序启动\n');
    fprintf('===============================\n');
    
    %% 多实验数据设置
    global exp_data;
    exp_data = struct();
    
    % 实验1: 2520秒
    exp_data.exp1 = struct();
    exp_data.exp1.time = 2520;
    exp_data.exp1.x_coords_mm = [0.075, 0.225, 0.375, 0.525, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
    exp_data.exp1.C_exp = [1.26, 1.09, 0.94, 0.79, 0.62, 0.45, 0.3, 0.24, 0.22, 0.2, 0.2];
    exp_data.exp1.weight = 1.0;  % 权重
    
    % 实验2: 3360秒
    exp_data.exp2 = struct();
    exp_data.exp2.time = 3360;
    exp_data.exp2.x_coords_mm = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
    exp_data.exp2.C_exp = [1.24, 0.96, 0.85, 0.74, 0.61, 0.45, 0.31, 0.23, 0.21, 0.20];
    exp_data.exp2.weight = 1.0;
    
    % 实验3: 6120秒
    exp_data.exp3 = struct();
    exp_data.exp3.time = 6120;
    exp_data.exp3.x_coords_mm = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
    exp_data.exp3.C_exp = [0.87, 0.81, 0.76, 0.69, 0.61, 0.52, 0.43, 0.34, 0.27, 0.23];
    exp_data.exp3.weight = 1.0;
    
    % 实验4: 8520秒
    exp_data.exp4 = struct();
    exp_data.exp4.time = 8520;
    exp_data.exp4.x_coords_mm = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
    exp_data.exp4.C_exp = [0.73, 0.74, 0.72, 0.71, 0.62, 0.55, 0.48, 0.4, 0.33, 0.27];
    exp_data.exp4.weight = 1.0;
    
    % 实验5: 9360秒
    exp_data.exp5 = struct();
    exp_data.exp5.time = 9360;
    exp_data.exp5.x_coords_mm = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
    exp_data.exp5.C_exp = [0.74, 0.71, 0.69, 0.66, 0.61, 0.55, 0.5, 0.43, 0.39, 0.32];
    exp_data.exp5.weight = 1.0;
    
    % 实验6: 10920秒
    exp_data.exp6 = struct();
    exp_data.exp6.time = 10920;
    exp_data.exp6.x_coords_mm = [0.1, 0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9];
    exp_data.exp6.C_exp = [0.71, 0.7, 0.69, 0.67, 0.63, 0.59, 0.55, 0.45, 0.41, 0.36];
    exp_data.exp6.weight = 1.0;
    
    % 实验名称列表
    exp_data.exp_names = {'exp1', 'exp2', 'exp3', 'exp4', 'exp5', 'exp6'};
    
    % 处理坐标转换和通用设置
    exp_data.y_coord_mm = 0;
    exp_data.y_coord_m = 0;
    exp_data.model_file = 'carbon_content_3.mph';
    
    % 为每个实验转换坐标单位
    for i = 1:length(exp_data.exp_names)
        exp_name = exp_data.exp_names{i};
        exp_data.(exp_name).x_coords_m = exp_data.(exp_name).x_coords_mm / 1000;
    end
    
    % 显示实验数据信息
    fprintf('多实验数据设置完成\n');
    total_data_points = 0;
    for i = 1:length(exp_data.exp_names)
        exp_name = exp_data.exp_names{i};
        fprintf('- %s: 时间=%d秒, 数据点=%d\n', exp_name, ...
            exp_data.(exp_name).time, length(exp_data.(exp_name).C_exp));
        total_data_points = total_data_points + length(exp_data.(exp_name).C_exp);
    end
    fprintf('总数据点数: %d\n', total_data_points);
    
    %% 参数优化设置
    param_bounds = struct();
    % 参数范围设置 [下界, 上界]
    param_bounds.high = [0.010, 0.020];      % high参数范围
    param_bounds.low = [0.008, 0.015];       % low参数范围
    param_bounds.D0 = [1e-12, 1e-10];        % D0参数范围
    param_bounds.k_m = [0.05, 0.2];          % k_m参数范围
    
    fprintf('\n参数优化范围设置:\n');
    fprintf('- high: [%.4f, %.4f]\n', param_bounds.high(1), param_bounds.high(2));
    fprintf('- low: [%.4f, %.4f]\n', param_bounds.low(1), param_bounds.low(2));
    fprintf('- D0: [%.2e, %.2e]\n', param_bounds.D0(1), param_bounds.D0(2));
    fprintf('- k_m: [%.3f, %.3f]\n', param_bounds.k_m(1), param_bounds.k_m(2));
    
    %% 遗传算法参数设置
    ga_options = struct();
    ga_options.population_size = 30;          % 增加种群大小以应对复杂优化
    ga_options.max_generations = 15;          % 增加迭代次数
    ga_options.crossover_rate = 0.8;          % 交叉率
    ga_options.mutation_rate = 0.15;          % 稍微增加变异率
    ga_options.elite_count = 3;               % 增加精英个体数量
    
    fprintf('\n遗传算法参数设置:\n');
    fprintf('- 种群大小: %d\n', ga_options.population_size);
    fprintf('- 最大迭代次数: %d\n', ga_options.max_generations);
    fprintf('- 交叉率: %.2f\n', ga_options.crossover_rate);
    fprintf('- 变异率: %.2f\n', ga_options.mutation_rate);
    fprintf('- 精英个体数: %d\n', ga_options.elite_count);
    
    %% 开始参数优化
    fprintf('\n===============================\n');
    fprintf('开始多实验数据参数优化...\n');
    fprintf('===============================\n');
    
    tic;
    [best_params, best_error, optimization_history] = genetic_algorithm_multi_exp_optimization(param_bounds, ga_options);
    optimization_time = toc;
    
    %% 显示优化结果
    fprintf('\n===============================\n');
    fprintf('优化完成！\n');
    fprintf('===============================\n');
    fprintf('优化耗时: %.2f分钟\n', optimization_time/60);
    fprintf('最优参数:\n');
    fprintf('- high = %.6f\n', best_params.high);
    fprintf('- low = %.6f\n', best_params.low);
    fprintf('- D0 = %.2e\n', best_params.D0);
    fprintf('- k_m = %.3f\n', best_params.k_m);
    fprintf('最小总误差: %.6f\n', best_error);
    
    %% 使用最优参数运行所有实验的最终仿真
    fprintf('\n===============================\n');
    fprintf('使用最优参数运行所有实验的最终仿真...\n');
    fprintf('===============================\n');
    
    [final_total_error, all_sim_results, ~] = run_multi_exp_comsol_simulation(best_params);
    
    %% 绘制优化结果
    plot_multi_exp_optimization_results(optimization_history, best_params, all_sim_results);
    
    %% 保存结果
    save_multi_exp_optimization_results(best_params, best_error, optimization_history, all_sim_results);
    
    fprintf('\n===============================\n');
    fprintf('多实验数据参数优化程序完成！\n');
    fprintf('===============================\n');
end

%% 多实验数据遗传算法优化函数
function [best_params, best_error, history] = genetic_algorithm_multi_exp_optimization(param_bounds, ga_options)
    % 初始化
    pop_size = ga_options.population_size;
    max_gen = ga_options.max_generations;
    
    % 参数个数和范围
    param_names = {'high', 'low', 'D0', 'k_m'};
    n_params = length(param_names);
    
    % 构建参数范围矩阵
    param_range = zeros(n_params, 2);
    for i = 1:n_params
        param_range(i, :) = param_bounds.(param_names{i});
    end
    
    % 初始化种群
    population = zeros(pop_size, n_params);
    fitness = zeros(pop_size, 1);
    
    % 生成初始种群
    fprintf('生成初始种群...\n');
    for i = 1:pop_size
        for j = 1:n_params
            population(i, j) = param_range(j, 1) + ...
                rand() * (param_range(j, 2) - param_range(j, 1));
        end
    end
    
    % 优化历史记录
    history = struct();
    history.best_error = zeros(max_gen, 1);
    history.mean_error = zeros(max_gen, 1);
    history.std_error = zeros(max_gen, 1);
    history.best_params = cell(max_gen, 1);
    history.individual_errors = cell(max_gen, 1);  % 记录各实验的误差
    
    % 主优化循环
    for gen = 1:max_gen
        fprintf('\n--- 第 %d/%d 代 ---\n', gen, max_gen);
        
        % 评估种群适应度
        individual_errors_gen = zeros(pop_size, 6);  % 6个实验的误差
        for i = 1:pop_size
            params = create_param_struct(population(i, :), param_names);
            [fitness(i), individual_errors] = evaluate_multi_exp_fitness(params);
            if length(individual_errors) == 6
                individual_errors_gen(i, :) = individual_errors;
            else
                individual_errors_gen(i, :) = ones(1, 6) * 1e6;  % 错误情况下的默认值
            end
            
            if mod(i, 5) == 0
                fprintf('个体 %d/%d 评估完成\n', i, pop_size);
            end
        end
        
        % 记录当前代最优结果
        [best_fit, best_idx] = min(fitness);
        history.best_error(gen) = best_fit;
        history.mean_error(gen) = mean(fitness);
        history.std_error(gen) = std(fitness);
        history.best_params{gen} = create_param_struct(population(best_idx, :), param_names);
        history.individual_errors{gen} = individual_errors_gen(best_idx, :);
        
        fprintf('第 %d 代最优误差: %.6f\n', gen, best_fit);
        fprintf('第 %d 代平均误差: %.6f ± %.6f\n', gen, mean(fitness), std(fitness));
        
        % 显示各实验的误差分布
        fprintf('各实验误差: [');
        for exp_idx = 1:6
            fprintf('%.4f', individual_errors_gen(best_idx, exp_idx));
            if exp_idx < 6
                fprintf(', ');
            end
        end
        fprintf(']\n');
        
        % 如果不是最后一代，进行选择、交叉、变异
        if gen < max_gen
            % 选择操作
            new_population = selection(population, fitness, ga_options);
            
            % 交叉操作
            new_population = crossover(new_population, ga_options, param_range);
            
            % 变异操作
            new_population = mutation(new_population, ga_options, param_range);
            
            population = new_population;
        end
    end
    
    % 返回最优结果
    [best_error, best_idx] = min(fitness);
    best_params = create_param_struct(population(best_idx, :), param_names);
end

%% 多实验数据适应度评估函数
function [total_error, individual_errors] = evaluate_multi_exp_fitness(params)
    try
        [total_error, ~, individual_errors] = run_multi_exp_comsol_simulation(params);
        % 确保返回的是数组而不是结构体
        if ~isnumeric(individual_errors)
            individual_errors = ones(1, 6) * 1e6;
        end
    catch ME
        fprintf('多实验仿真失败: %s\n', ME.message);
        total_error = 1e6; % 给失败的仿真分配很大的误差
        individual_errors = ones(1, 6) * 1e6;
    end
end

%% 创建参数结构体
function params = create_param_struct(param_array, param_names)
    params = struct();
    for i = 1:length(param_names)
        params.(param_names{i}) = param_array(i);
    end
end

%% 选择操作（锦标赛选择）
function new_population = selection(population, fitness, ga_options)
    [pop_size, n_params] = size(population);
    new_population = zeros(pop_size, n_params);
    
    % 精英保留
    [~, sorted_idx] = sort(fitness);
    elite_count = min(ga_options.elite_count, pop_size);
    new_population(1:elite_count, :) = population(sorted_idx(1:elite_count), :);
    
    % 锦标赛选择
    tournament_size = 3;
    for i = elite_count+1:pop_size
        tournament_idx = randperm(pop_size, tournament_size);
        tournament_fitness = fitness(tournament_idx);
        [~, winner_idx] = min(tournament_fitness);
        new_population(i, :) = population(tournament_idx(winner_idx), :);
    end
end

%% 交叉操作
function new_population = crossover(population, ga_options, param_range)
    [pop_size, n_params] = size(population);
    
    for i = 1:2:pop_size-1
        if rand() < ga_options.crossover_rate
            % 混合交叉（BLX-α）
            alpha = 0.5;
            for j = 1:n_params
                min_val = min(population(i, j), population(i+1, j));
                max_val = max(population(i, j), population(i+1, j));
                range_val = max_val - min_val;
                
                new_min = min_val - alpha * range_val;
                new_max = max_val + alpha * range_val;
                
                % 确保在参数范围内
                new_min = max(new_min, param_range(j, 1));
                new_max = min(new_max, param_range(j, 2));
                
                population(i, j) = new_min + rand() * (new_max - new_min);
                population(i+1, j) = new_min + rand() * (new_max - new_min);
            end
        end
    end
    
    new_population = population;
end

%% 变异操作
function new_population = mutation(population, ga_options, param_range)
    [pop_size, n_params] = size(population);
    
    for i = 1:pop_size
        for j = 1:n_params
            if rand() < ga_options.mutation_rate
                % 自适应高斯变异
                range_val = param_range(j, 2) - param_range(j, 1);
                sigma = range_val * 0.1 * exp(-i/pop_size);  % 自适应标准差
                mutation_value = normrnd(0, sigma);
                population(i, j) = population(i, j) + mutation_value;
                
                % 边界处理
                population(i, j) = max(param_range(j, 1), ...
                    min(param_range(j, 2), population(i, j)));
            end
        end
    end
    
    new_population = population;
end

%% 绘制多实验优化结果
function plot_multi_exp_optimization_results(history, best_params, all_sim_results)
    global exp_data;
    
    figure('Position', [100, 100, 1600, 1200]);
    
    % 子图1：优化收敛曲线
    subplot(3, 3, 1);
    plot(1:length(history.best_error), history.best_error, 'r-o', 'LineWidth', 2);
    hold on;
    plot(1:length(history.mean_error), history.mean_error, 'b--s', 'LineWidth', 1.5);
    fill([1:length(history.mean_error), length(history.mean_error):-1:1], ...
         [history.mean_error + history.std_error; flip(history.mean_error - history.std_error)], ...
         'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    xlabel('迭代次数');
    ylabel('误差');
    title('优化收敛曲线');
    legend('最优误差', '平均误差±标准差', 'Location', 'best');
    grid on;
    
    % 子图2：各实验误差演化
    subplot(3, 3, 2);
    colors = ['r', 'g', 'b', 'c', 'm', 'k'];
    for exp_idx = 1:6
        exp_errors = zeros(length(history.individual_errors), 1);
        for gen = 1:length(history.individual_errors)
            exp_errors(gen) = history.individual_errors{gen}(exp_idx);
        end
        plot(1:length(exp_errors), exp_errors, [colors(exp_idx) '-'], 'LineWidth', 1.5, ...
             'DisplayName', sprintf('实验%d', exp_idx));
        hold on;
    end
    xlabel('迭代次数');
    ylabel('误差');
    title('各实验误差演化');
    legend('show', 'Location', 'best');
    grid on;
    
    % 子图3-8：各实验数据对比
    for exp_idx = 1:6
        subplot(3, 3, exp_idx + 2);
        exp_name = exp_data.exp_names{exp_idx};
        
        plot(exp_data.(exp_name).x_coords_mm, exp_data.(exp_name).C_exp, 'ro-', ...
             'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', '实验数据');
        hold on;
        plot(exp_data.(exp_name).x_coords_mm, all_sim_results.(exp_name), 'bs-', ...
             'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', '优化后模拟');
        
        xlabel('深度 (mm)');
        ylabel('碳浓度 (%)');
        title(sprintf('实验%d对比 (t=%d秒)', exp_idx, exp_data.(exp_name).time));
        legend('show', 'Location', 'best');
        grid on;
    end
    
    % 总标题
    sgtitle(sprintf('多实验优化结果: high=%.4f, low=%.4f, D0=%.2e, k_m=%.3f', ...
        best_params.high, best_params.low, best_params.D0, best_params.k_m), 'FontSize', 14);
end

%% 保存多实验优化结果
function save_multi_exp_optimization_results(best_params, best_error, history, all_sim_results)
    global exp_data;
    
    % 创建结果文件名
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    filename = sprintf('multi_exp_optimization_results_%s.mat', timestamp);
    
    % 保存结果
    save(filename, 'best_params', 'best_error', 'history', 'all_sim_results', 'exp_data');
    
    % 保存详细文本报告
    report_filename = sprintf('multi_exp_optimization_report_%s.txt', timestamp);
    fid = fopen(report_filename, 'w');
    
    fprintf(fid, '===============================\n');
    fprintf(fid, 'COMSOL多实验数据参数优化结果报告\n');
    fprintf(fid, '===============================\n');
    fprintf(fid, '优化完成时间: %s\n', datestr(now));
    fprintf(fid, '\n最优参数:\n');
    fprintf(fid, '- high = %.6f\n', best_params.high);
    fprintf(fid, '- low = %.6f\n', best_params.low);
    fprintf(fid, '- D0 = %.2e\n', best_params.D0);
    fprintf(fid, '- k_m = %.3f\n', best_params.k_m);
    fprintf(fid, '\n最小总误差: %.6f\n', best_error);
    
    % 各实验详细对比
    for exp_idx = 1:6
        exp_name = exp_data.exp_names{exp_idx};
        fprintf(fid, '\n===============================\n');
        fprintf(fid, '实验%d详细对比 (时间: %d秒)\n', exp_idx, exp_data.(exp_name).time);
        fprintf(fid, '===============================\n');
        fprintf(fid, '深度(mm)\t实验值(%%)\t模拟值(%%)\t差值(%%)\t相对误差(%%)\n');
        fprintf(fid, '------------------------------------------------------------\n');
        
        exp_error = 0;
        for i = 1:length(exp_data.(exp_name).x_coords_mm)
            diff_val = all_sim_results.(exp_name)(i) - exp_data.(exp_name).C_exp(i);
            rel_error = abs(diff_val) / exp_data.(exp_name).C_exp(i) * 100;
            exp_error = exp_error + diff_val^2;
            
            fprintf(fid, '%.3f\t\t%.3f\t\t%.3f\t\t%.3f\t\t%.2f\n', ...
                exp_data.(exp_name).x_coords_mm(i), exp_data.(exp_name).C_exp(i), ...
                all_sim_results.(exp_name)(i), diff_val, rel_error);
        end
        
        fprintf(fid, '\n实验%d误差: %.6f\n', exp_idx, exp_error);
    end
    
    fclose(fid);
    
    fprintf('结果已保存至: %s\n', filename);
    fprintf('报告已保存至: %s\n', report_filename);
end