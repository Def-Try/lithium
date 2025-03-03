if SERVER then
	RunConsoleCommand("mem_max_heapsize", "131072")
	RunConsoleCommand("mem_max_heapsize_dedicated", "131072")
	RunConsoleCommand("mem_min_heapsize", "131072")
	RunConsoleCommand("threadpool_affinity", "64")
	RunConsoleCommand("decalfrequency", "10")
	RunConsoleCommand("gmod_physiterations", "2")
	RunConsoleCommand("sv_minrate", "1048576")
	return
end

if CLIENT then
	RunConsoleCommand("gmod_mcore_test", "1")
	RunConsoleCommand("mem_max_heapsize", "131072")
	RunConsoleCommand("mem_max_heapsize_dedicated", "131072")
	RunConsoleCommand("mem_min_heapsize", "131072")
	RunConsoleCommand("threadpool_affinity", "64")
	RunConsoleCommand("mat_queue_mode", "2")
	RunConsoleCommand("mat_powersavingsmode", "0")
	RunConsoleCommand("r_queued_ropes", "1")
	RunConsoleCommand("r_threaded_renderables", "1")
	RunConsoleCommand("r_threaded_particles", "1")
	RunConsoleCommand("r_threaded_client_shadow_manager", "1")
	RunConsoleCommand("cl_threaded_client_leaf_system","1") 
	RunConsoleCommand("cl_threaded_bone_setup","1") 
	RunConsoleCommand("cl_forcepreload", "1")
	RunConsoleCommand("cl_lagcompensation", "1")
	RunConsoleCommand("cl_timeout", "3600")
	RunConsoleCommand("cl_smoothtime", "0.05")
	RunConsoleCommand("cl_localnetworkbackdoor", "1")
	RunConsoleCommand("cl_cmdrate", "66")
	RunConsoleCommand("cl_updaterate", "66")
	RunConsoleCommand("cl_interp_ratio", "2")
	RunConsoleCommand("snd_mix_async", "1")
	RunConsoleCommand("snd_async_fullyasync", "1")
	RunConsoleCommand("snd_async_minsize", "0")
	RunConsoleCommand("sv_forcepreload", "1")
	RunConsoleCommand("studio_queue_mode", "1")
	RunConsoleCommand("net_maxpacketdrop", "0")
	RunConsoleCommand("net_chokeloop", "1")
	RunConsoleCommand("net_compresspackets", "1")
	RunConsoleCommand("net_splitpacket_maxrate", "50000")
	RunConsoleCommand("net_compresspackets_minsize", "4097")
	RunConsoleCommand("net_maxroutable", "1200")
	RunConsoleCommand("net_maxfragments", "1200")
	RunConsoleCommand("net_maxfilesize", "64")
	RunConsoleCommand("net_maxcleartime", "0")
	RunConsoleCommand("ai_expression_optimization", "1")
	RunConsoleCommand("filesystem_max_stdio_read", "64")
	RunConsoleCommand("in_usekeyboardsampletime", "1")
	RunConsoleCommand("r_radiosity", "4")
	RunConsoleCommand("rate", "1048576")
	RunConsoleCommand("mat_frame_sync_enable", "0")
	RunConsoleCommand("mat_framebuffercopyoverlaysize", "0")
	RunConsoleCommand("mat_managedtextures", "0")
	RunConsoleCommand("fast_fogvolume", "1")
	RunConsoleCommand("lod_TransitionDist", "2000")
	RunConsoleCommand("filesystem_unbuffered_io", "0")
	RunConsoleCommand("gmod_mcore_test", "0")
	RunConsoleCommand("mat_queue_mode", "-1")
	RunConsoleCommand("r_queued_ropes", "0")
	RunConsoleCommand("r_threaded_renderables", "0")
	RunConsoleCommand("r_threaded_particles", "0")
	RunConsoleCommand("r_threaded_client_shadow_manager", "0")
	RunConsoleCommand("cl_threaded_client_leaf_system","0") RunConsoleCommand("cl_threaded_bone_setup","0")
	RunConsoleCommand("ai_expression_optimization", "0")
	RunConsoleCommand("fast_fogvolume", "0")
	RunConsoleCommand("mat_managedtextures", "1")
	RunConsoleCommand("filesystem_unbuffered_io", "1") 
	RunConsoleCommand("snd_mix_async", "0")
	RunConsoleCommand("snd_async_fullyasync", "0")
	RunConsoleCommand("snd_async_minsize", "262144")
	RunConsoleCommand("cl_forcepreload", "0")
	RunConsoleCommand("net_maxpacketdrop", "5000")
	RunConsoleCommand("net_chokeloop", "0")
	RunConsoleCommand("net_splitpacket_maxrate", "1048576")
	RunConsoleCommand("net_compresspackets_minsize", "1024")
	RunConsoleCommand("net_maxfragments", "1260")
	RunConsoleCommand("net_maxfilesize", "16")
	RunConsoleCommand("net_maxcleartime", "4")
	RunConsoleCommand("cl_lagcompensation", "0")
	RunConsoleCommand("cl_timeout", "30")
	RunConsoleCommand("cl_smoothtime", "0.1")
	RunConsoleCommand("cl_localnetworkbackdoor", "0")
	RunConsoleCommand("cl_cmdrate", "30")
	RunConsoleCommand("cl_updaterate", "20")
	return
end