-- obtains the code name, including french quotes
local function code_name(block)
    if block.attributes["file"] ~= nil then
        return "file:" .. block.attributes["file"]
    end
    if block.identifier == nil or block.identifier == "" then
        return nil
    else
        return "«" .. block.identifier .. "»"
    end
end

-- get code-id for cross-referencing
local function code_id(block)
    if block.attributes["file"] ~= nil then
        return block.attributes["file"]
    end
    if block.identifier == nil or block.identifier == "" then
        return nil
    else
        return block.identifier
    end
end

-- split a string
function string:split(delimiter)
    local result = {}
    local from  = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from , delim_from-1))
        from  = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    table.insert(result, string.sub(self, from))
    return result
end

-- join a table into a string
function string:join(t)
    local result = nil
    for _, l in ipairs(t) do
        if result == nil then
            result = l
        else
            result = result .. self .. l
        end
    end
    return result
end

-- Filter code blocks
--
-- Does two things: annotate the code block with a title, and
-- find NoWEB references inside the code, turing them into
-- hyperlinks.
function CodeBlock(elem)
    local name = code_name(elem)
    local cid = code_id(elem)
    local blocks = {}
    local code_lines = {}

    local lines = elem.text:split('\n')
    for _, l in ipairs(lines) do
        local link = string.match(l, "^%s*<<([^%s<>]+)>>$")
        if link == nil then
            table.insert(code_lines, l)
        else
            if code_lines ~= {} then
                local text = ("\n"):join(code_lines)
                table.insert(blocks, pandoc.CodeBlock(text, {class = elem.classes[1]}))
                code_lines = {}
            end
            table.insert(blocks, pandoc.Div({ pandoc.Link(l, "#" .. link) }, { class="noweb-reference" }))
        end
    end
    if code_lines ~= {} then
        local text = ("\n"):join(code_lines)
        table.insert(blocks, pandoc.CodeBlock(text, {class = elem.classes[1]}))
        code_lines = {}
    end
    if name ~= nil then
        return pandoc.Div({ pandoc.Div({ pandoc.Str(name) }, {class = "code-block-title"})
                          , pandoc.Div(blocks, { class="code-block-content" })
                          }, { class="named-code-block", id=cid })
    end
end
