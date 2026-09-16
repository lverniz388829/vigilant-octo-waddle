local LocalScript = {}

function LocalScript.new(instance)
    local localScript = {}
    local closure = getScriptClosure(instance)

    localScript.Instance = instance
    localScript.Environment = getSenv(instance)
    localScript.Constants = getConstants(closure)
    localScript.Protos = getProtos(closure)
    
    localScript.GetSource = function()
        if decompile then
            local success, source = pcall(decompile, instance)
            if success and source then
                return source
            end
        end
        return "-- Decompiler not available or failed\n-- Use an executor with decompile() support"
    end

    return localScript
end

return LocalScript