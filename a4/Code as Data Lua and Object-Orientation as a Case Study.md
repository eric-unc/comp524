# Code as Data: Lua and Object-Orientation as a Case Study
#### Eric Schneider
Lua is a scripting language of considerable popularity, mainly used an embedded language to extend software. Lua is intentionally designed to be lightweight and simple. Lua feels like and looks like a normal imperative language, yet something about it seems rather pure. Part of this (???) can be justified in Lua's approach to object-orientation. Lua does not have a `class` keyword, nor a `struct` keyword, nor something equivalent; rather than treating object-orientation as some kind of magical construct in the language, a kind of object-orientation is achieved through existing constructs, which reflects a _code as data_ paradigm.

## A Primer: Tables and First-Class Functions
Before explaining the details of object-orientation in Lua, a few constructs in Lua should be explained. The first is Lua's _table_. A table is a built-in data structure, similar to a hash table (also known as a hash map), but with some surprises. Below is an example declaration of such a table:

```lua
-- Declaration of a table
ratings = {
  alsBurerShack = 5,
  mcDonalds = 2,
  ["Sup dogs"] = 3
}

-- Modification after declaration
ratings["Kipos"] = 3

-- Iterating through the table
for restaurant, rating in pairs(ratings) do
  print(restaurant .. ": " .. rating)
end

--[[
  The above will print out the following:

  Sup dogs: 3
  alsBurerShack: 5
  Kipos: 3
  mcDonalds: 2
]]
```

## References
1. Ierusalimschy, R. (2003). Programming in Lua (1st ed.). Lua.org. Retrieved February 18, 2021, from https://www.lua.org/pil/contents.html
