%% 测试坐标维度构造
% 用于验证修复后的坐标构造逻辑

function test_coordinate_dimensions()
    fprintf('===============================\n');
    fprintf('测试坐标维度构造\n');
    fprintf('===============================\n');

    % 模拟实验数据中的depths（可能是行向量或列向量）
    test_cases = {
        'depths是行向量',    [0.075, 0.225, 0.375, 0.525, 0.7];
        'depths是列向量',    [0.075; 0.225; 0.375; 0.525; 0.7];
    };

    for tc = 1:size(test_cases, 1)
        case_name = test_cases{tc, 1};
        depths = test_cases{tc, 2};

        fprintf('\n测试案例 %d: %s\n', tc, case_name);
        fprintf('  原始维度: %dx%d\n', size(depths, 1), size(depths, 2));

        % 转换为米
        depths_m = depths / 1000;
        fprintf('  转换后维度: %dx%d\n', size(depths_m, 1), size(depths_m, 2));

        % 应用修复后的逻辑
        if size(depths_m, 1) > size(depths_m, 2)
            depths_m = depths_m';  % 转换为行向量
            fprintf('  转置后维度: %dx%d\n', size(depths_m, 1), size(depths_m, 2));
        end

        % 测试不同维度的坐标构造
        for geom_dim = 1:3
            fprintf('\n  几何维度: %dD\n', geom_dim);

            try
                if geom_dim == 1
                    coords = depths_m';
                elseif geom_dim == 2
                    coords = [depths_m; zeros(1, length(depths_m))];
                elseif geom_dim == 3
                    coords = [depths_m; zeros(1, length(depths_m)); zeros(1, length(depths_m))];
                end

                fprintf('    ✓ 坐标矩阵大小: %dx%d\n', size(coords, 1), size(coords, 2));
                fprintf('    ✓ 前3个坐标点:\n');
                for i = 1:min(3, size(coords, 2))
                    if geom_dim == 1
                        fprintf('      点%d: x=%.6f\n', i, coords(i));
                    elseif geom_dim == 2
                        fprintf('      点%d: x=%.6f, y=%.6f\n', i, coords(1,i), coords(2,i));
                    elseif geom_dim == 3
                        fprintf('      点%d: x=%.6f, y=%.6f, z=%.6f\n', i, coords(1,i), coords(2,i), coords(3,i));
                    end
                end

            catch ME
                fprintf('    ✗ 错误: %s\n', ME.message);
            end
        end
    end

    fprintf('\n===============================\n');
    fprintf('测试完成！\n');
    fprintf('===============================\n');
end
