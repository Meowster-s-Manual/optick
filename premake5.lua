if _ACTION == "clean" then
	return
end

newoption {
	trigger = "UWP",
	description = "Generates Universal Windows Platform application type",
}

newoption {
	trigger = "DX12",
	description = "Generates a sample for DirectX12",
}

newoption {
	trigger = "Vulkan",
	description = "Generates a sample for Vulkan",
}

newoption {
    trigger = "Fibers",
    description = "Enables fibers support",
}

if not _ACTION then
	_ACTION="vs2022"
end

isVisualStudio = false
isUWP = false
isDX12 = false
isVulkan = false

if _ACTION == "vs2010" or _ACTION == "vs2012" or _ACTION == "vs2015" or _ACTION == "vs2017" or _ACTION == "vs2022" then
	isVisualStudio = true
end

if _OPTIONS["UWP"] then
	isUWP = true
end

if _OPTIONS["DX12"] then
	isDX12 = true
end

if _OPTIONS["Vulkan"] then
	isVulkan = true
end

if _OPTIONS["Fibers"] then
    isFibersEnabled = true
end

if isUWP then
	premake.vstudio.toolset = "v140"
	premake.vstudio.storeapp = "10.0"
end

-- SUBPROJECTS

project "OptickCore"
	uuid "830934D9-6F6C-C37D-18F2-FB3304348F00"
	defines { "_CRT_SECURE_NO_WARNINGS", "OPTICK_LIB=1" }
	if _ACTION == "2022" then
		systemversion "latest"
	end

 	kind "SharedLib"
 	defines { "OPTICK_EXPORTS" }

	targetdir("$(SolutionDir)" .. outputdir .. "/bin//%{prj.name}")
	objdir("$(SolutionDir)" .. outputdir .. "/bin-int/%{prj.name}")

	includedirs
	{
		"src"
	}
	
	if isDX12 then
		links { 
			"d3d12", 
			"dxgi",
		}
	else
		defines { "OPTICK_ENABLE_GPU_D3D12=0" }
	end
	
	if isVulkan then
		includedirs
		{
			"$(VULKAN_SDK)/Include",
		}
		libdirs {
			"$(VULKAN_SDK)/Lib",
		}
		links { 
			"vulkan-1",
		}
	else
		defines { "OPTICK_ENABLE_GPU_VULKAN=0" }
	end
	
	files {
		"src/**.cpp",
        "src/**.h", 
	}
	vpaths {
		["api"] = { 
			"src/optick.h",
			"src/optick.config.h",
		},
	}

	postbuildcommands { 
		"{MKDIR}  $(SolutionDir)" .. outputdir .. "/bin/MCGame",  
		"{COPY} %{cfg.buildtarget.relpath} $(SolutionDir)" .. outputdir .. "/bin/MCGame"
	}