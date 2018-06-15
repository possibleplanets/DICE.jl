function assign_scenario(s::BasePriceScenario, config::RockyRoadOptions, params::RockyRoadParameters, vars::VariablesV2013)
    photel = getvalue(vars.CPRICE);

    for i in 1:config.N
        if i <= config.tnopol
            setupperbound(vars.CPRICE[i], max(photel[i],params.cpricebase[i]));
        end
    end
end

function assign_scenario(s::OptimalPriceScenario, config::RockyRoadOptions, params::RockyRoadParameters, vars::VariablesV2013)
    setupperbound(vars.μ[1], config.μ₀);
end

function assign_scenario(s::Limit2DegreesScenario, config::RockyRoadOptions, params::RockyRoadParameters, vars::VariablesV2013)
    for i in 1:config.N
        setupperbound(vars.Tₐₜ[i], 2.0);
    end
end

function assign_scenario(s::SternScenario, config::RockyRoadOptions, params::RockyRoadParameters, vars::VariablesV2013)
    setvalue(params.α, 1.01);
    setvalue(params.ρ, 0.001);
end

function assign_scenario(s::SternCalibratedScenario, config::RockyRoadOptions, params::RockyRoadParameters, vars::VariablesV2013)
    setvalue(params.α, 2.1);
    setvalue(params.ρ, 0.001);
    #NOTE: This should ultimately be the following constraints, but
    #the JuMP/Ipopt configuration currently add new constraints
    #after solving. So we just bind the variable to its upper and lower bounds.

    #@constraint(model, vars.μ[1] == 0.038976);
    #@constraint(model, vars.Tₐₜ[1] == 0.83);
    setlowerbound(vars.μ[1], 0.038976);
    setupperbound(vars.μ[1], 0.038976);
    setlowerbound(vars.Tₐₜ[1], 0.83);
    setupperbound(vars.Tₐₜ[1], 0.83);

    for i in 2:config.N
        setlowerbound(vars.μ[i], 0.01);
    end
end

function assign_scenario(s::CopenhagenScenario, config::RockyRoadOptions, params::RockyRoadParameters, vars::VariablesV2013)
    # The Emissions Control Rate Imported
    imported_μ = fill(0.9, config.N);
    imported_μ[1:27] = [0.02,0.055874801,0.110937151,0.163189757,0.206247482,0.241939219,0.30180914,0.364484979,0.423670192,0.478283881,0.534073643,0.588156847,0.633622,0.672457,0.705173102,0.733018573,0.756457118,0.776297581,0.794110815,0.822197128,0.839125811,0.854453754,0.868106413,0.880485825,0.891631752,0.901741794,0.9];
    #NOTE: This should ultimately be the following constraints, but
    #the JuMP/Ipopt configuration currently add new constraints
    #after solving. So we just bind the variable to its upper and lower bounds.

    #@constraint(model, [i=1:config.N], vars.μ[i] == imported_μ[i]);
    #setlowerbound(vars.μ[1], 0.0);
    #setupperbound(vars.μ[1], 1.5);

    for i in 1:config.N
        setlowerbound(vars.μ[i], imported_μ[i]);
        setupperbound(vars.μ[i], imported_μ[i]);
    end

    #The Copenhagen participation fraction.
    imported_partfrac = ones(config.N);
    imported_partfrac[1:19] = [0.2,0.390423082,0.379051794,0.434731269,0.42272216,0.410416777,0.707776548,0.692148237,0.840306905,0.834064356,0.939658852,0.936731085,0.933881267,0.930944201,0.928088049,0.925153812,0.922301007,0.919378497,1.0];

    setvalue(params.partfract[i=1:config.N], imported_partfrac[i]);
end
