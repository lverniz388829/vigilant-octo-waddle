local ModuleScript = {}

function ModuleScript.new(instance)
    local moduleScript = {}
    local closure = getScriptClosure(instance)

    moduleScript.Instance = instance
    moduleScript.Constants = getConstants(closure)
    moduleScript.Protos = getProtos(closure)
    
    moduleScript.GetSource = function()
        if decompile then
            local success, source = pcall(decompile, instance)
            if success and source then
                return source
            end
        end
        return "-- Decompiler not available or failed\n-- Use an executor with decompile() support"
    end

    return moduleScript
end

return ModuleScript
