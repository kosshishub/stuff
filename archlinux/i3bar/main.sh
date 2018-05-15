#!/bin/sh
echo '{ "version": 1 }'
echo '['
echo '[]'
while :;
do
	ram="$(~/script/i3bar/rambar.sh)";
	dt=$(date '+%d/%m/%Y %H:%M:%S');

	load="$( cat /proc/loadavg | cut -d ' ' -f 1 )";

	clock="$(lscpu | grep "CPU MHz" | tr -s ' ' | cut -d ' ' -f 3 | cut -d '.' -f 1)";

	ip="$( ip addr show enp6s0 | grep "inet " | tr -s ' ' | cut -d ' ' -f 3 | cut -d '/' -f 1 )"

	gpu_temp_raw=$(cat /sys/class/drm/card0/device/hwmon/hwmon1/temp1_input);
	gpu_fan=$(cat /sys/class/drm/card0/device/hwmon/hwmon1/fan1_input);

	let "gpu_temp = gpu_temp_raw / 1000 "

	gpu_mem_state=$(cat /sys/class/drm/card0/device/pp_dpm_mclk | grep "*" | cut -d ' ' -f 2 | cut -d 'M' -f 1); 
	gpu_pci_state=$(cat /sys/class/drm/card0/device/pp_dpm_pcie | grep "*" | cut -d ' ' -f 2 | cut -d 'M' -f 1);
	gpu_clk_state=$(cat /sys/class/drm/card0/device/pp_dpm_sclk | grep "*" | cut -d ' ' -f 2 | cut -d 'M' -f 1);

	
	cpu_temp_raw=$(cat /sys/class/hwmon/hwmon0/temp1_input);
	let "cpu_temp = cpu_temp_raw / 1000";


	if	[ $(echo " $load > 8.00" | bc) -eq 1 ]
	then 	loadcolor="#ff8888";
	elif 	[ $(echo " $load > 4.00" | bc) -eq 1 ]
	then	loadcolor="#ffff88";
	else	loadcolor="#8888ff";
	fi


	if	[ $(echo " $gpu_temp > 60.00" | bc) -eq 1 ]
	then 	gpu_temp_color="#ff8888";
	elif 	[ $(echo " $gpu_temp > 45.00" | bc) -eq 1 ]
	then	gpu_temp_color="#ffff88";
	else	gpu_temp_color="#8888ff";
	fi

	
	if [ -z $ip ]
	then
		ip="No IP address"
		netcolor="#ff8888";
	else	netcolor="#8888ff";
	fi

	echo ",
	[{
		\"name\":			\"temperature\",
		\"full_text\":			\"GPU $gpu_temp 'C\",
		\"color\": 			\"$gpu_temp_color\",
		\"background\": 		\"#000000\",
		\"border\":		 	\"#000000\",
		\"min_width\":	 		50,
		\"align\":			\"center\"
	},{
		\"name\":			\"gpu\",
		\"full_text\":			\"$gpu_clk_state MHz $gpu_fan RPM\",
		\"color\": 			\"#ffffff\",
		\"background\": 		\"#000000\",
		\"border\":		 	\"#000000\",
		\"min_width\":	 		125,
		\"align\":			\"center\"
	},{
		\"name\":			\"net\",
		\"full_text\":			\"$ip\",
		\"color\": 			\"$netcolor\",
		\"background\": 		\"#000000\",
		\"border\":		 	\"#000000\",
		\"min_width\":	 		90,
		\"align\":			\"center\"
	},{
		\"name\":			\"ram\",
		\"full_text\":			\"$ram\",
		\"color\": 			\"#ffffff\",
		\"background\": 		\"#000000\",
		\"border\":		 	\"#000000\",
		\"min_width\":	 		135,
		\"align\":			\"center\"
	},{
		\"name\":			\"clock\",
		\"full_text\":			\"$clock MHz $cpu_temp 'C\",
		\"color\": 			\"#cccccc\",
		\"background\": 		\"#000000\",
		\"border\":		 	\"#000000\"
	},{
		\"name\":			\"load\",
		\"full_text\":			\"$load\",
		\"color\": 			\"$loadcolor\",
		\"background\": 		\"#000000\",
		\"border\":		 	\"#000000\"
	},{
		\"name\":			\"date\",
		\"full_text\":			\"$dt\",
		\"color\": 			\"#cccccc\",
		\"background\": 		\"#000000\",
		\"border\":		 	\"#000000\"
	}]"

	sleep 1
done
