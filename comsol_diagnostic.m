%% ===============================
% COMSOL连接诊断和模型信息查看工具
% 功能：检查COMSOL连接，查看模型详细信息
% 作者：参数优化系统
% 日期：2025年
%% ===============================

function comsol_diagnostic()
    clc;
    fprintf('===============================\n');
    fprintf('COMSOL连接诊断工具\n');
    fprintf('===============================\n');

    %% 步骤1：检查COMSOL是否可用
    fprintf('\n步骤1：检查COMSOL是否可用...\n');
    try
        import com.comsol.model.*;
        import com.comsol.model.util.*;
        fprintf('  ✓ COMSOL Java包导入成功\n');
    catch ME
        fprintf('  ✗ COMSOL Java包导入失败: %s\n', ME.message);
        fprintf('\n请执行以下操作：\n');
        fprintf('1. 启动COMSOL Desktop\n');
        fprintf('2. 在MATLAB中运行: mphstart\n');
        return;
    end

    %% 步骤2：检查模型文件
    fprintf('\n步骤2：检查模型文件...\n');
    model_file = 'carbon_content_3.mph';

    if ~exist(model_file, 'file')
        fprintf('  ✗ 模型文件未找到: %s\n', model_file);
        fprintf('  当前目录: %s\n', pwd);

        % 搜索可能的模型文件
        mph_files = dir('*.mph');
        if ~isempty(mph_files)
            fprintf('\n  在当前目录找到以下mph文件：\n');
            for i = 1:length(mph_files)
                fprintf('    - %s\n', mph_files(i).name);
            end

            user_input = input('\n  请输入要使用的模型文件名（或按回车跳过）: ', 's');
            if ~isempty(user_input)
                model_file = user_input;
            else
                return;
            end
        else
            return;
        end
    else
        fprintf('  ✓ 模型文件存在: %s\n', model_file);
    end

    %% 步骤3：加载模型
    fprintf('\n步骤3：加载模型...\n');
    try
        model = mphload(model_file);
        fprintf('  ✓ 模型加载成功\n');
    catch ME
        fprintf('  ✗ 模型加载失败: %s\n', ME.message);
        return;
    end

    %% 步骤4：查看模型基本信息
    fprintf('\n步骤4：模型基本信息\n');
    fprintf('======================================\n');

    % 几何信息
    fprintf('\n4.1 几何信息：\n');
    try
        geom_tags = model.geom.tags;
        fprintf('  - 几何数量: %d\n', length(geom_tags));
        for i = 1:length(geom_tags)
            geom_tag = char(geom_tags(i));
            geom_dim = model.geom(geom_tag).getSDim();
            fprintf('  - 几何 %s: %dD\n', geom_tag, geom_dim);
        end
    catch ME
        fprintf('  ✗ 无法获取几何信息: %s\n', ME.message);
    end

    % 全局参数
    fprintf('\n4.2 全局参数：\n');
    try
        param_names = model.param.varnames;
        if length(param_names) > 0
            for i = 1:length(param_names)
                param_name = char(param_names(i));
                param_value = model.param.evaluate(param_name);
                param_desc = model.param.descr(param_name);
                fprintf('  - %s = %s', param_name, mat2str(param_value));
                if ~isempty(param_desc)
                    fprintf(' (%s)', char(param_desc));
                end
                fprintf('\n');
            end
        else
            fprintf('  - 无全局参数\n');
        end
    catch ME
        fprintf('  ✗ 无法获取参数信息: %s\n', ME.message);
    end

    % 函数
    fprintf('\n4.3 定义的函数：\n');
    try
        func_tags = model.func.tags;
        if length(func_tags) > 0
            for i = 1:length(func_tags)
                func_tag = char(func_tags(i));
                func_type = char(model.func(func_tag).getType());
                fprintf('  - %s (类型: %s)\n', func_tag, func_type);
            end
        else
            fprintf('  - 无定义函数\n');
        end
    catch ME
        fprintf('  ✗ 无法获取函数信息: %s\n', ME.message);
    end

    % 物理场
    fprintf('\n4.4 物理场：\n');
    try
        phys_tags = model.physics.tags;
        if length(phys_tags) > 0
            for i = 1:length(phys_tags)
                phys_tag = char(phys_tags(i));
                phys_type = char(model.physics(phys_tag).getType());
                fprintf('  - %s (类型: %s)\n', phys_tag, phys_type);
            end
        else
            fprintf('  - 无物理场定义\n');
        end
    catch ME
        fprintf('  ✗ 无法获取物理场信息: %s\n', ME.message);
    end

    % 研究
    fprintf('\n4.5 研究：\n');
    try
        study_tags = model.study.tags;
        if length(study_tags) > 0
            for i = 1:length(study_tags)
                study_tag = char(study_tags(i));
                fprintf('  - %s\n', study_tag);

                % 研究步骤
                step_tags = model.study(study_tag).feature.tags;
                for j = 1:length(step_tags)
                    step_tag = char(step_tags(j));
                    step_type = char(model.study(study_tag).feature(step_tag).getType());
                    fprintf('    - 步骤 %s (类型: %s)\n', step_tag, step_type);
                end
            end
        else
            fprintf('  - 无研究定义\n');
        end
    catch ME
        fprintf('  ✗ 无法获取研究信息: %s\n', ME.message);
    end

    % 变量
    fprintf('\n4.6 模型变量：\n');
    try
        var_tags = model.variable.tags;
        if length(var_tags) > 0
            for i = 1:length(var_tags)
                var_tag = char(var_tags(i));
                var_names = model.variable(var_tag).varnames;
                fprintf('  - 变量组 %s: %d 个变量\n', var_tag, length(var_names));
                if length(var_names) <= 10
                    for j = 1:length(var_names)
                        fprintf('    - %s\n', char(var_names(j)));
                    end
                else
                    fprintf('    (太多，省略显示)\n');
                end
            end
        else
            fprintf('  - 无变量定义\n');
        end
    catch ME
        fprintf('  ✗ 无法获取变量信息: %s\n', ME.message);
    end

    %% 步骤5：测试结果提取
    fprintf('\n步骤5：测试结果提取\n');
    fprintf('======================================\n');

    user_input = input('是否运行模型并测试结果提取？(y/n): ', 's');
    if strcmpi(user_input, 'y')
        try
            fprintf('\n运行模型...\n');
            model.study('std1').run();
            fprintf('  ✓ 模型运行成功\n');

            % 测试不同的提取方法
            fprintf('\n测试结果提取方法...\n');

            % 方法1：mphinterp
            fprintf('\n方法1: mphinterp\n');
            try
                % 获取几何维度
                geom_tag = char(model.geom.tags(1));
                geom_dim = model.geom(geom_tag).getSDim();

                % 测试点 (x=0.001, y=0, z=0)
                if geom_dim == 1
                    test_coords = 0.001;
                elseif geom_dim == 2
                    test_coords = [0.001; 0];
                elseif geom_dim == 3
                    test_coords = [0.001; 0; 0];
                end

                result = mphinterp(model, 'c', 'coord', test_coords);
                fprintf('  ✓ mphinterp成功\n');
                fprintf('    测试点坐标: %s\n', mat2str(test_coords));
                fprintf('    碳浓度 c = %.6f\n', result);
            catch ME
                fprintf('  ✗ mphinterp失败: %s\n', ME.message);
            end

            % 方法2：mpheval
            fprintf('\n方法2: mpheval\n');
            try
                result = mpheval(model, 'c', 'dataset', 'dset1', 'edim', 0, 'selection', 1);
                fprintf('  ✓ mpheval成功\n');
                fprintf('    数据点数: %d\n', size(result.p, 2));
                fprintf('    坐标范围: [%.6f, %.6f]\n', min(result.p(1,:)), max(result.p(1,:)));
                fprintf('    碳浓度范围: [%.6f, %.6f]\n', min(result.d1), max(result.d1));

                % 显示前5个点
                fprintf('    前5个数据点:\n');
                for i = 1:min(5, size(result.p, 2))
                    fprintf('      x=%.6f, c=%.6f\n', result.p(1,i), result.d1(i));
                end
            catch ME
                fprintf('  ✗ mpheval失败: %s\n', ME.message);
            end

        catch ME
            fprintf('  ✗ 模型运行失败: %s\n', ME.message);
        end
    end

    %% 清理
    try
        ModelUtil.remove('model');
        fprintf('\n✓ 模型已清理\n');
    catch
    end

    fprintf('\n===============================\n');
    fprintf('诊断完成！\n');
    fprintf('===============================\n');
end
