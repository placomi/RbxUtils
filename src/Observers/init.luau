--!strict

-- this be sleitnicks observers
-- i decided that it would be nicer to just have this in my utils rather than importing using wally
-- also i added a observer class

-- TODO: fix the issue with ancestry
-- NOTE: this is likely because of deferred signals, combined with
-- custom destruction of character. Destroy is called.

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
	observePlayerCharacter = require("@self/observePlayerCharacter"),
}
