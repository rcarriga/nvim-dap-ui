--- Generated on 2023-05-13 08:57:30.479445

---@class dapui.DAPRequestsClient
local DAPUIRequestsClient = {}

---@class dapui.DAPEventListenerClient
local DAPUIEventListenerClient = {}

---@class dapui.client.ListenerOpts
---@field before boolean Run before event/request is processed by nvim-dap
--- Arguments for `attach` request. Additional attributes are implementation specific.
---@class dapui.types.AttachRequestArguments
---@field field__restart? any[] | boolean | integer | number | table<string,any> | string Arbitrary data from the previous, restarted session. The data is sent as the `restart` attribute of the `terminated` event. The client should leave the data intact.

--- The `attach` request is sent from the client to the debug adapter to attach to a debuggee that is already running.
--- Since attaching is debugger/runtime specific, the arguments for this request are not part of this specification.
---@async
---@param args dapui.types.AttachRequestArguments
function DAPUIRequestsClient.attach(args) end

---@class dapui.types.attachRequestListenerArgs
---@field request dapui.types.AttachRequestArguments
---@field error? table

---@param listener fun(args: dapui.types.attachRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.attach(listener, opts) end

--- The checksum of an item calculated by the specified algorithm.
---@class dapui.types.Checksum
---@field algorithm "MD5"|"SHA1"|"SHA256"|"timestamp" The algorithm used to calculate this checksum.
---@field checksum string Value of the checksum, encoded as a hexadecimal value.

--- A `Source` is a descriptor for source code.
--- It is returned from the debug adapter as part of a `StackFrame` and it is used by clients when specifying breakpoints.
---@class dapui.types.Source
---@field name? string The short name of the source. Every source returned from the debug adapter has a name. When sending a source to the debug adapter this name is optional.
---@field path? string The path of the source to be shown in the UI. It is only used to locate and load the content of the source if no `sourceReference` is specified (or its value is 0).
---@field sourceReference? integer If the value > 0 the contents of the source must be retrieved through the `source` request (even if a path is specified). Since a `sourceReference` is only valid for a session, it can not be used to persist a source. The value should be less than or equal to 2147483647 (2^31-1).
---@field presentationHint? "normal"|"emphasize"|"deemphasize" A hint for how to present the source in the UI. A value of `deemphasize` can be used to indicate that the source is not available or that it is skipped on stepping.
---@field origin? string The origin of this source. For example, 'internal module', 'inlined content from source map', etc.
---@field sources? dapui.types.Source[] A list of sources that are related to this source. These may be the source that generated this source.
---@field adapterData? any[] | boolean | integer | number | table<string,any> | string Additional data that a debug adapter might want to loop through the client. The client should leave the data intact and persist it across sessions. The client should not interpret the data.
---@field checksums? dapui.types.Checksum[] The checksums associated with this file.

--- Arguments for `breakpointLocations` request.
---@class dapui.types.BreakpointLocationsArguments
---@field source dapui.types.Source The source location of the breakpoints; either `source.path` or `source.reference` must be specified.
---@field line integer Start line of range to search possible breakpoint locations in. If only the line is specified, the request returns all possible locations in that line.
---@field column? integer Start position within `line` to search possible breakpoint locations in. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based. If no column is given, the first position in the start line is assumed.
---@field endLine? integer End line of range to search possible breakpoint locations in. If no end line is given, then the end line is assumed to be the start line.
---@field endColumn? integer End position within `endLine` to search possible breakpoint locations in. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based. If no end column is given, the last position in the end line is assumed.

--- Properties of a breakpoint location returned from the `breakpointLocations` request.
---@class dapui.types.BreakpointLocation
---@field line integer Start line of breakpoint location.
---@field column? integer The start position of a breakpoint location. Position is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field endLine? integer The end line of breakpoint location if the location covers a range.
---@field endColumn? integer The end position of a breakpoint location (if the location covers a range). Position is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.

---@class dapui.types.BreakpointLocationsResponse
---@field breakpoints dapui.types.BreakpointLocation[] Sorted set of possible breakpoint locations.

--- The `breakpointLocations` request returns all possible locations for source breakpoints in a given range.
--- Clients should only call this request if the corresponding capability `supportsBreakpointLocationsRequest` is true.
---@async
---@param args dapui.types.BreakpointLocationsArguments
---@return dapui.types.BreakpointLocationsResponse
function DAPUIRequestsClient.breakpointLocations(args) end

---@class dapui.types.breakpointLocationsRequestListenerArgs
---@field request dapui.types.BreakpointLocationsArguments
---@field error? table
---@field response dapui.types.BreakpointLocationsResponse

---@param listener fun(args: dapui.types.breakpointLocationsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.breakpointLocations(listener, opts) end

--- Arguments for `cancel` request.
---@class dapui.types.CancelArguments
---@field requestId? integer The ID (attribute `seq`) of the request to cancel. If missing no request is cancelled. Both a `requestId` and a `progressId` can be specified in one request.
---@field progressId? string The ID (attribute `progressId`) of the progress to cancel. If missing no progress is cancelled. Both a `requestId` and a `progressId` can be specified in one request.

--- The `cancel` request is used by the client in two situations:
--- - to indicate that it is no longer interested in the result produced by a specific request issued earlier
--- - to cancel a progress sequence. Clients should only call this request if the corresponding capability `supportsCancelRequest` is true.
--- This request has a hint characteristic: a debug adapter can only be expected to make a 'best effort' in honoring this request but there are no guarantees.
--- The `cancel` request may return an error if it could not cancel an operation but a client should refrain from presenting this error to end users.
--- The request that got cancelled still needs to send a response back. This can either be a normal result (`success` attribute true) or an error response (`success` attribute false and the `message` set to `cancelled`).
--- Returning partial results from a cancelled request is possible but please note that a client has no generic way for detecting that a response is partial or not.
--- The progress that got cancelled still needs to send a `progressEnd` event back.
--- A client should not assume that progress just got cancelled after sending the `cancel` request.
---@async
---@param args dapui.types.CancelArguments
function DAPUIRequestsClient.cancel(args) end

---@class dapui.types.cancelRequestListenerArgs
---@field request dapui.types.CancelArguments
---@field error? table

---@param listener fun(args: dapui.types.cancelRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.cancel(listener, opts) end

--- Arguments for `completions` request.
---@class dapui.types.CompletionsArguments
---@field frameId? integer Returns completions in the scope of this stack frame. If not specified, the completions are returned for the global scope.
---@field text string One or more source lines. Typically this is the text users have typed into the debug console before they asked for completion.
---@field column integer The position within `text` for which to determine the completion proposals. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field line? integer A line for which to determine the completion proposals. If missing the first line of the text is assumed.

--- `CompletionItems` are the suggestions returned from the `completions` request.
---@class dapui.types.CompletionItem
---@field label string The label of this completion item. By default this is also the text that is inserted when selecting this completion.
---@field text? string If text is returned and not an empty string, then it is inserted instead of the label.
---@field sortText? string A string that should be used when comparing this item with other items. If not returned or an empty string, the `label` is used instead.
---@field detail? string A human-readable string with additional information about this item, like type or symbol information.
---@field type? "method"|"function"|"constructor"|"field"|"variable"|"class"|"interface"|"module"|"property"|"unit"|"value"|"enum"|"keyword"|"snippet"|"text"|"color"|"file"|"reference"|"customcolor" The item's type. Typically the client uses this information to render the item in the UI with an icon.
---@field start? integer Start position (within the `text` attribute of the `completions` request) where the completion text is added. The position is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based. If the start position is omitted the text is added at the location specified by the `column` attribute of the `completions` request.
---@field length? integer Length determines how many characters are overwritten by the completion text and it is measured in UTF-16 code units. If missing the value 0 is assumed which results in the completion text being inserted.
---@field selectionStart? integer Determines the start of the new selection after the text has been inserted (or replaced). `selectionStart` is measured in UTF-16 code units and must be in the range 0 and length of the completion text. If omitted the selection starts at the end of the completion text.
---@field selectionLength? integer Determines the length of the new selection after the text has been inserted (or replaced) and it is measured in UTF-16 code units. The selection can not extend beyond the bounds of the completion text. If omitted the length is assumed to be 0.

---@class dapui.types.CompletionsResponse
---@field targets dapui.types.CompletionItem[] The possible completions for .

--- Returns a list of possible completions for a given caret position and text.
--- Clients should only call this request if the corresponding capability `supportsCompletionsRequest` is true.
---@async
---@param args dapui.types.CompletionsArguments
---@return dapui.types.CompletionsResponse
function DAPUIRequestsClient.completions(args) end

---@class dapui.types.completionsRequestListenerArgs
---@field request dapui.types.CompletionsArguments
---@field error? table
---@field response dapui.types.CompletionsResponse

---@param listener fun(args: dapui.types.completionsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.completions(listener, opts) end

--- Arguments for `configurationDone` request.
---@class dapui.types.ConfigurationDoneArguments

--- This request indicates that the client has finished initialization of the debug adapter.
--- So it is the last request in the sequence of configuration requests (which was started by the `initialized` event).
--- Clients should only call this request if the corresponding capability `supportsConfigurationDoneRequest` is true.
---@async
---@param args dapui.types.ConfigurationDoneArguments
function DAPUIRequestsClient.configurationDone(args) end

---@class dapui.types.configurationDoneRequestListenerArgs
---@field request dapui.types.ConfigurationDoneArguments
---@field error? table

---@param listener fun(args: dapui.types.configurationDoneRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.configurationDone(listener, opts) end

--- Arguments for `continue` request.
---@class dapui.types.ContinueArguments
---@field threadId integer Specifies the active thread. If the debug adapter supports single thread execution (see `supportsSingleThreadExecutionRequests`) and the argument `singleThread` is true, only the thread with this ID is resumed.
---@field singleThread? boolean If this flag is true, execution is resumed only for the thread with given `threadId`.

---@class dapui.types.ContinueResponse
---@field allThreadsContinued? boolean The value true (or a missing property) signals to the client that all threads have been resumed. The value false indicates that not all threads were resumed.

--- The request resumes execution of all threads. If the debug adapter supports single thread execution (see capability `supportsSingleThreadExecutionRequests`), setting the `singleThread` argument to true resumes only the specified thread. If not all threads were resumed, the `allThreadsContinued` attribute of the response should be set to false.
---@async
---@param args dapui.types.ContinueArguments
---@return dapui.types.ContinueResponse
function DAPUIRequestsClient.continue_(args) end

---@class dapui.types.continue_RequestListenerArgs
---@field request dapui.types.ContinueArguments
---@field error? table
---@field response dapui.types.ContinueResponse

---@param listener fun(args: dapui.types.continue_RequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.continue_(listener, opts) end

--- Arguments for `dataBreakpointInfo` request.
---@class dapui.types.DataBreakpointInfoArguments
---@field variablesReference? integer Reference to the variable container if the data breakpoint is requested for a child of the container. The `variablesReference` must have been obtained in the current suspended state. See 'Lifetime of Object References' in the Overview section for details.
---@field name string The name of the variable's child to obtain data breakpoint information for. If `variablesReference` isn't specified, this can be an expression.
---@field frameId? integer When `name` is an expression, evaluate it in the scope of this stack frame. If not specified, the expression is evaluated in the global scope. When `variablesReference` is specified, this property has no effect.

---@class dapui.types.DataBreakpointInfoResponse
---@field dataId string An identifier for the data on which a data breakpoint can be registered with the `setDataBreakpoints` request or null if no data breakpoint is available.
---@field description string UI string that describes on what data the breakpoint is set on or why a data breakpoint is not available.
---@field accessTypes? "read"|"write"|"readWrite"[] Attribute lists the available access types for a potential data breakpoint. A UI client could surface this information.
---@field canPersist? boolean Attribute indicates that a potential data breakpoint could be persisted across sessions.

--- Obtains information on a possible data breakpoint that could be set on an expression or variable.
--- Clients should only call this request if the corresponding capability `supportsDataBreakpoints` is true.
---@async
---@param args dapui.types.DataBreakpointInfoArguments
---@return dapui.types.DataBreakpointInfoResponse
function DAPUIRequestsClient.dataBreakpointInfo(args) end

---@class dapui.types.dataBreakpointInfoRequestListenerArgs
---@field request dapui.types.DataBreakpointInfoArguments
---@field error? table
---@field response dapui.types.DataBreakpointInfoResponse

---@param listener fun(args: dapui.types.dataBreakpointInfoRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.dataBreakpointInfo(listener, opts) end

--- Arguments for `disassemble` request.
---@class dapui.types.DisassembleArguments
---@field memoryReference string Memory reference to the base location containing the instructions to disassemble.
---@field offset? integer Offset (in bytes) to be applied to the reference location before disassembling. Can be negative.
---@field instructionOffset? integer Offset (in instructions) to be applied after the byte offset (if any) before disassembling. Can be negative.
---@field instructionCount integer Number of instructions to disassemble starting at the specified location and offset. An adapter must return exactly this number of instructions - any unavailable instructions should be replaced with an implementation-defined 'invalid instruction' value.
---@field resolveSymbols? boolean If true, the adapter should attempt to resolve memory addresses and other values to symbolic names.

--- Represents a single disassembled instruction.
---@class dapui.types.DisassembledInstruction
---@field address string The address of the instruction. Treated as a hex value if prefixed with `0x`, or as a decimal value otherwise.
---@field instructionBytes? string Raw bytes representing the instruction and its operands, in an implementation-defined format.
---@field instruction string Text representing the instruction and its operands, in an implementation-defined format.
---@field symbol? string Name of the symbol that corresponds with the location of this instruction, if any.
---@field location? dapui.types.Source Source location that corresponds to this instruction, if any. Should always be set (if available) on the first instruction returned, but can be omitted afterwards if this instruction maps to the same source file as the previous instruction.
---@field line? integer The line within the source location that corresponds to this instruction, if any.
---@field column? integer The column within the line that corresponds to this instruction, if any.
---@field endLine? integer The end line of the range that corresponds to this instruction, if any.
---@field endColumn? integer The end column of the range that corresponds to this instruction, if any.

---@class dapui.types.DisassembleResponse
---@field instructions dapui.types.DisassembledInstruction[] The list of disassembled instructions.

--- Disassembles code stored at the provided location.
--- Clients should only call this request if the corresponding capability `supportsDisassembleRequest` is true.
---@async
---@param args dapui.types.DisassembleArguments
---@return dapui.types.DisassembleResponse
function DAPUIRequestsClient.disassemble(args) end

---@class dapui.types.disassembleRequestListenerArgs
---@field request dapui.types.DisassembleArguments
---@field error? table
---@field response dapui.types.DisassembleResponse

---@param listener fun(args: dapui.types.disassembleRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.disassemble(listener, opts) end

--- Arguments for `disconnect` request.
---@class dapui.types.DisconnectArguments
---@field restart? boolean A value of true indicates that this `disconnect` request is part of a restart sequence.
---@field terminateDebuggee? boolean Indicates whether the debuggee should be terminated when the debugger is disconnected. If unspecified, the debug adapter is free to do whatever it thinks is best. The attribute is only honored by a debug adapter if the corresponding capability `supportTerminateDebuggee` is true.
---@field suspendDebuggee? boolean Indicates whether the debuggee should stay suspended when the debugger is disconnected. If unspecified, the debuggee should resume execution. The attribute is only honored by a debug adapter if the corresponding capability `supportSuspendDebuggee` is true.

--- The `disconnect` request asks the debug adapter to disconnect from the debuggee (thus ending the debug session) and then to shut down itself (the debug adapter).
--- In addition, the debug adapter must terminate the debuggee if it was started with the `launch` request. If an `attach` request was used to connect to the debuggee, then the debug adapter must not terminate the debuggee.
--- This implicit behavior of when to terminate the debuggee can be overridden with the `terminateDebuggee` argument (which is only supported by a debug adapter if the corresponding capability `supportTerminateDebuggee` is true).
---@async
---@param args dapui.types.DisconnectArguments
function DAPUIRequestsClient.disconnect(args) end

---@class dapui.types.disconnectRequestListenerArgs
---@field request dapui.types.DisconnectArguments
---@field error? table

---@param listener fun(args: dapui.types.disconnectRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.disconnect(listener, opts) end

--- Provides formatting information for a value.
---@class dapui.types.ValueFormat
---@field hex? boolean Display the value in hex.

--- Arguments for `evaluate` request.
---@class dapui.types.EvaluateArguments
---@field expression string The expression to evaluate.
---@field frameId? integer Evaluate the expression in the scope of this stack frame. If not specified, the expression is evaluated in the global scope.
---@field context? string The context in which the evaluate request is used.
---@field format? dapui.types.ValueFormat Specifies details on how to format the result. The attribute is only honored by a debug adapter if the corresponding capability `supportsValueFormattingOptions` is true.

--- Properties of a variable that can be used to determine how to render the variable in the UI.
---@class dapui.types.VariablePresentationHint
---@field kind? string The kind of variable. Before introducing additional values, try to use the listed values.
---@field attributes? string[] Set of attributes represented as an array of strings. Before introducing additional values, try to use the listed values.
---@field visibility? string Visibility of variable. Before introducing additional values, try to use the listed values.
---@field lazy? boolean If true, clients can present the variable with a UI that supports a specific gesture to trigger its evaluation. This mechanism can be used for properties that require executing code when retrieving their value and where the code execution can be expensive and/or produce side-effects. A typical example are properties based on a getter function. Please note that in addition to the `lazy` flag, the variable's `variablesReference` is expected to refer to a variable that will provide the value through another `variable` request.

---@class dapui.types.EvaluateResponse
---@field result string The result of the evaluate request.
---@field type? string The type of the evaluate result. This attribute should only be returned by a debug adapter if the corresponding capability `supportsVariableType` is true.
---@field presentationHint? dapui.types.VariablePresentationHint Properties of an evaluate result that can be used to determine how to render the result in the UI.
---@field variablesReference integer If `variablesReference` is > 0, the evaluate result is structured and its children can be retrieved by passing `variablesReference` to the `variables` request as long as execution remains suspended. See 'Lifetime of Object References' in the Overview section for details.
---@field namedVariables? integer The number of named child variables. The client can use this information to present the variables in a paged UI and fetch them in chunks. The value should be less than or equal to 2147483647 (2^31-1).
---@field indexedVariables? integer The number of indexed child variables. The client can use this information to present the variables in a paged UI and fetch them in chunks. The value should be less than or equal to 2147483647 (2^31-1).
---@field memoryReference? string A memory reference to a location appropriate for this result. For pointer type eval results, this is generally a reference to the memory address contained in the pointer. This attribute should be returned by a debug adapter if corresponding capability `supportsMemoryReferences` is true.

--- Evaluates the given expression in the context of the topmost stack frame.
--- The expression has access to any variables and arguments that are in scope.
---@async
---@param args dapui.types.EvaluateArguments
---@return dapui.types.EvaluateResponse
function DAPUIRequestsClient.evaluate(args) end

---@class dapui.types.evaluateRequestListenerArgs
---@field request dapui.types.EvaluateArguments
---@field error? table
---@field response dapui.types.EvaluateResponse

---@param listener fun(args: dapui.types.evaluateRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.evaluate(listener, opts) end

--- Arguments for `exceptionInfo` request.
---@class dapui.types.ExceptionInfoArguments
---@field threadId integer Thread for which exception information should be retrieved.

--- Detailed information about an exception that has occurred.
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
---@field breakMode "never"|"always"|"unhandled"|"userUnhandled" Mode that caused the exception notification to be raised.
---@field details? dapui.types.ExceptionDetails Detailed information about the exception.

--- Retrieves the details of the exception that caused this event to be raised.
--- Clients should only call this request if the corresponding capability `supportsExceptionInfoRequest` is true.
---@async
---@param args dapui.types.ExceptionInfoArguments
---@return dapui.types.ExceptionInfoResponse
function DAPUIRequestsClient.exceptionInfo(args) end

---@class dapui.types.exceptionInfoRequestListenerArgs
---@field request dapui.types.ExceptionInfoArguments
---@field error? table
---@field response dapui.types.ExceptionInfoResponse

---@param listener fun(args: dapui.types.exceptionInfoRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.exceptionInfo(listener, opts) end

--- Arguments for `goto` request.
---@class dapui.types.GotoArguments
---@field threadId integer Set the goto target for this thread.
---@field targetId integer The location where the debuggee will continue to run.

--- The request sets the location where the debuggee will continue to run.
--- This makes it possible to skip the execution of code or to execute code again.
--- The code between the current location and the goto target is not executed but skipped.
--- The debug adapter first sends the response and then a `stopped` event with reason `goto`.
--- Clients should only call this request if the corresponding capability `supportsGotoTargetsRequest` is true (because only then goto targets exist that can be passed as arguments).
---@async
---@param args dapui.types.GotoArguments
function DAPUIRequestsClient.goto_(args) end

---@class dapui.types.gotoRequestListenerArgs
---@field request dapui.types.GotoArguments
---@field error? table

---@param listener fun(args: dapui.types.gotoRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.goto_(listener, opts) end

--- Arguments for `gotoTargets` request.
---@class dapui.types.GotoTargetsArguments
---@field source dapui.types.Source The source location for which the goto targets are determined.
---@field line integer The line location for which the goto targets are determined.
---@field column? integer The position within `line` for which the goto targets are determined. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.

--- A `GotoTarget` describes a code location that can be used as a target in the `goto` request.
--- The possible goto targets can be determined via the `gotoTargets` request.
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

--- This request retrieves the possible goto targets for the specified source location.
--- These targets can be used in the `goto` request.
--- Clients should only call this request if the corresponding capability `supportsGotoTargetsRequest` is true.
---@async
---@param args dapui.types.GotoTargetsArguments
---@return dapui.types.GotoTargetsResponse
function DAPUIRequestsClient.gotoTargets(args) end

---@class dapui.types.gotoTargetsRequestListenerArgs
---@field request dapui.types.GotoTargetsArguments
---@field error? table
---@field response dapui.types.GotoTargetsResponse

---@param listener fun(args: dapui.types.gotoTargetsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.gotoTargets(listener, opts) end

--- Arguments for `initialize` request.
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

--- An `ExceptionBreakpointsFilter` is shown in the UI as an filter option for configuring how exceptions are dealt with.
---@class dapui.types.ExceptionBreakpointsFilter
---@field filter string The internal ID of the filter option. This value is passed to the `setExceptionBreakpoints` request.
---@field label string The name of the filter option. This is shown in the UI.
---@field description? string A help text providing additional information about the exception filter. This string is typically shown as a hover and can be translated.
---@field default? boolean Initial value of the filter option. If not specified a value false is assumed.
---@field supportsCondition? boolean Controls whether a condition can be specified for this filter option. If false or missing, a condition can not be set.
---@field conditionDescription? string A help text providing information about the condition. This string is shown as the placeholder text for a text box and can be translated.

--- A `ColumnDescriptor` specifies what module attribute to show in a column of the modules view, how to format it,
--- and what the column's label should be.
--- It is only used if the underlying UI actually supports this level of customization.
---@class dapui.types.ColumnDescriptor
---@field attributeName string Name of the attribute rendered in this column.
---@field label string Header UI label of column.
---@field format? string Format to use for the rendered values in this column. TBD how the format strings looks like.
---@field type? "string"|"number"|"boolean"|"unixTimestampUTC" Datatype of values in this column. Defaults to `string` if not specified.
---@field width? integer Width of this column in characters (hint only).

--- Information about the capabilities of a debug adapter.
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
---@field supportedChecksumAlgorithms? "MD5"|"SHA1"|"SHA256"|"timestamp"[] Checksum algorithms supported by the debug adapter.
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

--- The `initialize` request is sent as the first request from the client to the debug adapter in order to configure it with client capabilities and to retrieve capabilities from the debug adapter.
--- Until the debug adapter has responded with an `initialize` response, the client must not send any additional requests or events to the debug adapter.
--- In addition the debug adapter is not allowed to send any requests or events to the client until it has responded with an `initialize` response.
--- The `initialize` request may only be sent once.
---@async
---@param args dapui.types.InitializeRequestArguments
---@return dapui.types.InitializeResponse
function DAPUIRequestsClient.initialize(args) end

---@class dapui.types.initializeRequestListenerArgs
---@field request dapui.types.InitializeRequestArguments
---@field error? table
---@field response dapui.types.InitializeResponse

---@param listener fun(args: dapui.types.initializeRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.initialize(listener, opts) end

--- Arguments for `launch` request. Additional attributes are implementation specific.
---@class dapui.types.LaunchRequestArguments
---@field noDebug? boolean If true, the launch request should launch the program without enabling debugging.
---@field field__restart? any[] | boolean | integer | number | table<string,any> | string Arbitrary data from the previous, restarted session. The data is sent as the `restart` attribute of the `terminated` event. The client should leave the data intact.

--- This launch request is sent from the client to the debug adapter to start the debuggee with or without debugging (if `noDebug` is true).
--- Since launching is debugger/runtime specific, the arguments for this request are not part of this specification.
---@async
---@param args dapui.types.LaunchRequestArguments
function DAPUIRequestsClient.launch(args) end

---@class dapui.types.launchRequestListenerArgs
---@field request dapui.types.LaunchRequestArguments
---@field error? table

---@param listener fun(args: dapui.types.launchRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.launch(listener, opts) end

--- Arguments for `loadedSources` request.
---@class dapui.types.LoadedSourcesArguments

---@class dapui.types.LoadedSourcesResponse
---@field sources dapui.types.Source[] Set of loaded sources.

--- Retrieves the set of all sources currently loaded by the debugged process.
--- Clients should only call this request if the corresponding capability `supportsLoadedSourcesRequest` is true.
---@async
---@param args dapui.types.LoadedSourcesArguments
---@return dapui.types.LoadedSourcesResponse
function DAPUIRequestsClient.loadedSources(args) end

---@class dapui.types.loadedSourcesRequestListenerArgs
---@field request dapui.types.LoadedSourcesArguments
---@field error? table
---@field response dapui.types.LoadedSourcesResponse

---@param listener fun(args: dapui.types.loadedSourcesRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.loadedSources(listener, opts) end

--- Arguments for `modules` request.
---@class dapui.types.ModulesArguments
---@field startModule? integer The index of the first module to return; if omitted modules start at 0.
---@field moduleCount? integer The number of modules to return. If `moduleCount` is not specified or 0, all modules are returned.

--- A Module object represents a row in the modules view.
--- The `id` attribute identifies a module in the modules view and is used in a `module` event for identifying a module for adding, updating or deleting.
--- The `name` attribute is used to minimally render the module in the UI.
---
--- Additional attributes can be added to the module. They show up in the module view if they have a corresponding `ColumnDescriptor`.
---
--- To avoid an unnecessary proliferation of additional attributes with similar semantics but different names, we recommend to re-use attributes from the 'recommended' list below first, and only introduce new attributes if nothing appropriate could be found.
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

--- Modules can be retrieved from the debug adapter with this request which can either return all modules or a range of modules to support paging.
--- Clients should only call this request if the corresponding capability `supportsModulesRequest` is true.
---@async
---@param args dapui.types.ModulesArguments
---@return dapui.types.ModulesResponse
function DAPUIRequestsClient.modules(args) end

---@class dapui.types.modulesRequestListenerArgs
---@field request dapui.types.ModulesArguments
---@field error? table
---@field response dapui.types.ModulesResponse

---@param listener fun(args: dapui.types.modulesRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.modules(listener, opts) end

--- Arguments for `next` request.
---@class dapui.types.NextArguments
---@field threadId integer Specifies the thread for which to resume execution for one step (of the given granularity).
---@field singleThread? boolean If this flag is true, all other suspended threads are not resumed.
---@field granularity? "statement"|"line"|"instruction" Stepping granularity. If no granularity is specified, a granularity of `statement` is assumed.

--- The request executes one step (in the given granularity) for the specified thread and allows all other threads to run freely by resuming them.
--- If the debug adapter supports single thread execution (see capability `supportsSingleThreadExecutionRequests`), setting the `singleThread` argument to true prevents other suspended threads from resuming.
--- The debug adapter first sends the response and then a `stopped` event (with reason `step`) after the step has completed.
---@async
---@param args dapui.types.NextArguments
function DAPUIRequestsClient.next(args) end

---@class dapui.types.nextRequestListenerArgs
---@field request dapui.types.NextArguments
---@field error? table

---@param listener fun(args: dapui.types.nextRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.next(listener, opts) end

--- Arguments for `pause` request.
---@class dapui.types.PauseArguments
---@field threadId integer Pause execution for this thread.

--- The request suspends the debuggee.
--- The debug adapter first sends the response and then a `stopped` event (with reason `pause`) after the thread has been paused successfully.
---@async
---@param args dapui.types.PauseArguments
function DAPUIRequestsClient.pause(args) end

---@class dapui.types.pauseRequestListenerArgs
---@field request dapui.types.PauseArguments
---@field error? table

---@param listener fun(args: dapui.types.pauseRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.pause(listener, opts) end

--- Arguments for `readMemory` request.
---@class dapui.types.ReadMemoryArguments
---@field memoryReference string Memory reference to the base location from which data should be read.
---@field offset? integer Offset (in bytes) to be applied to the reference location before reading data. Can be negative.
---@field count integer Number of bytes to read at the specified location and offset.

---@class dapui.types.ReadMemoryResponse
---@field address string The address of the first byte of data returned. Treated as a hex value if prefixed with `0x`, or as a decimal value otherwise.
---@field unreadableBytes? integer The number of unreadable bytes encountered after the last successfully read byte. This can be used to determine the number of bytes that should be skipped before a subsequent `readMemory` request succeeds.
---@field data? string The bytes read from memory, encoded using base64. If the decoded length of `data` is less than the requested `count` in the original `readMemory` request, and `unreadableBytes` is zero or omitted, then the client should assume it's reached the end of readable memory.

--- Reads bytes from memory at the provided location.
--- Clients should only call this request if the corresponding capability `supportsReadMemoryRequest` is true.
---@async
---@param args dapui.types.ReadMemoryArguments
---@return dapui.types.ReadMemoryResponse
function DAPUIRequestsClient.readMemory(args) end

---@class dapui.types.readMemoryRequestListenerArgs
---@field request dapui.types.ReadMemoryArguments
---@field error? table
---@field response dapui.types.ReadMemoryResponse

---@param listener fun(args: dapui.types.readMemoryRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.readMemory(listener, opts) end

--- Arguments for `restartFrame` request.
---@class dapui.types.RestartFrameArguments
---@field frameId integer Restart the stack frame identified by `frameId`. The `frameId` must have been obtained in the current suspended state. See 'Lifetime of Object References' in the Overview section for details.

--- The request restarts execution of the specified stack frame.
--- The debug adapter first sends the response and then a `stopped` event (with reason `restart`) after the restart has completed.
--- Clients should only call this request if the corresponding capability `supportsRestartFrame` is true.
---@async
---@param args dapui.types.RestartFrameArguments
function DAPUIRequestsClient.restartFrame(args) end

---@class dapui.types.restartFrameRequestListenerArgs
---@field request dapui.types.RestartFrameArguments
---@field error? table

---@param listener fun(args: dapui.types.restartFrameRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.restartFrame(listener, opts) end

--- Arguments for `restart` request.
---@class dapui.types.RestartArguments
---@field arguments? dapui.types.LaunchRequestArguments | dapui.types.AttachRequestArguments The latest version of the `launch` or `attach` configuration.

--- Restarts a debug session. Clients should only call this request if the corresponding capability `supportsRestartRequest` is true.
--- If the capability is missing or has the value false, a typical client emulates `restart` by terminating the debug adapter first and then launching it anew.
---@async
---@param args dapui.types.RestartArguments
function DAPUIRequestsClient.restart(args) end

---@class dapui.types.restartRequestListenerArgs
---@field request dapui.types.RestartArguments
---@field error? table

---@param listener fun(args: dapui.types.restartRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.restart(listener, opts) end

--- Arguments for `reverseContinue` request.
---@class dapui.types.ReverseContinueArguments
---@field threadId integer Specifies the active thread. If the debug adapter supports single thread execution (see `supportsSingleThreadExecutionRequests`) and the `singleThread` argument is true, only the thread with this ID is resumed.
---@field singleThread? boolean If this flag is true, backward execution is resumed only for the thread with given `threadId`.

--- The request resumes backward execution of all threads. If the debug adapter supports single thread execution (see capability `supportsSingleThreadExecutionRequests`), setting the `singleThread` argument to true resumes only the specified thread. If not all threads were resumed, the `allThreadsContinued` attribute of the response should be set to false.
--- Clients should only call this request if the corresponding capability `supportsStepBack` is true.
---@async
---@param args dapui.types.ReverseContinueArguments
function DAPUIRequestsClient.reverseContinue(args) end

---@class dapui.types.reverseContinueRequestListenerArgs
---@field request dapui.types.ReverseContinueArguments
---@field error? table

---@param listener fun(args: dapui.types.reverseContinueRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.reverseContinue(listener, opts) end

--- Arguments for `runInTerminal` request.
---@class dapui.types.RunInTerminalRequestArguments
---@field kind? "integrated"|"external" What kind of terminal to launch. Defaults to `integrated` if not specified.
---@field title? string Title of the terminal.
---@field cwd string Working directory for the command. For non-empty, valid paths this typically results in execution of a change directory command.
---@field args string[] List of arguments. The first argument is the command to run.
---@field env? table<string,string> Environment key-value pairs that are added to or removed from the default environment.
---@field argsCanBeInterpretedByShell? boolean This property should only be set if the corresponding capability `supportsArgsCanBeInterpretedByShell` is true. If the client uses an intermediary shell to launch the application, then the client must not attempt to escape characters with special meanings for the shell. The user is fully responsible for escaping as needed and that arguments using special characters may not be portable across shells.

---@class dapui.types.RunInTerminalResponse
---@field processId? integer The process ID. The value should be less than or equal to 2147483647 (2^31-1).
---@field shellProcessId? integer The process ID of the terminal shell. The value should be less than or equal to 2147483647 (2^31-1).

--- This request is sent from the debug adapter to the client to run a command in a terminal.
--- This is typically used to launch the debuggee in a terminal provided by the client.
--- This request should only be called if the corresponding client capability `supportsRunInTerminalRequest` is true.
--- Client implementations of `runInTerminal` are free to run the command however they choose including issuing the command to a command line interpreter (aka 'shell'). Argument strings passed to the `runInTerminal` request must arrive verbatim in the command to be run. As a consequence, clients which use a shell are responsible for escaping any special shell characters in the argument strings to prevent them from being interpreted (and modified) by the shell.
--- Some users may wish to take advantage of shell processing in the argument strings. For clients which implement `runInTerminal` using an intermediary shell, the `argsCanBeInterpretedByShell` property can be set to true. In this case the client is requested not to escape any special shell characters in the argument strings.
---@async
---@param args dapui.types.RunInTerminalRequestArguments
---@return dapui.types.RunInTerminalResponse
function DAPUIRequestsClient.runInTerminal(args) end

---@class dapui.types.runInTerminalRequestListenerArgs
---@field request dapui.types.RunInTerminalRequestArguments
---@field error? table
---@field response dapui.types.RunInTerminalResponse

---@param listener fun(args: dapui.types.runInTerminalRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.runInTerminal(listener, opts) end

--- Arguments for `scopes` request.
---@class dapui.types.ScopesArguments
---@field frameId integer Retrieve the scopes for the stack frame identified by `frameId`. The `frameId` must have been obtained in the current suspended state. See 'Lifetime of Object References' in the Overview section for details.

--- A `Scope` is a named container for variables. Optionally a scope can map to a source or a range within a source.
---@class dapui.types.Scope
---@field name string Name of the scope such as 'Arguments', 'Locals', or 'Registers'. This string is shown in the UI as is and can be translated.
---@field presentationHint? string A hint for how to present this scope in the UI. If this attribute is missing, the scope is shown with a generic UI.
---@field variablesReference integer The variables of this scope can be retrieved by passing the value of `variablesReference` to the `variables` request as long as execution remains suspended. See 'Lifetime of Object References' in the Overview section for details.
---@field namedVariables? integer The number of named variables in this scope. The client can use this information to present the variables in a paged UI and fetch them in chunks.
---@field indexedVariables? integer The number of indexed variables in this scope. The client can use this information to present the variables in a paged UI and fetch them in chunks.
---@field expensive boolean If true, the number of variables in this scope is large or expensive to retrieve.
---@field source? dapui.types.Source The source for this scope.
---@field line? integer The start line of the range covered by this scope.
---@field column? integer Start position of the range covered by the scope. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field endLine? integer The end line of the range covered by this scope.
---@field endColumn? integer End position of the range covered by the scope. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.

---@class dapui.types.ScopesResponse
---@field scopes dapui.types.Scope[] The scopes of the stack frame. If the array has length zero, there are no scopes available.

--- The request returns the variable scopes for a given stack frame ID.
---@async
---@param args dapui.types.ScopesArguments
---@return dapui.types.ScopesResponse
function DAPUIRequestsClient.scopes(args) end

---@class dapui.types.scopesRequestListenerArgs
---@field request dapui.types.ScopesArguments
---@field error? table
---@field response dapui.types.ScopesResponse

---@param listener fun(args: dapui.types.scopesRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.scopes(listener, opts) end

--- Properties of a breakpoint or logpoint passed to the `setBreakpoints` request.
---@class dapui.types.SourceBreakpoint
---@field line integer The source line of the breakpoint or logpoint.
---@field column? integer Start position within source line of the breakpoint or logpoint. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field condition? string The expression for conditional breakpoints. It is only honored by a debug adapter if the corresponding capability `supportsConditionalBreakpoints` is true.
---@field hitCondition? string The expression that controls how many hits of the breakpoint are ignored. The debug adapter is expected to interpret the expression as needed. The attribute is only honored by a debug adapter if the corresponding capability `supportsHitConditionalBreakpoints` is true. If both this property and `condition` are specified, `hitCondition` should be evaluated only if the `condition` is met, and the debug adapter should stop only if both conditions are met.
---@field logMessage? string If this attribute exists and is non-empty, the debug adapter must not 'break' (stop) but log the message instead. Expressions within `{}` are interpolated. The attribute is only honored by a debug adapter if the corresponding capability `supportsLogPoints` is true. If either `hitCondition` or `condition` is specified, then the message should only be logged if those conditions are met.

--- Arguments for `setBreakpoints` request.
---@class dapui.types.SetBreakpointsArguments
---@field source dapui.types.Source The source location of the breakpoints; either `source.path` or `source.sourceReference` must be specified.
---@field breakpoints? dapui.types.SourceBreakpoint[] The code locations of the breakpoints.
---@field lines? integer[] Deprecated: The code locations of the breakpoints.
---@field sourceModified? boolean A value of true indicates that the underlying source has been modified which results in new breakpoint locations.

--- Information about a breakpoint created in `setBreakpoints`, `setFunctionBreakpoints`, `setInstructionBreakpoints`, or `setDataBreakpoints` requests.
---@class dapui.types.Breakpoint
---@field id? integer The identifier for the breakpoint. It is needed if breakpoint events are used to update or remove breakpoints.
---@field verified boolean If true, the breakpoint could be set (but not necessarily at the desired location).
---@field message? string A message about the state of the breakpoint. This is shown to the user and can be used to explain why a breakpoint could not be verified.
---@field source? dapui.types.Source The source where the breakpoint is located.
---@field line? integer The start line of the actual range covered by the breakpoint.
---@field column? integer Start position of the source range covered by the breakpoint. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field endLine? integer The end line of the actual range covered by the breakpoint.
---@field endColumn? integer End position of the source range covered by the breakpoint. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based. If no end line is given, then the end column is assumed to be in the start line.
---@field instructionReference? string A memory reference to where the breakpoint is set.
---@field offset? integer The offset from the instruction reference. This can be negative.

---@class dapui.types.SetBreakpointsResponse
---@field breakpoints dapui.types.Breakpoint[] Information about the breakpoints. The array elements are in the same order as the elements of the `breakpoints` (or the deprecated `lines`) array in the arguments.

--- Sets multiple breakpoints for a single source and clears all previous breakpoints in that source.
--- To clear all breakpoint for a source, specify an empty array.
--- When a breakpoint is hit, a `stopped` event (with reason `breakpoint`) is generated.
---@async
---@param args dapui.types.SetBreakpointsArguments
---@return dapui.types.SetBreakpointsResponse
function DAPUIRequestsClient.setBreakpoints(args) end

---@class dapui.types.setBreakpointsRequestListenerArgs
---@field request dapui.types.SetBreakpointsArguments
---@field error? table
---@field response dapui.types.SetBreakpointsResponse

---@param listener fun(args: dapui.types.setBreakpointsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.setBreakpoints(listener, opts) end

--- Properties of a data breakpoint passed to the `setDataBreakpoints` request.
---@class dapui.types.DataBreakpoint
---@field dataId string An id representing the data. This id is returned from the `dataBreakpointInfo` request.
---@field accessType? "read"|"write"|"readWrite" The access type of the data.
---@field condition? string An expression for conditional breakpoints.
---@field hitCondition? string An expression that controls how many hits of the breakpoint are ignored. The debug adapter is expected to interpret the expression as needed.

--- Arguments for `setDataBreakpoints` request.
---@class dapui.types.SetDataBreakpointsArguments
---@field breakpoints dapui.types.DataBreakpoint[] The contents of this array replaces all existing data breakpoints. An empty array clears all data breakpoints.

---@class dapui.types.SetDataBreakpointsResponse
---@field breakpoints dapui.types.Breakpoint[] Information about the data breakpoints. The array elements correspond to the elements of the input argument `breakpoints` array.

--- Replaces all existing data breakpoints with new data breakpoints.
--- To clear all data breakpoints, specify an empty array.
--- When a data breakpoint is hit, a `stopped` event (with reason `data breakpoint`) is generated.
--- Clients should only call this request if the corresponding capability `supportsDataBreakpoints` is true.
---@async
---@param args dapui.types.SetDataBreakpointsArguments
---@return dapui.types.SetDataBreakpointsResponse
function DAPUIRequestsClient.setDataBreakpoints(args) end

---@class dapui.types.setDataBreakpointsRequestListenerArgs
---@field request dapui.types.SetDataBreakpointsArguments
---@field error? table
---@field response dapui.types.SetDataBreakpointsResponse

---@param listener fun(args: dapui.types.setDataBreakpointsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.setDataBreakpoints(listener, opts) end

--- An `ExceptionFilterOptions` is used to specify an exception filter together with a condition for the `setExceptionBreakpoints` request.
---@class dapui.types.ExceptionFilterOptions
---@field filterId string ID of an exception filter returned by the `exceptionBreakpointFilters` capability.
---@field condition? string An expression for conditional exceptions. The exception breaks into the debugger if the result of the condition is true.

--- An `ExceptionPathSegment` represents a segment in a path that is used to match leafs or nodes in a tree of exceptions.
--- If a segment consists of more than one name, it matches the names provided if `negate` is false or missing, or it matches anything except the names provided if `negate` is true.
---@class dapui.types.ExceptionPathSegment
---@field negate? boolean If false or missing this segment matches the names provided, otherwise it matches anything except the names provided.
---@field names string[] Depending on the value of `negate` the names that should match or not match.

--- An `ExceptionOptions` assigns configuration options to a set of exceptions.
---@class dapui.types.ExceptionOptions
---@field path? dapui.types.ExceptionPathSegment[] A path that selects a single or multiple exceptions in a tree. If `path` is missing, the whole tree is selected. By convention the first segment of the path is a category that is used to group exceptions in the UI.
---@field breakMode "never"|"always"|"unhandled"|"userUnhandled" Condition when a thrown exception should result in a break.

--- Arguments for `setExceptionBreakpoints` request.
---@class dapui.types.SetExceptionBreakpointsArguments
---@field filters string[] Set of exception filters specified by their ID. The set of all possible exception filters is defined by the `exceptionBreakpointFilters` capability. The `filter` and `filterOptions` sets are additive.
---@field filterOptions? dapui.types.ExceptionFilterOptions[] Set of exception filters and their options. The set of all possible exception filters is defined by the `exceptionBreakpointFilters` capability. This attribute is only honored by a debug adapter if the corresponding capability `supportsExceptionFilterOptions` is true. The `filter` and `filterOptions` sets are additive.
---@field exceptionOptions? dapui.types.ExceptionOptions[] Configuration options for selected exceptions. The attribute is only honored by a debug adapter if the corresponding capability `supportsExceptionOptions` is true.

---@class dapui.types.SetExceptionBreakpointsResponse
---@field breakpoints? dapui.types.Breakpoint[] Information about the exception breakpoints or filters. The breakpoints returned are in the same order as the elements of the `filters`, `filterOptions`, `exceptionOptions` arrays in the arguments. If both `filters` and `filterOptions` are given, the returned array must start with `filters` information first, followed by `filterOptions` information.

--- The request configures the debugger's response to thrown exceptions.
--- If an exception is configured to break, a `stopped` event is fired (with reason `exception`).
--- Clients should only call this request if the corresponding capability `exceptionBreakpointFilters` returns one or more filters.
---@async
---@param args dapui.types.SetExceptionBreakpointsArguments
---@return dapui.types.SetExceptionBreakpointsResponse
function DAPUIRequestsClient.setExceptionBreakpoints(args) end

---@class dapui.types.setExceptionBreakpointsRequestListenerArgs
---@field request dapui.types.SetExceptionBreakpointsArguments
---@field error? table
---@field response dapui.types.SetExceptionBreakpointsResponse

---@param listener fun(args: dapui.types.setExceptionBreakpointsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.setExceptionBreakpoints(listener, opts) end

--- Arguments for `setExpression` request.
---@class dapui.types.SetExpressionArguments
---@field expression string The l-value expression to assign to.
---@field value string The value expression to assign to the l-value expression.
---@field frameId? integer Evaluate the expressions in the scope of this stack frame. If not specified, the expressions are evaluated in the global scope.
---@field format? dapui.types.ValueFormat Specifies how the resulting value should be formatted.

---@class dapui.types.SetExpressionResponse
---@field value string The new value of the expression.
---@field type? string The type of the value. This attribute should only be returned by a debug adapter if the corresponding capability `supportsVariableType` is true.
---@field presentationHint? dapui.types.VariablePresentationHint Properties of a value that can be used to determine how to render the result in the UI.
---@field variablesReference? integer If `variablesReference` is > 0, the evaluate result is structured and its children can be retrieved by passing `variablesReference` to the `variables` request as long as execution remains suspended. See 'Lifetime of Object References' in the Overview section for details.
---@field namedVariables? integer The number of named child variables. The client can use this information to present the variables in a paged UI and fetch them in chunks. The value should be less than or equal to 2147483647 (2^31-1).
---@field indexedVariables? integer The number of indexed child variables. The client can use this information to present the variables in a paged UI and fetch them in chunks. The value should be less than or equal to 2147483647 (2^31-1).

--- Evaluates the given `value` expression and assigns it to the `expression` which must be a modifiable l-value.
--- The expressions have access to any variables and arguments that are in scope of the specified frame.
--- Clients should only call this request if the corresponding capability `supportsSetExpression` is true.
--- If a debug adapter implements both `setExpression` and `setVariable`, a client uses `setExpression` if the variable has an `evaluateName` property.
---@async
---@param args dapui.types.SetExpressionArguments
---@return dapui.types.SetExpressionResponse
function DAPUIRequestsClient.setExpression(args) end

---@class dapui.types.setExpressionRequestListenerArgs
---@field request dapui.types.SetExpressionArguments
---@field error? table
---@field response dapui.types.SetExpressionResponse

---@param listener fun(args: dapui.types.setExpressionRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.setExpression(listener, opts) end

--- Properties of a breakpoint passed to the `setFunctionBreakpoints` request.
---@class dapui.types.FunctionBreakpoint
---@field name string The name of the function.
---@field condition? string An expression for conditional breakpoints. It is only honored by a debug adapter if the corresponding capability `supportsConditionalBreakpoints` is true.
---@field hitCondition? string An expression that controls how many hits of the breakpoint are ignored. The debug adapter is expected to interpret the expression as needed. The attribute is only honored by a debug adapter if the corresponding capability `supportsHitConditionalBreakpoints` is true.

--- Arguments for `setFunctionBreakpoints` request.
---@class dapui.types.SetFunctionBreakpointsArguments
---@field breakpoints dapui.types.FunctionBreakpoint[] The function names of the breakpoints.

---@class dapui.types.SetFunctionBreakpointsResponse
---@field breakpoints dapui.types.Breakpoint[] Information about the breakpoints. The array elements correspond to the elements of the `breakpoints` array.

--- Replaces all existing function breakpoints with new function breakpoints.
--- To clear all function breakpoints, specify an empty array.
--- When a function breakpoint is hit, a `stopped` event (with reason `function breakpoint`) is generated.
--- Clients should only call this request if the corresponding capability `supportsFunctionBreakpoints` is true.
---@async
---@param args dapui.types.SetFunctionBreakpointsArguments
---@return dapui.types.SetFunctionBreakpointsResponse
function DAPUIRequestsClient.setFunctionBreakpoints(args) end

---@class dapui.types.setFunctionBreakpointsRequestListenerArgs
---@field request dapui.types.SetFunctionBreakpointsArguments
---@field error? table
---@field response dapui.types.SetFunctionBreakpointsResponse

---@param listener fun(args: dapui.types.setFunctionBreakpointsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.setFunctionBreakpoints(listener, opts) end

--- Properties of a breakpoint passed to the `setInstructionBreakpoints` request
---@class dapui.types.InstructionBreakpoint
---@field instructionReference string The instruction reference of the breakpoint. This should be a memory or instruction pointer reference from an `EvaluateResponse`, `Variable`, `StackFrame`, `GotoTarget`, or `Breakpoint`.
---@field offset? integer The offset from the instruction reference. This can be negative.
---@field condition? string An expression for conditional breakpoints. It is only honored by a debug adapter if the corresponding capability `supportsConditionalBreakpoints` is true.
---@field hitCondition? string An expression that controls how many hits of the breakpoint are ignored. The debug adapter is expected to interpret the expression as needed. The attribute is only honored by a debug adapter if the corresponding capability `supportsHitConditionalBreakpoints` is true.

--- Arguments for `setInstructionBreakpoints` request
---@class dapui.types.SetInstructionBreakpointsArguments
---@field breakpoints dapui.types.InstructionBreakpoint[] The instruction references of the breakpoints

---@class dapui.types.SetInstructionBreakpointsResponse
---@field breakpoints dapui.types.Breakpoint[] Information about the breakpoints. The array elements correspond to the elements of the `breakpoints` array.

--- Replaces all existing instruction breakpoints. Typically, instruction breakpoints would be set from a disassembly window.
--- To clear all instruction breakpoints, specify an empty array.
--- When an instruction breakpoint is hit, a `stopped` event (with reason `instruction breakpoint`) is generated.
--- Clients should only call this request if the corresponding capability `supportsInstructionBreakpoints` is true.
---@async
---@param args dapui.types.SetInstructionBreakpointsArguments
---@return dapui.types.SetInstructionBreakpointsResponse
function DAPUIRequestsClient.setInstructionBreakpoints(args) end

---@class dapui.types.setInstructionBreakpointsRequestListenerArgs
---@field request dapui.types.SetInstructionBreakpointsArguments
---@field error? table
---@field response dapui.types.SetInstructionBreakpointsResponse

---@param listener fun(args: dapui.types.setInstructionBreakpointsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.setInstructionBreakpoints(listener, opts) end

--- Arguments for `setVariable` request.
---@class dapui.types.SetVariableArguments
---@field variablesReference integer The reference of the variable container. The `variablesReference` must have been obtained in the current suspended state. See 'Lifetime of Object References' in the Overview section for details.
---@field name string The name of the variable in the container.
---@field value string The value of the variable.
---@field format? dapui.types.ValueFormat Specifies details on how to format the response value.

---@class dapui.types.SetVariableResponse
---@field value string The new value of the variable.
---@field type? string The type of the new value. Typically shown in the UI when hovering over the value.
---@field variablesReference? integer If `variablesReference` is > 0, the new value is structured and its children can be retrieved by passing `variablesReference` to the `variables` request as long as execution remains suspended. See 'Lifetime of Object References' in the Overview section for details.
---@field namedVariables? integer The number of named child variables. The client can use this information to present the variables in a paged UI and fetch them in chunks. The value should be less than or equal to 2147483647 (2^31-1).
---@field indexedVariables? integer The number of indexed child variables. The client can use this information to present the variables in a paged UI and fetch them in chunks. The value should be less than or equal to 2147483647 (2^31-1).

--- Set the variable with the given name in the variable container to a new value. Clients should only call this request if the corresponding capability `supportsSetVariable` is true.
--- If a debug adapter implements both `setVariable` and `setExpression`, a client will only use `setExpression` if the variable has an `evaluateName` property.
---@async
---@param args dapui.types.SetVariableArguments
---@return dapui.types.SetVariableResponse
function DAPUIRequestsClient.setVariable(args) end

---@class dapui.types.setVariableRequestListenerArgs
---@field request dapui.types.SetVariableArguments
---@field error? table
---@field response dapui.types.SetVariableResponse

---@param listener fun(args: dapui.types.setVariableRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.setVariable(listener, opts) end

--- Arguments for `source` request.
---@class dapui.types.SourceArguments
---@field source? dapui.types.Source Specifies the source content to load. Either `source.path` or `source.sourceReference` must be specified.
---@field sourceReference integer The reference to the source. This is the same as `source.sourceReference`. This is provided for backward compatibility since old clients do not understand the `source` attribute.

---@class dapui.types.SourceResponse
---@field content string Content of the source reference.
---@field mimeType? string Content type (MIME type) of the source.

--- The request retrieves the source code for a given source reference.
---@async
---@param args dapui.types.SourceArguments
---@return dapui.types.SourceResponse
function DAPUIRequestsClient.source(args) end

---@class dapui.types.sourceRequestListenerArgs
---@field request dapui.types.SourceArguments
---@field error? table
---@field response dapui.types.SourceResponse

---@param listener fun(args: dapui.types.sourceRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.source(listener, opts) end

--- Provides formatting information for a stack frame.
---@class dapui.types.StackFrameFormat
---@field hex? boolean Display the value in hex.
---@field parameters? boolean Displays parameters for the stack frame.
---@field parameterTypes? boolean Displays the types of parameters for the stack frame.
---@field parameterNames? boolean Displays the names of parameters for the stack frame.
---@field parameterValues? boolean Displays the values of parameters for the stack frame.
---@field line? boolean Displays the line number of the stack frame.
---@field module? boolean Displays the module of the stack frame.
---@field includeAll? boolean Includes all stack frames, including those the debug adapter might otherwise hide.

--- Arguments for `stackTrace` request.
---@class dapui.types.StackTraceArguments
---@field threadId integer Retrieve the stacktrace for this thread.
---@field startFrame? integer The index of the first frame to return; if omitted frames start at 0.
---@field levels? integer The maximum number of frames to return. If levels is not specified or 0, all frames are returned.
---@field format? dapui.types.StackFrameFormat Specifies details on how to format the stack frames. The attribute is only honored by a debug adapter if the corresponding capability `supportsValueFormattingOptions` is true.

--- A Stackframe contains the source location.
---@class dapui.types.StackFrame
---@field id integer An identifier for the stack frame. It must be unique across all threads. This id can be used to retrieve the scopes of the frame with the `scopes` request or to restart the execution of a stack frame.
---@field name string The name of the stack frame, typically a method name.
---@field source? dapui.types.Source The source of the frame.
---@field line integer The line within the source of the frame. If the source attribute is missing or doesn't exist, `line` is 0 and should be ignored by the client.
---@field column integer Start position of the range covered by the stack frame. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based. If attribute `source` is missing or doesn't exist, `column` is 0 and should be ignored by the client.
---@field endLine? integer The end line of the range covered by the stack frame.
---@field endColumn? integer End position of the range covered by the stack frame. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field canRestart? boolean Indicates whether this frame can be restarted with the `restart` request. Clients should only use this if the debug adapter supports the `restart` request and the corresponding capability `supportsRestartRequest` is true. If a debug adapter has this capability, then `canRestart` defaults to `true` if the property is absent.
---@field instructionPointerReference? string A memory reference for the current instruction pointer in this frame.
---@field moduleId? integer | string The module associated with this frame, if any.
---@field presentationHint? "normal"|"label"|"subtle" A hint for how to present this frame in the UI. A value of `label` can be used to indicate that the frame is an artificial frame that is used as a visual label or separator. A value of `subtle` can be used to change the appearance of a frame in a 'subtle' way.

---@class dapui.types.StackTraceResponse
---@field stackFrames dapui.types.StackFrame[] The frames of the stack frame. If the array has length zero, there are no stack frames available. This means that there is no location information available.
---@field totalFrames? integer The total number of frames available in the stack. If omitted or if `totalFrames` is larger than the available frames, a client is expected to request frames until a request returns less frames than requested (which indicates the end of the stack). Returning monotonically increasing `totalFrames` values for subsequent requests can be used to enforce paging in the client.

--- The request returns a stacktrace from the current execution state of a given thread.
--- A client can request all stack frames by omitting the startFrame and levels arguments. For performance-conscious clients and if the corresponding capability `supportsDelayedStackTraceLoading` is true, stack frames can be retrieved in a piecemeal way with the `startFrame` and `levels` arguments. The response of the `stackTrace` request may contain a `totalFrames` property that hints at the total number of frames in the stack. If a client needs this total number upfront, it can issue a request for a single (first) frame and depending on the value of `totalFrames` decide how to proceed. In any case a client should be prepared to receive fewer frames than requested, which is an indication that the end of the stack has been reached.
---@async
---@param args dapui.types.StackTraceArguments
---@return dapui.types.StackTraceResponse
function DAPUIRequestsClient.stackTrace(args) end

---@class dapui.types.stackTraceRequestListenerArgs
---@field request dapui.types.StackTraceArguments
---@field error? table
---@field response dapui.types.StackTraceResponse

---@param listener fun(args: dapui.types.stackTraceRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.stackTrace(listener, opts) end

--- Arguments for `startDebugging` request.
---@class dapui.types.StartDebuggingRequestArguments
---@field configuration table<string,any> Arguments passed to the new debug session. The arguments must only contain properties understood by the `launch` or `attach` requests of the debug adapter and they must not contain any client-specific properties (e.g. `type`) or client-specific features (e.g. substitutable 'variables').
---@field request "launch"|"attach" Indicates whether the new debug session should be started with a `launch` or `attach` request.

--- This request is sent from the debug adapter to the client to start a new debug session of the same type as the caller.
--- This request should only be sent if the corresponding client capability `supportsStartDebuggingRequest` is true.
--- A client implementation of `startDebugging` should start a new debug session (of the same type as the caller) in the same way that the caller's session was started. If the client supports hierarchical debug sessions, the newly created session can be treated as a child of the caller session.
---@async
---@param args dapui.types.StartDebuggingRequestArguments
function DAPUIRequestsClient.startDebugging(args) end

---@class dapui.types.startDebuggingRequestListenerArgs
---@field request dapui.types.StartDebuggingRequestArguments
---@field error? table

---@param listener fun(args: dapui.types.startDebuggingRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.startDebugging(listener, opts) end

--- Arguments for `stepBack` request.
---@class dapui.types.StepBackArguments
---@field threadId integer Specifies the thread for which to resume execution for one step backwards (of the given granularity).
---@field singleThread? boolean If this flag is true, all other suspended threads are not resumed.
---@field granularity? "statement"|"line"|"instruction" Stepping granularity to step. If no granularity is specified, a granularity of `statement` is assumed.

--- The request executes one backward step (in the given granularity) for the specified thread and allows all other threads to run backward freely by resuming them.
--- If the debug adapter supports single thread execution (see capability `supportsSingleThreadExecutionRequests`), setting the `singleThread` argument to true prevents other suspended threads from resuming.
--- The debug adapter first sends the response and then a `stopped` event (with reason `step`) after the step has completed.
--- Clients should only call this request if the corresponding capability `supportsStepBack` is true.
---@async
---@param args dapui.types.StepBackArguments
function DAPUIRequestsClient.stepBack(args) end

---@class dapui.types.stepBackRequestListenerArgs
---@field request dapui.types.StepBackArguments
---@field error? table

---@param listener fun(args: dapui.types.stepBackRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.stepBack(listener, opts) end

--- Arguments for `stepIn` request.
---@class dapui.types.StepInArguments
---@field threadId integer Specifies the thread for which to resume execution for one step-into (of the given granularity).
---@field singleThread? boolean If this flag is true, all other suspended threads are not resumed.
---@field targetId? integer Id of the target to step into.
---@field granularity? "statement"|"line"|"instruction" Stepping granularity. If no granularity is specified, a granularity of `statement` is assumed.

--- The request resumes the given thread to step into a function/method and allows all other threads to run freely by resuming them.
--- If the debug adapter supports single thread execution (see capability `supportsSingleThreadExecutionRequests`), setting the `singleThread` argument to true prevents other suspended threads from resuming.
--- If the request cannot step into a target, `stepIn` behaves like the `next` request.
--- The debug adapter first sends the response and then a `stopped` event (with reason `step`) after the step has completed.
--- If there are multiple function/method calls (or other targets) on the source line,
--- the argument `targetId` can be used to control into which target the `stepIn` should occur.
--- The list of possible targets for a given source line can be retrieved via the `stepInTargets` request.
---@async
---@param args dapui.types.StepInArguments
function DAPUIRequestsClient.stepIn(args) end

---@class dapui.types.stepInRequestListenerArgs
---@field request dapui.types.StepInArguments
---@field error? table

---@param listener fun(args: dapui.types.stepInRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.stepIn(listener, opts) end

--- Arguments for `stepInTargets` request.
---@class dapui.types.StepInTargetsArguments
---@field frameId integer The stack frame for which to retrieve the possible step-in targets.

--- A `StepInTarget` can be used in the `stepIn` request and determines into which single target the `stepIn` request should step.
---@class dapui.types.StepInTarget
---@field id integer Unique identifier for a step-in target.
---@field label string The name of the step-in target (shown in the UI).
---@field line? integer The line of the step-in target.
---@field column? integer Start position of the range covered by the step in target. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field endLine? integer The end line of the range covered by the step-in target.
---@field endColumn? integer End position of the range covered by the step in target. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.

---@class dapui.types.StepInTargetsResponse
---@field targets dapui.types.StepInTarget[] The possible step-in targets of the specified source location.

--- This request retrieves the possible step-in targets for the specified stack frame.
--- These targets can be used in the `stepIn` request.
--- Clients should only call this request if the corresponding capability `supportsStepInTargetsRequest` is true.
---@async
---@param args dapui.types.StepInTargetsArguments
---@return dapui.types.StepInTargetsResponse
function DAPUIRequestsClient.stepInTargets(args) end

---@class dapui.types.stepInTargetsRequestListenerArgs
---@field request dapui.types.StepInTargetsArguments
---@field error? table
---@field response dapui.types.StepInTargetsResponse

---@param listener fun(args: dapui.types.stepInTargetsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.stepInTargets(listener, opts) end

--- Arguments for `stepOut` request.
---@class dapui.types.StepOutArguments
---@field threadId integer Specifies the thread for which to resume execution for one step-out (of the given granularity).
---@field singleThread? boolean If this flag is true, all other suspended threads are not resumed.
---@field granularity? "statement"|"line"|"instruction" Stepping granularity. If no granularity is specified, a granularity of `statement` is assumed.

--- The request resumes the given thread to step out (return) from a function/method and allows all other threads to run freely by resuming them.
--- If the debug adapter supports single thread execution (see capability `supportsSingleThreadExecutionRequests`), setting the `singleThread` argument to true prevents other suspended threads from resuming.
--- The debug adapter first sends the response and then a `stopped` event (with reason `step`) after the step has completed.
---@async
---@param args dapui.types.StepOutArguments
function DAPUIRequestsClient.stepOut(args) end

---@class dapui.types.stepOutRequestListenerArgs
---@field request dapui.types.StepOutArguments
---@field error? table

---@param listener fun(args: dapui.types.stepOutRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.stepOut(listener, opts) end

--- Arguments for `terminate` request.
---@class dapui.types.TerminateArguments
---@field restart? boolean A value of true indicates that this `terminate` request is part of a restart sequence.

--- The `terminate` request is sent from the client to the debug adapter in order to shut down the debuggee gracefully. Clients should only call this request if the capability `supportsTerminateRequest` is true.
--- Typically a debug adapter implements `terminate` by sending a software signal which the debuggee intercepts in order to clean things up properly before terminating itself.
--- Please note that this request does not directly affect the state of the debug session: if the debuggee decides to veto the graceful shutdown for any reason by not terminating itself, then the debug session just continues.
--- Clients can surface the `terminate` request as an explicit command or they can integrate it into a two stage Stop command that first sends `terminate` to request a graceful shutdown, and if that fails uses `disconnect` for a forceful shutdown.
---@async
---@param args dapui.types.TerminateArguments
function DAPUIRequestsClient.terminate(args) end

---@class dapui.types.terminateRequestListenerArgs
---@field request dapui.types.TerminateArguments
---@field error? table

---@param listener fun(args: dapui.types.terminateRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.terminate(listener, opts) end

--- Arguments for `terminateThreads` request.
---@class dapui.types.TerminateThreadsArguments
---@field threadIds? integer[] Ids of threads to be terminated.

--- The request terminates the threads with the given ids.
--- Clients should only call this request if the corresponding capability `supportsTerminateThreadsRequest` is true.
---@async
---@param args dapui.types.TerminateThreadsArguments
function DAPUIRequestsClient.terminateThreads(args) end

---@class dapui.types.terminateThreadsRequestListenerArgs
---@field request dapui.types.TerminateThreadsArguments
---@field error? table

---@param listener fun(args: dapui.types.terminateThreadsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.terminateThreads(listener, opts) end

--- A Thread
---@class dapui.types.Thread
---@field id integer Unique identifier for the thread.
---@field name string The name of the thread.

---@class dapui.types.ThreadsResponse
---@field threads dapui.types.Thread[] All threads.

--- The request retrieves a list of all threads.
---@async
---@return dapui.types.ThreadsResponse
function DAPUIRequestsClient.threads() end

---@class dapui.types.threadsRequestListenerArgs
---@field error? table
---@field response dapui.types.ThreadsResponse

---@param listener fun(args: dapui.types.threadsRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.threads(listener, opts) end

--- Arguments for `variables` request.
---@class dapui.types.VariablesArguments
---@field variablesReference integer The variable for which to retrieve its children. The `variablesReference` must have been obtained in the current suspended state. See 'Lifetime of Object References' in the Overview section for details.
---@field filter? "indexed"|"named" Filter to limit the child variables to either named or indexed. If omitted, both types are fetched.
---@field start? integer The index of the first variable to return; if omitted children start at 0.
---@field count? integer The number of variables to return. If count is missing or 0, all variables are returned.
---@field format? dapui.types.ValueFormat Specifies details on how to format the Variable values. The attribute is only honored by a debug adapter if the corresponding capability `supportsValueFormattingOptions` is true.

--- A Variable is a name/value pair.
--- The `type` attribute is shown if space permits or when hovering over the variable's name.
--- The `kind` attribute is used to render additional properties of the variable, e.g. different icons can be used to indicate that a variable is public or private.
--- If the value is structured (has children), a handle is provided to retrieve the children with the `variables` request.
--- If the number of named or indexed children is large, the numbers should be returned via the `namedVariables` and `indexedVariables` attributes.
--- The client can use this information to present the children in a paged UI and fetch them in chunks.
---@class dapui.types.Variable
---@field name string The variable's name.
---@field value string The variable's value. This can be a multi-line text, e.g. for a function the body of a function. For structured variables (which do not have a simple value), it is recommended to provide a one-line representation of the structured object. This helps to identify the structured object in the collapsed state when its children are not yet visible. An empty string can be used if no value should be shown in the UI.
---@field type? string The type of the variable's value. Typically shown in the UI when hovering over the value. This attribute should only be returned by a debug adapter if the corresponding capability `supportsVariableType` is true.
---@field presentationHint? dapui.types.VariablePresentationHint Properties of a variable that can be used to determine how to render the variable in the UI.
---@field evaluateName? string The evaluatable name of this variable which can be passed to the `evaluate` request to fetch the variable's value.
---@field variablesReference integer If `variablesReference` is > 0, the variable is structured and its children can be retrieved by passing `variablesReference` to the `variables` request as long as execution remains suspended. See 'Lifetime of Object References' in the Overview section for details.
---@field namedVariables? integer The number of named child variables. The client can use this information to present the children in a paged UI and fetch them in chunks.
---@field indexedVariables? integer The number of indexed child variables. The client can use this information to present the children in a paged UI and fetch them in chunks.
---@field memoryReference? string The memory reference for the variable if the variable represents executable code, such as a function pointer. This attribute is only required if the corresponding capability `supportsMemoryReferences` is true.

---@class dapui.types.VariablesResponse
---@field variables dapui.types.Variable[] All (or a range) of variables for the given variable reference.

--- Retrieves all child variables for the given variable reference.
--- A filter can be used to limit the fetched children to either named or indexed children.
---@async
---@param args dapui.types.VariablesArguments
---@return dapui.types.VariablesResponse
function DAPUIRequestsClient.variables(args) end

---@class dapui.types.variablesRequestListenerArgs
---@field request dapui.types.VariablesArguments
---@field error? table
---@field response dapui.types.VariablesResponse

---@param listener fun(args: dapui.types.variablesRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.variables(listener, opts) end

--- Arguments for `writeMemory` request.
---@class dapui.types.WriteMemoryArguments
---@field memoryReference string Memory reference to the base location to which data should be written.
---@field offset? integer Offset (in bytes) to be applied to the reference location before writing data. Can be negative.
---@field allowPartial? boolean Property to control partial writes. If true, the debug adapter should attempt to write memory even if the entire memory region is not writable. In such a case the debug adapter should stop after hitting the first byte of memory that cannot be written and return the number of bytes written in the response via the `offset` and `bytesWritten` properties. If false or missing, a debug adapter should attempt to verify the region is writable before writing, and fail the response if it is not.
---@field data string Bytes to write, encoded using base64.

---@class dapui.types.WriteMemoryResponse
---@field offset? integer Property that should be returned when `allowPartial` is true to indicate the offset of the first byte of data successfully written. Can be negative.
---@field bytesWritten? integer Property that should be returned when `allowPartial` is true to indicate the number of bytes starting from address that were successfully written.

--- Writes bytes to memory at the provided location.
--- Clients should only call this request if the corresponding capability `supportsWriteMemoryRequest` is true.
---@async
---@param args dapui.types.WriteMemoryArguments
---@return dapui.types.WriteMemoryResponse
function DAPUIRequestsClient.writeMemory(args) end

---@class dapui.types.writeMemoryRequestListenerArgs
---@field request dapui.types.WriteMemoryArguments
---@field error? table
---@field response dapui.types.WriteMemoryResponse

---@param listener fun(args: dapui.types.writeMemoryRequestListenerArgs): boolean | nil
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.writeMemory(listener, opts) end

---@class dapui.types.BreakpointEventArgs
---@field reason string The reason for the event.
---@field breakpoint dapui.types.Breakpoint The `id` attribute is used to find the target breakpoint, the other attributes are used as the new values.

--- The event indicates that some information about a breakpoint has changed.
---@param listener fun(args: dapui.types.BreakpointEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.breakpoint(listener, opts) end

--- Information about the capabilities of a debug adapter.
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
---@field supportedChecksumAlgorithms? "MD5"|"SHA1"|"SHA256"|"timestamp"[] Checksum algorithms supported by the debug adapter.
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

--- The event indicates that one or more capabilities have changed.
--- Since the capabilities are dependent on the client and its UI, it might not be possible to change that at random times (or too late).
--- Consequently this event has a hint characteristic: a client can only be expected to make a 'best effort' in honoring individual capabilities but there are no guarantees.
--- Only changed capabilities need to be included, all other capabilities keep their values.
---@param listener fun(args: dapui.types.CapabilitiesEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.capabilities(listener, opts) end

---@class dapui.types.ContinuedEventArgs
---@field threadId integer The thread which was continued.
---@field allThreadsContinued? boolean If `allThreadsContinued` is true, a debug adapter can announce that all threads have continued.

--- The event indicates that the execution of the debuggee has continued.
--- Please note: a debug adapter is not expected to send this event in response to a request that implies that execution continues, e.g. `launch` or `continue`.
--- It is only necessary to send a `continued` event if there was no previous request that implied this.
---@param listener fun(args: dapui.types.ContinuedEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.continued(listener, opts) end

---@class dapui.types.ExitedEventArgs
---@field exitCode integer The exit code returned from the debuggee.

--- The event indicates that the debuggee has exited and returns its exit code.
---@param listener fun(args: dapui.types.ExitedEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.exited(listener, opts) end

--- This event indicates that the debug adapter is ready to accept configuration requests (e.g. `setBreakpoints`, `setExceptionBreakpoints`).
--- A debug adapter is expected to send this event when it is ready to accept configuration requests (but not before the `initialize` request has finished).
--- The sequence of events/requests is as follows:
--- - adapters sends `initialized` event (after the `initialize` request has returned)
--- - client sends zero or more `setBreakpoints` requests
--- - client sends one `setFunctionBreakpoints` request (if corresponding capability `supportsFunctionBreakpoints` is true)
--- - client sends a `setExceptionBreakpoints` request if one or more `exceptionBreakpointFilters` have been defined (or if `supportsConfigurationDoneRequest` is not true)
--- - client sends other future configuration requests
--- - client sends one `configurationDone` request to indicate the end of the configuration.
---@param listener fun()
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.initialized(listener, opts) end

---@class dapui.types.InvalidatedAreas
---@field __root__ string Logical areas that can be invalidated by the `invalidated` event.

---@class dapui.types.InvalidatedEventArgs
---@field areas? dapui.types.InvalidatedAreas[] Set of logical areas that got invalidated. This property has a hint characteristic: a client can only be expected to make a 'best effort' in honoring the areas but there are no guarantees. If this property is missing, empty, or if values are not understood, the client should assume a single value `all`.
---@field threadId? integer If specified, the client only needs to refetch data related to this thread.
---@field stackFrameId? integer If specified, the client only needs to refetch data related to this stack frame (and the `threadId` is ignored).

--- This event signals that some state in the debug adapter has changed and requires that the client needs to re-render the data snapshot previously requested.
--- Debug adapters do not have to emit this event for runtime changes like stopped or thread events because in that case the client refetches the new state anyway. But the event can be used for example to refresh the UI after rendering formatting has changed in the debug adapter.
--- This event should only be sent if the corresponding capability `supportsInvalidatedEvent` is true.
---@param listener fun(args: dapui.types.InvalidatedEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.invalidated(listener, opts) end

---@class dapui.types.LoadedSourceEventArgs
---@field reason "new"|"changed"|"removed" The reason for the event.
---@field source dapui.types.Source The new, changed, or removed source.

--- The event indicates that some source has been added, changed, or removed from the set of all loaded sources.
---@param listener fun(args: dapui.types.LoadedSourceEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.loadedSource(listener, opts) end

---@class dapui.types.MemoryEventArgs
---@field memoryReference string Memory reference of a memory range that has been updated.
---@field offset integer Starting offset in bytes where memory has been updated. Can be negative.
---@field count integer Number of bytes updated.

--- This event indicates that some memory range has been updated. It should only be sent if the corresponding capability `supportsMemoryEvent` is true.
--- Clients typically react to the event by re-issuing a `readMemory` request if they show the memory identified by the `memoryReference` and if the updated memory range overlaps the displayed range. Clients should not make assumptions how individual memory references relate to each other, so they should not assume that they are part of a single continuous address range and might overlap.
--- Debug adapters can use this event to indicate that the contents of a memory range has changed due to some other request like `setVariable` or `setExpression`. Debug adapters are not expected to emit this event for each and every memory change of a running program, because that information is typically not available from debuggers and it would flood clients with too many events.
---@param listener fun(args: dapui.types.MemoryEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.memory(listener, opts) end

---@class dapui.types.ModuleEventArgs
---@field reason "new"|"changed"|"removed" The reason for the event.
---@field module dapui.types.Module The new, changed, or removed module. In case of `removed` only the module id is used.

--- The event indicates that some information about a module has changed.
---@param listener fun(args: dapui.types.ModuleEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.module(listener, opts) end

---@class dapui.types.OutputEventArgs
---@field category? string The output category. If not specified or if the category is not understood by the client, `console` is assumed.
---@field output string The output to report.
---@field group? "start"|"startCollapsed"|"end" Support for keeping an output log organized by grouping related messages.
---@field variablesReference? integer If an attribute `variablesReference` exists and its value is > 0, the output contains objects which can be retrieved by passing `variablesReference` to the `variables` request as long as execution remains suspended. See 'Lifetime of Object References' in the Overview section for details.
---@field source? dapui.types.Source The source location where the output was produced.
---@field line? integer The source location's line where the output was produced.
---@field column? integer The position in `line` where the output was produced. It is measured in UTF-16 code units and the client capability `columnsStartAt1` determines whether it is 0- or 1-based.
---@field data? any[] | boolean | integer | number | table<string,any> | string Additional data to report. For the `telemetry` category the data is sent to telemetry, for the other categories the data is shown in JSON format.

--- The event indicates that the target has produced some output.
---@param listener fun(args: dapui.types.OutputEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.output(listener, opts) end

---@class dapui.types.ProcessEventArgs
---@field name string The logical name of the process. This is usually the full path to process's executable file. Example: /home/example/myproj/program.js.
---@field systemProcessId? integer The system process id of the debugged process. This property is missing for non-system processes.
---@field isLocalProcess? boolean If true, the process is running on the same computer as the debug adapter.
---@field startMethod? "launch"|"attach"|"attachForSuspendedLaunch" Describes how the debug engine started debugging this process.
---@field pointerSize? integer The size of a pointer or address for this process, in bits. This value may be used by clients when formatting addresses for display.

--- The event indicates that the debugger has begun debugging a new process. Either one that it has launched, or one that it has attached to.
---@param listener fun(args: dapui.types.ProcessEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.process(listener, opts) end

---@class dapui.types.ProgressEndEventArgs
---@field progressId string The ID that was introduced in the initial `ProgressStartEvent`.
---@field message? string More detailed progress message. If omitted, the previous message (if any) is used.

--- The event signals the end of the progress reporting with a final message.
--- This event should only be sent if the corresponding capability `supportsProgressReporting` is true.
---@param listener fun(args: dapui.types.ProgressEndEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.progressEnd(listener, opts) end

---@class dapui.types.ProgressStartEventArgs
---@field progressId string An ID that can be used in subsequent `progressUpdate` and `progressEnd` events to make them refer to the same progress reporting. IDs must be unique within a debug session.
---@field title string Short title of the progress reporting. Shown in the UI to describe the long running operation.
---@field requestId? integer The request ID that this progress report is related to. If specified a debug adapter is expected to emit progress events for the long running request until the request has been either completed or cancelled. If the request ID is omitted, the progress report is assumed to be related to some general activity of the debug adapter.
---@field cancellable? boolean If true, the request that reports progress may be cancelled with a `cancel` request. So this property basically controls whether the client should use UX that supports cancellation. Clients that don't support cancellation are allowed to ignore the setting.
---@field message? string More detailed progress message.
---@field percentage? number Progress percentage to display (value range: 0 to 100). If omitted no percentage is shown.

--- The event signals that a long running operation is about to start and provides additional information for the client to set up a corresponding progress and cancellation UI.
--- The client is free to delay the showing of the UI in order to reduce flicker.
--- This event should only be sent if the corresponding capability `supportsProgressReporting` is true.
---@param listener fun(args: dapui.types.ProgressStartEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.progressStart(listener, opts) end

---@class dapui.types.ProgressUpdateEventArgs
---@field progressId string The ID that was introduced in the initial `progressStart` event.
---@field message? string More detailed progress message. If omitted, the previous message (if any) is used.
---@field percentage? number Progress percentage to display (value range: 0 to 100). If omitted no percentage is shown.

--- The event signals that the progress reporting needs to be updated with a new message and/or percentage.
--- The client does not have to update the UI immediately, but the clients needs to keep track of the message and/or percentage values.
--- This event should only be sent if the corresponding capability `supportsProgressReporting` is true.
---@param listener fun(args: dapui.types.ProgressUpdateEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.progressUpdate(listener, opts) end

---@class dapui.types.StoppedEventArgs
---@field reason string The reason for the event. For backward compatibility this string is shown in the UI if the `description` attribute is missing (but it must not be translated).
---@field description? string The full reason for the event, e.g. 'Paused on exception'. This string is shown in the UI as is and can be translated.
---@field threadId? integer The thread which was stopped.
---@field preserveFocusHint? boolean A value of true hints to the client that this event should not change the focus.
---@field text? string Additional information. E.g. if reason is `exception`, text contains the exception name. This string is shown in the UI.
---@field allThreadsStopped? boolean If `allThreadsStopped` is true, a debug adapter can announce that all threads have stopped. - The client should use this information to enable that all threads can be expanded to access their stacktraces. - If the attribute is missing or false, only the thread with the given `threadId` can be expanded.
---@field hitBreakpointIds? integer[] Ids of the breakpoints that triggered the event. In most cases there is only a single breakpoint but here are some examples for multiple breakpoints: - Different types of breakpoints map to the same location. - Multiple source breakpoints get collapsed to the same instruction by the compiler/runtime. - Multiple function breakpoints with different function names map to the same location.

--- The event indicates that the execution of the debuggee has stopped due to some condition.
--- This can be caused by a breakpoint previously set, a stepping request has completed, by executing a debugger statement etc.
---@param listener fun(args: dapui.types.StoppedEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.stopped(listener, opts) end

---@class dapui.types.TerminatedEventArgs
---@field restart? any[] | boolean | integer | number | table<string,any> | string A debug adapter may set `restart` to true (or to an arbitrary object) to request that the client restarts the session. The value is not interpreted by the client and passed unmodified as an attribute `__restart` to the `launch` and `attach` requests.

--- The event indicates that debugging of the debuggee has terminated. This does **not** mean that the debuggee itself has exited.
---@param listener fun(args: dapui.types.TerminatedEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.terminated(listener, opts) end

---@class dapui.types.ThreadEventArgs
---@field reason string The reason for the event.
---@field threadId integer The identifier of the thread.

--- The event indicates that a thread has started or exited.
---@param listener fun(args: dapui.types.ThreadEventArgs)
---@param opts? dapui.client.ListenerOpts
function DAPUIEventListenerClient.thread(listener, opts) end

return { request = DAPUIRequestsClient, listen = DAPUIEventListenerClient }
