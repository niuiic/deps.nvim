---@class deps.Dep
---@field name string
---@field is_installed fun(): boolean
---@field install fun()
---@field update fun() | nil
---@field uninstall fun()

local M = {
	_deps = {},
}

---@param dep deps.Dep
function M.add_dep(dep)
	M._deps[dep.name] = dep
end

function M.install_deps()
	for _, dep in pairs(M._deps) do
		if not dep.is_installed() then
			M._install_dep(dep)
		end
	end
end

function M.update_deps()
	for _, dep in pairs(M._deps) do
		if dep.is_installed() then
			M._update_dep(dep)
		else
			M._install_dep(dep)
		end
	end
end

function M.uninstall_deps()
	for _, dep in pairs(M._deps) do
		if dep.is_installed() then
			M._uninstall_dep(dep)
		end
	end
end

---@param dep deps.Dep
function M._update_dep(dep)
	print(string.format([[[deps.nvim] do update for "%s"]], dep.name))
	xpcall(dep.update or dep.install, function(err)
		print(string.format([[[deps.nvim] update for "%s" failed: %s]], dep.name, err))
	end)
end

---@param dep deps.Dep
function M._install_dep(dep)
	print(string.format([[[deps.nvim] do install for "%s"]], dep.name))
	xpcall(dep.install, function(err)
		print(string.format([[[deps.nvim] install for "%s" failed: %s]], dep.name, err))
	end)
end

return M
