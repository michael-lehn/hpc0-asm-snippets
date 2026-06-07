local function asm_define_function()
	local name = vim.fn.input("Function name: ")
	if name == "" then
		return
	end
	local lines = {
		name .. ":",
		"\tsubq 8, %SP, %SP",
		"\tmovq %2, (%SP)",
		"\t// begin of function body",
		"",
		"\t// end of function body",
		"." .. name .. ".leave:",
		"\tmovq (%SP), %2",
		"\taddq 8, %SP, %SP",
		"\tret %2",
	}
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, lines)
	vim.api.nvim_win_set_cursor(0, { row + 4, 4 })
end

local function asm_call_function()
	local name = vim.fn.input("Function name: ")
	if name == "" then
		return
	end
	local n = tonumber(vim.fn.input("Number of arguments: "))
	if n == nil or n < 0 or math.floor(n) ~= n then
		print("Expected a non-negative integer")
		return
	end
	local lines = {}
	table.insert(lines, string.format("\tsubq (%d + 1)*8, %%SP, %%SP", n))
	for i = 1, n do
		table.insert(lines, string.format("\t// TODO: insert code to copy argument %d into %%2", i))
		table.insert(lines, string.format("\tmovq %%2, 8*%d(%%SP)", i))
	end
	table.insert(lines, string.format("\tcall %s, %%2", name))
	table.insert(lines, "\tmovq (%SP), %3   // return value now in %3")
	table.insert(lines, string.format("\taddq (%d + 1)*8, %%SP, %%SP", n))
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, lines)
	if n > 0 then
		vim.api.nvim_win_set_cursor(0, { row + 1, 4 })
	else
		vim.api.nvim_win_set_cursor(0, { row + 2, 4 })
	end
end

local function check_while_id(id)
	for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
		if line:match("^%.while" .. id .. ":") then
			return -1
		end
	end
	return id
end

local function next_while_id()
	local id = 0
	while check_while_id(id) == -1 do
		id = id + 1
	end
	return id
end

local function asm_while_loop()
	local id = next_while_id()
	local lines = {
		string.format(".while%d:", id),
		string.format("\t# insert here code for condition: If condition is false jump to .done.while%d", id),
		"",
		"\t# insert here code for loop-body",
		string.format("\tjmp .while%d", id),
		string.format(".done.while%d:", id),
	}
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, lines)
	vim.api.nvim_win_set_cursor(0, { row + 1, 8 })
end

vim.keymap.set("n", "<leader>a", "", { desc = "HPC0 Assembly" })
vim.keymap.set("n", "<leader>af", asm_define_function, { desc = "Define function" })
vim.keymap.set("n", "<leader>ac", asm_call_function, { desc = "Call function" })
vim.keymap.set("n", "<leader>aw", asm_while_loop, { desc = "While loop" })
