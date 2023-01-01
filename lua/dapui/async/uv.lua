local tasks = require("dapui.async.tasks")

local dapui = { async = {} }

---@text
--- Provides asynchronous versions of vim.loop functions.
--- See corresponding function documentation for parameter and return
--- information.
---
---@class dapui.async.uv
---@field close async fun(handle: dapui.async.uv.Handle)
---@field fs_open async fun(path: any, flags: any, mode: any): (string|nil,integer|nil)
---@field fs_read async fun(fd: integer, size: integer, offset?: integer): (string|nil,string|nil)
---@field fs_close async fun(fd: integer): (string|nil,boolean|nil)
---@field fs_unlink async fun(path: string): (string|nil,boolean|nil)
---@field fs_write async fun(fd: any, data: any, offset?: any): (string|nil,integer|nil)
---@field fs_mkdir async fun(path: string, mode: integer): (string|nil,boolean|nil)
---@field fs_mkdtemp async fun(template: string): (string|nil,string|nil)
---@field fs_rmdir async fun(path: string): (string|nil,boolean|nil)
---@field fs_stat async fun(path: string): (string|nil,dapui.async.uv.Stat|nil)
---@field fs_fstat async fun(fd: integer): (string|nil,dapui.async.uv.Stat|nil)
---@field fs_lstat async fun(path: string): (string|nil,dapui.async.uv.Stat|nil)
---@field fs_statfs async fun(path: string): (string|nil,dapui.async.uv.StatFs|nil)
---@field fs_rename async fun(old_path: string, new_path: string): (string|nil,boolean|nil)
---@field fs_fsync async fun(fd: integer): (string|nil,boolean|nil)
---@field fs_fdatasync async fun(fd: integer): (string|nil,boolean|nil)
---@field fs_ftruncate async fun(fd: integer, offset: integer): (string|nil,boolean|nil)
---@field fs_sendfile async fun(out_fd: integer, in_fd: integer, in_offset: integer, length: integer): (string|nil,integer|nil)
---@field fs_access async fun(path: string, mode: integer): (string|nil,boolean|nil)
---@field fs_chmod async fun(path: string, mode: integer): (string|nil,boolean|nil)
---@field fs_fchmod async fun(fd: integer, mode: integer): (string|nil,boolean|nil)
---@field fs_utime async fun(path: string, atime: number, mtime: number): (string|nil,boolean|nil)
---@field fs_futime async fun(fd: integer, atime: number, mtime: number): (string|nil,boolean|nil)
---@field fs_link async fun(path: string, new_path: string): (string|nil,boolean|nil)
---@field fs_symlink async fun(path: string, new_path: string, flags?: integer): (string|nil,boolean|nil)
---@field fs_readlink async fun(path: string): (string|nil,string|nil)
---@field fs_realpath async fun(path: string): (string|nil,string|nil)
---@field fs_chown async fun(path: string, uid: integer, gid: integer): (string|nil,boolean|nil)
---@field fs_fchown async fun(fd: integer, uid: integer, gid: integer): (string|nil,boolean|nil)
---@field fs_lchown async fun(path: string, uid: integer, gid: integer): (string|nil,boolean|nil)
---@field fs_copyfile async fun(path: any, new_path: any, flags?: any): (string|nil,boolean|nil)
---@field fs_opendir async fun(path: string, entries?: integer): (string|nil,dapui.async.uv.Dir|nil)
---@field fs_readdir async fun(dir: dapui.async.uv.Dir): (string|nil,dapui.async.uv.DirEntry[]|nil)
---@field fs_closedir async fun(dir: dapui.async.uv.Dir): (string|nil,boolean|nil)
---@field fs_scandir async fun(path: string): (string|nil,dapui.async.uv.DirEntry[]|nil)
---@field shutdown async fun(stream: dapui.async.uv.Stream): string|nil
---@field listen async fun(stream: dapui.async.uv.Stream, backlog: integer): string|nil
---@field write async fun(stream: dapui.async.uv.Stream, data: string|string[]): string|nil
---@field write2 async fun(stream: dapui.async.uv.Stream, data: string|string[], send_handle: dapui.async.uv.Stream): string|nil
dapui.async.uv = {}

---@class dapui.async.uv.Handle

---@class dapui.async.uv.Stream : dapui.async.uv.Handle

---@class dapui.async.uv.Stat
---@field dev integer
---@field mode integer
---@field nlink integer
---@field uid integer
---@field gid integer
---@field rdev integer
---@field ino integer
---@field size integer
---@field blksize integer
---@field blocks integer
---@field flags integer
---@field gen integer
---@field atime dapui.async.uv.StatTime
---@field mtime dapui.async.uv.StatTime
---@field ctime dapui.async.uv.StatTime
---@field birthtime dapui.async.uv.StatTime
---@field type string

---@class dapui.async.uv.StatTime
---@field sec integer
---@field nsec integer

---@class dapui.async.uv.StatFs
---@field type integer
---@field bsize integer
---@field blocks integer
---@field bfree integer
---@field bavail integer
---@field files integer
---@field ffree integer

---@class dapui.async.uv.Dir

---@class dapui.async.uv.DirEntry

---@nodoc
local function add(name, argc)
  local success, ret = pcall(tasks.wrap, vim.loop[name], argc)

  if not success then
    error("Failed to add function with name " .. name)
  end

  dapui.async.uv[name] = ret
end

add("close", 4) -- close a handle
-- filesystem operations
add("fs_open", 4)
add("fs_read", 4)
add("fs_close", 2)
add("fs_unlink", 2)
add("fs_write", 4)
add("fs_mkdir", 3)
add("fs_mkdtemp", 2)
-- 'fs_mkstemp',
add("fs_rmdir", 2)
add("fs_scandir", 2)
add("fs_stat", 2)
add("fs_fstat", 2)
add("fs_lstat", 2)
add("fs_rename", 3)
add("fs_fsync", 2)
add("fs_fdatasync", 2)
add("fs_ftruncate", 3)
add("fs_sendfile", 5)
add("fs_access", 3)
add("fs_chmod", 3)
add("fs_fchmod", 3)
add("fs_utime", 4)
add("fs_futime", 4)
-- 'fs_lutime',
add("fs_link", 3)
add("fs_symlink", 4)
add("fs_readlink", 2)
add("fs_realpath", 2)
add("fs_chown", 4)
add("fs_fchown", 4)
-- 'fs_lchown',
add("fs_copyfile", 4)
dapui.async.uv.fs_opendir = tasks.wrap(function(path, entries, cb)
  vim.loop.fs_opendir(path, cb, entries)
end, 3)
add("fs_readdir", 2)
add("fs_closedir", 2)
add("fs_statfs", 2)
-- stream
add("shutdown", 2)
add("listen", 3)
-- add('read_start', 2) -- do not do this one, the callback is made multiple times
add("write", 3)
add("write2", 4)
add("shutdown", 2)

return dapui.async.uv
