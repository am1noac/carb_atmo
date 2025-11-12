%% ===== 修改后的主程序 =====
function main_pulse_carburizing_optimization()
    %% 全局设置
    clc;
    clear;
    fprintf('===============================\n');
    fprintf('脉冲渗碳参数优化程序启动\n');
    fprintf('===============================\n');
    
    %% 全局变量
    global exp_data output_file;
    output_file = 'C:\Users\76454\Desktop\sisso+pinn\边界条件\carb.txt';
    
    %% 加载实验数据
    dataset = load_carburizing_data();
    selected_indices = [3, 4, 5, 13, 14, 15];
    exp_data = prepare_exp_data(dataset(selected_indices));
    
    fprintf('已加载 %d 组实验数据\n', exp_data.n_exp);
    
    %% ===== 新增：生成初始carb.txt =====
    fprintf('\n生成初始carb.txt文件...\n');
    initial_params = struct();
    initial_params.beta = 1.4;
    initial_params.tau = 10;
    initial_params.C_final = 0.011;
    initial_params.tau_rise = 35;
    initial_params.tau_fall = 40;
    initial_params.D0 = 5e-11;
    initial_params.k_m = 0.1;
    
    % 生成48分钟的初始碳势曲线
    generate_carb_txt(initial_params, 48*60);
    fprintf('初始carb.txt已生成，参数:\n');
    fprintf('  beta=%.2f, tau=%.1f, C_final=%.4f\n', ...
        initial_params.beta, initial_params.tau, initial_params.C_final);
    fprintf('  tau_rise=%.1f, tau_fall=%.1f\n', ...
        initial_params.tau_rise, initial_params.tau_fall);
    
    %% ===== 暂停，让用户在COMSOL中加载插值函数 =====
    fprintf('\n================== 重要 ==================\n');
    fprintf('请在COMSOL中执行以下操作：\n');
    fprintf('1. 打开模型文件: %s\n', exp_data.model_file);
    fprintf('2. 定义 > 函数 > 插值\n');
    fprintf('3. 函数名称: C_surface_func\n');
    fprintf('4. 数据源: 文件\n');
    fprintf('5. 选择文件: %s\n', output_file);
    fprintf('6. 设置:\n');
    fprintf('   - 数据格式: 电子表格\n');
    fprintf('   - 跳过表头: 5 行\n');
    fprintf('   - 十进制分隔符: 点\n');
    fprintf('7. 边界条件中使用: C_surface_func(t)\n');
    fprintf('8. 保存模型\n');
    fprintf('==========================================\n');
    
    input('完成上述步骤后，按回车键继续...\n');
    
    %% 参数优化范围设置
    param_bounds = struct();
    param_bounds.beta = [1.0, 2.0];
    param_bounds.tau = [5, 20];
    param_bounds.C_final = [0.009, 0.013];
    param_bounds.tau_rise = [20, 50];
    param_bounds.tau_fall = [20, 50];
    param_bounds.D0 = [1e-12, 1e-10];
    param_bounds.k_m = [0.05, 0.2];
    
    fprintf('\n参数优化范围:\n');
    fprintf('  beta: [%.2f, %.2f]\n', param_bounds.beta);
    fprintf('  tau: [%.0f, %.0f] 周期\n', param_bounds.tau);
    fprintf('  C_final: [%.4f, %.4f]\n', param_bounds.C_final);
    fprintf('  tau_rise: [%.0f, %.0f] s\n', param_bounds.tau_rise);
    fprintf('  tau_fall: [%.0f, %.0f] s\n', param_bounds.tau_fall);
    fprintf('  D0: [%.2e, %.2e]\n', param_bounds.D0);
    fprintf('  k_m: [%.2f, %.2f]\n', param_bounds.k_m);
    
    %% 遗传算法参数设置
    ga_options = struct();
    ga_options.population_size = 40;
    ga_options.max_generations = 20;
    ga_options.crossover_rate = 0.8;
    ga_options.mutation_rate = 0.15;
    ga_options.elite_count = 4;
    
    fprintf('\n遗传算法参数:\n');
    fprintf('  种群大小: %d\n', ga_options.population_size);
    fprintf('  最大迭代次数: %d\n', ga_options.max_generations);
    fprintf('  交叉率: %.2f\n', ga_options.crossover_rate);
    fprintf('  变异率: %.2f\n', ga_options.mutation_rate);
    fprintf('  精英个体数: %d\n', ga_options.elite_count);
    
    %% 开始优化
    fprintf('\n===============================\n');
    fprintf('开始参数优化...\n');
    fprintf('===============================\n');
    
    tic;
    [best_params, best_error, history] = ...
        genetic_algorithm_optimization(param_bounds, ga_options);
    optimization_time = toc;
    
    %% 显示优化结果
    fprintf('\n===============================\n');
    fprintf('优化完成！\n');
    fprintf('===============================\n');
    fprintf('优化耗时: %.2f 分钟\n', optimization_time/60);
    fprintf('最优参数:\n');
    fprintf('  beta = %.4f\n', best_params.beta);
    fprintf('  tau = %.2f 周期\n', best_params.tau);
    fprintf('  C_final = %.6f (%.2f%%)\n', best_params.C_final, best_params.C_final*100);
    fprintf('  tau_rise = %.2f s\n', best_params.tau_rise);
    fprintf('  tau_fall = %.2f s\n', best_params.tau_fall);
    fprintf('  D0 = %.2e\n', best_params.D0);
    fprintf('  k_m = %.4f\n', best_params.k_m);
    fprintf('最小总误差: %.6e\n', best_error);
    
    %% 生成最终carb.txt（48分钟）
    fprintf('\n生成最终carb.txt (48分钟)...\n');
    generate_carb_txt(best_params, 48*60);
    
    %% 使用最优参数运行最终仿真
    fprintf('\n运行最终仿真验证...\n');
    [final_error, individual_errors, all_sim_results] = evaluate_fitness(best_params);
    
    %% 可视化
    plot_optimization_results(history, best_params, all_sim_results);
    
    %% 保存结果
    save_optimization_results(best_params, best_error, history, all_sim_results);
    
    fprintf('\n===============================\n');
    fprintf('优化程序完成！\n');
    fprintf('===============================\n');
end

%% ===== 数据准备函数 =====
function exp_data = prepare_exp_data(dataset)
    exp_data = struct();
    exp_data.datasets = dataset;
    exp_data.n_exp = length(dataset);
    
    % 为每个实验转换单位
    for i = 1:exp_data.n_exp
        % 深度：mm → m
        exp_data.datasets(i).depths_m = dataset(i).depths / 1000;
        % 碳浓度：% → 小数
        exp_data.datasets(i).carbon_decimal = dataset(i).exp_values / 100;
    end
    
    % COMSOL模型文件路径（根据你的实际路径修改）
    exp_data.model_file = 'carbon_content_3.mph';
end

%% ===== 生成carb.txt核心函数 =====
function generate_carb_txt(params, total_time)
    global output_file;
    
    % 1. 提取参数
    beta = params.beta;
    tau = params.tau;
    C_final = params.C_final;
    tau_rise = params.tau_rise;
    tau_fall = params.tau_fall;
    
    % 2. 工艺参数
    Q_C2H2 = 10;       % 乙炔流量 L/min
    Q_N2 = 8;          % 氮气流量 L/min
    P_high = 3;        % 高压 kPa
    P_low = 0.5;       % 低压 kPa
    
    T_rise = 140;      % 升压时间 s
    T_hold = 30;       % 保压时间 s
    T_fall = 90;       % 降压时间 s
    T_cycle = T_rise + T_hold + T_fall;  % 单周期时间 260s
    
    % 3. 计算气体分压
    x_C2H2 = Q_C2H2 / (Q_C2H2 + Q_N2);
    P_C2H2_high = P_high * x_C2H2;
    P_C2H2_low = P_low * x_C2H2;
    
    % 4. 计算平衡碳势（小数形式，不是百分比）
    A = 0.7;
    B = 0.2;
    
    % 计算百分比值
    C_high_percent = beta * (A * sqrt(P_C2H2_high) + B);
    C_low_percent = beta * (A * sqrt(P_C2H2_low) + B);
    
    % 转换为小数（除以100）
    C_high_eq = C_high_percent / 100;
    C_low_eq = C_low_percent / 100;
    
    % 限制在固溶极限 1.35% = 0.0135
    C_high = min(C_high_eq, 0.0135);
    C_low_initial = C_low_eq;
    
    % 5. 生成时间向量（每秒一个点）
    dt = 1;
    time = (0:dt:total_time)';
    n_points = length(time);
    C_surface = zeros(n_points, 1);
    
    % 6. 计算每个时间点的碳势
    for i = 1:n_points
        t = time(i);
        
        % 确定当前周期数和周期内时间
        cycle_num = floor(t / T_cycle);
        t_local = mod(t, T_cycle);
        
        % 计算当前周期的低碳势基准
        C_low_current = C_final - (C_final - C_low_initial) * exp(-cycle_num / tau);
        
        % 下一周期的低碳势
        C_low_next = C_final - (C_final - C_low_initial) * exp(-(cycle_num+1) / tau);
        
        % 根据周期内位置计算碳势
        if t_local < T_rise
            % 升压段：指数上升
            C_surface(i) = C_low_current + ...
                (C_high - C_low_current) * (1 - exp(-t_local / tau_rise));
        elseif t_local < (T_rise + T_hold)
            % 保压段：恒定高碳势
            C_surface(i) = C_high;
        else
            % 降压段：指数下降
            t_fall_local = t_local - (T_rise + T_hold);
            C_surface(i) = C_low_next + ...
                (C_high - C_low_next) * exp(-t_fall_local / tau_fall);
        end
    end
    
    % 7. 写入文件
    fid = fopen(output_file, 'w');
    
    for i = 1:n_points
        fprintf(fid, '%.6f %.6f\n', time(i), C_surface(i));
    end
    fclose(fid);
end

%% ===== 适应度评估函数 =====
function [total_error, individual_errors, all_sim_results] = evaluate_fitness(params)
    global exp_data;
    
    individual_errors = zeros(exp_data.n_exp, 1);
    all_sim_results = cell(exp_data.n_exp, 1);
    
    for i = 1:exp_data.n_exp
        exp = exp_data.datasets(i);
        
        try
            % 1. 生成对应时间长度的carb.txt
            generate_carb_txt(params, exp.total_time);
            
            % 2. 调用COMSOL仿真
            C_sim = run_comsol_simulation(exp, params);
            
            % 3. 计算误差
            error = sum((C_sim - exp.carbon_decimal).^2);
            individual_errors(i) = error;
            all_sim_results{i} = C_sim;
            
        catch ME
            fprintf('  实验%s仿真失败: %s\n', exp.id, ME.message);
            individual_errors(i) = 1e6;
            all_sim_results{i} = zeros(size(exp.carbon_decimal));
        end
    end
    
    total_error = sum(individual_errors);
end

%% ===== COMSOL仿真函数（完整修正版）=====
function C_sim = run_comsol_simulation(exp, params)
    global exp_data output_file;
    
    import com.comsol.model.*;
    import com.comsol.model.util.*;
    
    try
        % 1. 加载模型
        model = mphload(exp_data.model_file);
        
        % 2. 处理插值函数
        func_exists = false;
        try
            model.func('C_surface_func');
            func_exists = true;
        catch
        end
        
        if func_exists
            % 函数已存在，只更新数据
            model.func('C_surface_func').set('filename', output_file);
            model.func('C_surface_func').importData();
        else
            % 函数不存在，创建新的
            model.func.create('C_surface_func', 'Interpolation');
            model.func('C_surface_func').set('source', 'file');
            model.func('C_surface_func').set('filename', output_file);
            model.func('C_surface_func').set('nargs', '1');
            model.func('C_surface_func').set('struct', 'spreadsheet');
            model.func('C_surface_func').set('funcs', {'C_surface_func' '1'});
            model.func('C_surface_func').set('interp', 'linear');
            model.func('C_surface_func').importData();
        end
        
        % 3. 设置参数
        model.param.set('D0', sprintf('%.6e', params.D0));
        model.param.set('k_m', sprintf('%.6f', params.k_m));
        
        % 4. 设置求解时间
        model.study('std1').feature('time').set('tlist', ...
            sprintf('range(0,1,%d)', exp.total_time));
        
        % 5. 运行求解
        model.study('std1').run();
        
        % 6. 提取结果
        coords = [exp.depths_m; zeros(size(exp.depths_m))];
        C_sim = mphinterp(model, 'c', 'coord', coords);
        C_sim = C_sim(:);
        
        % 7. 清理
        ModelUtil.remove('model');
        
    catch ME
        % 确保清理模型
        try
            ModelUtil.remove('model');
        catch
        end
        % 重新抛出错误
        rethrow(ME);
    end
end
%% ===== 遗传算法主函数 =====
function [best_params, best_error, history] = ...
    genetic_algorithm_optimization(param_bounds, ga_options)
    
    % 参数名称和数量
    param_names = {'beta', 'tau', 'C_final', 'tau_rise', 'tau_fall', 'D0', 'k_m'};
    n_params = length(param_names);
    
    % 参数范围矩阵
    param_range = zeros(n_params, 2);
    for i = 1:n_params
        param_range(i, :) = param_bounds.(param_names{i});
    end
    
    % 初始化
    pop_size = ga_options.population_size;
    max_gen = ga_options.max_generations;
    
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
    history.individual_errors = cell(max_gen, 1);
    
    % 主优化循环
    for gen = 1:max_gen
        fprintf('\n--- 第 %d/%d 代 ---\n', gen, max_gen);
        
  % 评估种群适应度
for i = 1:pop_size
    params = create_param_struct(population(i, :), param_names);
    
    try
        [fitness(i), ind_errors, ~] = evaluate_fitness(params);
    catch ME
        % 修正：使用 ME.message
        fprintf('  个体 %d 评估失败: %s\n', i, ME.message);
        fitness(i) = 1e6;
        ind_errors = ones(exp_data.n_exp, 1) * 1e6;
    end
    
    if mod(i, 5) == 0
        fprintf('  个体 %d/%d 评估完成, 误差=%.6e\n', i, pop_size, fitness(i));
    end
end
        
        % 记录当前代最优结果
        [best_fit, best_idx] = min(fitness);
        history.best_error(gen) = best_fit;
        history.mean_error(gen) = mean(fitness);
        history.std_error(gen) = std(fitness);
        history.best_params{gen} = create_param_struct(population(best_idx, :), param_names);
        
        % 获取最优个体的各实验误差
        [~, ind_errors, ~] = evaluate_fitness(history.best_params{gen});
        history.individual_errors{gen} = ind_errors;
        
        fprintf('第 %d 代最优误差: %.6e\n', gen, best_fit);
        fprintf('第 %d 代平均误差: %.6e ± %.6e\n', gen, mean(fitness), std(fitness));
        
        % 显示各实验误差
        fprintf('各实验误差: [');
        for j = 1:length(ind_errors)
            fprintf('%.4e', ind_errors(j));
            if j < length(ind_errors)
                fprintf(', ');
            end
        end
        fprintf(']\n');
        
        % 如果不是最后一代，进行遗传操作
        if gen < max_gen
            % 选择
            new_population = selection(population, fitness, ga_options);
            % 交叉
            new_population = crossover(new_population, ga_options, param_range);
            % 变异
            new_population = mutation(new_population, ga_options, param_range);
            
            population = new_population;
        end
    end
    
    % 返回最优结果
    [best_error, best_idx] = min(fitness);
    best_params = create_param_struct(population(best_idx, :), param_names);
end

%% ===== 创建参数结构体 =====
function params = create_param_struct(param_array, param_names)
    params = struct();
    for i = 1:length(param_names)
        params.(param_names{i}) = param_array(i);
    end
end

%% ===== 选择操作（锦标赛选择）=====
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

%% ===== 交叉操作 =====
function new_population = crossover(population, ga_options, param_range)
    [pop_size, n_params] = size(population);
    
    for i = 1:2:pop_size-1
        if rand() < ga_options.crossover_rate
            % BLX-α交叉
            alpha = 0.5;
            for j = 1:n_params
                min_val = min(population(i, j), population(i+1, j));
                max_val = max(population(i, j), population(i+1, j));
                range_val = max_val - min_val;
                
                new_min = max(min_val - alpha * range_val, param_range(j, 1));
                new_max = min(max_val + alpha * range_val, param_range(j, 2));
                
                population(i, j) = new_min + rand() * (new_max - new_min);
                population(i+1, j) = new_min + rand() * (new_max - new_min);
            end
        end
    end
    
    new_population = population;
end

%% ===== 变异操作 =====
function new_population = mutation(population, ga_options, param_range)
    [pop_size, n_params] = size(population);
    
    for i = 1:pop_size
        for j = 1:n_params
            if rand() < ga_options.mutation_rate
                % 自适应高斯变异
                range_val = param_range(j, 2) - param_range(j, 1);
                sigma = range_val * 0.1;
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

%% ===== 可视化函数 =====
function plot_optimization_results(history, best_params, all_sim_results)
    global exp_data;
    
    n_exp = exp_data.n_exp;
    
    % 创建大图
    figure('Position', [100, 100, 1600, 1000]);
    
    % 子图1：优化收敛曲线
    subplot(3, 3, 1);
    semilogy(1:length(history.best_error), history.best_error, 'r-o', 'LineWidth', 2);
    hold on;
    semilogy(1:length(history.mean_error), history.mean_error, 'b--s', 'LineWidth', 1.5);
    xlabel('迭代次数');
    ylabel('误差（对数）');
    title('优化收敛曲线');
    legend('最优误差', '平均误差', 'Location', 'best');
    grid on;
    
    % 子图2：各实验误差演化
    subplot(3, 3, 2);
    colors = lines(n_exp);
    for i = 1:n_exp
        exp_errors = zeros(length(history.individual_errors), 1);
        for gen = 1:length(history.individual_errors)
            exp_errors(gen) = history.individual_errors{gen}(i);
        end
        semilogy(1:length(exp_errors), exp_errors, 'LineWidth', 1.5, ...
            'Color', colors(i,:), 'DisplayName', exp_data.datasets(i).id);
        hold on;
    end
    xlabel('迭代次数');
    ylabel('误差（对数）');
    title('各实验误差演化');
    legend('show', 'Location', 'best');
    grid on;
    
    % 子图3-8：各实验数据对比
    for i = 1:min(n_exp, 6)
        subplot(3, 3, i + 2);
        exp = exp_data.datasets(i);
        
        plot(exp.depths, exp.exp_values, 'ro-', ...
            'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', '实验数据');
        hold on;
        plot(exp.depths, all_sim_results{i}*100, 'bs-', ...
            'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', '优化结果');
        
        xlabel('深度 (mm)');
        ylabel('碳浓度 (%)');
        title(sprintf('%s (%s)', exp.id, exp.name));
        legend('show', 'Location', 'best');
        grid on;
    end
    
    % 总标题
    sgtitle(sprintf('优化结果: β=%.3f, τ=%.1f, C_{final}=%.4f, τ_{rise}=%.1f, τ_{fall}=%.1f', ...
        best_params.beta, best_params.tau, best_params.C_final, ...
        best_params.tau_rise, best_params.tau_fall), 'FontSize', 12);
end

%% ===== 保存结果函数 =====
function save_optimization_results(best_params, best_error, history, all_sim_results)
    global exp_data;
    
    % 生成时间戳
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    
    % 保存.mat文件
    filename_mat = sprintf('optimization_results_%s.mat', timestamp);
    save(filename_mat, 'best_params', 'best_error', 'history', ...
        'all_sim_results', 'exp_data');
    
    % 保存文本报告
    filename_txt = sprintf('optimization_report_%s.txt', timestamp);
    fid = fopen(filename_txt, 'w');
    
    fprintf(fid, '===============================\n');
    fprintf(fid, '脉冲渗碳参数优化结果报告\n');
    fprintf(fid, '===============================\n');
    fprintf(fid, '完成时间: %s\n', datestr(now));
    fprintf(fid, '\n最优参数:\n');
    fprintf(fid, '  beta = %.6f\n', best_params.beta);
    fprintf(fid, '  tau = %.4f 周期\n', best_params.tau);
    fprintf(fid, '  C_final = %.6f (%.2f%%)\n', best_params.C_final, best_params.C_final*100);
    fprintf(fid, '  tau_rise = %.4f s\n', best_params.tau_rise);
    fprintf(fid, '  tau_fall = %.4f s\n', best_params.tau_fall);
    fprintf(fid, '  D0 = %.6e\n', best_params.D0);
    fprintf(fid, '  k_m = %.6f\n', best_params.k_m);
    fprintf(fid, '\n最小总误差: %.6e\n', best_error);
    
    % 各实验详细结果
    for i = 1:exp_data.n_exp
        exp = exp_data.datasets(i);
        fprintf(fid, '\n===============================\n');
        fprintf(fid, '%s: %s (时间: %d秒)\n', exp.id, exp.name, exp.total_time);
        fprintf(fid, '===============================\n');
        fprintf(fid, '深度(mm)\t实验值(%%)\t模拟值(%%)\t绝对误差\t相对误差(%%)\n');
        fprintf(fid, '------------------------------------------------------------\n');
        
        for j = 1:length(exp.depths)
            sim_val = all_sim_results{i}(j) * 100;
            exp_val = exp.exp_values(j);
            abs_err = sim_val - exp_val;
            rel_err = abs(abs_err) / exp_val * 100;
            
            fprintf(fid, '%.3f\t\t%.3f\t\t%.3f\t\t%.3f\t\t%.2f\n', ...
                exp.depths(j), exp_val, sim_val, abs_err, rel_err);
        end
    end
    
    fclose(fid);
    
    fprintf('\n结果已保存:\n');
    fprintf('  MAT文件: %s\n', filename_mat);
    fprintf('  报告文件: %s\n', filename_txt);
end