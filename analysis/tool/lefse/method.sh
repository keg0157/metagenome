#LefSe方法
python format_input.py input/species_table_LTP_2017_05_29_relative_stage0 tmp/stage0.in -c 2 -u 1 -o 1000000
python run_lefse.py tmp/stage0.in results/stage0.res
python plot_res.py results/stage0.res output_figures/stage0_bar.png
python plot_cladogram.py results/stage0.res output_figures/stage0.cladogram.png --format png
