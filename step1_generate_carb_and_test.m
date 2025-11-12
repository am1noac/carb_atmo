%% ===============================
% 步骤1：动态碳势曲线生成和COMSOL测试程序
% 功能：
%   1. 从load_carburizing_data提取carb_only（强渗）实验数据
%   2. 生成动态碳势曲线并输出到carb.txt
%   3. COMSOL读取carb.txt进行仿真测试
% 作者：参数优化系统
% 日期：2025年
% MATLAB版本：2023b
%% ===============================

function step1_generate_carb_and_test()
    %% 初始化
    clc;
    clear;
    close all;

    fprintf('===============================\n');
    fprintf('步骤1：碳势曲线生成和COMSOL测试\n');
    fprintf('===============================\n');

    %% 步骤1：加载并筛选强渗实验数据
    fprintf('\n步骤1：加载实验数据...\n');
    all_data = load_carburizing_data();

    % 筛选carb_only（强渗）数据
    carb_only_indices = [];
    for i = 1:length(all_data)
        if strcmp(all_data(i).process_type, 'carb_only')
            carb_only_indices = [carb_only_indices; i];
        end
    end

    exp_data = all_data(carb_only_indices);

    fprintf('找到 %d 组强渗实验数据：\n', length(exp_data));
    for i = 1:length(exp_data)
        fprintf('  %s: %s (时间=%d秒, 数据点=%d)\n', ...
            exp_data(i).id, exp_data(i).name, ...
            exp_data(i).total_time, length(exp_data(i).depths));
    end

    %% 步骤2：设置碳势曲线参数
    fprintf('\n步骤2：设置碳势曲线参数...\n');

    % 碳势曲线参数（这些参数后续会通过优化得到）
    carb_params = struct();
    carb_params.beta = 1.4;           % 碳势系数
    carb_params.tau = 10;             % 衰减时间常数（周期数）
    carb_params.C_final = 0.011;      % 最终碳势（小数，1.1%）
    carb_params.tau_rise = 35;        % 升压时间常数（秒）
    carb_params.tau_fall = 40;        % 降压时间常数（秒）

    fprintf('碳势曲线参数：\n');
    fprintf('  beta = %.2f\n', carb_params.beta);
    fprintf('  tau = %.1f 周期\n', carb_params.tau);
    fprintf('  C_final = %.4f (%.2f%%)\n', carb_params.C_final, carb_params.C_final*100);
    fprintf('  tau_rise = %.1f s\n', carb_params.tau_rise);
    fprintf('  tau_fall = %.1f s\n', carb_params.tau_fall);

    %% 步骤3：生成碳势曲线并保存到carb.txt
    fprintf('\n步骤3：生成碳势曲线...\n');

    % 选择一个实验来测试（使用最长时间的实验）
    [max_time, max_idx] = max([exp_data.total_time]);
    test_exp = exp_data(max_idx);

    fprintf('选择实验 %s 进行测试 (时长=%d秒)\n', test_exp.id, test_exp.total_time);

    % 生成碳势曲线
    output_file = fullfile(pwd, 'carb.txt');
    [time_vec, C_surface_vec] = generate_carb_curve(carb_params, test_exp.total_time);

    % 保存到carb.txt
    save_carb_txt(output_file, time_vec, C_surface_vec);

    fprintf('碳势曲线已保存到: %s\n', output_file);
    fprintf('  - 时间点数: %d\n', length(time_vec));
    fprintf('  - 碳势范围: %.4f - %.4f (%.2f%% - %.2f%%)\n', ...
        min(C_surface_vec), max(C_surface_vec), ...
        min(C_surface_vec)*100, max(C_surface_vec)*100);

    %% 步骤4：可视化碳势曲线
    fprintf('\n步骤4：可视化碳势曲线...\n');
    plot_carb_curve(time_vec, C_surface_vec, carb_params);

    %% 步骤5：COMSOL测试（可选）
    fprintf('\n步骤5：COMSOL仿真测试...\n');
    fprintf('========================================\n');
    fprintf('请确认以下事项：\n');
    fprintf('1. COMSOL模型文件存在: carbon_content_3.mph\n');
    fprintf('2. carb.txt文件已生成: %s\n', output_file);
    fprintf('========================================\n');

    user_choice = input('是否运行COMSOL测试仿真？(y/n): ', 's');

    if strcmpi(user_choice, 'y')
        % COMSOL参数
        comsol_params = struct();
        comsol_params.D0 = 5e-11;      % 扩散系数
        comsol_params.k_m = 0.1;       % 传质系数
        comsol_params.model_file = 'carbon_content_3.mph';

        fprintf('\nCOMSOL参数：\n');
        fprintf('  D0 = %.2e\n', comsol_params.D0);
        fprintf('  k_m = %.2f\n', comsol_params.k_m);
        fprintf('  模型文件 = %s\n', comsol_params.model_file);

        try
            % 运行COMSOL仿真
            fprintf('\n开始COMSOL仿真...\n');
            C_sim = run_comsol_with_carb_txt(test_exp, comsol_params, output_file);

            % 显示结果
            fprintf('\nCOMSOL仿真完成！\n');
            fprintf('实验数据对比：\n');
            fprintf('深度(mm)\t实验值(%%)\t模拟值(%%)\t差值(%%)\n');
            fprintf('------------------------------------------------\n');
            for i = 1:length(test_exp.depths)
                diff = C_sim(i)*100 - test_exp.exp_values(i);
                fprintf('%.3f\t\t%.2f\t\t%.2f\t\t%.2f\n', ...
                    test_exp.depths(i), test_exp.exp_values(i), C_sim(i)*100, diff);
            end

            % 可视化对比
            plot_comparison(test_exp, C_sim);

        catch ME
            fprintf('\nCOMSOL仿真失败: %s\n', ME.message);
            fprintf('错误位置: %s (第%d行)\n', ME.stack(1).name, ME.stack(1).line);
            fprintf('\n请检查：\n');
            fprintf('1. COMSOL Server是否启动\n');
            fprintf('2. 模型文件路径是否正确\n');
            fprintf('3. MATLAB是否连接到COMSOL\n');
        end
    else
        fprintf('\n跳过COMSOL测试。\n');
    end

    fprintf('\n===============================\n');
    fprintf('步骤1完成！\n');
    fprintf('===============================\n');
    fprintf('\n生成的文件：\n');
    fprintf('  - carb.txt: 碳势曲线数据\n');
    fprintf('  - 可视化图形已显示\n');
end

%% ===== 碳势曲线生成函数 =====
function [time_vec, C_surface_vec] = generate_carb_curve(params, total_time)
    % 功能：根据工艺参数生成碳势曲线
    % 输入：
    %   params - 碳势曲线参数结构体（beta, tau, C_final, tau_rise, tau_fall）
    %   total_time - 总时间（秒）
    % 输出：
    %   time_vec - 时间向量（秒）
    %   C_surface_vec - 表面碳势向量（小数形式）

    fprintf('  生成碳势曲线（总时长=%d秒）...\n', total_time);

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

    % 4. 计算平衡碳势（小数形式）
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

    fprintf('    碳势计算：\n');
    fprintf('      C_high = %.4f (%.2f%%)\n', C_high, C_high*100);
    fprintf('      C_low_initial = %.4f (%.2f%%)\n', C_low_initial, C_low_initial*100);
    fprintf('      单周期时间 = %d秒\n', T_cycle);

    % 5. 生成时间向量（每秒一个点）
    dt = 1;
    time_vec = (0:dt:total_time)';
    n_points = length(time_vec);
    C_surface_vec = zeros(n_points, 1);

    % 6. 计算每个时间点的碳势
    for i = 1:n_points
        t = time_vec(i);

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
            C_surface_vec(i) = C_low_current + ...
                (C_high - C_low_current) * (1 - exp(-t_local / tau_rise));
        elseif t_local < (T_rise + T_hold)
            % 保压段：恒定高碳势
            C_surface_vec(i) = C_high;
        else
            % 降压段：指数下降
            t_fall_local = t_local - (T_rise + T_hold);
            C_surface_vec(i) = C_low_next + ...
                (C_high - C_low_next) * exp(-t_fall_local / tau_fall);
        end
    end

    fprintf('  碳势曲线生成完成！\n');
end

%% ===== 保存carb.txt文件 =====
function save_carb_txt(output_file, time_vec, C_surface_vec)
    % 功能：保存碳势曲线到carb.txt文件
    % 输入：
    %   output_file - 输出文件路径
    %   time_vec - 时间向量
    %   C_surface_vec - 碳势向量

    fid = fopen(output_file, 'w');
    if fid == -1
        error('无法创建文件: %s', output_file);
    end

    % 写入数据（格式：时间 碳势）
    for i = 1:length(time_vec)
        fprintf(fid, '%.6f %.6f\n', time_vec(i), C_surface_vec(i));
    end

    fclose(fid);
end

%% ===== 可视化碳势曲线 =====
function plot_carb_curve(time_vec, C_surface_vec, params)
    % 功能：绘制碳势曲线

    figure('Position', [100, 100, 1200, 500]);

    % 子图1：完整碳势曲线
    subplot(1, 2, 1);
    plot(time_vec/60, C_surface_vec*100, 'b-', 'LineWidth', 1.5);
    xlabel('时间 (分钟)');
    ylabel('表面碳势 (%)');
    title('完整碳势曲线');
    grid on;

    % 子图2：前3个周期的细节
    subplot(1, 2, 2);
    max_time = min(780, length(time_vec));  % 前3个周期 (3*260秒)
    plot(time_vec(1:max_time), C_surface_vec(1:max_time)*100, 'r-', 'LineWidth', 2);
    xlabel('时间 (秒)');
    ylabel('表面碳势 (%)');
    title('前3个周期细节');
    grid on;

    sgtitle(sprintf('碳势曲线 (β=%.2f, τ=%.1f, C_{final}=%.2f%%)', ...
        params.beta, params.tau, params.C_final*100), 'FontSize', 12);
end

%% ===== COMSOL仿真函数 =====
function C_sim = run_comsol_with_carb_txt(exp_data, comsol_params, carb_file)
    % 功能：使用carb.txt运行COMSOL仿真
    % 输入：
    %   exp_data - 实验数据结构体
    %   comsol_params - COMSOL参数（D0, k_m, model_file）
    %   carb_file - carb.txt文件路径
    % 输出：
    %   C_sim - 模拟的碳浓度（小数形式）

    import com.comsol.model.*;
    import com.comsol.model.util.*;

    try
        % 1. 加载模型
        fprintf('  加载COMSOL模型: %s\n', comsol_params.model_file);
        model = mphload(comsol_params.model_file);

        % 2. 检查并创建/更新插值函数
        fprintf('  设置碳势插值函数...\n');
        func_exists = false;
        try
            model.func('C_surface_func');
            func_exists = true;
        catch
        end

        if func_exists
            % 函数已存在，只更新数据
            fprintf('    更新已有插值函数\n');
            model.func('C_surface_func').set('filename', carb_file);
            model.func('C_surface_func').importData();
        else
            % 函数不存在，创建新的
            fprintf('    创建新插值函数\n');
            model.func.create('C_surface_func', 'Interpolation');
            model.func('C_surface_func').set('source', 'file');
            model.func('C_surface_func').set('filename', carb_file);
            model.func('C_surface_func').set('nargs', '1');
            model.func('C_surface_func').set('struct', 'spreadsheet');
            model.func('C_surface_func').set('funcs', {'C_surface_func', '1'});
            model.func('C_surface_func').set('interp', 'linear');
            model.func('C_surface_func').importData();
        end

        % 3. 设置扩散参数
        fprintf('  设置COMSOL参数...\n');
        model.param.set('D0', sprintf('%.6e', comsol_params.D0));
        model.param.set('k_m', sprintf('%.6f', comsol_params.k_m));

        % 4. 设置求解时间
        fprintf('  设置求解时间: %d秒\n', exp_data.total_time);
        model.study('std1').feature('time').set('tlist', ...
            sprintf('range(0,1,%d)', exp_data.total_time));

        % 5. 运行求解
        fprintf('  开始求解...\n');
        model.study('std1').run();
        fprintf('  求解完成！\n');

        % 6. 提取结果
        fprintf('  提取结果...\n');
        depths_m = exp_data.depths / 1000;  % mm转m

        % 构造2D坐标矩阵 (2行N列): [x坐标; y坐标]
        % 假设：深度是x方向，y=0
        coords = [depths_m(:)'; zeros(1, length(depths_m))];
        fprintf('    坐标矩阵大小: %dx%d\n', size(coords, 1), size(coords, 2));

        % 使用mphinterp提取结果
        C_sim = mphinterp(model, 'c', 'coord', coords);
        C_sim = C_sim(:);
        fprintf('    提取成功，数据点数: %d\n', length(C_sim));

        % 7. 清理
        ModelUtil.remove('model');
        fprintf('  模型已清理\n');

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

%% ===== 对比可视化 =====
function plot_comparison(exp_data, C_sim)
    % 功能：绘制实验与模拟的对比图

    figure('Position', [100, 100, 800, 600]);

    % 实验数据
    plot(exp_data.depths, exp_data.exp_values, 'ro-', ...
        'LineWidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', 'r', ...
        'DisplayName', '实验数据');
    hold on;

    % 模拟数据
    plot(exp_data.depths, C_sim*100, 'bs-', ...
        'LineWidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', 'b', ...
        'DisplayName', 'COMSOL模拟');

    xlabel('深度 (mm)', 'FontSize', 12);
    ylabel('碳浓度 (%)', 'FontSize', 12);
    title(sprintf('实验数据对比: %s (%s)', exp_data.id, exp_data.name), ...
        'FontSize', 14);
    legend('Location', 'best', 'FontSize', 11);
    grid on;

    % 计算误差
    error_vals = (C_sim*100 - exp_data.exp_values');
    rmse = sqrt(mean(error_vals.^2));
    mae = mean(abs(error_vals));

    % 添加误差信息
    text(0.6, 0.95, sprintf('RMSE = %.3f%%\nMAE = %.3f%%', rmse, mae), ...
        'Units', 'normalized', 'FontSize', 11, ...
        'BackgroundColor', 'white', 'EdgeColor', 'black');
end
