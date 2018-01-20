{application, 'test_cowboy2', [
	{description, "New project"},
	{vsn, "0.1.0"},
	{modules, ['auto','familie','fiets','index_depr_dtl','index_dtl','intelligentie','interface','log_handler','login_dtl','login_handler','logout_handler','logs_dtl','persoon','request_handler','reserveer_handler','stop_handler','test_cowboy2_app','test_cowboy2_sup','toplevel','vanNaar','verwijder_handler']},
	{registered, [test_cowboy2_sup,toplevel,interface]},
	{applications, [kernel,stdlib,wx,observer,runtime_tools,cowboy,erlydtl]},
	{mod, {test_cowboy2_app, []}},
	{env, []}
]}.