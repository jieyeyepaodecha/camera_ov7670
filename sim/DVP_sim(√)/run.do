#Modelsim指令： do run.do
#退出当前仿真

quit -sim

vlib work

#编译文件.
vlog "../../src/DVP.v"
vlog "./*.v"

#开始仿真
vsim -voptargs=+acc work.tb_DVP

#添加指定信号
#添加顶层所有的信号
# Set the window types
# 打开波形窗口

view wave
view structure

# 打开信号窗口

view signals

# 添加波形模板

add wave tb_DVP/u_DVP/*


.main clear

#运行xxms

run 100ms
