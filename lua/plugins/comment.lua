return {
	"numToStr/Comment.nvim",
	lazy = true,
	config = function()
		require("Comment").setup({
			mappings = {
				basic = false,
				extra = false,
			},
		})
	end,
}
