-- Converts a Quarto style header in a code block into Pandoc attributes.
--
--     ```python
--     #| id: code-block-id
--     #| file: src/filename.py
--     #| classes: [hidden]
--     ...
--     ```
--
-- The comment prefix (`#|`, `//|`, `--|`, ...) is taken from the first line
-- and the header extends as long as lines start with that same prefix. The
-- header is parsed as YAML: `id` sets the identifier, `classes` adds to the
-- classes and every other key becomes an attribute.

-- parse YAML text, returning a Pandoc Meta table
local function parse_yaml(text)
    local doc = pandoc.read("---\n" .. text .. "\n---\n", "markdown-smart")
    return doc.meta
end

-- turn a meta value into a list of strings
local function string_list(value)
    local result = {}
    if pandoc.utils.type(value) == "List" then
        for _, v in ipairs(value) do
            table.insert(result, pandoc.utils.stringify(v))
        end
    else
        for c in pandoc.utils.stringify(value):gmatch("%S+") do
            table.insert(result, c)
        end
    end
    return result
end

function CodeBlock(elem)
    local prefix = elem.text:match("^([^%w%s|]+)|")
    if prefix == nil then
        return nil
    end

    local header = {}
    local body = {}
    local in_header = true
    for line in (elem.text .. "\n"):gmatch("([^\n]*)\n") do
        if in_header and line:sub(1, #prefix + 1) == prefix .. "|" then
            table.insert(header, (line:sub(#prefix + 2):gsub("^ ", "", 1)))
        else
            in_header = false
            table.insert(body, line)
        end
    end

    local meta = parse_yaml(table.concat(header, "\n"))
    for key, value in pairs(meta) do
        if key == "id" then
            elem.identifier = pandoc.utils.stringify(value)
        elseif key == "classes" then
            elem.classes:extend(string_list(value))
        else
            elem.attributes[key] = pandoc.utils.stringify(value)
        end
    end

    elem.text = table.concat(body, "\n")
    return elem
end
