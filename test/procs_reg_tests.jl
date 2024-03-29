let
    gw = GW._test_gw()
    GW.agent_dir(gw) |> GW._rm
    
    agent_ider = "HBKJSDBHK"
    pid = getpid()
    rfile = GW._reg_proc(gw, agent_ider, pid)
    @test isfile(rfile)
    rfile1 = GW._findfirst_proc_reg(gw, pid)
    rfile2 = GW._findfirst_proc_reg(gw, agent_ider)
    @test rfile1 == rfile2

    @test GW._is_valid_proc(gw, pid)
    @test GW._is_valid_proc(gw, agent_ider)

    GW.agent_dir(gw) |> GW._rm
end