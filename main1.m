%% 主函数参考 知乎[平面三角形单元有限元实现——有限元实践笔记（5）] 进行验证
%% 和可视化https://zhuanlan.zhihu.com/p/350535965

clc
clear;
% %-----主程序
%-------------------------------% 初始化 %------------------------------%
% 导入节点信息和杆单元
clc
clear;
node=[1 0 0 0;
      2 0.75 0 0;
      3 1.5  0 0;
      4 2.25 0 0;
      5 3 0 0;
      6 0 0.75 0;
      7 0.75 0.75 0;
      8 1.5 0.75 0;
      9 2.25 0.75 0;
      10 3 0.75 0;
      11 0 1.5 0;
      12 0.75 1.5 0;
      13 1.5 1.5 0;
      14 2.25 1.5 0;
      15 3 1.5 0];   %节点信息，第一列为节点编号，2~4列分别为x,y,z方向坐标
ele=[1 1 2 7;
     2 1 7 6;
     3 2 3 8;
     4 2 8 7;
     5 3 4 9;
     6 3 9 8;
     7 4 5 10;
     8 4 10 9;
     9 6 7 12;
     10 6 12 11;
     11 7 8 13;
     12 7 13 12;
     13 8 9 14;
     14 8 14 13;
     15 9 10 15;
     16 9 15 14];
num_ele=size(ele, 1);          % 单元数


 %---物理参数------------------
E = 1;               % 弹性模量
t = 0.001;               % 单元厚度
miu = 0;               % 泊松比

n_ele = length(ele(:, 1));   %单元数
%-----------------------------------------------------------------------%

%-------------------------% 组装整体刚度矩阵 %---------------------------%
%组装总体刚度矩阵
dof = length(node(:, 1))*2;       % 自由度数，梁单元每个节点有3个自由度
                               % (横向位移、扭转角位移、弯曲角位移)
f = ones(dof, 1)*1e8;             % 结构整体外载荷矩阵，整体坐标系下
f_loc = zeros(6, 1);              % 单元外载荷矩阵，局部坐标系下
u = ones(dof, 1)*1e6;             % 位移矩阵
K = zeros(dof);                  % 总体刚度矩阵
stress = zeros(n_ele, 1);         % 单元应力矩阵

for i = 1 : n_ele
    k_ele = TriangleElementStiffness(E, miu, t, node(ele(i, 2:4), 2:4));
    K = assemTriangle(K, k_ele, ele(i, 2), ele(i, 3), ele(i, 4));
end
%-----------------------------------------------------------------------%

%---------------------------% 定义边界条件 %-----------------------------%
%力边界条件 
f(9)=5;        % 5节点横向力
f(10)=0;            % 5节点垂向力
f(19)=10;        % 10节点横向力
f(20)=0;            % 10节点垂向力
f(29)=5;       % 15节点横向力
f(30)=0;            % 15节点垂向力
f(3)=0; f(4)=0; f(13)=0; f(14)=0; f(23)=0; f(24)=0; 
f(5)=0; f(6)=0; f(15)=0; f(16)=0; f(25)=0; f(26)=0; 
f(7)=0; f(8)=0; f(17)=0; f(18)=0; f(27)=0; f(28)=0;
%位移边界条件
u(1)=0; u(2)=0; u(11)=0; u(12)=0; u(21)=0; u(22)=0;
%-----------------------------------------------------------------------%

%-------------------------------% 求解 %--------------------------------%
%求解未知自由度
index = [];           % 未知自由度的索引
p = [];               % 未知自由度对应的节点力矩阵
for i = 1:dof
    if u(i) ~= 0
        index = [index, i];
        p = [p; f(i)];
    end
end
u(index) = K(index, index) \ p;    % 高斯消去
f = K * u;

% 单元应力
stress = zeros(num_ele, 3);
x1 = node(:, 2) + u(1:2:30);
y1 = node(:, 3) + u(2:2:30);
%-----------------------------------------------------------------------%

%------------------------------% 可视化 %-------------------------------%
figure;
for i=1 : n_ele
    u1 = [u(2*ele(i, 2)-1);
        u(2*ele(i, 2));
        u(2*ele(i, 3)-1);
        u(2*ele(i, 3));
        u(2*ele(i, 4)-1);
        u(2*ele(i, 4))];
    stress(i, :) = TriangleElementStress(E, miu, node(ele(i ,2:4), 2:3), u1, 1)';   % 单元应力计算
    patch(node(ele(i, 2:4), 2), node(ele(i, 2:4), 3), stress(i, 1), 'FaceColor','flat', 'EdgeColor','k');
end
colormap(jet);  % 使用 jet 颜色图
colorbar;  % 显示颜色条

hold on;
figure;
for i=1 : n_ele
    patch(node(ele(i, 2:4),2), node(ele(i, 2:4),3), ...
        'w', 'FaceColor', 'none', 'LineStyle', '-','EdgeColor', 'b');
    hold on;
    patch(x1(ele(i, 2:4)), y1(ele(i, 2:4)), ...
        'w', 'FaceColor', 'none', 'EdgeColor', 'r');
end
%-----------------------------------------------------------------------%
    
    
    
    