---@class Model
---@field requests Request[]
---@field notifications Notification[]
---@field enumerations Enumeration
---@field typeAliases TypeAlias[]
---@field structures Structure[]

---@alias BaseTypes "URI" | "DocumentUri" | "integer" | "uinteger" | "decimal" | "RegExp" | "string" | "boolean" | "null"

---@class BooleanLiteralType
---@field kind "boolean"
---@field value boolean

---@class EnumerationEntry
---@field documentation? string An optional documentation.
---@field name string The name of the enum item.
---@field proposed? boolean Whether this is a proposed enumeration entry. If omitted, the enumeration entry is final.
---@field since? string Since when (release number) this enumeration entry is available. Is undefined if not known.
---@field value string | float The value.

---@alias Name "string" | "integer" | "uinteger"

---@class EnumerationType
---@field kind "enumeration"
---@field name Name

---@class IntegerLiteralType
---@field kind "integer" Represents an integer literal type (e.g. `kind: 1`).
---@field value float

---@alias Name1 "URI" | "DocumentUri" | "string" | "integer"

---@class MapKeyTypeItem
---@field kind TypeKind
---@field name Name1

---@alias MessageDirection "clientToServer" | "serverToClient" | "both"

---@class MetaData
---@field version string The protocol version.

---@class ReferenceType
---@field kind "reference"
---@field name string

---@class StringLiteralType
---@field kind "stringLiteral"
---@field value string

---@alias TypeKind "base" | "reference" | "array" | "map" | "and" | "or" | "tuple" | "literal" | "stringLiteral" | "integerLiteral" | "booleanLiteral"

---@class BaseType
---@field kind "base"
---@field name BaseTypes

---@class Enumeration
---@field documentation? string An optional documentation.
---@field name string The name of the enumeration.
---@field proposed? boolean Whether this is a proposed enumeration. If omitted, the enumeration is final.
---@field since? string Since when (release number) this enumeration is available. Is undefined if not known.
---@field supportsCustomValues? boolean Whether the enumeration supports custom values (e.g. values which are not part of the set defined in `values`). If omitted no custom values are supported.
---@field type EnumerationType The type of the elements.
---@field values EnumerationEntry[] The enum values.

---- Represents a type that can be used as a key in a map type. If a reference type is used then the type must either resolve to a `string` or `integer` type. (e.g. `type ChangeAnnotationIdentifier === string`).
---@alias MapKeyType MapKeyTypeItem | ReferenceType

---@class AndType
---@field items Type[]
---@field kind "and"

---@class ArrayType
---@field element Type
---@field kind "array"

---@class MapType
---@field key MapKeyType
---@field kind "map"
---@field value Type

---@class MetaModel
---@field enumerations Enumeration[] The enumerations.
---@field metaData MetaData Additional meta data.
---@field notifications Notification[] The notifications.
---@field requests Request[] The requests.
---@field structures Structure[] The structures.
---@field typeAliases TypeAlias[] The type aliases.

---@class Notification
---@field documentation? string An optional documentation;
---@field messageDirection MessageDirection The direction in which this notification is sent in the protocol.
---@field method string The request's method name.
---@field params? Type | Type[] The parameter type(s) if any.
---@field proposed? boolean Whether this is a proposed notification. If omitted the notification is final.
---@field registrationMethod? string Optional a dynamic registration method if it different from the request's method.
---@field registrationOptions? Type Optional registration options if the notification supports dynamic registration.
---@field since? string Since when (release number) this notification is available. Is undefined if not known.

---@class OrType
---@field items Type[]
---@field kind "or"

---@class Property
---@field documentation? string An optional documentation.
---@field name string The property name;
---@field optional? boolean Whether the property is optional. If omitted, the property is mandatory.
---@field proposed? boolean Whether this is a proposed property. If omitted, the structure is final.
---@field since? string Since when (release number) this property is available. Is undefined if not known.
---@field type Type The type of the property

---@class Request
---@field documentation? string An optional documentation;
---@field errorData? Type An optional error data type.
---@field messageDirection MessageDirection The direction in which this request is sent in the protocol.
---@field method string The request's method name.
---@field params? Type | Type[] The parameter type(s) if any.
---@field partialResult? Type Optional partial result type if the request supports partial result reporting.
---@field proposed? boolean Whether this is a proposed feature. If omitted the feature is final.
---@field registrationMethod? string Optional a dynamic registration method if it different from the request's method.
---@field registrationOptions? Type Optional registration options if the request supports dynamic registration.
---@field result Type The result type.
---@field since? string Since when (release number) this request is available. Is undefined if not known.

---@class Structure
---@field documentation? string An optional documentation;
---@field extends? Type[] Structures extended from. This structures form a polymorphic type hierarchy.
---@field mixins? Type[] Structures to mix in. The properties of these structures are `copied` into this structure. Mixins don't form a polymorphic type hierarchy in LSP.
---@field name string The name of the structure.
---@field properties Property[] The properties.
---@field proposed? boolean Whether this is a proposed structure. If omitted, the structure is final.
---@field since? string Since when (release number) this structure is available. Is undefined if not known.

---@class StructureLiteral
---@field documentation? string An optional documentation.
---@field properties Property[] The properties.
---@field proposed? boolean Whether this is a proposed structure. If omitted, the structure is final.
---@field since? string Since when (release number) this structure is available. Is undefined if not known.

---@class StructureLiteralType
---@field kind "literal"
---@field value StructureLiteral

---@class TupleType
---@field items Type[]
---@field kind "tuple"

---@alias Type  BaseType | ReferenceType | ArrayType | MapType | AndType | OrType | TupleType | StructureLiteralType | StringLiteralType | IntegerLiteralType | BooleanLiteralType

---@class TypeAlias
---@field documentation? string An optional documentation.
---@field name string The name of the type alias.
---@field proposed? boolean Whether this is a proposed type alias. If omitted, the type alias is final.
---@field since? string Since when (release number) this structure is available. Is undefined if not known.
---@field type Type The aliased type.

---@class Generator
---@field known_objs table<string, Structure | TypeAlias>
---@field known_literals table<StructureLiteral, Structure>
---@field model Model
local Generator = {}
Generator.__index = Generator

function Generator.new(model)
  local self = setmetatable({}, Generator)
  self.model = model
  self.known_objs = {}
  self.known_literals = {}
  return self
end

---@param obj Structure | TypeAlias | StructureLiteral
---@return Structure | TypeAlias
function Generator:register(obj)
  if not obj.name then
    if not self.known_literals[obj] then
      self.known_literals[obj] = {
        name = ("Structure%s"):format(#vim.tbl_keys(self.known_literals)),
        documentation = obj.documentation,
        properties = obj.properties,
        proposed = obj.proposed,
        since = obj.since,
        extends = {},
        mixins = {},
      }
    end
    obj = self.known_literals[obj]
  end
  print(("Registering %s"):format(obj.name))
  if not self.known_objs[obj.name] then
    self.known_objs[obj.name] = obj
  end
  return obj
end

---@param name string
---@return string
function Generator:convert_method_name(name)
  local new_name = name:gsub("/", "_"):gsub("%$", "_")
  return new_name
end

---@return string
function Generator:type_prefix()
  return "dapui.async.lsp.types"
end

---@param orig_name string
---@return string
function Generator:structure_name(orig_name)
  return self:type_prefix() .. "." .. orig_name
end

---@param items ReferenceType[]
---@return Structure
function Generator:and_type(items)
  local names = vim.tbl_map(function(item)
    return item.name
  end, items)
  local sub_structure = {
    name = table.concat(names, "And"),
    documentation = "",
    extends = items,
    properties = {},
    mixins = {},
    proposed = nil,
    since = nil,
  }
  return sub_structure
end

---@param name Name | Name1
---@return string
function Generator:key_name_type(name)
  if name == "URI" then
    return self:type_prefix() .. ".URI"
  elseif name == "DocumentUri" then
    return self:type_prefix() .. ".DocumentUri"
  else
    return name
  end
end

---@param type_ Type | MapKeyType)
---@return string
function Generator:type_name(type_)
  if type_.kind == "base" then
    local name = type_.name
    if name == "integer" or name == "uinteger" then
      return "integer"
    elseif name == "decimal" then
      return "number"
    elseif name == "string" then
      return "string"
    elseif name == "boolean" then
      return "boolean"
    elseif name == "null" then
      return "nil"
    else
      return self:key_name_type(name)
    end
  elseif type_.kind == "reference" then
    local name = type_.name
    return self:structure_name(name)
  elseif type_.kind == "array" then
    local element = type_.element
    return self:type_name(element) .. "[]"
  elseif type_.kind == "map" then
    local key, value = type_.key, type_.value
    if key.kind == "reference" then
      return ("table<%s, %s>"):format(self:type_name(key), self:type_name(value))
    else
      local name = key.name
      return ("table<%s, %s>"):format(self:key_name_type(name), self:type_name(value))
    end
  elseif type_.kind == "and" then
    local items = type_.items
    local refs = {}
    for _, item in ipairs(items) do
      if item.kind == "reference" then
        refs[#refs + 1] = item
      end
    end
    if #items > #refs then
      print(("Discarding non-reference/literal types from AndType"):format())
    end
    local struc = self:and_type(refs)
    self:register(struc)
    return self:structure_name(struc.name)
  elseif type_.kind == "or" then
    local items = type_.items
    local names = vim.tbl_map(function(item)
      return self:type_name(item)
    end, items)

    return table.concat(names, "|")
  elseif type_.kind == "tuple" then
    local items = type_.items
    local names = vim.tbl_map(function(item)
      return self:type_name(item)
    end, items)

    return table.concat(names, ",")
  elseif type_.kind == "literal" then
    local value = type_.value
    local struc = self:register(value)
    return self:structure_name(struc.name)
  elseif type_.kind == "stringLiteral" then
    local value = type_.value
    return ("'%s'"):format(value)
  end
  error("Unknown type " .. type_.kind)
end

---@param doc string
---@param multiline boolean
---@return string[]
function Generator:prepare_doc(doc, multiline)
  local lines = vim.split(doc, "\n", { trimempty = false, plain = true })
  if multiline then
    return vim.tbl_map(function(line)
      return #line and ("--- %s"):format(line) or "---"
    end, lines)
  end
  return { table.concat(lines, " ") }
end

---@param structure Structure
---@return string[]
function Generator:structure(structure)
  local lines = { "" }
  if structure.documentation then
    vim.list_extend(lines, self:prepare_doc(structure.documentation, true))
  end

  lines[#lines + 1] = ("---@class %s"):format(self:structure_name(structure.name))
  if structure.extends or structure.mixins then
    local extends = vim.list_extend(vim.deepcopy(structure.extends or {}), structure.mixins or {})
    local names = vim.tbl_map(function(type_)
      return self:type_name(type_)
    end, extends)
    if #names > 0 then
      lines[#lines] = lines[#lines] .. " : " .. table.concat(names, ",")
    end
  end
  for _, prop in ipairs(structure.properties) do
    local line = ("---@field %s%s %s"):format(
      prop.name,
      prop.optional and "?" or "",
      self:type_name(prop.type)
    )
    if prop.documentation then
      line = line .. " " .. self:prepare_doc(prop.documentation, false)[1]
    end
    lines[#lines + 1] = line
  end
  return lines
end

---@param type_alias TypeAlias
---@return string[]
function Generator:type_alias(type_alias)
  self:register(type_alias)
  return {
    ("---@alias %s.%s %s"):format(
      self:type_prefix(),
      type_alias.name,
      self:type_name(type_alias.type)
    ),
  }
end

---@param request Request
---@return string[]
function Generator:request(request)
  local lines = {}
  if request.documentation then
    vim.list_extend(lines, self:prepare_doc(request.documentation, true))
  end

  lines[#lines + 1] = "---@async"
  lines[#lines + 1] = "---@param bufnr integer Buffer number (0 for current buffer)"
  if request.params then
    lines[#lines + 1] = ("---@param args %s"):format(self:type_name(request.params))
  end
  lines[#lines + 1] = "---@param opts? dapui.async.lsp.RequestOpts Options for the request handling"
  if request.result then
    lines[#lines + 1] = (("---@return %s"):format(self:type_name(request.result)))
  end

  lines[#lines + 1] = (
    ("function LSPRequestClient.%s(bufnr%s, opts) end"):format(
      self:convert_method_name(request.method),
      request.params and ", args" or ""
    )
    )
  lines[#lines + 1] = ""
  return lines
end

---@param notification Notification
---@return string[]
function Generator:notification(notification)
  local lines = {}
  if notification.documentation then
    vim.list_extend(lines, self:prepare_doc(notification.documentation, true))
  end

  lines[#lines + 1] = "---@async"
  if notification.params then
    lines[#lines + 1] = (("---@param args %s"):format(self:type_name(notification.params)))
    lines[#lines + 1] = (
      ("function LSPNotifyClient.%s(%s) end"):format(
        self:convert_method_name(notification.method),
        notification.params and "args" or ""
      )
      )
    lines[#lines + 1] = ""
  end
  return lines
end

---@param enum Enumeration
---@return string[]
function Generator:enumeration(enum)
  local lines = {}
  if enum.documentation then
    vim.list_extend(lines, self:prepare_doc(enum.documentation, true))
  end
  lines[#lines + 1] = (
    ("---@alias %s.%s %s"):format(
      self:type_prefix(),
      enum.name,
      table.concat(
        vim.tbl_map(function(val)
          return vim.json.encode(val.value)
        end, enum.values),
        "|"
      )
    )
    )
  lines[#lines + 1] = ""
  return lines
end

function Generator:generate()
  local lines = {
    ("---Generated on %s"):format(os.date("!%Y-%m-%d-%H:%M:%S GMT")),
    "",
    "---@class dapui.async.lsp.RequestClient",
    "local LSPRequestClient = {}",
    "---@class dapui.async.lsp.RequestOpts",
    "---@field timeout integer Timeout of request in milliseconds",
    "",
  }
  local strucs = {}
  vim.list_extend(strucs, self.model.structures)
  vim.list_extend(strucs, self.model.typeAliases)
  vim.list_extend(strucs, self.model.enumerations)
  for _, obj in ipairs(strucs) do
    self:register(obj)
  end
  print("Generating requests")
  for _, request in ipairs(self.model.requests) do
    if request.messageDirection == "clientToServer" or request.messageDirection == "both" then
      vim.list_extend(lines, self:request(request))
    end
  end
  vim.list_extend(lines, {
    "---@class dapui.async.lsp.NotifyClient",
    "local LSPNotifyClient = {}",
    "",
  })
  print("Generating notifications")
  for _, notification in ipairs(self.model.notifications) do
    if notification.messageDirection == "clientToServer" or notification.messageDirection == "both"
    then
      vim.list_extend(lines, self:notification(notification))
    end
  end
  vim.list_extend(lines, {
    ("---@alias %s string"):format(self:key_name_type("URI")),
    ("---@alias %s string"):format(self:key_name_type("DocumentUri")),
  })

  local length = function()
    return #vim.tbl_keys(self.known_objs)
  end
  local last_length = 0

  print("Discovering types")
  while length() > last_length do
    for _, obj in pairs(self.known_objs) do
      if obj.properties then
        self:structure(obj)
      elseif obj.values then
        self:enumeration(obj)
      else
        self:type_alias(obj)
      end
    end
    last_length = length()
  end

  print("Generating structures")
  for _, obj in pairs(self.known_objs) do
    if obj.properties then
      vim.list_extend(lines, self:structure(obj))
    elseif obj.values then
      vim.list_extend(lines, self:enumeration(obj))
    else
      vim.list_extend(lines, self:type_alias(obj))
    end
  end
  print(("Generated %d lines\n"):format(#lines))
  return lines
end

local file = assert(io.open("lsp.json"))
local model = vim.json.decode(file:read("*a"))
file:close()
local lines = Generator.new(model):generate()

local out = assert(io.open("lua/dapui/async/lsp-types.lua", "w"))
out:write(table.concat(lines, "\n"))
out:close()
vim.cmd("exit")
