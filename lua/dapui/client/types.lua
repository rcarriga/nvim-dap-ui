
---@class dapui.DAPRequestsClient
local DAPUIRequestsClient = {}

---@class dapui.DAPEventListenerClient
local DAPUIEventListenerClient = {}

---@class dapui.DAPClient
DAPUIClient = {
    request = DAPUIRequestsClient,
    listen = DAPUIEventListenerClient,
}
---@class dapui.types.AttachRequestArguments

---@async
---@param args dapui.types.AttachRequestArguments 
function DAPUIRequestsClient.attach(args) end

---@class dapui.types.Checksum
---@field algorithm "MD5" The algorithm used to calculate this checksum.
---@field checksum string Value of the checksum, encoded as a hexadecimal value.

---@class dapui.types.Source
---@field name? string The short name of the source. Every source returned from the debug adapter has a name.
---When sending a source to the debug adapter this name is optional.
---@field path? string The path of the source to be shown in the UI.
---It is only used to locate and load the content of the source if no `sourceReference` is specified (or its value is 0).
---@field sourceReference? integer If the value > 0 the contents of the source must be retrieved through the `source` request (even if a path is specified).
---Since a `sourceReference` is only valid for a session, it can not be used to persist a source.
---The value should be less than or equal to 2147483647 (2^31-1).
---@field presentationHint? "normal" A hint for how to present the source in the UI.
---A value of `deemphasize` can be used to indicate that the source is not available or that it is skipped on stepping.
---@field origin? string The origin of this source. For example, 'internal module', 'inlined content from source map', etc.
---@field sources? dapui.types.Source[] A list of sources that are related to this source. These may be the source that generated this source.
---@field adapterData? any[] | boolean | integer | number | table<string,any> | string Additional data that a debug adapter might want to loop through the client.
---The client should leave the data intact and persist it across sessions. The client should not interpret the data.
---@field checksums? dapui.types.Checksum[] The checksums associated with this file.

---@class dapui.types.BreakpointLocationsArguments
---@field source dapui.types.Source The source location of the breakpoints; either `source.path` or `source.reference` must be specified.
---@field line integer Start line of range to search possible breakpoint locations in. If only the line is specified, the request returns all possible locations in that line.
---@field column? integer Start position within `line` to search possible breakpoint locations in. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based. If no column is given, the first position in the start line is assumed.
---@field endLine? integer End line of range to search possible breakpoint locations in. If no end line is given, then the end line is assumed to be the start line.
---@field endColumn? integer End position within `endLine` to search possible breakpoint locations in. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based. If no end column is given, the last position in the end line is assumed.

---@class dapui.types.BreakpointLocation
---@field line integer Start line of breakpoint location.
---@field column? integer The start position of a breakpoint location. Position is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field endLine? integer The end line of breakpoint location if the location covers a range.
---@field endColumn? integer The end position of a breakpoint location (if the location covers a range). Position is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.

---@class dapui.types.BreakpointLocationsResponse
---@field breakpoints dapui.types.BreakpointLocation[] Sorted set of possible breakpoint locations.

---@async
---@param args dapui.types.BreakpointLocationsArguments 
---@return dapui.types.BreakpointLocationsResponse
function DAPUIRequestsClient.breakpointLocations(args) end

---@class dapui.types.CancelArguments
---@field requestId? integer The ID (attribute `seq`) of the request to cancel. If missing no request is cancelled.
---Both a `requestId` and a `progressId` can be specified in one request.
---@field progressId? string The ID (attribute `progressId`) of the progress to cancel. If missing no progress is cancelled.
---Both a `requestId` and a `progressId` can be specified in one request.

---@async
---@param args dapui.types.CancelArguments 
function DAPUIRequestsClient.cancel(args) end

---@class dapui.types.CompletionsArguments
---@field frameId? integer Returns completions in the scope of this stack frame. If not specified, the completions are returned for the global scope.
---@field text string One or more source lines. Typically this is the text users have typed into the debug console before they asked for completion.
---@field column integer The position within `text` for which to determine the completion proposals. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field line? integer A line for which to determine the completion proposals. If missing the first line of the text is assumed.

---@class dapui.types.CompletionItem
---@field label string The label of this completion item. By default this is also the text that is inserted when selecting this completion.
---@field text? string If text is returned and not an empty string, then it is inserted instead of the label.
---@field sortText? string A string that should be used when comparing this item with other items. If not returned or an empty string, the `label` is used instead.
---@field detail? string A human-readable string with additional information about this item, like type or symbol information.
---@field type? "method" The item's type. Typically the client uses this information to render the item in the UI with an icon.
---@field start? integer Start position (within the `text` attribute of the `completions` request) where the completion text is added. The position is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based. If the start position is omitted the text is added at the location specified by the `column` attribute of the `completions` request.
---@field length? integer Length determines how many characters are overwritten by the completion text and it is measured in UTF-16 code units. If missing the value 0 is assumed which results in the completion text being inserted.
---@field selectionStart? integer Determines the start of the new selection after the text has been inserted (or replaced). `selectionStart` is measured in UTF-16 code units and must be in the range 0 and length of the completion text. If omitted the selection starts at the end of the completion text.
---@field selectionLength? integer Determines the length of the new selection after the text has been inserted (or replaced) and it is measured in UTF-16 code units. The selection can not extend beyond the bounds of the completion text. If omitted the length is assumed to be 0.

---@class dapui.types.CompletionsResponse
---@field targets dapui.types.CompletionItem[] The possible completions for .

---@async
---@param args dapui.types.CompletionsArguments 
---@return dapui.types.CompletionsResponse
function DAPUIRequestsClient.completions(args) end

---@class dapui.types.ConfigurationDoneArguments

---@async
---@param args dapui.types.ConfigurationDoneArguments 
function DAPUIRequestsClient.configurationDone(args) end

---@class dapui.types.ContinueArguments
---@field threadId integer Specifies the active thread. If the debug adapter supports single thread execution (see `supportsSingleThreadExecutionRequests`) and the argument `singleThread` is true, only the thread with this ID is resumed.
---@field singleThread? boolean If this flag is true, execution is resumed only for the thread with given `threadId`.

---@class dapui.types.ContinueResponse
---@field allThreadsContinued? boolean The value true (or a missing property) signals to the client that all threads have been resumed. The value false indicates that not all threads were resumed.

---@async
---@param args dapui.types.ContinueArguments 
---@return dapui.types.ContinueResponse
function DAPUIRequestsClient.continue_(args) end

---@class dapui.types.DataBreakpointInfoArguments
---@field variablesReference? integer Reference to the variable container if the data breakpoint is requested for a child of the container.
---@field name string The name of the variable's child to obtain data breakpoint information for.
---If `variablesReference` isn't specified, this can be an expression.

---@class dapui.types.DataBreakpointInfoResponse
---@field dataId string An identifier for the data on which a data breakpoint can be registered with the `setDataBreakpoints` request or null if no data breakpoint is available.
---@field description string UI string that describes on what data the breakpoint is set on or why a data breakpoint is not available.
---@field accessTypes? "read"[] Attribute lists the available access types for a potential data breakpoint. A UI client could surface this information.
---@field canPersist? boolean Attribute indicates that a potential data breakpoint could be persisted across sessions.

---@async
---@param args dapui.types.DataBreakpointInfoArguments 
---@return dapui.types.DataBreakpointInfoResponse
function DAPUIRequestsClient.dataBreakpointInfo(args) end

---@class dapui.types.DisassembleArguments
---@field memoryReference string Memory reference to the base location containing the instructions to disassemble.
---@field offset? integer Offset (in bytes) to be applied to the reference location before disassembling. Can be negative.
---@field instructionOffset? integer Offset (in instructions) to be applied after the byte offset (if any) before disassembling. Can be negative.
---@field instructionCount integer Number of instructions to disassemble starting at the specified location and offset.
---An adapter must return exactly this number of instructions - any unavailable instructions should be replaced with an implementation-defined 'invalid instruction' value.
---@field resolveSymbols? boolean If true, the adapter should attempt to resolve memory addresses and other values to symbolic names.

---@class dapui.types.DisassembledInstruction
---@field address string The address of the instruction. Treated as a hex value if prefixed with `0x`, or as a decimal value otherwise.
---@field instructionBytes? string Raw bytes representing the instruction and its operands, in an implementation-defined format.
---@field instruction string Text representing the instruction and its operands, in an implementation-defined format.
---@field symbol? string Name of the symbol that corresponds with the location of this instruction, if any.
---@field location? dapui.types.Source Source location that corresponds to this instruction, if any.
---Should always be set (if available) on the first instruction returned,
---but can be omitted afterwards if this instruction maps to the same source file as the previous instruction.
---@field line? integer The line within the source location that corresponds to this instruction, if any.
---@field column? integer The column within the line that corresponds to this instruction, if any.
---@field endLine? integer The end line of the range that corresponds to this instruction, if any.
---@field endColumn? integer The end column of the range that corresponds to this instruction, if any.

---@class dapui.types.DisassembleResponse
---@field instructions dapui.types.DisassembledInstruction[] The list of disassembled instructions.

---@async
---@param args dapui.types.DisassembleArguments 
---@return dapui.types.DisassembleResponse
function DAPUIRequestsClient.disassemble(args) end

---@class dapui.types.DisconnectArguments
---@field restart? boolean A value of true indicates that this `disconnect` request is part of a restart sequence.
---@field terminateDebuggee? boolean Indicates whether the debuggee should be terminated when the debugger is disconnected.
---If unspecified, the debug adapter is free to do whatever it thinks is best.
---The attribute is only honored by a debug adapter if the corresponding capability `supportTerminateDebuggee` is true.
---@field suspendDebuggee? boolean Indicates whether the debuggee should stay suspended when the debugger is disconnected.
---If unspecified, the debuggee should resume execution.
---The attribute is only honored by a debug adapter if the corresponding capability `supportSuspendDebuggee` is true.

---@async
---@param args dapui.types.DisconnectArguments 
function DAPUIRequestsClient.disconnect(args) end

---@class dapui.types.ValueFormat
---@field hex? boolean Display the value in hex.

---@class dapui.types.EvaluateArguments
---@field expression string The expression to evaluate.
---@field frameId? integer Evaluate the expression in the scope of this stack frame. If not specified, the expression is evaluated in the global scope.
---@field context? string The context in which the evaluate request is used.
---@field format? dapui.types.ValueFormat Specifies details on how to format the result.
---The attribute is only honored by a debug adapter if the corresponding capability `supportsValueFormattingOptions` is true.

---@class dapui.types.VariablePresentationHint
---@field kind? string The kind of variable. Before introducing additional values, try to use the listed values.
---@field attributes? string[] Set of attributes represented as an array of strings. Before introducing additional values, try to use the listed values.
---@field visibility? string Visibility of variable. Before introducing additional values, try to use the listed values.
---@field lazy? boolean If true, clients can present the variable with a UI that supports a specific gesture to trigger its evaluation.
---This mechanism can be used for properties that require executing code when retrieving their value and where the code execution can be expensive and/or produce side-effects. A typical example are properties based on a getter function.
---Please note that in addition to the `lazy` flag, the variable's `variablesReference` is expected to refer to a variable that will provide the value through another `variable` request.

---@class dapui.types.EvaluateResponse
---@field result string The result of the evaluate request.
---@field type? string The type of the evaluate result.
---This attribute should only be returned by a debug adapter if the corresponding capability `supportsVariableType` is true.
---@field presentationHint? dapui.types.VariablePresentationHint Properties of an evaluate result that can be used to determine how to render the result in the UI.
---@field variablesReference integer If `variablesReference` is > 0, the evaluate result is structured and its children can be retrieved by passing `variablesReference` to the `variables` request.
---The value should be less than or equal to 2147483647 (2^31-1).
---@field namedVariables? integer The number of named child variables.
---The client can use this information to present the variables in a paged UI and fetch them in chunks.
---The value should be less than or equal to 2147483647 (2^31-1).
---@field indexedVariables? integer The number of indexed child variables.
---The client can use this information to present the variables in a paged UI and fetch them in chunks.
---The value should be less than or equal to 2147483647 (2^31-1).
---@field memoryReference? string A memory reference to a location appropriate for this result.
---For pointer type eval results, this is generally a reference to the memory address contained in the pointer.
---This attribute should be returned by a debug adapter if corresponding capability `supportsMemoryReferences` is true.

---@async
---@param args dapui.types.EvaluateArguments 
---@return dapui.types.EvaluateResponse
function DAPUIRequestsClient.evaluate(args) end

---@class dapui.types.ExceptionInfoArguments
---@field threadId integer Thread for which exception information should be retrieved.

---@class dapui.types.ExceptionDetails
---@field message? string Message contained in the exception.
---@field typeName? string Short type name of the exception object.
---@field fullTypeName? string Fully-qualified type name of the exception object.
---@field evaluateName? string An expression that can be evaluated in the current scope to obtain the exception object.
---@field stackTrace? string Stack trace at the time the exception was thrown.
---@field innerException? dapui.types.ExceptionDetails[] Details of the exception contained by this exception, if any.

---@class dapui.types.ExceptionInfoResponse
---@field exceptionId string ID of the exception that was thrown.
---@field description? string Descriptive text for the exception.
---@field breakMode "never" Mode that caused the exception notification to be raised.
---@field details? dapui.types.ExceptionDetails Detailed information about the exception.

---@async
---@param args dapui.types.ExceptionInfoArguments 
---@return dapui.types.ExceptionInfoResponse
function DAPUIRequestsClient.exceptionInfo(args) end

---@class dapui.types.GotoArguments
---@field threadId integer Set the goto target for this thread.
---@field targetId integer The location where the debuggee will continue to run.

---@async
---@param args dapui.types.GotoArguments 
function DAPUIRequestsClient.goto_(args) end

---@class dapui.types.GotoTargetsArguments
---@field source dapui.types.Source The source location for which the goto targets are determined.
---@field line integer The line location for which the goto targets are determined.
---@field column? integer The position within `line` for which the goto targets are determined. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.

---@class dapui.types.GotoTarget
---@field id integer Unique identifier for a goto target. This is used in the `goto` request.
---@field label string The name of the goto target (shown in the UI).
---@field line integer The line of the goto target.
---@field column? integer The column of the goto target.
---@field endLine? integer The end line of the range covered by the goto target.
---@field endColumn? integer The end column of the range covered by the goto target.
---@field instructionPointerReference? string A memory reference for the instruction pointer value represented by this target.

---@class dapui.types.GotoTargetsResponse
---@field targets dapui.types.GotoTarget[] The possible goto targets of the specified location.

---@async
---@param args dapui.types.GotoTargetsArguments 
---@return dapui.types.GotoTargetsResponse
function DAPUIRequestsClient.gotoTargets(args) end

---@class dapui.types.InitializeRequestArguments
---@field clientID? string The ID of the client using this adapter.
---@field clientName? string The human-readable name of the client using this adapter.
---@field adapterID string The ID of the debug adapter.
---@field locale? string The ISO-639 locale of the client using this adapter, e.g. en-US or de-CH.
---@field linesStartAt1? boolean If true all line numbers are 1-based (default).
---@field columnsStartAt1? boolean If true all column numbers are 1-based (default).
---@field pathFormat? string Determines in what format paths are specified. The default is `path`, which is the native format.
---@field supportsVariableType? boolean Client supports the `type` attribute for variables.
---@field supportsVariablePaging? boolean Client supports the paging of variables.
---@field supportsRunInTerminalRequest? boolean Client supports the `runInTerminal` request.
---@field supportsMemoryReferences? boolean Client supports memory references.
---@field supportsProgressReporting? boolean Client supports progress reporting.
---@field supportsInvalidatedEvent? boolean Client supports the `invalidated` event.
---@field supportsMemoryEvent? boolean Client supports the `memory` event.
---@field supportsArgsCanBeInterpretedByShell? boolean Client supports the `argsCanBeInterpretedByShell` attribute on the `runInTerminal` request.
---@field supportsStartDebuggingRequest? boolean Client supports the `startDebugging` request.

---@class dapui.types.ExceptionBreakpointsFilter
---@field filter string The internal ID of the filter option. This value is passed to the `setExceptionBreakpoints` request.
---@field label string The name of the filter option. This is shown in the UI.
---@field description? string A help text providing additional information about the exception filter. This string is typically shown as a hover and can be translated.
---@field default? boolean Initial value of the filter option. If not specified a value false is assumed.
---@field supportsCondition? boolean Controls whether a condition can be specified for this filter option. If false or missing, a condition can not be set.
---@field conditionDescription? string A help text providing information about the condition. This string is shown as the placeholder text for a text box and can be translated.

---@class dapui.types.ColumnDescriptor
---@field attributeName string Name of the attribute rendered in this column.
---@field label string Header UI label of column.
---@field format? string Format to use for the rendered values in this column. TBD how the format strings looks like.
---@field type? "string" Datatype of values in this column. Defaults to `string` if not specified.
---@field width? integer Width of this column in characters (hint only).

---@class dapui.types.InitializeResponse
---@field supportsConfigurationDoneRequest? boolean The debug adapter supports the `configurationDone` request.
---@field supportsFunctionBreakpoints? boolean The debug adapter supports function breakpoints.
---@field supportsConditionalBreakpoints? boolean The debug adapter supports conditional breakpoints.
---@field supportsHitConditionalBreakpoints? boolean The debug adapter supports breakpoints that break execution after a specified number of hits.
---@field supportsEvaluateForHovers? boolean The debug adapter supports a (side effect free) `evaluate` request for data hovers.
---@field exceptionBreakpointFilters? dapui.types.ExceptionBreakpointsFilter[] Available exception filter options for the `setExceptionBreakpoints` request.
---@field supportsStepBack? boolean The debug adapter supports stepping back via the `stepBack` and `reverseContinue` requests.
---@field supportsSetVariable? boolean The debug adapter supports setting a variable to a value.
---@field supportsRestartFrame? boolean The debug adapter supports restarting a frame.
---@field supportsGotoTargetsRequest? boolean The debug adapter supports the `gotoTargets` request.
---@field supportsStepInTargetsRequest? boolean The debug adapter supports the `stepInTargets` request.
---@field supportsCompletionsRequest? boolean The debug adapter supports the `completions` request.
---@field completionTriggerCharacters? string[] The set of characters that should trigger completion in a REPL. If not specified, the UI should assume the `.` character.
---@field supportsModulesRequest? boolean The debug adapter supports the `modules` request.
---@field additionalModuleColumns? dapui.types.ColumnDescriptor[] The set of additional module information exposed by the debug adapter.
---@field supportedChecksumAlgorithms? "MD5"[] Checksum algorithms supported by the debug adapter.
---@field supportsRestartRequest? boolean The debug adapter supports the `restart` request. In this case a client should not implement `restart` by terminating and relaunching the adapter but by calling the `restart` request.
---@field supportsExceptionOptions? boolean The debug adapter supports `exceptionOptions` on the `setExceptionBreakpoints` request.
---@field supportsValueFormattingOptions? boolean The debug adapter supports a `format` attribute on the `stackTrace`, `variables`, and `evaluate` requests.
---@field supportsExceptionInfoRequest? boolean The debug adapter supports the `exceptionInfo` request.
---@field supportTerminateDebuggee? boolean The debug adapter supports the `terminateDebuggee` attribute on the `disconnect` request.
---@field supportSuspendDebuggee? boolean The debug adapter supports the `suspendDebuggee` attribute on the `disconnect` request.
---@field supportsDelayedStackTraceLoading? boolean The debug adapter supports the delayed loading of parts of the stack, which requires that both the `startFrame` and `levels` arguments and the `totalFrames` result of the `stackTrace` request are supported.
---@field supportsLoadedSourcesRequest? boolean The debug adapter supports the `loadedSources` request.
---@field supportsLogPoints? boolean The debug adapter supports log points by interpreting the `logMessage` attribute of the `SourceBreakpoint`.
---@field supportsTerminateThreadsRequest? boolean The debug adapter supports the `terminateThreads` request.
---@field supportsSetExpression? boolean The debug adapter supports the `setExpression` request.
---@field supportsTerminateRequest? boolean The debug adapter supports the `terminate` request.
---@field supportsDataBreakpoints? boolean The debug adapter supports data breakpoints.
---@field supportsReadMemoryRequest? boolean The debug adapter supports the `readMemory` request.
---@field supportsWriteMemoryRequest? boolean The debug adapter supports the `writeMemory` request.
---@field supportsDisassembleRequest? boolean The debug adapter supports the `disassemble` request.
---@field supportsCancelRequest? boolean The debug adapter supports the `cancel` request.
---@field supportsBreakpointLocationsRequest? boolean The debug adapter supports the `breakpointLocations` request.
---@field supportsClipboardContext? boolean The debug adapter supports the `clipboard` context value in the `evaluate` request.
---@field supportsSteppingGranularity? boolean The debug adapter supports stepping granularities (argument `granularity`) for the stepping requests.
---@field supportsInstructionBreakpoints? boolean The debug adapter supports adding breakpoints based on instruction references.
---@field supportsExceptionFilterOptions? boolean The debug adapter supports `filterOptions` as an argument on the `setExceptionBreakpoints` request.
---@field supportsSingleThreadExecutionRequests? boolean The debug adapter supports the `singleThread` property on the execution requests (`continue`, `next`, `stepIn`, `stepOut`, `reverseContinue`, `stepBack`).

---@async
---@param args dapui.types.InitializeRequestArguments 
---@return dapui.types.InitializeResponse
function DAPUIRequestsClient.initialize(args) end

---@class dapui.types.LaunchRequestArguments
---@field noDebug? boolean If true, the launch request should launch the program without enabling debugging.

---@async
---@param args dapui.types.LaunchRequestArguments 
function DAPUIRequestsClient.launch(args) end

---@class dapui.types.LoadedSourcesArguments

---@class dapui.types.LoadedSourcesResponse
---@field sources dapui.types.Source[] Set of loaded sources.

---@async
---@param args dapui.types.LoadedSourcesArguments 
---@return dapui.types.LoadedSourcesResponse
function DAPUIRequestsClient.loadedSources(args) end

---@class dapui.types.ModulesArguments
---@field startModule? integer The index of the first module to return; if omitted modules start at 0.
---@field moduleCount? integer The number of modules to return. If `moduleCount` is not specified or 0, all modules are returned.

---@class dapui.types.Module
---@field id integer | string Unique identifier for the module.
---@field name string A name of the module.
---@field path? string Logical full path to the module. The exact definition is implementation defined, but usually this would be a full path to the on-disk file for the module.
---@field isOptimized? boolean True if the module is optimized.
---@field isUserCode? boolean True if the module is considered 'user code' by a debugger that supports 'Just My Code'.
---@field version? string Version of Module.
---@field symbolStatus? string User-understandable description of if symbols were found for the module (ex: 'Symbols Loaded', 'Symbols not found', etc.)
---@field symbolFilePath? string Logical full path to the symbol file. The exact definition is implementation defined.
---@field dateTimeStamp? string Module created or modified, encoded as a RFC 3339 timestamp.
---@field addressRange? string Address range covered by this module.

---@class dapui.types.ModulesResponse
---@field modules dapui.types.Module[] All modules or range of modules.
---@field totalModules? integer The total number of modules available.

---@async
---@param args dapui.types.ModulesArguments 
---@return dapui.types.ModulesResponse
function DAPUIRequestsClient.modules(args) end

---@class dapui.types.NextArguments
---@field threadId integer Specifies the thread for which to resume execution for one step (of the given granularity).
---@field singleThread? boolean If this flag is true, all other suspended threads are not resumed.
---@field granularity? "statement" Stepping granularity. If no granularity is specified, a granularity of `statement` is assumed.

---@async
---@param args dapui.types.NextArguments 
function DAPUIRequestsClient.next(args) end

---@class dapui.types.PauseArguments
---@field threadId integer Pause execution for this thread.

---@async
---@param args dapui.types.PauseArguments 
function DAPUIRequestsClient.pause(args) end

---@class dapui.types.ReadMemoryArguments
---@field memoryReference string Memory reference to the base location from which data should be read.
---@field offset? integer Offset (in bytes) to be applied to the reference location before reading data. Can be negative.
---@field count integer Number of bytes to read at the specified location and offset.

---@class dapui.types.ReadMemoryResponse
---@field address string The address of the first byte of data returned.
---Treated as a hex value if prefixed with `0x`, or as a decimal value otherwise.
---@field unreadableBytes? integer The number of unreadable bytes encountered after the last successfully read byte.
---This can be used to determine the number of bytes that should be skipped before a subsequent `readMemory` request succeeds.
---@field data? string The bytes read from memory, encoded using base64.

---@async
---@param args dapui.types.ReadMemoryArguments 
---@return dapui.types.ReadMemoryResponse
function DAPUIRequestsClient.readMemory(args) end

---@class dapui.types.RestartFrameArguments
---@field frameId integer Restart this stackframe.

---@async
---@param args dapui.types.RestartFrameArguments 
function DAPUIRequestsClient.restartFrame(args) end

---@class dapui.types.RestartArguments
---@field arguments? dapui.types.LaunchRequestArguments | dapui.types.AttachRequestArguments The latest version of the `launch` or `attach` configuration.

---@async
---@param args dapui.types.RestartArguments 
function DAPUIRequestsClient.restart(args) end

---@class dapui.types.ReverseContinueArguments
---@field threadId integer Specifies the active thread. If the debug adapter supports single thread execution (see `supportsSingleThreadExecutionRequests`) and the `singleThread` argument is true, only the thread with this ID is resumed.
---@field singleThread? boolean If this flag is true, backward execution is resumed only for the thread with given `threadId`.

---@async
---@param args dapui.types.ReverseContinueArguments 
function DAPUIRequestsClient.reverseContinue(args) end

---@class dapui.types.RunInTerminalRequestArguments
---@field kind? "integrated" What kind of terminal to launch.
---@field title? string Title of the terminal.
---@field cwd string Working directory for the command. For non-empty, valid paths this typically results in execution of a change directory command.
---@field args string[] List of arguments. The first argument is the command to run.
---@field env? table<string,string> Environment key-value pairs that are added to or removed from the default environment.
---@field argsCanBeInterpretedByShell? boolean This property should only be set if the corresponding capability `supportsArgsCanBeInterpretedByShell` is true. If the client uses an intermediary shell to launch the application, then the client must not attempt to escape characters with special meanings for the shell. The user is fully responsible for escaping as needed and that arguments using special characters may not be portable across shells.

---@class dapui.types.RunInTerminalResponse
---@field processId? integer The process ID. The value should be less than or equal to 2147483647 (2^31-1).
---@field shellProcessId? integer The process ID of the terminal shell. The value should be less than or equal to 2147483647 (2^31-1).

---@async
---@param args dapui.types.RunInTerminalRequestArguments 
---@return dapui.types.RunInTerminalResponse
function DAPUIRequestsClient.runInTerminal(args) end

---@class dapui.types.ScopesArguments
---@field frameId integer Retrieve the scopes for this stackframe.

---@class dapui.types.Scope
---@field name string Name of the scope such as 'Arguments', 'Locals', or 'Registers'. This string is shown in the UI as is and can be translated.
---@field presentationHint? string A hint for how to present this scope in the UI. If this attribute is missing, the scope is shown with a generic UI.
---@field variablesReference integer The variables of this scope can be retrieved by passing the value of `variablesReference` to the `variables` request.
---@field namedVariables? integer The number of named variables in this scope.
---The client can use this information to present the variables in a paged UI and fetch them in chunks.
---@field indexedVariables? integer The number of indexed variables in this scope.
---The client can use this information to present the variables in a paged UI and fetch them in chunks.
---@field expensive boolean If true, the number of variables in this scope is large or expensive to retrieve.
---@field source? dapui.types.Source The source for this scope.
---@field line? integer The start line of the range covered by this scope.
---@field column? integer Start position of the range covered by the scope. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field endLine? integer The end line of the range covered by this scope.
---@field endColumn? integer End position of the range covered by the scope. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.

---@class dapui.types.ScopesResponse
---@field scopes dapui.types.Scope[] The scopes of the stackframe. If the array has length zero, there are no scopes available.

---@async
---@param args dapui.types.ScopesArguments 
---@return dapui.types.ScopesResponse
function DAPUIRequestsClient.scopes(args) end

---@class dapui.types.SourceBreakpoint
---@field line integer The source line of the breakpoint or logpoint.
---@field column? integer Start position within source line of the breakpoint or logpoint. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field condition? string The expression for conditional breakpoints.
---It is only honored by a debug adapter if the corresponding capability `supportsConditionalBreakpoints` is true.
---@field hitCondition? string The expression that controls how many hits of the breakpoint are ignored.
---The debug adapter is expected to interpret the expression as needed.
---The attribute is only honored by a debug adapter if the corresponding capability `supportsHitConditionalBreakpoints` is true.
---@field logMessage? string If this attribute exists and is non-empty, the debug adapter must not 'break' (stop)
---but log the message instead. Expressions within `{}` are interpolated.
---The attribute is only honored by a debug adapter if the corresponding capability `supportsLogPoints` is true.

---@class dapui.types.SetBreakpointsArguments
---@field source dapui.types.Source The source location of the breakpoints; either `source.path` or `source.sourceReference` must be specified.
---@field breakpoints? dapui.types.SourceBreakpoint[] The code locations of the breakpoints.
---@field lines? integer[] Deprecated: The code locations of the breakpoints.
---@field sourceModified? boolean A value of true indicates that the underlying source has been modified which results in new breakpoint locations.

---@class dapui.types.Breakpoint
---@field id? integer The identifier for the breakpoint. It is needed if breakpoint events are used to update or remove breakpoints.
---@field verified boolean If true, the breakpoint could be set (but not necessarily at the desired location).
---@field message? string A message about the state of the breakpoint.
---This is shown to the user and can be used to explain why a breakpoint could not be verified.
---@field source? dapui.types.Source The source where the breakpoint is located.
---@field line? integer The start line of the actual range covered by the breakpoint.
---@field column? integer Start position of the source range covered by the breakpoint. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field endLine? integer The end line of the actual range covered by the breakpoint.
---@field endColumn? integer End position of the source range covered by the breakpoint. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---If no end line is given, then the end column is assumed to be in the start line.
---@field instructionReference? string A memory reference to where the breakpoint is set.
---@field offset? integer The offset from the instruction reference.
---This can be negative.

---@class dapui.types.SetBreakpointsResponse
---@field breakpoints dapui.types.Breakpoint[] Information about the breakpoints.
---The array elements are in the same order as the elements of the `breakpoints` (or the deprecated `lines`) array in the arguments.

---@async
---@param args dapui.types.SetBreakpointsArguments 
---@return dapui.types.SetBreakpointsResponse
function DAPUIRequestsClient.setBreakpoints(args) end

---@class dapui.types.DataBreakpoint
---@field dataId string An id representing the data. This id is returned from the `dataBreakpointInfo` request.
---@field accessType? "read" The access type of the data.
---@field condition? string An expression for conditional breakpoints.
---@field hitCondition? string An expression that controls how many hits of the breakpoint are ignored.
---The debug adapter is expected to interpret the expression as needed.

---@class dapui.types.SetDataBreakpointsArguments
---@field breakpoints dapui.types.DataBreakpoint[] The contents of this array replaces all existing data breakpoints. An empty array clears all data breakpoints.

---@class dapui.types.SetDataBreakpointsResponse
---@field breakpoints dapui.types.Breakpoint[] Information about the data breakpoints. The array elements correspond to the elements of the input argument `breakpoints` array.

---@async
---@param args dapui.types.SetDataBreakpointsArguments 
---@return dapui.types.SetDataBreakpointsResponse
function DAPUIRequestsClient.setDataBreakpoints(args) end

---@class dapui.types.ExceptionFilterOptions
---@field filterId string ID of an exception filter returned by the `exceptionBreakpointFilters` capability.
---@field condition? string An expression for conditional exceptions.
---The exception breaks into the debugger if the result of the condition is true.

---@class dapui.types.ExceptionPathSegment
---@field negate? boolean If false or missing this segment matches the names provided, otherwise it matches anything except the names provided.
---@field names string[] Depending on the value of `negate` the names that should match or not match.

---@class dapui.types.ExceptionOptions
---@field path? dapui.types.ExceptionPathSegment[] A path that selects a single or multiple exceptions in a tree. If `path` is missing, the whole tree is selected.
---By convention the first segment of the path is a category that is used to group exceptions in the UI.
---@field breakMode "never" Condition when a thrown exception should result in a break.

---@class dapui.types.SetExceptionBreakpointsArguments
---@field filters string[] Set of exception filters specified by their ID. The set of all possible exception filters is defined by the `exceptionBreakpointFilters` capability. The `filter` and `filterOptions` sets are additive.
---@field filterOptions? dapui.types.ExceptionFilterOptions[] Set of exception filters and their options. The set of all possible exception filters is defined by the `exceptionBreakpointFilters` capability. This attribute is only honored by a debug adapter if the corresponding capability `supportsExceptionFilterOptions` is true. The `filter` and `filterOptions` sets are additive.
---@field exceptionOptions? dapui.types.ExceptionOptions[] Configuration options for selected exceptions.
---The attribute is only honored by a debug adapter if the corresponding capability `supportsExceptionOptions` is true.

---@class dapui.types.SetExceptionBreakpointsResponse
---@field breakpoints? dapui.types.Breakpoint[] Information about the exception breakpoints or filters.
---The breakpoints returned are in the same order as the elements of the `filters`, `filterOptions`, `exceptionOptions` arrays in the arguments. If both `filters` and `filterOptions` are given, the returned array must start with `filters` information first, followed by `filterOptions` information.

---@async
---@param args dapui.types.SetExceptionBreakpointsArguments 
---@return dapui.types.SetExceptionBreakpointsResponse
function DAPUIRequestsClient.setExceptionBreakpoints(args) end

---@class dapui.types.SetExpressionArguments
---@field expression string The l-value expression to assign to.
---@field value string The value expression to assign to the l-value expression.
---@field frameId? integer Evaluate the expressions in the scope of this stack frame. If not specified, the expressions are evaluated in the global scope.
---@field format? dapui.types.ValueFormat Specifies how the resulting value should be formatted.

---@class dapui.types.SetExpressionResponse
---@field value string The new value of the expression.
---@field type? string The type of the value.
---This attribute should only be returned by a debug adapter if the corresponding capability `supportsVariableType` is true.
---@field presentationHint? dapui.types.VariablePresentationHint Properties of a value that can be used to determine how to render the result in the UI.
---@field variablesReference? integer If `variablesReference` is > 0, the value is structured and its children can be retrieved by passing `variablesReference` to the `variables` request.
---The value should be less than or equal to 2147483647 (2^31-1).
---@field namedVariables? integer The number of named child variables.
---The client can use this information to present the variables in a paged UI and fetch them in chunks.
---The value should be less than or equal to 2147483647 (2^31-1).
---@field indexedVariables? integer The number of indexed child variables.
---The client can use this information to present the variables in a paged UI and fetch them in chunks.
---The value should be less than or equal to 2147483647 (2^31-1).

---@async
---@param args dapui.types.SetExpressionArguments 
---@return dapui.types.SetExpressionResponse
function DAPUIRequestsClient.setExpression(args) end

---@class dapui.types.FunctionBreakpoint
---@field name string The name of the function.
---@field condition? string An expression for conditional breakpoints.
---It is only honored by a debug adapter if the corresponding capability `supportsConditionalBreakpoints` is true.
---@field hitCondition? string An expression that controls how many hits of the breakpoint are ignored.
---The debug adapter is expected to interpret the expression as needed.
---The attribute is only honored by a debug adapter if the corresponding capability `supportsHitConditionalBreakpoints` is true.

---@class dapui.types.SetFunctionBreakpointsArguments
---@field breakpoints dapui.types.FunctionBreakpoint[] The function names of the breakpoints.

---@class dapui.types.SetFunctionBreakpointsResponse
---@field breakpoints dapui.types.Breakpoint[] Information about the breakpoints. The array elements correspond to the elements of the `breakpoints` array.

---@async
---@param args dapui.types.SetFunctionBreakpointsArguments 
---@return dapui.types.SetFunctionBreakpointsResponse
function DAPUIRequestsClient.setFunctionBreakpoints(args) end

---@class dapui.types.InstructionBreakpoint
---@field instructionReference string The instruction reference of the breakpoint.
---This should be a memory or instruction pointer reference from an `EvaluateResponse`, `Variable`, `StackFrame`, `GotoTarget`, or `Breakpoint`.
---@field offset? integer The offset from the instruction reference.
---This can be negative.
---@field condition? string An expression for conditional breakpoints.
---It is only honored by a debug adapter if the corresponding capability `supportsConditionalBreakpoints` is true.
---@field hitCondition? string An expression that controls how many hits of the breakpoint are ignored.
---The debug adapter is expected to interpret the expression as needed.
---The attribute is only honored by a debug adapter if the corresponding capability `supportsHitConditionalBreakpoints` is true.

---@class dapui.types.SetInstructionBreakpointsArguments
---@field breakpoints dapui.types.InstructionBreakpoint[] The instruction references of the breakpoints

---@class dapui.types.SetInstructionBreakpointsResponse
---@field breakpoints dapui.types.Breakpoint[] Information about the breakpoints. The array elements correspond to the elements of the `breakpoints` array.

---@async
---@param args dapui.types.SetInstructionBreakpointsArguments 
---@return dapui.types.SetInstructionBreakpointsResponse
function DAPUIRequestsClient.setInstructionBreakpoints(args) end

---@class dapui.types.SetVariableArguments
---@field variablesReference integer The reference of the variable container.
---@field name string The name of the variable in the container.
---@field value string The value of the variable.
---@field format? dapui.types.ValueFormat Specifies details on how to format the response value.

---@class dapui.types.SetVariableResponse
---@field value string The new value of the variable.
---@field type? string The type of the new value. Typically shown in the UI when hovering over the value.
---@field variablesReference? integer If `variablesReference` is > 0, the new value is structured and its children can be retrieved by passing `variablesReference` to the `variables` request.
---The value should be less than or equal to 2147483647 (2^31-1).
---@field namedVariables? integer The number of named child variables.
---The client can use this information to present the variables in a paged UI and fetch them in chunks.
---The value should be less than or equal to 2147483647 (2^31-1).
---@field indexedVariables? integer The number of indexed child variables.
---The client can use this information to present the variables in a paged UI and fetch them in chunks.
---The value should be less than or equal to 2147483647 (2^31-1).

---@async
---@param args dapui.types.SetVariableArguments 
---@return dapui.types.SetVariableResponse
function DAPUIRequestsClient.setVariable(args) end

---@class dapui.types.SourceArguments
---@field source? dapui.types.Source Specifies the source content to load. Either `source.path` or `source.sourceReference` must be specified.
---@field sourceReference integer The reference to the source. This is the same as `source.sourceReference`.
---This is provided for backward compatibility since old clients do not understand the `source` attribute.

---@class dapui.types.SourceResponse
---@field content string Content of the source reference.
---@field mimeType? string Content type (MIME type) of the source.

---@async
---@param args dapui.types.SourceArguments 
---@return dapui.types.SourceResponse
function DAPUIRequestsClient.source(args) end

---@class dapui.types.StackFrameFormat
---@field hex? boolean Display the value in hex.
---@field parameters? boolean Displays parameters for the stack frame.
---@field parameterTypes? boolean Displays the types of parameters for the stack frame.
---@field parameterNames? boolean Displays the names of parameters for the stack frame.
---@field parameterValues? boolean Displays the values of parameters for the stack frame.
---@field line? boolean Displays the line number of the stack frame.
---@field module? boolean Displays the module of the stack frame.
---@field includeAll? boolean Includes all stack frames, including those the debug adapter might otherwise hide.

---@class dapui.types.StackTraceArguments
---@field threadId integer Retrieve the stacktrace for this thread.
---@field startFrame? integer The index of the first frame to return; if omitted frames start at 0.
---@field levels? integer The maximum number of frames to return. If levels is not specified or 0, all frames are returned.
---@field format? dapui.types.StackFrameFormat Specifies details on how to format the stack frames.
---The attribute is only honored by a debug adapter if the corresponding capability `supportsValueFormattingOptions` is true.

---@class dapui.types.StackFrame
---@field id integer An identifier for the stack frame. It must be unique across all threads.
---This id can be used to retrieve the scopes of the frame with the `scopes` request or to restart the execution of a stackframe.
---@field name string The name of the stack frame, typically a method name.
---@field source? dapui.types.Source The source of the frame.
---@field line integer The line within the source of the frame. If the source attribute is missing or doesn't exist, `line` is 0 and should be ignored by the client.
---@field column integer Start position of the range covered by the stack frame. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based. If attribute `source` is missing or doesn't exist, `column` is 0 and should be ignored by the client.
---@field endLine? integer The end line of the range covered by the stack frame.
---@field endColumn? integer End position of the range covered by the stack frame. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field canRestart? boolean Indicates whether this frame can be restarted with the `restart` request. Clients should only use this if the debug adapter supports the `restart` request and the corresponding capability `supportsRestartRequest` is true.
---@field instructionPointerReference? string A memory reference for the current instruction pointer in this frame.
---@field moduleId? integer | string The module associated with this frame, if any.
---@field presentationHint? "normal" A hint for how to present this frame in the UI.
---A value of `label` can be used to indicate that the frame is an artificial frame that is used as a visual label or separator. A value of `subtle` can be used to change the appearance of a frame in a 'subtle' way.

---@class dapui.types.StackTraceResponse
---@field stackFrames dapui.types.StackFrame[] The frames of the stackframe. If the array has length zero, there are no stackframes available.
---This means that there is no location information available.
---@field totalFrames? integer The total number of frames available in the stack. If omitted or if `totalFrames` is larger than the available frames, a client is expected to request frames until a request returns less frames than requested (which indicates the end of the stack). Returning monotonically increasing `totalFrames` values for subsequent requests can be used to enforce paging in the client.

---@async
---@param args dapui.types.StackTraceArguments 
---@return dapui.types.StackTraceResponse
function DAPUIRequestsClient.stackTrace(args) end

---@class dapui.types.StartDebuggingRequestArguments
---@field configuration table<string,any> Arguments passed to the new debug session. The arguments must only contain properties understood by the `launch` or `attach` requests of the debug adapter and they must not contain any client-specific properties (e.g. `type`) or client-specific features (e.g. substitutable 'variables').
---@field request "launch" Indicates whether the new debug session should be started with a `launch` or `attach` request.

---@async
---@param args dapui.types.StartDebuggingRequestArguments 
function DAPUIRequestsClient.startDebugging(args) end

---@class dapui.types.StepBackArguments
---@field threadId integer Specifies the thread for which to resume execution for one step backwards (of the given granularity).
---@field singleThread? boolean If this flag is true, all other suspended threads are not resumed.
---@field granularity? "statement" Stepping granularity to step. If no granularity is specified, a granularity of `statement` is assumed.

---@async
---@param args dapui.types.StepBackArguments 
function DAPUIRequestsClient.stepBack(args) end

---@class dapui.types.StepInArguments
---@field threadId integer Specifies the thread for which to resume execution for one step-into (of the given granularity).
---@field singleThread? boolean If this flag is true, all other suspended threads are not resumed.
---@field targetId? integer Id of the target to step into.
---@field granularity? "statement" Stepping granularity. If no granularity is specified, a granularity of `statement` is assumed.

---@async
---@param args dapui.types.StepInArguments 
function DAPUIRequestsClient.stepIn(args) end

---@class dapui.types.StepInTargetsArguments
---@field frameId integer The stack frame for which to retrieve the possible step-in targets.

---@class dapui.types.StepInTarget
---@field id integer Unique identifier for a step-in target.
---@field label string The name of the step-in target (shown in the UI).
---@field line? integer The line of the step-in target.
---@field column? integer Start position of the range covered by the step in target. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field endLine? integer The end line of the range covered by the step-in target.
---@field endColumn? integer End position of the range covered by the step in target. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.

---@class dapui.types.StepInTargetsResponse
---@field targets dapui.types.StepInTarget[] The possible step-in targets of the specified source location.

---@async
---@param args dapui.types.StepInTargetsArguments 
---@return dapui.types.StepInTargetsResponse
function DAPUIRequestsClient.stepInTargets(args) end

---@class dapui.types.StepOutArguments
---@field threadId integer Specifies the thread for which to resume execution for one step-out (of the given granularity).
---@field singleThread? boolean If this flag is true, all other suspended threads are not resumed.
---@field granularity? "statement" Stepping granularity. If no granularity is specified, a granularity of `statement` is assumed.

---@async
---@param args dapui.types.StepOutArguments 
function DAPUIRequestsClient.stepOut(args) end

---@class dapui.types.TerminateArguments
---@field restart? boolean A value of true indicates that this `terminate` request is part of a restart sequence.

---@async
---@param args dapui.types.TerminateArguments 
function DAPUIRequestsClient.terminate(args) end

---@class dapui.types.TerminateThreadsArguments
---@field threadIds? integer[] Ids of threads to be terminated.

---@async
---@param args dapui.types.TerminateThreadsArguments 
function DAPUIRequestsClient.terminateThreads(args) end


---@class dapui.types.Thread
---@field id integer Unique identifier for the thread.
---@field name string The name of the thread.

---@class dapui.types.ThreadsResponse
---@field threads dapui.types.Thread[] All threads.

---@async
---@param args any[] | boolean | integer | number | table<string,any> | string Object containing arguments for the command.
---@return dapui.types.ThreadsResponse
function DAPUIRequestsClient.threads(args) end

---@class dapui.types.VariablesArguments
---@field variablesReference integer The Variable reference.
---@field filter? "indexed" Filter to limit the child variables to either named or indexed. If omitted, both types are fetched.
---@field start? integer The index of the first variable to return; if omitted children start at 0.
---@field count? integer The number of variables to return. If count is missing or 0, all variables are returned.
---@field format? dapui.types.ValueFormat Specifies details on how to format the Variable values.
---The attribute is only honored by a debug adapter if the corresponding capability `supportsValueFormattingOptions` is true.

---@class dapui.types.Variable
---@field name string The variable's name.
---@field value string The variable's value.
---This can be a multi-line text, e.g. for a function the body of a function.
---For structured variables (which do not have a simple value), it is recommended to provide a one-line representation of the structured object. This helps to identify the structured object in the collapsed state when its children are not yet visible.
---An empty string can be used if no value should be shown in the UI.
---@field type? string The type of the variable's value. Typically shown in the UI when hovering over the value.
---This attribute should only be returned by a debug adapter if the corresponding capability `supportsVariableType` is true.
---@field presentationHint? dapui.types.VariablePresentationHint Properties of a variable that can be used to determine how to render the variable in the UI.
---@field evaluateName? string The evaluatable name of this variable which can be passed to the `evaluate` request to fetch the variable's value.
---@field variablesReference integer If `variablesReference` is > 0, the variable is structured and its children can be retrieved by passing `variablesReference` to the `variables` request.
---@field namedVariables? integer The number of named child variables.
---The client can use this information to present the children in a paged UI and fetch them in chunks.
---@field indexedVariables? integer The number of indexed child variables.
---The client can use this information to present the children in a paged UI and fetch them in chunks.
---@field memoryReference? string The memory reference for the variable if the variable represents executable code, such as a function pointer.
---This attribute is only required if the corresponding capability `supportsMemoryReferences` is true.

---@class dapui.types.VariablesResponse
---@field variables dapui.types.Variable[] All (or a range) of variables for the given variable reference.

---@async
---@param args dapui.types.VariablesArguments 
---@return dapui.types.VariablesResponse
function DAPUIRequestsClient.variables(args) end

---@class dapui.types.WriteMemoryArguments
---@field memoryReference string Memory reference to the base location to which data should be written.
---@field offset? integer Offset (in bytes) to be applied to the reference location before writing data. Can be negative.
---@field allowPartial? boolean Property to control partial writes. If true, the debug adapter should attempt to write memory even if the entire memory region is not writable. In such a case the debug adapter should stop after hitting the first byte of memory that cannot be written and return the number of bytes written in the response via the `offset` and `bytesWritten` properties.
---If false or missing, a debug adapter should attempt to verify the region is writable before writing, and fail the response if it is not.
---@field data string Bytes to write, encoded using base64.

---@class dapui.types.WriteMemoryResponse
---@field offset? integer Property that should be returned when `allowPartial` is true to indicate the offset of the first byte of data successfully written. Can be negative.
---@field bytesWritten? integer Property that should be returned when `allowPartial` is true to indicate the number of bytes starting from address that were successfully written.

---@async
---@param args dapui.types.WriteMemoryArguments 
---@return dapui.types.WriteMemoryResponse
function DAPUIRequestsClient.writeMemory(args) end

---@class dapui.types.BreakpointEventArgs
---@field reason string The reason for the event.
---@field breakpoint dapui.types.Breakpoint The `id` attribute is used to find the target breakpoint, the other attributes are used as the new values.

---@param listener fun(args: dapui.types.BreakpointEventArgs)
function DAPUIEventListenerClient.breakpoint(listener) end

---@class dapui.types.Capabilities
---@field supportsConfigurationDoneRequest? boolean The debug adapter supports the `configurationDone` request.
---@field supportsFunctionBreakpoints? boolean The debug adapter supports function breakpoints.
---@field supportsConditionalBreakpoints? boolean The debug adapter supports conditional breakpoints.
---@field supportsHitConditionalBreakpoints? boolean The debug adapter supports breakpoints that break execution after a specified number of hits.
---@field supportsEvaluateForHovers? boolean The debug adapter supports a (side effect free) `evaluate` request for data hovers.
---@field exceptionBreakpointFilters? dapui.types.ExceptionBreakpointsFilter[] Available exception filter options for the `setExceptionBreakpoints` request.
---@field supportsStepBack? boolean The debug adapter supports stepping back via the `stepBack` and `reverseContinue` requests.
---@field supportsSetVariable? boolean The debug adapter supports setting a variable to a value.
---@field supportsRestartFrame? boolean The debug adapter supports restarting a frame.
---@field supportsGotoTargetsRequest? boolean The debug adapter supports the `gotoTargets` request.
---@field supportsStepInTargetsRequest? boolean The debug adapter supports the `stepInTargets` request.
---@field supportsCompletionsRequest? boolean The debug adapter supports the `completions` request.
---@field completionTriggerCharacters? string[] The set of characters that should trigger completion in a REPL. If not specified, the UI should assume the `.` character.
---@field supportsModulesRequest? boolean The debug adapter supports the `modules` request.
---@field additionalModuleColumns? dapui.types.ColumnDescriptor[] The set of additional module information exposed by the debug adapter.
---@field supportedChecksumAlgorithms? "MD5"[] Checksum algorithms supported by the debug adapter.
---@field supportsRestartRequest? boolean The debug adapter supports the `restart` request. In this case a client should not implement `restart` by terminating and relaunching the adapter but by calling the `restart` request.
---@field supportsExceptionOptions? boolean The debug adapter supports `exceptionOptions` on the `setExceptionBreakpoints` request.
---@field supportsValueFormattingOptions? boolean The debug adapter supports a `format` attribute on the `stackTrace`, `variables`, and `evaluate` requests.
---@field supportsExceptionInfoRequest? boolean The debug adapter supports the `exceptionInfo` request.
---@field supportTerminateDebuggee? boolean The debug adapter supports the `terminateDebuggee` attribute on the `disconnect` request.
---@field supportSuspendDebuggee? boolean The debug adapter supports the `suspendDebuggee` attribute on the `disconnect` request.
---@field supportsDelayedStackTraceLoading? boolean The debug adapter supports the delayed loading of parts of the stack, which requires that both the `startFrame` and `levels` arguments and the `totalFrames` result of the `stackTrace` request are supported.
---@field supportsLoadedSourcesRequest? boolean The debug adapter supports the `loadedSources` request.
---@field supportsLogPoints? boolean The debug adapter supports log points by interpreting the `logMessage` attribute of the `SourceBreakpoint`.
---@field supportsTerminateThreadsRequest? boolean The debug adapter supports the `terminateThreads` request.
---@field supportsSetExpression? boolean The debug adapter supports the `setExpression` request.
---@field supportsTerminateRequest? boolean The debug adapter supports the `terminate` request.
---@field supportsDataBreakpoints? boolean The debug adapter supports data breakpoints.
---@field supportsReadMemoryRequest? boolean The debug adapter supports the `readMemory` request.
---@field supportsWriteMemoryRequest? boolean The debug adapter supports the `writeMemory` request.
---@field supportsDisassembleRequest? boolean The debug adapter supports the `disassemble` request.
---@field supportsCancelRequest? boolean The debug adapter supports the `cancel` request.
---@field supportsBreakpointLocationsRequest? boolean The debug adapter supports the `breakpointLocations` request.
---@field supportsClipboardContext? boolean The debug adapter supports the `clipboard` context value in the `evaluate` request.
---@field supportsSteppingGranularity? boolean The debug adapter supports stepping granularities (argument `granularity`) for the stepping requests.
---@field supportsInstructionBreakpoints? boolean The debug adapter supports adding breakpoints based on instruction references.
---@field supportsExceptionFilterOptions? boolean The debug adapter supports `filterOptions` as an argument on the `setExceptionBreakpoints` request.
---@field supportsSingleThreadExecutionRequests? boolean The debug adapter supports the `singleThread` property on the execution requests (`continue`, `next`, `stepIn`, `stepOut`, `reverseContinue`, `stepBack`).

---@class dapui.types.CapabilitiesEventArgs
---@field capabilities dapui.types.Capabilities The set of updated capabilities.

---@param listener fun(args: dapui.types.CapabilitiesEventArgs)
function DAPUIEventListenerClient.capabilities(listener) end

---@class dapui.types.ContinuedEventArgs
---@field threadId integer The thread which was continued.
---@field allThreadsContinued? boolean If `allThreadsContinued` is true, a debug adapter can announce that all threads have continued.

---@param listener fun(args: dapui.types.ContinuedEventArgs)
function DAPUIEventListenerClient.continued(listener) end

---@class dapui.types.ExitedEventArgs
---@field exitCode integer The exit code returned from the debuggee.

---@param listener fun(args: dapui.types.ExitedEventArgs)
function DAPUIEventListenerClient.exited(listener) end


---@param listener fun()
function DAPUIEventListenerClient.initialized(listener) end

---@class dapui.types.InvalidatedAreas
---@field __root__ string Logical areas that can be invalidated by the `invalidated` event.

---@class dapui.types.InvalidatedEventArgs
---@field areas? dapui.types.InvalidatedAreas[] Set of logical areas that got invalidated. This property has a hint characteristic: a client can only be expected to make a 'best effort' in honoring the areas but there are no guarantees. If this property is missing, empty, or if values are not understood, the client should assume a single value `all`.
---@field threadId? integer If specified, the client only needs to refetch data related to this thread.
---@field stackFrameId? integer If specified, the client only needs to refetch data related to this stack frame (and the `threadId` is ignored).

---@param listener fun(args: dapui.types.InvalidatedEventArgs)
function DAPUIEventListenerClient.invalidated(listener) end

---@class dapui.types.LoadedSourceEventArgs
---@field reason "new" The reason for the event.
---@field source dapui.types.Source The new, changed, or removed source.

---@param listener fun(args: dapui.types.LoadedSourceEventArgs)
function DAPUIEventListenerClient.loadedSource(listener) end

---@class dapui.types.MemoryEventArgs
---@field memoryReference string Memory reference of a memory range that has been updated.
---@field offset integer Starting offset in bytes where memory has been updated. Can be negative.
---@field count integer Number of bytes updated.

---@param listener fun(args: dapui.types.MemoryEventArgs)
function DAPUIEventListenerClient.memory(listener) end

---@class dapui.types.ModuleEventArgs
---@field reason "new" The reason for the event.
---@field module dapui.types.Module The new, changed, or removed module. In case of `removed` only the module id is used.

---@param listener fun(args: dapui.types.ModuleEventArgs)
function DAPUIEventListenerClient.module(listener) end

---@class dapui.types.OutputEventArgs
---@field category? string The output category. If not specified or if the category is not understood by the client, `console` is assumed.
---@field output string The output to report.
---@field group? "start" Support for keeping an output log organized by grouping related messages.
---@field variablesReference? integer If an attribute `variablesReference` exists and its value is > 0, the output contains objects which can be retrieved by passing `variablesReference` to the `variables` request. The value should be less than or equal to 2147483647 (2^31-1).
---@field source? dapui.types.Source The source location where the output was produced.
---@field line? integer The source location's line where the output was produced.
---@field column? integer The position in `line` where the output was produced. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field data? any[] | boolean | integer | number | table<string,any> | string Additional data to report. For the `telemetry` category the data is sent to telemetry, for the other categories the data is shown in JSON format.

---@param listener fun(args: dapui.types.OutputEventArgs)
function DAPUIEventListenerClient.output(listener) end

---@class dapui.types.ProcessEventArgs
---@field name string The logical name of the process. This is usually the full path to process's executable file. Example: /home/example/myproj/program.js.
---@field systemProcessId? integer The system process id of the debugged process. This property is missing for non-system processes.
---@field isLocalProcess? boolean If true, the process is running on the same computer as the debug adapter.
---@field startMethod? "launch" Describes how the debug engine started debugging this process.
---@field pointerSize? integer The size of a pointer or address for this process, in bits. This value may be used by clients when formatting addresses for display.

---@param listener fun(args: dapui.types.ProcessEventArgs)
function DAPUIEventListenerClient.process(listener) end

---@class dapui.types.ProgressEndEventArgs
---@field progressId string The ID that was introduced in the initial `ProgressStartEvent`.
---@field message? string More detailed progress message. If omitted, the previous message (if any) is used.

---@param listener fun(args: dapui.types.ProgressEndEventArgs)
function DAPUIEventListenerClient.progressEnd(listener) end

---@class dapui.types.ProgressStartEventArgs
---@field progressId string An ID that can be used in subsequent `progressUpdate` and `progressEnd` events to make them refer to the same progress reporting.
---IDs must be unique within a debug session.
---@field title string Short title of the progress reporting. Shown in the UI to describe the long running operation.
---@field requestId? integer The request ID that this progress report is related to. If specified a debug adapter is expected to emit progress events for the long running request until the request has been either completed or cancelled.
---If the request ID is omitted, the progress report is assumed to be related to some general activity of the debug adapter.
---@field cancellable? boolean If true, the request that reports progress may be cancelled with a `cancel` request.
---So this property basically controls whether the client should use UX that supports cancellation.
---Clients that don't support cancellation are allowed to ignore the setting.
---@field message? string More detailed progress message.
---@field percentage? number Progress percentage to display (value range: 0 to 100). If omitted no percentage is shown.

---@param listener fun(args: dapui.types.ProgressStartEventArgs)
function DAPUIEventListenerClient.progressStart(listener) end

---@class dapui.types.ProgressUpdateEventArgs
---@field progressId string The ID that was introduced in the initial `progressStart` event.
---@field message? string More detailed progress message. If omitted, the previous message (if any) is used.
---@field percentage? number Progress percentage to display (value range: 0 to 100). If omitted no percentage is shown.

---@param listener fun(args: dapui.types.ProgressUpdateEventArgs)
function DAPUIEventListenerClient.progressUpdate(listener) end

---@class dapui.types.StoppedEventArgs
---@field reason string The reason for the event.
---For backward compatibility this string is shown in the UI if the `description` attribute is missing (but it must not be translated).
---@field description? string The full reason for the event, e.g. 'Paused on exception'. This string is shown in the UI as is and can be translated.
---@field threadId? integer The thread which was stopped.
---@field preserveFocusHint? boolean A value of true hints to the client that this event should not change the focus.
---@field text? string Additional information. E.g. if reason is `exception`, text contains the exception name. This string is shown in the UI.
---@field allThreadsStopped? boolean If `allThreadsStopped` is true, a debug adapter can announce that all threads have stopped.
---- The client should use this information to enable that all threads can be expanded to access their stacktraces.
---- If the attribute is missing or false, only the thread with the given `threadId` can be expanded.
---@field hitBreakpointIds? integer[] Ids of the breakpoints that triggered the event. In most cases there is only a single breakpoint but here are some examples for multiple breakpoints:
---- Different types of breakpoints map to the same location.
---- Multiple source breakpoints get collapsed to the same instruction by the compiler/runtime.
---- Multiple function breakpoints with different function names map to the same location.

---@param listener fun(args: dapui.types.StoppedEventArgs)
function DAPUIEventListenerClient.stopped(listener) end

---@class dapui.types.TerminatedEventArgs
---@field restart? any[] | boolean | integer | number | table<string,any> | string A debug adapter may set `restart` to true (or to an arbitrary object) to request that the client restarts the session.
---The value is not interpreted by the client and passed unmodified as an attribute `__restart` to the `launch` and `attach` requests.

---@param listener fun(args: dapui.types.TerminatedEventArgs)
function DAPUIEventListenerClient.terminated(listener) end

---@class dapui.types.ThreadEventArgs
---@field reason string The reason for the event.
---@field threadId integer The identifier of the thread.

---@param listener fun(args: dapui.types.ThreadEventArgs)
function DAPUIEventListenerClient.thread(listener) end


