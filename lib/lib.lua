function Scandir(directory)
	local i, t, popen = 0, {}, io.popen
	local pfile = popen('find -maxdepth 1 -print0 "' .. directory .. '"')
	for filename in pfile:lines() do
		i = i + 1
		t[i] = filename
	end
	pfile:close()
	return t
end
function Iswindows()
	return string.find(Wezterm.target_triple, "windows") ~= nil
end
Windows = Iswindows()
