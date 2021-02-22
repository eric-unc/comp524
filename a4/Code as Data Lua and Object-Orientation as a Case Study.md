# Code as Data: Lua and Object-Orientation as a Case Study
#### Eric Schneider
Lua is a scripting language of considerable popularity, mainly used an embedded language to extend software. Lua feels like and looks like a normal imperative language, yet something about it seems rather pure. Lua is intentionally designed to be lightweight, simple, and consistent.

The creators of Lua describe Lua's design as "mechanisms instead of policies" (Ierusalimschy el al., 2018). This can be demonstrated in Lua's approach to object-orientation. Lua does not have a `class` keyword, nor a `struct` keyword, nor something equivalent; rather than treating object-orientation as some kind of magical construct in the language, a kind of object-orientation is achieved through existing constructs, which reflects a _code as data_ paradigm.

## Primer 1: Tables in Lua
Before explaining the details of object-orientation in Lua, a few constructs in Lua should be explained. The first is Lua's _table_. A table is a built-in data structure, essentially a hash table (also known as a hash map), but with some surprises. Below is an example declaration of such a table:

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

Tables consist of pairs of _keys_ which map to _values_. A key can have any type, including strings, integers, and even more discrete structures. Because Lua uses hashing, each attempted access of a value has a time complexity of `O(1)`. If no value is found, then the access will return `nil`.

Interestingly enough, the table is Lua's _only_ built-in data structure. Arrays must be implemented as tables:
```lua
array = {-5, 8, 20}

-- The above is equivalent to:
--[[
array = {
  [1] = -5,
  [2] = 8,
  [3] = 20
}
]]

-- Iterating and printing through the elements of the array.
for i = 1, #array do
  print(array[i])
end
```

When unspecified, array indexes start at `1` in Lua. However, _what designates the start of an array is entirely arbitrary_. In the above example, `1` is actually just a key which maps to `-5`. If we wanted, we could use `0` as an "index", or we could use negative indices, or indices above the length of the array (like `5`). Or, because our "array" is really just a table, we could use strings as indices. But, then our object could no longer functionally be described as an array. Later in this paper, we will find Lua's idea of object-orientation functions much the same way.

## Primer 2: First-Class Functions in Lua
Functions can be declared plainly in Lua as follows:

```lua
function add(a, b)
  return a + b
end

print(add(5, 3)) -- Prints 8
```

However, they can also be declared in another way:
```lua
minus = function(a, b)
  return a - b
end

print(minus(5, 3)) -- Prints 2
```

Above, `minus` can be described as a function. However, the reality is more complicated: `minus` is simply another variable, with its value set to an _anonymous function_. The function has no identifier by itself; it is merely another kind of value. Functions in Lua are _first-class_; that is, a function is treated as just another type, like an integer, or a string.

This idea of a function being simply another type is not particularly unique. JavaScript acts similarly; in fact, aside from using curly braces, the syntax is almost exactly the same. First-class functions stem from the idea of _code as data_. Code should be treated as data; a sequence of statements should be treated the same as a sequence of numbers.

## References
1. Ierusalimschy, R. (2003). Programming in Lua (1st ed.). Lua.org. Retrieved February 18, 2021, from https://www.lua.org/pil/contents.html
2. Ierusalimschy, R., De Figueiredo, L. H., & Celes, W. (2018). A look at the design of Lua. Communications of the ACM, 61(11), 114-123. doi:10.1145/3186277, from https://cacm.acm.org/magazines/2018/11/232214-a-look-at-the-design-of-lua/fulltext
