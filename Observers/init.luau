--!strict

-- this be sleitnicks observers
-- i decided that it would be nicer to just have this in my utils rather than importing using wally
-- also i added a observer class

--[=[
	@class Observers

	A collection of observer utility functions.
]=]
return {
	observeTag = require("@self/observeTag"),
	observeAttribute = require("@self/observeAttribute"),
	observeProperty = require("@self/observeProperty"),
	observePlayer = require("@self/observePlayer"),
	observeCharacter = require("@self/observeCharacter"),
	observeLocalCharacter = require("@self/observeLocalCharacter"),
}
