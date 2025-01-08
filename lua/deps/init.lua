---@class deps.Dep
---@field name string
---@field is_installed fun(): boolean
---@field install fun(notify: deps.Notify)
---@field update fun(notify: deps.Notify) | nil
---@field uninstall fun(notify: deps.Notify)

---@class deps.Notify
---@field start fun()
---@field finish fun()
---@field fail fun(err: string)

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
	local notify = M._get_notify(dep.name, "update")
	xpcall(function()
		if dep.update then
			dep.update(notify)
		else
			dep.install(notify)
		end
	end, function(err)
		notify.fail(err)
	end)
end

---@param dep deps.Dep
function M._install_dep(dep)
	local notify = M._get_notify(dep.name, "install")
	xpcall(function()
		dep.install(notify)
	end, function(err)
		notify.fail(err)
	end)
end

---@param dep deps.Dep
function M._uninstall_dep(dep)
	local notify = M._get_notify(dep.name, "uninstall")
	xpcall(function()
		dep.uninstall(notify)
	end, function(err)
		notify.fail(err)
	end)
end

---@return deps.Notify
M._get_notify = function(dep_name, method)
	return {
		start = function()
			print(string.format([[[deps.nvim] start %s for "%s"]], method, dep_name))
		end,
		finish = function()
			print(string.format([[[deps.nvim] finish %s for "%s"]], method, dep_name))
		end,
		fail = function(err)
			print(string.format([[[deps.nvim] %s for "%s" failed: %s]], method, dep_name, err))
		end,
	}
end

return M
