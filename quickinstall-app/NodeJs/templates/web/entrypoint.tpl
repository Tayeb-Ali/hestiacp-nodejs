module.exports = {
	apps : [{
		name   : '%app_name%',
		script : '%app_start_script%',
		cwd    : '%app_cwd%',
		env    : {
			NODE_ENV : 'production',
			PORT     : '%app_port%'
		},
		watch  : false,
		max_memory_restart : '512M',
		instances : 1,
		autorestart : true
	}]
}