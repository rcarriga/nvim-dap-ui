---Generated on 2023-01-08-10:01:01 GMT

---@class dapui.async.lsp.RequestClient
local LSPRequestClient = {}
---@class dapui.async.lsp.RequestOpts
---@field timeout integer Timeout of request in milliseconds

--- A request to resolve the implementation locations of a symbol at a given text
--- document position. The request's parameter is of type [TextDocumentPositionParams]
--- (#TextDocumentPositionParams) the response is of type [Definition](#Definition) or a
--- Thenable that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.ImplementationParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.Definition|dapui.async.lsp.types.DefinitionLink[]|nil
function LSPRequestClient.textDocument_implementation(bufnr, args, opts) end

--- A request to resolve the type definition locations of a symbol at a given text
--- document position. The request's parameter is of type [TextDocumentPositionParams]
--- (#TextDocumentPositionParams) the response is of type [Definition](#Definition) or a
--- Thenable that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.TypeDefinitionParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.Definition|dapui.async.lsp.types.DefinitionLink[]|nil
function LSPRequestClient.textDocument_typeDefinition(bufnr, args, opts) end

--- A request to list all color symbols found in a given text document. The request's
--- parameter is of type [DocumentColorParams](#DocumentColorParams) the
--- response is of type [ColorInformation[]](#ColorInformation) or a Thenable
--- that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DocumentColorParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.ColorInformation[]
function LSPRequestClient.textDocument_documentColor(bufnr, args, opts) end

--- A request to list all presentation for a color. The request's
--- parameter is of type [ColorPresentationParams](#ColorPresentationParams) the
--- response is of type [ColorInformation[]](#ColorInformation) or a Thenable
--- that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.ColorPresentationParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.ColorPresentation[]
function LSPRequestClient.textDocument_colorPresentation(bufnr, args, opts) end

--- A request to provide folding ranges in a document. The request's
--- parameter is of type [FoldingRangeParams](#FoldingRangeParams), the
--- response is of type [FoldingRangeList](#FoldingRangeList) or a Thenable
--- that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.FoldingRangeParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.FoldingRange[]|nil
function LSPRequestClient.textDocument_foldingRange(bufnr, args, opts) end

--- A request to resolve the type definition locations of a symbol at a given text
--- document position. The request's parameter is of type [TextDocumentPositionParams]
--- (#TextDocumentPositionParams) the response is of type [Declaration](#Declaration)
--- or a typed array of [DeclarationLink](#DeclarationLink) or a Thenable that resolves
--- to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DeclarationParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.Declaration|dapui.async.lsp.types.DeclarationLink[]|nil
function LSPRequestClient.textDocument_declaration(bufnr, args, opts) end

--- A request to provide selection ranges in a document. The request's
--- parameter is of type [SelectionRangeParams](#SelectionRangeParams), the
--- response is of type [SelectionRange[]](#SelectionRange[]) or a Thenable
--- that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.SelectionRangeParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.SelectionRange[]|nil
function LSPRequestClient.textDocument_selectionRange(bufnr, args, opts) end

--- A request to result a `CallHierarchyItem` in a document at a given position.
--- Can be used as an input to an incoming or outgoing call hierarchy.
---
--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.CallHierarchyPrepareParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.CallHierarchyItem[]|nil
function LSPRequestClient.textDocument_prepareCallHierarchy(bufnr, args, opts) end

--- A request to resolve the incoming calls for a given `CallHierarchyItem`.
---
--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.CallHierarchyIncomingCallsParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.CallHierarchyIncomingCall[]|nil
function LSPRequestClient.callHierarchy_incomingCalls(bufnr, args, opts) end

--- A request to resolve the outgoing calls for a given `CallHierarchyItem`.
---
--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.CallHierarchyOutgoingCallsParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.CallHierarchyOutgoingCall[]|nil
function LSPRequestClient.callHierarchy_outgoingCalls(bufnr, args, opts) end

--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.SemanticTokensParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.SemanticTokens|nil
function LSPRequestClient.textDocument_semanticTokens_full(bufnr, args, opts) end

--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.SemanticTokensDeltaParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.SemanticTokens|dapui.async.lsp.types.SemanticTokensDelta|nil
function LSPRequestClient.textDocument_semanticTokens_full_delta(bufnr, args, opts) end

--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.SemanticTokensRangeParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.SemanticTokens|nil
function LSPRequestClient.textDocument_semanticTokens_range(bufnr, args, opts) end

--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return nil
function LSPRequestClient.workspace_semanticTokens_refresh(bufnr, opts) end

--- A request to provide ranges that can be edited together.
---
--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.LinkedEditingRangeParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.LinkedEditingRanges|nil
function LSPRequestClient.textDocument_linkedEditingRange(bufnr, args, opts) end

--- The will create files request is sent from the client to the server before files are actually
--- created as long as the creation is triggered from within the client.
---
--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.CreateFilesParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.WorkspaceEdit|nil
function LSPRequestClient.workspace_willCreateFiles(bufnr, args, opts) end

--- The will rename files request is sent from the client to the server before files are actually
--- renamed as long as the rename is triggered from within the client.
---
--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.RenameFilesParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.WorkspaceEdit|nil
function LSPRequestClient.workspace_willRenameFiles(bufnr, args, opts) end

--- The did delete files notification is sent from the client to the server when
--- files were deleted from within the client.
---
--- @since 3.16.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DeleteFilesParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.WorkspaceEdit|nil
function LSPRequestClient.workspace_willDeleteFiles(bufnr, args, opts) end

--- A request to get the moniker of a symbol at a given text document position.
--- The request parameter is of type [TextDocumentPositionParams](#TextDocumentPositionParams).
--- The response is of type [Moniker[]](#Moniker[]) or `null`.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.MonikerParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.Moniker[]|nil
function LSPRequestClient.textDocument_moniker(bufnr, args, opts) end

--- A request to result a `TypeHierarchyItem` in a document at a given position.
--- Can be used as an input to a subtypes or supertypes type hierarchy.
---
--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.TypeHierarchyPrepareParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.TypeHierarchyItem[]|nil
function LSPRequestClient.textDocument_prepareTypeHierarchy(bufnr, args, opts) end

--- A request to resolve the supertypes for a given `TypeHierarchyItem`.
---
--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.TypeHierarchySupertypesParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.TypeHierarchyItem[]|nil
function LSPRequestClient.typeHierarchy_supertypes(bufnr, args, opts) end

--- A request to resolve the subtypes for a given `TypeHierarchyItem`.
---
--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.TypeHierarchySubtypesParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.TypeHierarchyItem[]|nil
function LSPRequestClient.typeHierarchy_subtypes(bufnr, args, opts) end

--- A request to provide inline values in a document. The request's parameter is of
--- type [InlineValueParams](#InlineValueParams), the response is of type
--- [InlineValue[]](#InlineValue[]) or a Thenable that resolves to such.
---
--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.InlineValueParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.InlineValue[]|nil
function LSPRequestClient.textDocument_inlineValue(bufnr, args, opts) end

--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return nil
function LSPRequestClient.workspace_inlineValue_refresh(bufnr, opts) end

--- A request to provide inlay hints in a document. The request's parameter is of
--- type [InlayHintsParams](#InlayHintsParams), the response is of type
--- [InlayHint[]](#InlayHint[]) or a Thenable that resolves to such.
---
--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.InlayHintParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.InlayHint[]|nil
function LSPRequestClient.textDocument_inlayHint(bufnr, args, opts) end

--- A request to resolve additional properties for an inlay hint.
--- The request's parameter is of type [InlayHint](#InlayHint), the response is
--- of type [InlayHint](#InlayHint) or a Thenable that resolves to such.
---
--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.InlayHint
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.InlayHint
function LSPRequestClient.inlayHint_resolve(bufnr, args, opts) end

--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return nil
function LSPRequestClient.workspace_inlayHint_refresh(bufnr, opts) end

--- The document diagnostic request definition.
---
--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DocumentDiagnosticParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.DocumentDiagnosticReport
function LSPRequestClient.textDocument_diagnostic(bufnr, args, opts) end

--- The workspace diagnostic request definition.
---
--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.WorkspaceDiagnosticParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.WorkspaceDiagnosticReport
function LSPRequestClient.workspace_diagnostic(bufnr, args, opts) end

--- The diagnostic refresh request definition.
---
--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return nil
function LSPRequestClient.workspace_diagnostic_refresh(bufnr, opts) end

--- The initialize request is sent from the client to the server.
--- It is sent once as the request after starting up the server.
--- The requests parameter is of type [InitializeParams](#InitializeParams)
--- the response if of type [InitializeResult](#InitializeResult) of a Thenable that
--- resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.InitializeParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.InitializeResult
function LSPRequestClient.initialize(bufnr, args, opts) end

--- A shutdown request is sent from the client to the server.
--- It is sent once when the client decides to shutdown the
--- server. The only notification that is sent after a shutdown request
--- is the exit event.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return nil
function LSPRequestClient.shutdown(bufnr, opts) end

--- A document will save request is sent from the client to the server before
--- the document is actually saved. The request can return an array of TextEdits
--- which will be applied to the text document before it is saved. Please note that
--- clients might drop results if computing the text edits took too long or if a
--- server constantly fails on this request. This is done to keep the save fast and
--- reliable.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.WillSaveTextDocumentParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.TextEdit[]|nil
function LSPRequestClient.textDocument_willSaveWaitUntil(bufnr, args, opts) end

--- Request to request completion at a given text document position. The request's
--- parameter is of type [TextDocumentPosition](#TextDocumentPosition) the response
--- is of type [CompletionItem[]](#CompletionItem) or [CompletionList](#CompletionList)
--- or a Thenable that resolves to such.
---
--- The request can delay the computation of the [`detail`](#CompletionItem.detail)
--- and [`documentation`](#CompletionItem.documentation) properties to the `completionItem/resolve`
--- request. However, properties that are needed for the initial sorting and filtering, like `sortText`,
--- `filterText`, `insertText`, and `textEdit`, must not be changed during resolve.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.CompletionParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.CompletionItem[]|dapui.async.lsp.types.CompletionList|nil
function LSPRequestClient.textDocument_completion(bufnr, args, opts) end

--- Request to resolve additional information for a given completion item.The request's
--- parameter is of type [CompletionItem](#CompletionItem) the response
--- is of type [CompletionItem](#CompletionItem) or a Thenable that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.CompletionItem
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.CompletionItem
function LSPRequestClient.completionItem_resolve(bufnr, args, opts) end

--- Request to request hover information at a given text document position. The request's
--- parameter is of type [TextDocumentPosition](#TextDocumentPosition) the response is of
--- type [Hover](#Hover) or a Thenable that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.HoverParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.Hover|nil
function LSPRequestClient.textDocument_hover(bufnr, args, opts) end

---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.SignatureHelpParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.SignatureHelp|nil
function LSPRequestClient.textDocument_signatureHelp(bufnr, args, opts) end

--- A request to resolve the definition location of a symbol at a given text
--- document position. The request's parameter is of type [TextDocumentPosition]
--- (#TextDocumentPosition) the response is of either type [Definition](#Definition)
--- or a typed array of [DefinitionLink](#DefinitionLink) or a Thenable that resolves
--- to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DefinitionParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.Definition|dapui.async.lsp.types.DefinitionLink[]|nil
function LSPRequestClient.textDocument_definition(bufnr, args, opts) end

--- A request to resolve project-wide references for the symbol denoted
--- by the given text document position. The request's parameter is of
--- type [ReferenceParams](#ReferenceParams) the response is of type
--- [Location[]](#Location) or a Thenable that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.ReferenceParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.Location[]|nil
function LSPRequestClient.textDocument_references(bufnr, args, opts) end

--- Request to resolve a [DocumentHighlight](#DocumentHighlight) for a given
--- text document position. The request's parameter is of type [TextDocumentPosition]
--- (#TextDocumentPosition) the request response is of type [DocumentHighlight[]]
--- (#DocumentHighlight) or a Thenable that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DocumentHighlightParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.DocumentHighlight[]|nil
function LSPRequestClient.textDocument_documentHighlight(bufnr, args, opts) end

--- A request to list all symbols found in a given text document. The request's
--- parameter is of type [TextDocumentIdentifier](#TextDocumentIdentifier) the
--- response is of type [SymbolInformation[]](#SymbolInformation) or a Thenable
--- that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DocumentSymbolParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.SymbolInformation[]|dapui.async.lsp.types.DocumentSymbol[]|nil
function LSPRequestClient.textDocument_documentSymbol(bufnr, args, opts) end

--- A request to provide commands for the given text document and range.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.CodeActionParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.Command|dapui.async.lsp.types.CodeAction[]|nil
function LSPRequestClient.textDocument_codeAction(bufnr, args, opts) end

--- Request to resolve additional information for a given code action.The request's
--- parameter is of type [CodeAction](#CodeAction) the response
--- is of type [CodeAction](#CodeAction) or a Thenable that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.CodeAction
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.CodeAction
function LSPRequestClient.codeAction_resolve(bufnr, args, opts) end

--- A request to list project-wide symbols matching the query string given
--- by the [WorkspaceSymbolParams](#WorkspaceSymbolParams). The response is
--- of type [SymbolInformation[]](#SymbolInformation) or a Thenable that
--- resolves to such.
---
--- @since 3.17.0 - support for WorkspaceSymbol in the returned data. Clients
---  need to advertise support for WorkspaceSymbols via the client capability
---  `workspace.symbol.resolveSupport`.
---
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.WorkspaceSymbolParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.SymbolInformation[]|dapui.async.lsp.types.WorkspaceSymbol[]|nil
function LSPRequestClient.workspace_symbol(bufnr, args, opts) end

--- A request to resolve the range inside the workspace
--- symbol's location.
---
--- @since 3.17.0
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.WorkspaceSymbol
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.WorkspaceSymbol
function LSPRequestClient.workspaceSymbol_resolve(bufnr, args, opts) end

--- A request to provide code lens for the given text document.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.CodeLensParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.CodeLens[]|nil
function LSPRequestClient.textDocument_codeLens(bufnr, args, opts) end

--- A request to resolve a command for a given code lens.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.CodeLens
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.CodeLens
function LSPRequestClient.codeLens_resolve(bufnr, args, opts) end

--- A request to provide document links
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DocumentLinkParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.DocumentLink[]|nil
function LSPRequestClient.textDocument_documentLink(bufnr, args, opts) end

--- Request to resolve additional information for a given document link. The request's
--- parameter is of type [DocumentLink](#DocumentLink) the response
--- is of type [DocumentLink](#DocumentLink) or a Thenable that resolves to such.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DocumentLink
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.DocumentLink
function LSPRequestClient.documentLink_resolve(bufnr, args, opts) end

--- A request to to format a whole document.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DocumentFormattingParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.TextEdit[]|nil
function LSPRequestClient.textDocument_formatting(bufnr, args, opts) end

--- A request to to format a range in a document.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DocumentRangeFormattingParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.TextEdit[]|nil
function LSPRequestClient.textDocument_rangeFormatting(bufnr, args, opts) end

--- A request to format a document on type.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.DocumentOnTypeFormattingParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.TextEdit[]|nil
function LSPRequestClient.textDocument_onTypeFormatting(bufnr, args, opts) end

--- A request to rename a symbol.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.RenameParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.WorkspaceEdit|nil
function LSPRequestClient.textDocument_rename(bufnr, args, opts) end

--- A request to test and perform the setup necessary for a rename.
---
--- @since 3.16 - support for default behavior
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.PrepareRenameParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.PrepareRenameResult|nil
function LSPRequestClient.textDocument_prepareRename(bufnr, args, opts) end

--- A request send from the client to the server to execute a command. The request might return
--- a workspace edit which the client will apply to the workspace.
---@async
---@param bufnr integer Buffer number (0 for current buffer)
---@param args dapui.async.lsp.types.ExecuteCommandParams
---@param opts? dapui.async.lsp.RequestOpts Options for the request handling
---@return dapui.async.lsp.types.LSPAny|nil
function LSPRequestClient.workspace_executeCommand(bufnr, args, opts) end

---@class dapui.async.lsp.NotifyClient
local LSPNotifyClient = {}

--- The `workspace/didChangeWorkspaceFolders` notification is sent from the client to the server when the workspace
--- folder configuration changes.
---@async
---@param args dapui.async.lsp.types.DidChangeWorkspaceFoldersParams
function LSPNotifyClient.workspace_didChangeWorkspaceFolders(args) end

--- The `window/workDoneProgress/cancel` notification is sent from  the client to the server to cancel a progress
--- initiated on the server side.
---@async
---@param args dapui.async.lsp.types.WorkDoneProgressCancelParams
function LSPNotifyClient.window_workDoneProgress_cancel(args) end

--- The did create files notification is sent from the client to the server when
--- files were created from within the client.
---
--- @since 3.16.0
---@async
---@param args dapui.async.lsp.types.CreateFilesParams
function LSPNotifyClient.workspace_didCreateFiles(args) end

--- The did rename files notification is sent from the client to the server when
--- files were renamed from within the client.
---
--- @since 3.16.0
---@async
---@param args dapui.async.lsp.types.RenameFilesParams
function LSPNotifyClient.workspace_didRenameFiles(args) end

--- The will delete files request is sent from the client to the server before files are actually
--- deleted as long as the deletion is triggered from within the client.
---
--- @since 3.16.0
---@async
---@param args dapui.async.lsp.types.DeleteFilesParams
function LSPNotifyClient.workspace_didDeleteFiles(args) end

--- A notification sent when a notebook opens.
---
--- @since 3.17.0
---@async
---@param args dapui.async.lsp.types.DidOpenNotebookDocumentParams
function LSPNotifyClient.notebookDocument_didOpen(args) end

---@async
---@param args dapui.async.lsp.types.DidChangeNotebookDocumentParams
function LSPNotifyClient.notebookDocument_didChange(args) end

--- A notification sent when a notebook document is saved.
---
--- @since 3.17.0
---@async
---@param args dapui.async.lsp.types.DidSaveNotebookDocumentParams
function LSPNotifyClient.notebookDocument_didSave(args) end

--- A notification sent when a notebook closes.
---
--- @since 3.17.0
---@async
---@param args dapui.async.lsp.types.DidCloseNotebookDocumentParams
function LSPNotifyClient.notebookDocument_didClose(args) end

--- The initialized notification is sent from the client to the
--- server after the client is fully initialized and the server
--- is allowed to send requests from the server to the client.
---@async
---@param args dapui.async.lsp.types.InitializedParams
function LSPNotifyClient.initialized(args) end

--- The exit event is sent from the client to the server to
--- ask the server to exit its process.
---@async
--- The configuration change notification is sent from the client to the server
--- when the client's configuration has changed. The notification contains
--- the changed configuration as defined by the language client.
---@async
---@param args dapui.async.lsp.types.DidChangeConfigurationParams
function LSPNotifyClient.workspace_didChangeConfiguration(args) end

--- The document open notification is sent from the client to the server to signal
--- newly opened text documents. The document's truth is now managed by the client
--- and the server must not try to read the document's truth using the document's
--- uri. Open in this sense means it is managed by the client. It doesn't necessarily
--- mean that its content is presented in an editor. An open notification must not
--- be sent more than once without a corresponding close notification send before.
--- This means open and close notification must be balanced and the max open count
--- is one.
---@async
---@param args dapui.async.lsp.types.DidOpenTextDocumentParams
function LSPNotifyClient.textDocument_didOpen(args) end

--- The document change notification is sent from the client to the server to signal
--- changes to a text document.
---@async
---@param args dapui.async.lsp.types.DidChangeTextDocumentParams
function LSPNotifyClient.textDocument_didChange(args) end

--- The document close notification is sent from the client to the server when
--- the document got closed in the client. The document's truth now exists where
--- the document's uri points to (e.g. if the document's uri is a file uri the
--- truth now exists on disk). As with the open notification the close notification
--- is about managing the document's content. Receiving a close notification
--- doesn't mean that the document was open in an editor before. A close
--- notification requires a previous open notification to be sent.
---@async
---@param args dapui.async.lsp.types.DidCloseTextDocumentParams
function LSPNotifyClient.textDocument_didClose(args) end

--- The document save notification is sent from the client to the server when
--- the document got saved in the client.
---@async
---@param args dapui.async.lsp.types.DidSaveTextDocumentParams
function LSPNotifyClient.textDocument_didSave(args) end

--- A document will save notification is sent from the client to the server before
--- the document is actually saved.
---@async
---@param args dapui.async.lsp.types.WillSaveTextDocumentParams
function LSPNotifyClient.textDocument_willSave(args) end

--- The watched files notification is sent from the client to the server when
--- the client detects changes to file watched by the language client.
---@async
---@param args dapui.async.lsp.types.DidChangeWatchedFilesParams
function LSPNotifyClient.workspace_didChangeWatchedFiles(args) end

---@async
---@param args dapui.async.lsp.types.SetTraceParams
function LSPNotifyClient.__setTrace(args) end

---@async
---@param args dapui.async.lsp.types.CancelParams
function LSPNotifyClient.__cancelRequest(args) end

---@async
---@param args dapui.async.lsp.types.ProgressParams
function LSPNotifyClient.__progress(args) end

---@alias dapui.async.lsp.types.URI string
---@alias dapui.async.lsp.types.DocumentUri string

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration. If this is set to `true` the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)` return value for the corresponding server capability as well.
---@field requests dapui.async.lsp.types.Structure0 Which requests the client supports and might send to the server depending on the server's capability. Please note that clients might not show semantic tokens or degrade some of the user experience if a range or full request is advertised by the client but not provided by the server. If for example the client capability `requests.full` and `request.range` are both set to true but the server only provides a range provider the client might not render a minimap correctly or might even decide to not show any semantic tokens at all.
---@field tokenTypes string[] The token types that the client supports.
---@field tokenModifiers string[] The token modifiers that the client supports.
---@field formats dapui.async.lsp.types.TokenFormat[] The token formats the clients supports.
---@field overlappingTokenSupport? boolean Whether the client supports tokens that can overlap each other.
---@field multilineTokenSupport? boolean Whether the client supports tokens that can span multiple lines.
---@field serverCancelSupport? boolean Whether the client allows the server to actively cancel a semantic token request, e.g. supports returning LSPErrorCodes.ServerCancelled. If a server does the client needs to retrigger the request.  @since 3.17.0
---@field augmentsSyntaxTokens? boolean Whether the client uses semantic tokens to augment existing syntax tokens. If set to `true` client side created syntax tokens and semantic tokens are both used for colorization. If set to `false` the client only uses the returned semantic tokens for colorization.  If the value is `undefined` then the client behavior is not specified.  @since 3.17.0

--- Client capabilities for the linked editing range request.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.LinkedEditingRangeClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration. If this is set to `true` the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)` return value for the corresponding server capability as well.

--- Client capabilities specific to the moniker request.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.MonikerClientCapabilities
---@field dynamicRegistration? boolean Whether moniker supports dynamic registration. If this is set to `true` the client supports the new `MonikerRegistrationOptions` return value for the corresponding server capability as well.

--- @since 3.17.0
---@class dapui.async.lsp.types.TypeHierarchyClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration. If this is set to `true` the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)` return value for the corresponding server capability as well.

--- Client capabilities specific to inline values.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlineValueClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration for inline value providers.

---@class dapui.async.lsp.types.Structure43
---@field valueSet? dapui.async.lsp.types.FoldingRangeKind[] The folding range kind values the client supports. When this property exists the client also guarantees that it will handle values outside its set gracefully and falls back to a default value when unknown.

--- Inlay hint client capabilities.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlayHintClientCapabilities
---@field dynamicRegistration? boolean Whether inlay hints support dynamic registration.
---@field resolveSupport? dapui.async.lsp.types.Structure1 Indicates which properties a client can resolve lazily on an inlay hint.

--- Client capabilities specific to diagnostic pull requests.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DiagnosticClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration. If this is set to `true` the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)` return value for the corresponding server capability as well.
---@field relatedDocumentSupport? boolean Whether the clients supports related documents for document diagnostic pulls.

--- Notebook specific client capabilities.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.NotebookDocumentSyncClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration. If this is set to `true` the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)` return value for the corresponding server capability as well.
---@field executionSummarySupport? boolean The client supports sending execution summary data per cell.

--- Describe options to be used when registered for text document change events.
---@class dapui.async.lsp.types.DidChangeWatchedFilesRegistrationOptions
---@field watchers dapui.async.lsp.types.FileSystemWatcher[] The watchers to register.

--- Show message request client capabilities
---@class dapui.async.lsp.types.ShowMessageRequestClientCapabilities
---@field messageActionItem? dapui.async.lsp.types.Structure2 Capabilities specific to the `MessageActionItem` type.

--- The publish diagnostic notification's parameters.
---@class dapui.async.lsp.types.PublishDiagnosticsParams
---@field uri dapui.async.lsp.types.DocumentUri The URI for which diagnostic information is reported.
---@field version? integer Optional the version number of the document the diagnostics are published for.  @since 3.15.0
---@field diagnostics dapui.async.lsp.types.Diagnostic[] An array of diagnostic information items.

--- Client capabilities for the showDocument request.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.ShowDocumentClientCapabilities
---@field support boolean The client has support for the showDocument request.

---@class dapui.async.lsp.types.SetTraceParams
---@field value dapui.async.lsp.types.TraceValues

---@class dapui.async.lsp.types.LogTraceParams
---@field message string
---@field verbose? string

---@class dapui.async.lsp.types.CancelParams
---@field id integer|string The request id to cancel.

---@class dapui.async.lsp.types.ProgressParams
---@field token dapui.async.lsp.types.ProgressToken The progress token provided by the client or server.
---@field value dapui.async.lsp.types.LSPAny The progress data.

--- A parameter literal used in requests to pass a text document and a position inside that
--- document.
---@class dapui.async.lsp.types.TextDocumentPositionParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.
---@field position dapui.async.lsp.types.Position The position inside the text document.

---@class dapui.async.lsp.types.WorkDoneProgressParams
---@field workDoneToken? dapui.async.lsp.types.ProgressToken An optional token that a server can use to report work done progress.

---@class dapui.async.lsp.types.ImplementationOptions : dapui.async.lsp.types.WorkDoneProgressOptions

--- Static registration options to be returned in the initialize
--- request.
---@class dapui.async.lsp.types.StaticRegistrationOptions
---@field id? string The id used to register the request. The id can be used to deregister the request again. See also Registration#id.

---@class dapui.async.lsp.types.TypeDefinitionOptions : dapui.async.lsp.types.WorkDoneProgressOptions

--- A relative pattern is a helper to construct glob patterns that are matched
--- relatively to a base URI. The common value for a `baseUri` is a workspace
--- folder root, but it can be another absolute URI as well.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.RelativePattern
---@field baseUri dapui.async.lsp.types.WorkspaceFolder|dapui.async.lsp.types.URI A workspace folder or a base URI to which this pattern will be matched against relatively.
---@field pattern dapui.async.lsp.types.Pattern The actual glob pattern;

--- The workspace folder change event.
---@class dapui.async.lsp.types.WorkspaceFoldersChangeEvent
---@field added dapui.async.lsp.types.WorkspaceFolder[] The array of added workspace folders
---@field removed dapui.async.lsp.types.WorkspaceFolder[] The array of the removed workspace folders
---@alias dapui.async.lsp.types.Pattern string

---@class dapui.async.lsp.types.Structure1
---@field properties string[] The properties that a client can resolve lazily.

---@class dapui.async.lsp.types.ConfigurationItem
---@field scopeUri? string The scope to get the configuration section for.
---@field section? string The configuration section asked for.
---@alias dapui.async.lsp.types.ProgressToken integer|string
--- A pattern kind describing if a glob pattern matches a file a folder or
--- both.
---
--- @since 3.16.0
---@alias dapui.async.lsp.types.FileOperationPatternKind "file"|"folder"

--- A literal to identify a text document in the client.
---@class dapui.async.lsp.types.TextDocumentIdentifier
---@field uri dapui.async.lsp.types.DocumentUri The text document's uri.

--- Matching options for the file operation pattern.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.FileOperationPatternOptions
---@field ignoreCase? boolean The pattern should be matched ignoring casing.

--- A full document diagnostic report for a workspace diagnostic result.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.WorkspaceFullDocumentDiagnosticReport : dapui.async.lsp.types.FullDocumentDiagnosticReport
---@field uri dapui.async.lsp.types.DocumentUri The URI for which diagnostic information is reported.
---@field version integer|nil The version number for which the diagnostics are reported. If the document is not marked as open `null` can be provided.

---@class dapui.async.lsp.types.DocumentColorOptions : dapui.async.lsp.types.WorkDoneProgressOptions

--- An unchanged document diagnostic report for a workspace diagnostic result.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.WorkspaceUnchangedDocumentDiagnosticReport : dapui.async.lsp.types.UnchangedDocumentDiagnosticReport
---@field uri dapui.async.lsp.types.DocumentUri The URI for which diagnostic information is reported.
---@field version integer|nil The version number for which the diagnostics are reported. If the document is not marked as open `null` can be provided.
--- A notebook cell kind.
---
--- @since 3.17.0
---@alias dapui.async.lsp.types.NotebookCellKind 1|2

---@alias dapui.async.lsp.types.DocumentSelector dapui.async.lsp.types.DocumentFilter[]

---@class dapui.async.lsp.types.ExecutionSummary
---@field executionOrder integer A strict monotonically increasing value indicating the execution order of a cell inside a notebook.
---@field success? boolean Whether the execution was successful or not if known by the client.

--- Represents a color in RGBA space.
---@class dapui.async.lsp.types.Color
---@field red number The red component of this color in the range [0-1].
---@field green number The green component of this color in the range [0-1].
---@field blue number The blue component of this color in the range [0-1].
---@field alpha number The alpha component of this color in the range [0-1].

--- Workspace specific client capabilities.
---@class dapui.async.lsp.types.WorkspaceClientCapabilities
---@field applyEdit? boolean The client supports applying batch edits to the workspace by supporting the request 'workspace/applyEdit'
---@field workspaceEdit? dapui.async.lsp.types.WorkspaceEditClientCapabilities Capabilities specific to `WorkspaceEdit`s.
---@field didChangeConfiguration? dapui.async.lsp.types.DidChangeConfigurationClientCapabilities Capabilities specific to the `workspace/didChangeConfiguration` notification.
---@field didChangeWatchedFiles? dapui.async.lsp.types.DidChangeWatchedFilesClientCapabilities Capabilities specific to the `workspace/didChangeWatchedFiles` notification.
---@field symbol? dapui.async.lsp.types.WorkspaceSymbolClientCapabilities Capabilities specific to the `workspace/symbol` request.
---@field executeCommand? dapui.async.lsp.types.ExecuteCommandClientCapabilities Capabilities specific to the `workspace/executeCommand` request.
---@field workspaceFolders? boolean The client has support for workspace folders.  @since 3.6.0
---@field configuration? boolean The client supports `workspace/configuration` requests.  @since 3.6.0
---@field semanticTokens? dapui.async.lsp.types.SemanticTokensWorkspaceClientCapabilities Capabilities specific to the semantic token requests scoped to the workspace.  @since 3.16.0.
---@field codeLens? dapui.async.lsp.types.CodeLensWorkspaceClientCapabilities Capabilities specific to the code lens requests scoped to the workspace.  @since 3.16.0.
---@field fileOperations? dapui.async.lsp.types.FileOperationClientCapabilities The client has support for file notifications/requests for user operations on files.  Since 3.16.0
---@field inlineValue? dapui.async.lsp.types.InlineValueWorkspaceClientCapabilities Capabilities specific to the inline values requests scoped to the workspace.  @since 3.17.0.
---@field inlayHint? dapui.async.lsp.types.InlayHintWorkspaceClientCapabilities Capabilities specific to the inlay hint requests scoped to the workspace.  @since 3.17.0.
---@field diagnostics? dapui.async.lsp.types.DiagnosticWorkspaceClientCapabilities Capabilities specific to the diagnostic requests scoped to the workspace.  @since 3.17.0.

--- Text document specific client capabilities.
---@class dapui.async.lsp.types.TextDocumentClientCapabilities
---@field synchronization? dapui.async.lsp.types.TextDocumentSyncClientCapabilities Defines which synchronization capabilities the client supports.
---@field completion? dapui.async.lsp.types.CompletionClientCapabilities Capabilities specific to the `textDocument/completion` request.
---@field hover? dapui.async.lsp.types.HoverClientCapabilities Capabilities specific to the `textDocument/hover` request.
---@field signatureHelp? dapui.async.lsp.types.SignatureHelpClientCapabilities Capabilities specific to the `textDocument/signatureHelp` request.
---@field declaration? dapui.async.lsp.types.DeclarationClientCapabilities Capabilities specific to the `textDocument/declaration` request.  @since 3.14.0
---@field definition? dapui.async.lsp.types.DefinitionClientCapabilities Capabilities specific to the `textDocument/definition` request.
---@field typeDefinition? dapui.async.lsp.types.TypeDefinitionClientCapabilities Capabilities specific to the `textDocument/typeDefinition` request.  @since 3.6.0
---@field implementation? dapui.async.lsp.types.ImplementationClientCapabilities Capabilities specific to the `textDocument/implementation` request.  @since 3.6.0
---@field references? dapui.async.lsp.types.ReferenceClientCapabilities Capabilities specific to the `textDocument/references` request.
---@field documentHighlight? dapui.async.lsp.types.DocumentHighlightClientCapabilities Capabilities specific to the `textDocument/documentHighlight` request.
---@field documentSymbol? dapui.async.lsp.types.DocumentSymbolClientCapabilities Capabilities specific to the `textDocument/documentSymbol` request.
---@field codeAction? dapui.async.lsp.types.CodeActionClientCapabilities Capabilities specific to the `textDocument/codeAction` request.
---@field codeLens? dapui.async.lsp.types.CodeLensClientCapabilities Capabilities specific to the `textDocument/codeLens` request.
---@field documentLink? dapui.async.lsp.types.DocumentLinkClientCapabilities Capabilities specific to the `textDocument/documentLink` request.
---@field colorProvider? dapui.async.lsp.types.DocumentColorClientCapabilities Capabilities specific to the `textDocument/documentColor` and the `textDocument/colorPresentation` request.  @since 3.6.0
---@field formatting? dapui.async.lsp.types.DocumentFormattingClientCapabilities Capabilities specific to the `textDocument/formatting` request.
---@field rangeFormatting? dapui.async.lsp.types.DocumentRangeFormattingClientCapabilities Capabilities specific to the `textDocument/rangeFormatting` request.
---@field onTypeFormatting? dapui.async.lsp.types.DocumentOnTypeFormattingClientCapabilities Capabilities specific to the `textDocument/onTypeFormatting` request.
---@field rename? dapui.async.lsp.types.RenameClientCapabilities Capabilities specific to the `textDocument/rename` request.
---@field foldingRange? dapui.async.lsp.types.FoldingRangeClientCapabilities Capabilities specific to the `textDocument/foldingRange` request.  @since 3.10.0
---@field selectionRange? dapui.async.lsp.types.SelectionRangeClientCapabilities Capabilities specific to the `textDocument/selectionRange` request.  @since 3.15.0
---@field publishDiagnostics? dapui.async.lsp.types.PublishDiagnosticsClientCapabilities Capabilities specific to the `textDocument/publishDiagnostics` notification.
---@field callHierarchy? dapui.async.lsp.types.CallHierarchyClientCapabilities Capabilities specific to the various call hierarchy requests.  @since 3.16.0
---@field semanticTokens? dapui.async.lsp.types.SemanticTokensClientCapabilities Capabilities specific to the various semantic token request.  @since 3.16.0
---@field linkedEditingRange? dapui.async.lsp.types.LinkedEditingRangeClientCapabilities Capabilities specific to the `textDocument/linkedEditingRange` request.  @since 3.16.0
---@field moniker? dapui.async.lsp.types.MonikerClientCapabilities Client capabilities specific to the `textDocument/moniker` request.  @since 3.16.0
---@field typeHierarchy? dapui.async.lsp.types.TypeHierarchyClientCapabilities Capabilities specific to the various type hierarchy requests.  @since 3.17.0
---@field inlineValue? dapui.async.lsp.types.InlineValueClientCapabilities Capabilities specific to the `textDocument/inlineValue` request.  @since 3.17.0
---@field inlayHint? dapui.async.lsp.types.InlayHintClientCapabilities Capabilities specific to the `textDocument/inlayHint` request.  @since 3.17.0
---@field diagnostic? dapui.async.lsp.types.DiagnosticClientCapabilities Capabilities specific to the diagnostic pull model.  @since 3.17.0

--- Capabilities specific to the notebook document support.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.NotebookDocumentClientCapabilities
---@field synchronization dapui.async.lsp.types.NotebookDocumentSyncClientCapabilities Capabilities specific to notebook document synchronization  @since 3.17.0

---@class dapui.async.lsp.types.Structure2
---@field additionalPropertiesSupport? boolean Whether the client supports additional attributes which are preserved and send back to the server in the request's response.

---@class dapui.async.lsp.types.WindowClientCapabilities
---@field workDoneProgress? boolean It indicates whether the client supports server initiated progress using the `window/workDoneProgress/create` request.  The capability also controls Whether client supports handling of progress notifications. If set servers are allowed to report a `workDoneProgress` property in the request specific server capabilities.  @since 3.15.0
---@field showMessage? dapui.async.lsp.types.ShowMessageRequestClientCapabilities Capabilities specific to the showMessage request.  @since 3.16.0
---@field showDocument? dapui.async.lsp.types.ShowDocumentClientCapabilities Capabilities specific to the showDocument request.  @since 3.16.0

---@class dapui.async.lsp.types.FoldingRangeOptions : dapui.async.lsp.types.WorkDoneProgressOptions

---@class dapui.async.lsp.types.DeclarationOptions : dapui.async.lsp.types.WorkDoneProgressOptions

--- General client capabilities.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.GeneralClientCapabilities
---@field staleRequestSupport? dapui.async.lsp.types.Structure3 Client capability that signals how the client handles stale requests (e.g. a request for which the client will not process the response anymore since the information is outdated).  @since 3.17.0
---@field regularExpressions? dapui.async.lsp.types.RegularExpressionsClientCapabilities Client capabilities specific to regular expressions.  @since 3.16.0
---@field markdown? dapui.async.lsp.types.MarkdownClientCapabilities Client capabilities specific to the client's markdown parser.  @since 3.16.0
---@field positionEncodings? dapui.async.lsp.types.PositionEncodingKind[] The position encodings supported by the client. Client and server have to agree on the same position encoding to ensure that offsets (e.g. character position in a line) are interpreted the same on both sides.  To keep the protocol backwards compatible the following applies: if the value 'utf-16' is missing from the array of position encodings servers can assume that the client supports UTF-16. UTF-16 is therefore a mandatory encoding.  If omitted it defaults to ['utf-16'].  Implementation considerations: since the conversion from one encoding into another requires the content of the file / line the conversion is best done where the file is read which is usually on the server side.  @since 3.17.0

---@class dapui.async.lsp.types.SelectionRangeOptions : dapui.async.lsp.types.WorkDoneProgressOptions
--- Symbol tags are extra annotations that tweak the rendering of a symbol.
---
--- @since 3.16
---@alias dapui.async.lsp.types.SymbolTag 1

---@class dapui.async.lsp.types.Structure13
---@field range dapui.async.lsp.types.Range
---@field placeholder string
--- A set of predefined position encoding kinds.
---
--- @since 3.17.0
---@alias dapui.async.lsp.types.PositionEncodingKind "utf-8"|"utf-16"|"utf-32"

---@class dapui.async.lsp.types.Structure9
---@field commitCharacters? string[] A default commit character set.  @since 3.17.0
---@field editRange? dapui.async.lsp.types.Range|dapui.async.lsp.types.Structure46 A default edit range.  @since 3.17.0
---@field insertTextFormat? dapui.async.lsp.types.InsertTextFormat A default insert text format.  @since 3.17.0
---@field insertTextMode? dapui.async.lsp.types.InsertTextMode A default insert text mode.  @since 3.17.0
---@field data? dapui.async.lsp.types.LSPAny A default data value.  @since 3.17.0

---@class dapui.async.lsp.types.Structure14
---@field defaultBehavior boolean

--- Position in a text document expressed as zero-based line and character
--- offset. Prior to 3.17 the offsets were always based on a UTF-16 string
--- representation. So a string of the form `a𐐀b` the character offset of the
--- character `a` is 0, the character offset of `𐐀` is 1 and the character
--- offset of b is 3 since `𐐀` is represented using two code units in UTF-16.
--- Since 3.17 clients and servers can agree on a different string encoding
--- representation (e.g. UTF-8). The client announces it's supported encoding
--- via the client capability [`general.positionEncodings`](#clientCapabilities).
--- The value is an array of position encodings the client supports, with
--- decreasing preference (e.g. the encoding at index `0` is the most preferred
--- one). To stay backwards compatible the only mandatory encoding is UTF-16
--- represented via the string `utf-16`. The server can pick one of the
--- encodings offered by the client and signals that encoding back to the
--- client via the initialize result's property
--- [`capabilities.positionEncoding`](#serverCapabilities). If the string value
--- `utf-16` is missing from the client's capability `general.positionEncodings`
--- servers can safely assume that the client supports UTF-16. If the server
--- omits the position encoding in its initialize result the encoding defaults
--- to the string value `utf-16`. Implementation considerations: since the
--- conversion from one encoding into another requires the content of the
--- file / line the conversion is best done where the file is read which is
--- usually on the server side.
---
--- Positions are line end character agnostic. So you can not specify a position
--- that denotes `\r|\n` or `\n|` where `|` represents the character offset.
---
--- @since 3.17.0 - support for negotiated position encoding.
---@class dapui.async.lsp.types.Position
---@field line integer Line position in a document (zero-based).  If a line number is greater than the number of lines in a document, it defaults back to the number of lines in the document. If a line number is negative, it defaults to 0.
---@field character integer Character offset on a line in a document (zero-based).  The meaning of this offset is determined by the negotiated `PositionEncodingKind`.  If the character value is greater than the line length it defaults back to the line length.

--- Call hierarchy options used during static registration.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.CallHierarchyOptions : dapui.async.lsp.types.WorkDoneProgressOptions
--- The kind of a completion entry.
---@alias dapui.async.lsp.types.CompletionItemKind 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25

--- Provider options for a [CodeActionRequest](#CodeActionRequest).
---@class dapui.async.lsp.types.CodeActionOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field codeActionKinds? dapui.async.lsp.types.CodeActionKind[] CodeActionKinds that this server may return.  The list of kinds may be generic, such as `CodeActionKind.Refactor`, or the server may list out every specific kind they provide.
---@field resolveProvider? boolean The server provides support to resolve additional information for a code action.  @since 3.16.0
--- Completion item tags are extra annotations that tweak the rendering of a completion
--- item.
---
--- @since 3.15.0
---@alias dapui.async.lsp.types.CompletionItemTag 1

--- Describes the content type that a client supports in various
--- result literals like `Hover`, `ParameterInfo` or `CompletionItem`.
---
--- Please note that `MarkupKinds` must not start with a `$`. This kinds
--- are reserved for internal usage.
---@alias dapui.async.lsp.types.MarkupKind "plaintext"|"markdown"

--- How whitespace and indentation is handled during completion
--- item insertion.
---
--- @since 3.16.0
---@alias dapui.async.lsp.types.InsertTextMode 1|2

--- Server capabilities for a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
---@class dapui.async.lsp.types.WorkspaceSymbolOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field resolveProvider? boolean The server provides support to resolve additional information for a workspace symbol.  @since 3.17.0

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field legend dapui.async.lsp.types.SemanticTokensLegend The legend used by the server
---@field range? boolean|dapui.async.lsp.types.Structure4 Server supports providing semantic tokens for a specific range of a document.
---@field full? boolean|dapui.async.lsp.types.Structure5 Server supports providing semantic tokens for a full document.

--- A range in a text document expressed as (zero-based) start and end positions.
---
--- If you want to specify a range that contains a line including the line ending
--- character(s) then use an end position denoting the start of the next line.
--- For example:
--- ```ts
--- {
---     start: { line: 5, character: 23 }
---     end : { line 6, character : 0 }
--- }
--- ```
---@class dapui.async.lsp.types.Range
---@field start dapui.async.lsp.types.Position The range's start position.
---@field end dapui.async.lsp.types.Position The range's end position.

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensEdit
---@field start integer The start offset of the edit.
---@field deleteCount integer The count of elements to remove.
---@field data? integer[] The elements to insert.

---@class dapui.async.lsp.types.Structure3
---@field cancel boolean The client will actively cancel the request.
---@field retryOnContentModified string[] The list of requests for which the client will retry the request if it receives a response with error code `ContentModified`

---@class dapui.async.lsp.types.LinkedEditingRangeOptions : dapui.async.lsp.types.WorkDoneProgressOptions

--- Represents information on a file/folder create.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.FileCreate
---@field uri string A file:// URI for the location of the file/folder being created.
--- A set of predefined token types. This set is not fixed
--- an clients can specify additional token types via the
--- corresponding client capabilities.
---
--- @since 3.16.0
---@alias dapui.async.lsp.types.SemanticTokenTypes "namespace"|"type"|"class"|"enum"|"interface"|"struct"|"typeParameter"|"parameter"|"variable"|"property"|"enumMember"|"event"|"function"|"method"|"macro"|"keyword"|"modifier"|"comment"|"string"|"number"|"regexp"|"operator"|"decorator"

--- Describes textual changes on a text document. A TextDocumentEdit describes all changes
--- on a document version Si and after they are applied move the document to version Si+1.
--- So the creator of a TextDocumentEdit doesn't need to sort the array of edits or do any
--- kind of ordering. However the edits must be non overlapping.
---@class dapui.async.lsp.types.TextDocumentEdit
---@field textDocument dapui.async.lsp.types.OptionalVersionedTextDocumentIdentifier The text document to change.
---@field edits dapui.async.lsp.types.TextEdit|dapui.async.lsp.types.AnnotatedTextEdit[] The edits to be applied.  @since 3.16.0 - support for AnnotatedTextEdit. This is guarded using a client capability.

--- Create file operation.
---@class dapui.async.lsp.types.CreateFile : dapui.async.lsp.types.ResourceOperation
---@field kind 'create' A create
---@field uri dapui.async.lsp.types.DocumentUri The resource to create.
---@field options? dapui.async.lsp.types.CreateFileOptions Additional options

---@class dapui.async.lsp.types.DeclarationParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams

---@class dapui.async.lsp.types.DeclarationRegistrationOptions : dapui.async.lsp.types.DeclarationOptions,dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.StaticRegistrationOptions
--- The document diagnostic report kinds.
---
--- @since 3.17.0
---@alias dapui.async.lsp.types.DocumentDiagnosticReportKind "full"|"unchanged"

--- A selection range represents a part of a selection hierarchy. A selection range
--- may have a parent selection range that contains it.
---@class dapui.async.lsp.types.SelectionRange
---@field range dapui.async.lsp.types.Range The [range](#Range) of this selection range.
---@field parent? dapui.async.lsp.types.SelectionRange The parent selection range containing this range. Therefore `parent.range` must contain `this.range`.

--- A parameter literal used in selection range requests.
---@class dapui.async.lsp.types.SelectionRangeParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.
---@field positions dapui.async.lsp.types.Position[] The positions inside the text document.

---@class dapui.async.lsp.types.SelectionRangeRegistrationOptions : dapui.async.lsp.types.SelectionRangeOptions,dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- A filter to describe in which file operation requests or notifications
--- the server is interested in receiving.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.FileOperationFilter
---@field scheme? string A Uri scheme like `file` or `untitled`.
---@field pattern dapui.async.lsp.types.FileOperationPattern The actual file operation pattern.

--- Represents programming constructs like functions or constructors in the context
--- of call hierarchy.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.CallHierarchyItem
---@field name string The name of this item.
---@field kind dapui.async.lsp.types.SymbolKind The kind of this item.
---@field tags? dapui.async.lsp.types.SymbolTag[] Tags for this item.
---@field detail? string More detail for this item, e.g. the signature of a function.
---@field uri dapui.async.lsp.types.DocumentUri The resource identifier of this item.
---@field range dapui.async.lsp.types.Range The range enclosing this symbol not including leading/trailing whitespace but everything else, e.g. comments and code.
---@field selectionRange dapui.async.lsp.types.Range The range that should be selected and revealed when this symbol is being picked, e.g. the name of a function. Must be contained by the [`range`](#CallHierarchyItem.range).
---@field data? dapui.async.lsp.types.LSPAny A data entry field that is preserved between a call hierarchy prepare and incoming calls or outgoing calls requests.

--- The parameter of a `textDocument/prepareCallHierarchy` request.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.CallHierarchyPrepareParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams

--- Call hierarchy options used during static or dynamic registration.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.CallHierarchyRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.CallHierarchyOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- Represents information on a file/folder delete.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.FileDelete
---@field uri string A file:// URI for the location of the file/folder being deleted.

--- Represents an incoming call, e.g. a caller of a method or constructor.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.CallHierarchyIncomingCall
---@field from dapui.async.lsp.types.CallHierarchyItem The item that makes the call.
---@field fromRanges dapui.async.lsp.types.Range[] The ranges at which the calls appear. This is relative to the caller denoted by [`this.from`](#CallHierarchyIncomingCall.from).

--- The parameter of a `callHierarchy/incomingCalls` request.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.CallHierarchyIncomingCallsParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field item dapui.async.lsp.types.CallHierarchyItem

--- Represents an outgoing call, e.g. calling a getter from a method or a method from a constructor etc.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.CallHierarchyOutgoingCall
---@field to dapui.async.lsp.types.CallHierarchyItem The item that is called.
---@field fromRanges dapui.async.lsp.types.Range[] The range at which this item is called. This is the range relative to the caller, e.g the item passed to [`provideCallHierarchyOutgoingCalls`](#CallHierarchyItemProvider.provideCallHierarchyOutgoingCalls) and not [`this.to`](#CallHierarchyOutgoingCall.to).

--- The parameter of a `callHierarchy/outgoingCalls` request.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.CallHierarchyOutgoingCallsParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field item dapui.async.lsp.types.CallHierarchyItem
--- Moniker uniqueness level to define scope of the moniker.
---
--- @since 3.16.0
---@alias dapui.async.lsp.types.UniquenessLevel "document"|"project"|"group"|"scheme"|"global"

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokens
---@field resultId? string An optional result id. If provided and clients support delta updating the client will include the result id in the next semantic token request. A server can then instead of computing all semantic tokens again simply send a delta.
---@field data integer[] The actual tokens.

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensPartialResult
---@field data integer[]

---@class dapui.async.lsp.types.MonikerOptions : dapui.async.lsp.types.WorkDoneProgressOptions

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.SemanticTokensOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensDelta
---@field resultId? string
---@field edits dapui.async.lsp.types.SemanticTokensEdit[] The semantic token edits to transform a previous result into a new result.

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensDeltaParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.
---@field previousResultId string The result id of a previous response. The result Id can either point to a full response or a delta response depending on what was received last.

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensDeltaPartialResult
---@field edits dapui.async.lsp.types.SemanticTokensEdit[]

---@class dapui.async.lsp.types.Structure34
---@field valueSet? dapui.async.lsp.types.CompletionItemKind[] The completion item kind values the client supports. When this property exists the client also guarantees that it will handle values outside its set gracefully and falls back to a default value when unknown.  If this property is not present the client only supports the completion items kinds from `Text` to `Reference` as defined in the initial version of the protocol.

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensRangeParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.
---@field range dapui.async.lsp.types.Range The range the semantic tokens are requested for.

--- The result of a showDocument request.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.ShowDocumentResult
---@field success boolean A boolean indicating if the show was successful.

--- Params to show a document.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.ShowDocumentParams
---@field uri dapui.async.lsp.types.URI The document uri to show.
---@field external? boolean Indicates to show the resource in an external program. To show for example `https://code.visualstudio.com/` in the default WEB browser set `external` to `true`.
---@field takeFocus? boolean An optional property to indicate whether the editor showing the document should take focus or not. Clients might ignore this property if an external program is started.
---@field selection? dapui.async.lsp.types.Range An optional selection range if the document is a text document. Clients might ignore the property if an external program is started or the file is not a text file.

--- @since 3.17.0
---@class dapui.async.lsp.types.InlineValueContext
---@field frameId integer The stack frame (as a DAP Id) where the execution has stopped.
---@field stoppedLocation dapui.async.lsp.types.Range The document range where execution has stopped. Typically the end position of the range denotes the line where the inline values are shown.

--- The result of a linked editing range request.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.LinkedEditingRanges
---@field ranges dapui.async.lsp.types.Range[] A list of ranges that can be edited together. The ranges must have identical length and contain identical text content. The ranges cannot overlap.
---@field wordPattern? string An optional word pattern (regular expression) that describes valid contents for the given ranges. If no pattern is provided, the client configuration's word pattern will be used.

---@class dapui.async.lsp.types.LinkedEditingRangeParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams

---@class dapui.async.lsp.types.LinkedEditingRangeRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.LinkedEditingRangeOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- A workspace edit represents changes to many resources managed in the workspace. The edit
--- should either provide `changes` or `documentChanges`. If documentChanges are present
--- they are preferred over `changes` if the client can handle versioned document edits.
---
--- Since version 3.13.0 a workspace edit can contain resource operations as well. If resource
--- operations are present clients need to execute the operations in the order in which they
--- are provided. So a workspace edit for example can consist of the following two changes:
--- (1) a create file a.txt and (2) a text document edit which insert text into file a.txt.
---
--- An invalid sequence (e.g. (1) delete file a.txt and (2) insert text into file a.txt) will
--- cause failure of the operation. How the client recovers from the failure is described by
--- the client capability: `workspace.workspaceEdit.failureHandling`
---@class dapui.async.lsp.types.WorkspaceEdit
---@field changes? table<dapui.async.lsp.types.DocumentUri, dapui.async.lsp.types.TextEdit[]> Holds changes to existing resources.
---@field documentChanges? dapui.async.lsp.types.TextDocumentEdit|dapui.async.lsp.types.CreateFile|dapui.async.lsp.types.RenameFile|dapui.async.lsp.types.DeleteFile[] Depending on the client capability `workspace.workspaceEdit.resourceOperations` document changes are either an array of `TextDocumentEdit`s to express changes to n different text documents where each text document edit addresses a specific version of a text document. Or it can contain above `TextDocumentEdit`s mixed with create, rename and delete file / folder operations.  Whether a client supports versioned document edits is expressed via `workspace.workspaceEdit.documentChanges` client capability.  If a client neither supports `documentChanges` nor `workspace.workspaceEdit.resourceOperations` then only plain `TextEdit`s using the `changes` property are supported.
---@field changeAnnotations? table<dapui.async.lsp.types.ChangeAnnotationIdentifier, dapui.async.lsp.types.ChangeAnnotation> A map of change annotations that can be referenced in `AnnotatedTextEdit`s or create, rename and delete file / folder operations.  Whether clients honor this property depends on the client capability `workspace.changeAnnotationSupport`.  @since 3.16.0

--- An inlay hint label part allows for interactive and composite labels
--- of inlay hints.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlayHintLabelPart
---@field value string The value of this label part.
---@field tooltip? string|dapui.async.lsp.types.MarkupContent The tooltip text when you hover over this label part. Depending on the client capability `inlayHint.resolveSupport` clients might resolve this property late using the resolve request.
---@field location? dapui.async.lsp.types.Location An optional source code location that represents this label part.  The editor will use this location for the hover and for code navigation features: This part will become a clickable link that resolves to the definition of the symbol at the given location (not necessarily the location itself), it shows the hover that shows at the given location, and it shows a context menu with further code navigation commands.  Depending on the client capability `inlayHint.resolveSupport` clients might resolve this property late using the resolve request.
---@field command? dapui.async.lsp.types.Command An optional command for this label part.  Depending on the client capability `inlayHint.resolveSupport` clients might resolve this property late using the resolve request.

--- The options to register for file operations.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.FileOperationRegistrationOptions
---@field filters dapui.async.lsp.types.FileOperationFilter[] The actual filters.
--- Inlay hint kinds.
---
--- @since 3.17.0
---@alias dapui.async.lsp.types.InlayHintKind 1|2

--- The parameters sent in notifications/requests for user-initiated renames of
--- files.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.RenameFilesParams
---@field files dapui.async.lsp.types.FileRename[] An array of all files/folders renamed in this operation. When a folder is renamed, only the folder will be included, and not its children.

---@class dapui.async.lsp.types.Structure35
---@field itemDefaults? string[] The client supports the following itemDefaults on a completion list.  The value lists the supported property names of the `CompletionList.itemDefaults` object. If omitted no properties are supported.  @since 3.17.0

--- A `MarkupContent` literal represents a string value which content is interpreted base on its
--- kind flag. Currently the protocol supports `plaintext` and `markdown` as markup kinds.
---
--- If the kind is `markdown` then the value can contain fenced code blocks like in GitHub issues.
--- See https://help.github.com/articles/creating-and-highlighting-code-blocks/#syntax-highlighting
---
--- Here is an example how such a string can be constructed using JavaScript / TypeScript:
--- ```ts
--- let markdown: MarkdownContent = {
---  kind: MarkupKind.Markdown,
---  value: [
---    '# Header',
---    'Some text',
---    '```typescript',
---    'someCode();',
---    '```'
---  ].join('\n')
--- };
--- ```
---
--- *Please Note* that clients might sanitize the return markdown. A client could decide to
--- remove HTML from the markdown to avoid script execution.
---@class dapui.async.lsp.types.MarkupContent
---@field kind dapui.async.lsp.types.MarkupKind The type of the Markup
---@field value string The content itself

--- The parameters sent in notifications/requests for user-initiated deletes of
--- files.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.DeleteFilesParams
---@field files dapui.async.lsp.types.FileDelete[] An array of all files/folders deleted in this operation.

--- Represents the connection of two locations. Provides additional metadata over normal [locations](#Location),
--- including an origin range.
---@class dapui.async.lsp.types.LocationLink
---@field originSelectionRange? dapui.async.lsp.types.Range Span of the origin of this link.  Used as the underlined span for mouse interaction. Defaults to the word range at the definition position.
---@field targetUri dapui.async.lsp.types.DocumentUri The target resource identifier of this link.
---@field targetRange dapui.async.lsp.types.Range The full target range of this link. If the target for example is a symbol then target range is the range enclosing this symbol not including leading/trailing whitespace but everything else like comments. This information is typically used to highlight the range in the editor.
---@field targetSelectionRange dapui.async.lsp.types.Range The range that should be selected and revealed when this link is being followed, e.g the name of a function. Must be contained by the `targetRange`. See also `DocumentSymbol#range`

--- Moniker definition to match LSIF 0.5 moniker definition.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.Moniker
---@field scheme string The scheme of the moniker. For example tsc or .Net
---@field identifier string The identifier of the moniker. The value is opaque in LSIF however schema owners are allowed to define the structure if they want.
---@field unique dapui.async.lsp.types.UniquenessLevel The scope in which the moniker is unique
---@field kind? dapui.async.lsp.types.MonikerKind The moniker kind if known.

---@class dapui.async.lsp.types.MonikerParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams

---@class dapui.async.lsp.types.MonikerRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.MonikerOptions

--- Inlay hint options used during static registration.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlayHintOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field resolveProvider? boolean The server provides support to resolve additional information for an inlay hint item.

--- @since 3.17.0
---@class dapui.async.lsp.types.TypeHierarchyItem
---@field name string The name of this item.
---@field kind dapui.async.lsp.types.SymbolKind The kind of this item.
---@field tags? dapui.async.lsp.types.SymbolTag[] Tags for this item.
---@field detail? string More detail for this item, e.g. the signature of a function.
---@field uri dapui.async.lsp.types.DocumentUri The resource identifier of this item.
---@field range dapui.async.lsp.types.Range The range enclosing this symbol not including leading/trailing whitespace but everything else, e.g. comments and code.
---@field selectionRange dapui.async.lsp.types.Range The range that should be selected and revealed when this symbol is being picked, e.g. the name of a function. Must be contained by the [`range`](#TypeHierarchyItem.range).
---@field data? dapui.async.lsp.types.LSPAny A data entry field that is preserved between a type hierarchy prepare and supertypes or subtypes requests. It could also be used to identify the type hierarchy in the server, helping improve the performance on resolving supertypes and subtypes.

--- The parameter of a `textDocument/prepareTypeHierarchy` request.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.TypeHierarchyPrepareParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams

--- Type hierarchy options used during static or dynamic registration.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.TypeHierarchyRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.TypeHierarchyOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- A diagnostic report with a full set of problems.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.FullDocumentDiagnosticReport
---@field kind 'full' A full document diagnostic report.
---@field resultId? string An optional result id. If provided it will be sent on the next diagnostic request for the same document.
---@field items dapui.async.lsp.types.Diagnostic[] The actual items.

--- A diagnostic report indicating that the last returned
--- report is still accurate.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.UnchangedDocumentDiagnosticReport
---@field kind 'unchanged' A document diagnostic report indicating no changes to the last result. A server can only return `unchanged` if result ids are provided.
---@field resultId string A result id which will be sent on the next diagnostic request for the same document.

--- The parameter of a `typeHierarchy/subtypes` request.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.TypeHierarchySubtypesParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field item dapui.async.lsp.types.TypeHierarchyItem

--- Diagnostic options.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DiagnosticOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field identifier? string An optional identifier under which the diagnostics are managed by the client.
---@field interFileDependencies boolean Whether the language has inter file dependencies meaning that editing code in one file can result in a different diagnostic set in another file. Inter file dependencies are common for most programming languages and typically uncommon for linters.
---@field workspaceDiagnostics boolean The server provides support for workspace diagnostics as well.
---@alias dapui.async.lsp.types.InlineValue dapui.async.lsp.types.InlineValueText|dapui.async.lsp.types.InlineValueVariableLookup|dapui.async.lsp.types.InlineValueEvaluatableExpression

--- A parameter literal used in inline value requests.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlineValueParams : dapui.async.lsp.types.WorkDoneProgressParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.
---@field range dapui.async.lsp.types.Range The document range for which inline values should be computed.
---@field context dapui.async.lsp.types.InlineValueContext Additional information about the context in which inline values were requested.

--- Inline value options used during static or dynamic registration.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlineValueRegistrationOptions : dapui.async.lsp.types.InlineValueOptions,dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- A previous result id in a workspace pull request.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.PreviousResultId
---@field uri dapui.async.lsp.types.DocumentUri The URI for which the client knowns a result id.
---@field value string The value of the previous result id.

---@class dapui.async.lsp.types.Structure22
---@field text string The new text of the whole document.

---@class dapui.async.lsp.types.WorkspaceFoldersInitializeParams
---@field workspaceFolders? dapui.async.lsp.types.WorkspaceFolder[]|nil The workspace folders configured in the client when the server starts.  This property is only available if the client supports workspace folders. It can be `null` if the client supports workspace folders but none are configured.  @since 3.6.0

--- Defines the capabilities provided by a language
--- server.
---@class dapui.async.lsp.types.ServerCapabilities
---@field positionEncoding? dapui.async.lsp.types.PositionEncodingKind The position encoding the server picked from the encodings offered by the client via the client capability `general.positionEncodings`.  If the client didn't provide any position encodings the only valid value that a server can return is 'utf-16'.  If omitted it defaults to 'utf-16'.  @since 3.17.0
---@field textDocumentSync? dapui.async.lsp.types.TextDocumentSyncOptions|dapui.async.lsp.types.TextDocumentSyncKind Defines how text documents are synced. Is either a detailed structure defining each notification or for backwards compatibility the TextDocumentSyncKind number.
---@field notebookDocumentSync? dapui.async.lsp.types.NotebookDocumentSyncOptions|dapui.async.lsp.types.NotebookDocumentSyncRegistrationOptions Defines how notebook documents are synced.  @since 3.17.0
---@field completionProvider? dapui.async.lsp.types.CompletionOptions The server provides completion support.
---@field hoverProvider? boolean|dapui.async.lsp.types.HoverOptions The server provides hover support.
---@field signatureHelpProvider? dapui.async.lsp.types.SignatureHelpOptions The server provides signature help support.
---@field declarationProvider? boolean|dapui.async.lsp.types.DeclarationOptions|dapui.async.lsp.types.DeclarationRegistrationOptions The server provides Goto Declaration support.
---@field definitionProvider? boolean|dapui.async.lsp.types.DefinitionOptions The server provides goto definition support.
---@field typeDefinitionProvider? boolean|dapui.async.lsp.types.TypeDefinitionOptions|dapui.async.lsp.types.TypeDefinitionRegistrationOptions The server provides Goto Type Definition support.
---@field implementationProvider? boolean|dapui.async.lsp.types.ImplementationOptions|dapui.async.lsp.types.ImplementationRegistrationOptions The server provides Goto Implementation support.
---@field referencesProvider? boolean|dapui.async.lsp.types.ReferenceOptions The server provides find references support.
---@field documentHighlightProvider? boolean|dapui.async.lsp.types.DocumentHighlightOptions The server provides document highlight support.
---@field documentSymbolProvider? boolean|dapui.async.lsp.types.DocumentSymbolOptions The server provides document symbol support.
---@field codeActionProvider? boolean|dapui.async.lsp.types.CodeActionOptions The server provides code actions. CodeActionOptions may only be specified if the client states that it supports `codeActionLiteralSupport` in its initial `initialize` request.
---@field codeLensProvider? dapui.async.lsp.types.CodeLensOptions The server provides code lens.
---@field documentLinkProvider? dapui.async.lsp.types.DocumentLinkOptions The server provides document link support.
---@field colorProvider? boolean|dapui.async.lsp.types.DocumentColorOptions|dapui.async.lsp.types.DocumentColorRegistrationOptions The server provides color provider support.
---@field workspaceSymbolProvider? boolean|dapui.async.lsp.types.WorkspaceSymbolOptions The server provides workspace symbol support.
---@field documentFormattingProvider? boolean|dapui.async.lsp.types.DocumentFormattingOptions The server provides document formatting.
---@field documentRangeFormattingProvider? boolean|dapui.async.lsp.types.DocumentRangeFormattingOptions The server provides document range formatting.
---@field documentOnTypeFormattingProvider? dapui.async.lsp.types.DocumentOnTypeFormattingOptions The server provides document formatting on typing.
---@field renameProvider? boolean|dapui.async.lsp.types.RenameOptions The server provides rename support. RenameOptions may only be specified if the client states that it supports `prepareSupport` in its initial `initialize` request.
---@field foldingRangeProvider? boolean|dapui.async.lsp.types.FoldingRangeOptions|dapui.async.lsp.types.FoldingRangeRegistrationOptions The server provides folding provider support.
---@field selectionRangeProvider? boolean|dapui.async.lsp.types.SelectionRangeOptions|dapui.async.lsp.types.SelectionRangeRegistrationOptions The server provides selection range support.
---@field executeCommandProvider? dapui.async.lsp.types.ExecuteCommandOptions The server provides execute command support.
---@field callHierarchyProvider? boolean|dapui.async.lsp.types.CallHierarchyOptions|dapui.async.lsp.types.CallHierarchyRegistrationOptions The server provides call hierarchy support.  @since 3.16.0
---@field linkedEditingRangeProvider? boolean|dapui.async.lsp.types.LinkedEditingRangeOptions|dapui.async.lsp.types.LinkedEditingRangeRegistrationOptions The server provides linked editing range support.  @since 3.16.0
---@field semanticTokensProvider? dapui.async.lsp.types.SemanticTokensOptions|dapui.async.lsp.types.SemanticTokensRegistrationOptions The server provides semantic tokens support.  @since 3.16.0
---@field monikerProvider? boolean|dapui.async.lsp.types.MonikerOptions|dapui.async.lsp.types.MonikerRegistrationOptions The server provides moniker support.  @since 3.16.0
---@field typeHierarchyProvider? boolean|dapui.async.lsp.types.TypeHierarchyOptions|dapui.async.lsp.types.TypeHierarchyRegistrationOptions The server provides type hierarchy support.  @since 3.17.0
---@field inlineValueProvider? boolean|dapui.async.lsp.types.InlineValueOptions|dapui.async.lsp.types.InlineValueRegistrationOptions The server provides inline values.  @since 3.17.0
---@field inlayHintProvider? boolean|dapui.async.lsp.types.InlayHintOptions|dapui.async.lsp.types.InlayHintRegistrationOptions The server provides inlay hints.  @since 3.17.0
---@field diagnosticProvider? dapui.async.lsp.types.DiagnosticOptions|dapui.async.lsp.types.DiagnosticRegistrationOptions The server has support for pull model diagnostics.  @since 3.17.0
---@field workspace? dapui.async.lsp.types.Structure6 Workspace specific server capabilities.
---@field experimental? dapui.async.lsp.types.LSPAny Experimental server capabilities.

--- Inlay hint options used during static or dynamic registration.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlayHintRegistrationOptions : dapui.async.lsp.types.InlayHintOptions,dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- A notebook document.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.NotebookDocument
---@field uri dapui.async.lsp.types.URI The notebook document's uri.
---@field notebookType string The type of the notebook.
---@field version integer The version number of this document (it will increase after each change, including undo/redo).
---@field metadata? dapui.async.lsp.types.LSPObject Additional metadata stored with the notebook document.  Note: should always be an object literal (e.g. LSPObject)
---@field cells dapui.async.lsp.types.NotebookCell[] The cells of a notebook.

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensLegend
---@field tokenTypes string[] The token types a server uses.
---@field tokenModifiers string[] The token modifiers a server uses.

--- An item to transfer a text document from the client to the
--- server.
---@class dapui.async.lsp.types.TextDocumentItem
---@field uri dapui.async.lsp.types.DocumentUri The text document's uri.
---@field languageId string The text document's language identifier.
---@field version integer The version number of this document (it will increase after each change, including undo/redo).
---@field text string The content of the opened text document.

--- Parameters of the document diagnostic request.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DocumentDiagnosticParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.
---@field identifier? string The additional identifier  provided during registration.
---@field previousResultId? string The result id of a previous response if provided.

--- A partial result for a document diagnostic report.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DocumentDiagnosticReportPartialResult
---@field relatedDocuments table<dapui.async.lsp.types.DocumentUri, dapui.async.lsp.types.FullDocumentDiagnosticReport|dapui.async.lsp.types.UnchangedDocumentDiagnosticReport>

--- A versioned notebook document identifier.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.VersionedNotebookDocumentIdentifier
---@field version integer The version number of this notebook document.
---@field uri dapui.async.lsp.types.URI The notebook document's uri.

--- Cancellation data returned from a diagnostic request.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DiagnosticServerCancellationData
---@field retriggerRequest boolean

--- A change event for a notebook document.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.NotebookDocumentChangeEvent
---@field metadata? dapui.async.lsp.types.LSPObject The changed meta data if any.  Note: should always be an object literal (e.g. LSPObject)
---@field cells? dapui.async.lsp.types.Structure7 Changes to cells

--- A literal to identify a notebook document in the client.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.NotebookDocumentIdentifier
---@field uri dapui.async.lsp.types.URI The notebook document's uri.

--- A text document identifier to optionally denote a specific version of a text document.
---@class dapui.async.lsp.types.OptionalVersionedTextDocumentIdentifier : dapui.async.lsp.types.TextDocumentIdentifier
---@field version integer|nil The version number of this document. If a versioned text document identifier is sent from the server to the client and the file is not open in the editor (the server has not received an open notification before) the server can send `null` to indicate that the version is unknown and the content on disk is the truth (as specified with document content ownership).

--- A partial result for a workspace diagnostic report.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.WorkspaceDiagnosticReportPartialResult
---@field items dapui.async.lsp.types.WorkspaceDocumentDiagnosticReport[]

--- A special text edit with an additional change annotation.
---
--- @since 3.16.0.
---@class dapui.async.lsp.types.AnnotatedTextEdit : dapui.async.lsp.types.TextEdit
---@field annotationId dapui.async.lsp.types.ChangeAnnotationIdentifier The actual identifier of the change annotation

---@class dapui.async.lsp.types.RegistrationParams
---@field registrations dapui.async.lsp.types.Registration[]

--- A text document identifier to denote a specific version of a text document.
---@class dapui.async.lsp.types.VersionedTextDocumentIdentifier : dapui.async.lsp.types.TextDocumentIdentifier
---@field version integer The version number of this document.

--- General parameters to unregister a request or notification.
---@class dapui.async.lsp.types.Unregistration
---@field id string The id used to unregister the request or notification. Usually an id provided during the register request.
---@field method string The method to unregister for.

--- The initialize parameters
---@class dapui.async.lsp.types._InitializeParams : dapui.async.lsp.types.WorkDoneProgressParams
---@field processId integer|nil The process Id of the parent process that started the server.  Is `null` if the process has not been started by another process. If the parent process is not alive then the server should exit.
---@field clientInfo? dapui.async.lsp.types.Structure8 Information about the client  @since 3.15.0
---@field locale? string The locale the client is currently showing the user interface in. This must not necessarily be the locale of the operating system.  Uses IETF language tags as the value's syntax (See https://en.wikipedia.org/wiki/IETF_language_tag)  @since 3.16.0
---@field rootPath? string|nil The rootPath of the workspace. Is null if no folder is open.  @deprecated in favour of rootUri.
---@field rootUri dapui.async.lsp.types.DocumentUri|nil The rootUri of the workspace. Is null if no folder is open. If both `rootPath` and `rootUri` are set `rootUri` wins.  @deprecated in favour of workspaceFolders.
---@field capabilities dapui.async.lsp.types.ClientCapabilities The capabilities provided by the client (editor or tool)
---@field initializationOptions? dapui.async.lsp.types.LSPAny User provided initialization options.
---@field trace? 'off'|'messages'|'compact'|'verbose' The initial trace setting. If omitted trace is disabled ('off').

--- A generic resource operation.
---@class dapui.async.lsp.types.ResourceOperation
---@field kind string The resource operation kind.
---@field annotationId? dapui.async.lsp.types.ChangeAnnotationIdentifier An optional annotation identifier describing the operation.  @since 3.16.0

---@class dapui.async.lsp.types.InitializeParams : dapui.async.lsp.types._InitializeParams,dapui.async.lsp.types.WorkspaceFoldersInitializeParams

---@class dapui.async.lsp.types.MessageActionItem
---@field title string A short title like 'Retry', 'Open Log' etc.

--- Rename file options
---@class dapui.async.lsp.types.RenameFileOptions
---@field overwrite? boolean Overwrite target if existing. Overwrite wins over `ignoreIfExists`
---@field ignoreIfExists? boolean Ignores if target exists.

--- A text edit applicable to a text document.
---@class dapui.async.lsp.types.TextEdit
---@field range dapui.async.lsp.types.Range The range of the text document to be manipulated. To insert text into a document create a range where start === end.
---@field newText string The string to be inserted. For delete operations use an empty string.

--- The parameters sent in a will save text document notification.
---@class dapui.async.lsp.types.WillSaveTextDocumentParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The document that will be saved.
---@field reason dapui.async.lsp.types.TextDocumentSaveReason The 'TextDocumentSaveReason'.

--- Save options.
---@class dapui.async.lsp.types.SaveOptions
---@field includeText? boolean The client is supposed to include the content on save.

--- Delete file options
---@class dapui.async.lsp.types.DeleteFileOptions
---@field recursive? boolean Delete the content recursively if a folder is denoted.
---@field ignoreIfNotExists? boolean Ignore the operation if the file doesn't exist.

--- Represents a collection of [completion items](#CompletionItem) to be presented
--- in the editor.
---@class dapui.async.lsp.types.CompletionList
---@field isIncomplete boolean This list it not complete. Further typing results in recomputing this list.  Recomputed lists have all their items replaced (not appended) in the incomplete completion sessions.
---@field itemDefaults? dapui.async.lsp.types.Structure9 In many cases the items of an actual completion result share the same value for properties like `commitCharacters` or the range of a text edit. A completion list can therefore define item defaults which will be used if a completion item itself doesn't specify the value.  If a completion list specifies a default value and a completion item also specifies a corresponding value the one from the item is used.  Servers are only allowed to return default values if the client signals support for this via the `completionList.itemDefaults` capability.  @since 3.17.0
---@field items dapui.async.lsp.types.CompletionItem[] The completion items.

--- Completion parameters
---@class dapui.async.lsp.types.CompletionParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field context? dapui.async.lsp.types.CompletionContext The completion context. This is only available it the client specifies to send this using the client capability `textDocument.completion.contextSupport === true`

--- Registration options for a [CompletionRequest](#CompletionRequest).
---@class dapui.async.lsp.types.CompletionRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.CompletionOptions

---@class dapui.async.lsp.types.Structure24
---@field language? string A language id, like `typescript`.
---@field scheme string A Uri [scheme](#Uri.scheme), like `file` or `untitled`.
---@field pattern? string A glob pattern, like `*.{ts,js}`.

--- The result of a hover request.
---@class dapui.async.lsp.types.Hover
---@field contents dapui.async.lsp.types.MarkupContent|dapui.async.lsp.types.MarkedString|dapui.async.lsp.types.MarkedString[] The hover's content
---@field range? dapui.async.lsp.types.Range An optional range inside the text document that is used to visualize the hover, e.g. by changing the background color.

--- An event describing a file change.
---@class dapui.async.lsp.types.FileEvent
---@field uri dapui.async.lsp.types.DocumentUri The file's uri.
---@field type dapui.async.lsp.types.FileChangeType The change type.

--- Registration options for a [HoverRequest](#HoverRequest).
---@class dapui.async.lsp.types.HoverRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.HoverOptions

--- A pattern to describe in which file operation requests or notifications
--- the server is interested in receiving.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.FileOperationPattern
---@field glob string The glob pattern to match. Glob patterns can have the following syntax: - `*` to match one or more characters in a path segment - `?` to match on one character in a path segment - `**` to match any number of path segments, including none - `{}` to group sub patterns into an OR expression. (e.g. `**​/*.{ts,js}` matches all TypeScript and JavaScript files) - `[]` to declare a range of characters to match in a path segment (e.g., `example.[0-9]` to match on `example.0`, `example.1`, …) - `[!...]` to negate a range of characters to match in a path segment (e.g., `example.[!0-9]` to match on `example.a`, `example.b`, but not `example.0`)
---@field matches? dapui.async.lsp.types.FileOperationPatternKind Whether to match files or folders with this pattern.  Matches both if undefined.
---@field options? dapui.async.lsp.types.FileOperationPatternOptions Additional options used during matching.

--- Signature help represents the signature of something
--- callable. There can be multiple signature but only one
--- active and only one active parameter.
---@class dapui.async.lsp.types.SignatureHelp
---@field signatures dapui.async.lsp.types.SignatureInformation[] One or more signatures.
---@field activeSignature? integer The active signature. If omitted or the value lies outside the range of `signatures` the value defaults to zero or is ignored if the `SignatureHelp` has no signatures.  Whenever possible implementors should make an active decision about the active signature and shouldn't rely on a default value.  In future version of the protocol this property might become mandatory to better express this.
---@field activeParameter? integer The active parameter of the active signature. If omitted or the value lies outside the range of `signatures[activeSignature].parameters` defaults to 0 if the active signature has parameters. If the active signature has no parameters it is ignored. In future version of the protocol this property might become mandatory to better express the active parameter if the active signature does have any.

---@class dapui.async.lsp.types.FileSystemWatcher
---@field globPattern dapui.async.lsp.types.GlobPattern The glob pattern to watch. See {@link GlobPattern glob pattern} for more detail.  @since 3.17.0 support for relative patterns.
---@field kind? dapui.async.lsp.types.WatchKind The kind of events of interest. If omitted it defaults to WatchKind.Create | WatchKind.Change | WatchKind.Delete which is 7.

--- Registration options for a [SignatureHelpRequest](#SignatureHelpRequest).
---@class dapui.async.lsp.types.SignatureHelpRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.SignatureHelpOptions

--- Parameters for a [DefinitionRequest](#DefinitionRequest).
---@class dapui.async.lsp.types.DefinitionParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams

--- Registration options for a [DefinitionRequest](#DefinitionRequest).
---@class dapui.async.lsp.types.DefinitionRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.DefinitionOptions

--- Parameters for a [ReferencesRequest](#ReferencesRequest).
---@class dapui.async.lsp.types.ReferenceParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field context dapui.async.lsp.types.ReferenceContext

--- Registration options for a [ReferencesRequest](#ReferencesRequest).
---@class dapui.async.lsp.types.ReferenceRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.ReferenceOptions

--- A document highlight is a range inside a text document which deserves
--- special attention. Usually a document highlight is visualized by changing
--- the background color of its range.
---@class dapui.async.lsp.types.DocumentHighlight
---@field range dapui.async.lsp.types.Range The range this highlight applies to.
---@field kind? dapui.async.lsp.types.DocumentHighlightKind The highlight kind, default is [text](#DocumentHighlightKind.Text).

--- Parameters for a [DocumentHighlightRequest](#DocumentHighlightRequest).
---@class dapui.async.lsp.types.DocumentHighlightParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams

--- Registration options for a [DocumentHighlightRequest](#DocumentHighlightRequest).
---@class dapui.async.lsp.types.DocumentHighlightRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.DocumentHighlightOptions

--- Represents information about programming constructs like variables, classes,
--- interfaces etc.
---@class dapui.async.lsp.types.SymbolInformation : dapui.async.lsp.types.BaseSymbolInformation
---@field deprecated? boolean Indicates if this symbol is deprecated.  @deprecated Use tags instead
---@field location dapui.async.lsp.types.Location The location of this symbol. The location's range is used by a tool to reveal the location in the editor. If the symbol is selected in the tool the range's start information is used to position the cursor. So the range usually spans more than the actual symbol's name and does normally include things like visibility modifiers.  The range doesn't have to denote a node range in the sense of an abstract syntax tree. It can therefore not be used to re-construct a hierarchy of the symbols.

--- Represents programming constructs like variables, classes, interfaces etc.
--- that appear in a document. Document symbols can be hierarchical and they
--- have two ranges: one that encloses its definition and one that points to
--- its most interesting range, e.g. the range of an identifier.
---@class dapui.async.lsp.types.DocumentSymbol
---@field name string The name of this symbol. Will be displayed in the user interface and therefore must not be an empty string or a string only consisting of white spaces.
---@field detail? string More detail for this symbol, e.g the signature of a function.
---@field kind dapui.async.lsp.types.SymbolKind The kind of this symbol.
---@field tags? dapui.async.lsp.types.SymbolTag[] Tags for this document symbol.  @since 3.16.0
---@field deprecated? boolean Indicates if this symbol is deprecated.  @deprecated Use tags instead
---@field range dapui.async.lsp.types.Range The range enclosing this symbol not including leading/trailing whitespace but everything else like comments. This information is typically used to determine if the clients cursor is inside the symbol to reveal in the symbol in the UI.
---@field selectionRange dapui.async.lsp.types.Range The range that should be selected and revealed when this symbol is being picked, e.g the name of a function. Must be contained by the `range`.
---@field children? dapui.async.lsp.types.DocumentSymbol[] Children of this symbol, e.g. properties of a class.

--- Parameters for a [DocumentSymbolRequest](#DocumentSymbolRequest).
---@class dapui.async.lsp.types.DocumentSymbolParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.

--- Registration options for a [DocumentSymbolRequest](#DocumentSymbolRequest).
---@class dapui.async.lsp.types.DocumentSymbolRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.DocumentSymbolOptions

--- A code action represents a change that can be performed in code, e.g. to fix a problem or
--- to refactor code.
---
--- A CodeAction must set either `edit` and/or a `command`. If both are supplied, the `edit` is applied first, then the `command` is executed.
---@class dapui.async.lsp.types.CodeAction
---@field title string A short, human-readable, title for this code action.
---@field kind? dapui.async.lsp.types.CodeActionKind The kind of the code action.  Used to filter code actions.
---@field diagnostics? dapui.async.lsp.types.Diagnostic[] The diagnostics that this code action resolves.
---@field isPreferred? boolean Marks this as a preferred action. Preferred actions are used by the `auto fix` command and can be targeted by keybindings.  A quick fix should be marked preferred if it properly addresses the underlying error. A refactoring should be marked preferred if it is the most reasonable choice of actions to take.  @since 3.15.0
---@field disabled? dapui.async.lsp.types.Structure10 Marks that the code action cannot currently be applied.  Clients should follow the following guidelines regarding disabled code actions:    - Disabled code actions are not shown in automatic [lightbulbs](https://code.visualstudio.com/docs/editor/editingevolved#_code-action)     code action menus.    - Disabled actions are shown as faded out in the code action menu when the user requests a more specific type     of code action, such as refactorings.    - If the user has a [keybinding](https://code.visualstudio.com/docs/editor/refactoring#_keybindings-for-code-actions)     that auto applies a code action and only disabled code actions are returned, the client should show the user an     error message with `reason` in the editor.  @since 3.16.0
---@field edit? dapui.async.lsp.types.WorkspaceEdit The workspace edit this code action performs.
---@field command? dapui.async.lsp.types.Command A command this code action executes. If a code action provides an edit and a command, first the edit is executed and then the command.
---@field data? dapui.async.lsp.types.LSPAny A data entry field that is preserved on a code action between a `textDocument/codeAction` and a `codeAction/resolve` request.  @since 3.16.0

--- The parameters of a [CodeActionRequest](#CodeActionRequest).
---@class dapui.async.lsp.types.CodeActionParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The document in which the command was invoked.
---@field range dapui.async.lsp.types.Range The range for which the command was invoked.
---@field context dapui.async.lsp.types.CodeActionContext Context carrying additional information.

--- Registration options for a [CodeActionRequest](#CodeActionRequest).
---@class dapui.async.lsp.types.CodeActionRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.CodeActionOptions

--- Provide an inline value through an expression evaluation.
--- If only a range is specified, the expression will be extracted from the underlying document.
--- An optional expression can be used to override the extracted expression.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlineValueEvaluatableExpression
---@field range dapui.async.lsp.types.Range The document range for which the inline value applies. The range is used to extract the evaluatable expression from the underlying document.
---@field expression? string If specified the expression overrides the extracted expression.

--- A special workspace symbol that supports locations without a range.
---
--- See also SymbolInformation.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.WorkspaceSymbol : dapui.async.lsp.types.BaseSymbolInformation
---@field location dapui.async.lsp.types.Location|dapui.async.lsp.types.Structure11 The location of the symbol. Whether a server is allowed to return a location without a range depends on the client capability `workspace.symbol.resolveSupport`.  See SymbolInformation#location for more details.
---@field data? dapui.async.lsp.types.LSPAny A data entry field that is preserved on a workspace symbol between a workspace symbol request and a workspace symbol resolve request.

--- The parameters of a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
---@class dapui.async.lsp.types.WorkspaceSymbolParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field query string A query string to filter symbols by. Clients may send an empty string here to request all symbols.

--- Registration options for a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
---@class dapui.async.lsp.types.WorkspaceSymbolRegistrationOptions : dapui.async.lsp.types.WorkspaceSymbolOptions

---@class dapui.async.lsp.types.Structure40
---@field valueSet dapui.async.lsp.types.SymbolTag[] The tags supported by the client.

--- Inline value options used during static registration.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlineValueOptions : dapui.async.lsp.types.WorkDoneProgressOptions

---@class dapui.async.lsp.types.Structure27
---@field notebookType? string The type of the enclosing notebook.
---@field scheme string A Uri [scheme](#Uri.scheme), like `file` or `untitled`.
---@field pattern? string A glob pattern.

---@class dapui.async.lsp.types.Structure45
---@field valueSet dapui.async.lsp.types.DiagnosticTag[] The tags supported by the client.

--- A code lens represents a [command](#Command) that should be shown along with
--- source text, like the number of references, a way to run tests, etc.
---
--- A code lens is _unresolved_ when no command is associated to it. For performance
--- reasons the creation of a code lens and resolving should be done in two stages.
---@class dapui.async.lsp.types.CodeLens
---@field range dapui.async.lsp.types.Range The range in which this code lens is valid. Should only span a single line.
---@field command? dapui.async.lsp.types.Command The command this code lens represents.
---@field data? dapui.async.lsp.types.LSPAny A data entry field that is preserved on a code lens item between a [CodeLensRequest](#CodeLensRequest) and a [CodeLensResolveRequest] (#CodeLensResolveRequest)

--- The parameters of a [CodeLensRequest](#CodeLensRequest).
---@class dapui.async.lsp.types.CodeLensParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The document to request code lens for.

--- Registration options for a [CodeLensRequest](#CodeLensRequest).
---@class dapui.async.lsp.types.CodeLensRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.CodeLensOptions

---@class dapui.async.lsp.types.Structure44
---@field collapsedText? boolean If set, the client signals that it supports setting collapsedText on folding ranges to display custom labels instead of the default text.  @since 3.17.0

---@class dapui.async.lsp.types.Structure28
---@field notebookType? string The type of the enclosing notebook.
---@field scheme? string A Uri [scheme](#Uri.scheme), like `file` or `untitled`.
---@field pattern string A glob pattern.

--- Represents a reference to a command. Provides a title which
--- will be used to represent a command in the UI and, optionally,
--- an array of arguments which will be passed to the command handler
--- function when invoked.
---@class dapui.async.lsp.types.Command
---@field title string Title of the command, like `save`.
---@field command string The identifier of the actual command handler.
---@field arguments? dapui.async.lsp.types.LSPAny[] Arguments that the command handler should be invoked with.

---@class dapui.async.lsp.types.Structure41
---@field codeActionKind dapui.async.lsp.types.Structure47 The code action kind is support with the following value set.

--- A full diagnostic report with a set of related documents.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.RelatedFullDocumentDiagnosticReport : dapui.async.lsp.types.FullDocumentDiagnosticReport
---@field relatedDocuments? table<dapui.async.lsp.types.DocumentUri, dapui.async.lsp.types.FullDocumentDiagnosticReport|dapui.async.lsp.types.UnchangedDocumentDiagnosticReport> Diagnostics of related documents. This information is useful in programming languages where code in a file A can generate diagnostics in a file B which A depends on. An example of such a language is C/C++ where marco definitions in a file a.cpp and result in errors in a header file b.hpp.  @since 3.17.0

--- A document link is a range in a text document that links to an internal or external resource, like another
--- text document or a web site.
---@class dapui.async.lsp.types.DocumentLink
---@field range dapui.async.lsp.types.Range The range this link applies to.
---@field target? string The uri this link points to. If missing a resolve request is sent later.
---@field tooltip? string The tooltip text when you hover over this link.  If a tooltip is provided, is will be displayed in a string that includes instructions on how to trigger the link, such as `{0} (ctrl + click)`. The specific instructions vary depending on OS, user settings, and localization.  @since 3.15.0
---@field data? dapui.async.lsp.types.LSPAny A data entry field that is preserved on a document link between a DocumentLinkRequest and a DocumentLinkResolveRequest.

--- The parameters of a [DocumentLinkRequest](#DocumentLinkRequest).
---@class dapui.async.lsp.types.DocumentLinkParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The document to provide document links for.

--- Registration options for a [DocumentLinkRequest](#DocumentLinkRequest).
---@class dapui.async.lsp.types.DocumentLinkRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.DocumentLinkOptions

---@class dapui.async.lsp.types.Structure39
---@field valueSet? dapui.async.lsp.types.SymbolKind[] The symbol kind values the client supports. When this property exists the client also guarantees that it will handle values outside its set gracefully and falls back to a default value when unknown.  If this property is not present the client only supports the symbol kinds from `File` to `Array` as defined in the initial version of the protocol.

--- Completion options.
---@class dapui.async.lsp.types.CompletionOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field triggerCharacters? string[] Most tools trigger completion request automatically without explicitly requesting it using a keyboard shortcut (e.g. Ctrl+Space). Typically they do so when the user starts to type an identifier. For example if the user types `c` in a JavaScript file code complete will automatically pop up present `console` besides others as a completion item. Characters that make up identifiers don't need to be listed here.  If code complete should automatically be trigger on characters not being valid inside an identifier (for example `.` in JavaScript) list them in `triggerCharacters`.
---@field allCommitCharacters? string[] The list of all possible characters that commit a completion. This field can be used if clients don't support individual commit characters per completion item. See `ClientCapabilities.textDocument.completion.completionItem.commitCharactersSupport`  If a server provides both `allCommitCharacters` and commit characters on an individual completion item the ones on the completion item win.  @since 3.2.0
---@field resolveProvider? boolean The server provides support to resolve additional information for a completion item.
---@field completionItem? dapui.async.lsp.types.Structure12 The server supports the following `CompletionItem` specific capabilities.  @since 3.17.0

---@class dapui.async.lsp.types.Structure38
---@field name string The name of the server as defined by the server.
---@field version? string The server's version as defined by the server.

--- The parameters of a [DocumentFormattingRequest](#DocumentFormattingRequest).
---@class dapui.async.lsp.types.DocumentFormattingParams : dapui.async.lsp.types.WorkDoneProgressParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The document to format.
---@field options dapui.async.lsp.types.FormattingOptions The format options.

--- Registration options for a [DocumentFormattingRequest](#DocumentFormattingRequest).
---@class dapui.async.lsp.types.DocumentFormattingRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.DocumentFormattingOptions

--- Parameters for a [ColorPresentationRequest](#ColorPresentationRequest).
---@class dapui.async.lsp.types.ColorPresentationParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.
---@field color dapui.async.lsp.types.Color The color to request presentations for.
---@field range dapui.async.lsp.types.Range The range where the color would be inserted. Serves as a context.

---@class dapui.async.lsp.types.WorkDoneProgressOptions
---@field workDoneProgress? boolean

--- General text document registration options.
---@class dapui.async.lsp.types.TextDocumentRegistrationOptions
---@field documentSelector dapui.async.lsp.types.DocumentSelector|nil A document selector to identify the scope of the registration. If set to null the document selector provided on the client side will be used.

--- Hover options.
---@class dapui.async.lsp.types.HoverOptions : dapui.async.lsp.types.WorkDoneProgressOptions

---@class dapui.async.lsp.types.ShowMessageRequestParams
---@field type dapui.async.lsp.types.MessageType The message type. See {@link MessageType}
---@field message string The actual message.
---@field actions? dapui.async.lsp.types.MessageActionItem[] The message action items to present.

--- Represents a folding range. To be valid, start and end line must be bigger than zero and smaller
--- than the number of lines in the document. Clients are free to ignore invalid ranges.
---@class dapui.async.lsp.types.FoldingRange
---@field startLine integer The zero-based start line of the range to fold. The folded area starts after the line's last character. To be valid, the end must be zero or larger and smaller than the number of lines in the document.
---@field startCharacter? integer The zero-based character offset from where the folded range starts. If not defined, defaults to the length of the start line.
---@field endLine integer The zero-based end line of the range to fold. The folded area ends with the line's last character. To be valid, the end must be zero or larger and smaller than the number of lines in the document.
---@field endCharacter? integer The zero-based character offset before the folded range ends. If not defined, defaults to the length of the end line.
---@field kind? dapui.async.lsp.types.FoldingRangeKind Describes the kind of the folding range such as `comment' or 'region'. The kind is used to categorize folding ranges and used by commands like 'Fold all comments'. See [FoldingRangeKind](#FoldingRangeKind) for an enumeration of standardized kinds.
---@field collapsedText? string The text that the client should show when the specified range is collapsed. If not defined or not supported by the client, a default will be chosen by the client.  @since 3.17.0

--- Parameters for a [FoldingRangeRequest](#FoldingRangeRequest).
---@class dapui.async.lsp.types.FoldingRangeParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.

---@class dapui.async.lsp.types.FoldingRangeRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.FoldingRangeOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- The parameters of a [RenameRequest](#RenameRequest).
---@class dapui.async.lsp.types.RenameParams : dapui.async.lsp.types.WorkDoneProgressParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The document to rename.
---@field position dapui.async.lsp.types.Position The position at which this request was sent.
---@field newName string The new name of the symbol. If the given name is not valid the request must return a [ResponseError](#ResponseError) with an appropriate message set.

--- Registration options for a [RenameRequest](#RenameRequest).
---@class dapui.async.lsp.types.RenameRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.RenameOptions

--- Delete file operation
---@class dapui.async.lsp.types.DeleteFile : dapui.async.lsp.types.ResourceOperation
---@field kind 'delete' A delete
---@field uri dapui.async.lsp.types.DocumentUri The file to delete.
---@field options? dapui.async.lsp.types.DeleteFileOptions Delete options.
---@alias dapui.async.lsp.types.PrepareRenameResult dapui.async.lsp.types.Range|dapui.async.lsp.types.Structure13|dapui.async.lsp.types.Structure14

---@class dapui.async.lsp.types.PrepareRenameParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams

--- Server Capabilities for a [SignatureHelpRequest](#SignatureHelpRequest).
---@class dapui.async.lsp.types.SignatureHelpOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field triggerCharacters? string[] List of characters that trigger signature help automatically.
---@field retriggerCharacters? string[] List of characters that re-trigger signature help.  These trigger characters are only active when signature help is already showing. All trigger characters are also counted as re-trigger characters.  @since 3.15.0

---@class dapui.async.lsp.types.Structure33
---@field snippetSupport? boolean Client supports snippets as insert text.  A snippet can define tab stops and placeholders with `$1`, `$2` and `${3:foo}`. `$0` defines the final tab stop, it defaults to the end of the snippet. Placeholders with equal identifiers are linked, that is typing in one will update others too.
---@field commitCharactersSupport? boolean Client supports commit characters on a completion item.
---@field documentationFormat? dapui.async.lsp.types.MarkupKind[] Client supports the following content formats for the documentation property. The order describes the preferred format of the client.
---@field deprecatedSupport? boolean Client supports the deprecated property on a completion item.
---@field preselectSupport? boolean Client supports the preselect property on a completion item.
---@field tagSupport? dapui.async.lsp.types.Structure48 Client supports the tag property on a completion item. Clients supporting tags have to handle unknown tags gracefully. Clients especially need to preserve unknown tags when sending a completion item back to the server in a resolve call.  @since 3.15.0
---@field insertReplaceSupport? boolean Client support insert replace edit to control different behavior if a completion item is inserted in the text or should replace text.  @since 3.16.0
---@field resolveSupport? dapui.async.lsp.types.Structure49 Indicates which properties a client can resolve lazily on a completion item. Before version 3.16.0 only the predefined properties `documentation` and `details` could be resolved lazily.  @since 3.16.0
---@field insertTextModeSupport? dapui.async.lsp.types.Structure50 The client supports the `insertTextMode` property on a completion item to override the whitespace handling mode as defined by the client (see `insertTextMode`).  @since 3.16.0
---@field labelDetailsSupport? boolean The client has support for completion item label details (see also `CompletionItemLabelDetails`).  @since 3.17.0

--- The parameters of a [ExecuteCommandRequest](#ExecuteCommandRequest).
---@class dapui.async.lsp.types.ExecuteCommandParams : dapui.async.lsp.types.WorkDoneProgressParams
---@field command string The identifier of the actual command handler.
---@field arguments? dapui.async.lsp.types.LSPAny[] Arguments that the command should be invoked with.

--- LSP object definition.
--- @since 3.17.0
---@class dapui.async.lsp.types.LSPObject

---@class dapui.async.lsp.types.Structure32
---@field properties string[] The properties that a client can resolve lazily. Usually `location.range`

--- The result returned from the apply workspace edit request.
---
--- @since 3.17 renamed from ApplyWorkspaceEditResponse
---@class dapui.async.lsp.types.ApplyWorkspaceEditResult
---@field applied boolean Indicates whether the edit was applied or not.
---@field failureReason? string An optional textual description for why the edit was not applied. This may be used by the server for diagnostic logging or to provide a suitable error for a request that triggered the edit.
---@field failedChange? integer Depending on the client's failure handling strategy `failedChange` might contain the index of the change that failed. This property is only available if the client signals a `failureHandlingStrategy` in its client capabilities.

--- A notebook cell.
---
--- A cell's document URI must be unique across ALL notebook
--- cells and can therefore be used to uniquely identify a
--- notebook cell or the cell's text document.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.NotebookCell
---@field kind dapui.async.lsp.types.NotebookCellKind The cell's kind
---@field document dapui.async.lsp.types.DocumentUri The URI of the cell's text document content.
---@field metadata? dapui.async.lsp.types.LSPObject Additional metadata stored with the cell.  Note: should always be an object literal (e.g. LSPObject)
---@field executionSummary? dapui.async.lsp.types.ExecutionSummary Additional execution summary information if supported by the client.

--- Reference options.
---@class dapui.async.lsp.types.ReferenceOptions : dapui.async.lsp.types.WorkDoneProgressOptions

--- The parameters of a `workspace/didChangeWorkspaceFolders` notification.
---@class dapui.async.lsp.types.DidChangeWorkspaceFoldersParams
---@field event dapui.async.lsp.types.WorkspaceFoldersChangeEvent The actual workspace folder change event.

---@class dapui.async.lsp.types.Structure31
---@field valueSet dapui.async.lsp.types.SymbolTag[] The tags supported by the client.

---@class dapui.async.lsp.types.Structure30
---@field valueSet? dapui.async.lsp.types.SymbolKind[] The symbol kind values the client supports. When this property exists the client also guarantees that it will handle values outside its set gracefully and falls back to a default value when unknown.  If this property is not present the client only supports the symbol kinds from `File` to `Array` as defined in the initial version of the protocol.

---@class dapui.async.lsp.types.WorkDoneProgressCancelParams
---@field token dapui.async.lsp.types.ProgressToken The token to be used to report progress.

---@class dapui.async.lsp.types.Structure25
---@field language? string A language id, like `typescript`.
---@field scheme? string A Uri [scheme](#Uri.scheme), like `file` or `untitled`.
---@field pattern string A glob pattern, like `*.{ts,js}`.

--- Provider options for a [DocumentHighlightRequest](#DocumentHighlightRequest).
---@class dapui.async.lsp.types.DocumentHighlightOptions : dapui.async.lsp.types.WorkDoneProgressOptions

---@class dapui.async.lsp.types.Structure42
---@field properties string[] The properties that a client can resolve lazily.

---@class dapui.async.lsp.types.Structure26
---@field notebookType string The type of the enclosing notebook.
---@field scheme? string A Uri [scheme](#Uri.scheme), like `file` or `untitled`.
---@field pattern? string A glob pattern.

---@class dapui.async.lsp.types.Structure29
---@field language string
---@field value string

---@class dapui.async.lsp.types.Structure23
---@field language string A language id, like `typescript`.
---@field scheme? string A Uri [scheme](#Uri.scheme), like `file` or `untitled`.
---@field pattern? string A glob pattern, like `*.{ts,js}`.

--- A base for all symbol information.
---@class dapui.async.lsp.types.BaseSymbolInformation
---@field name string The name of this symbol.
---@field kind dapui.async.lsp.types.SymbolKind The kind of this symbol.
---@field tags? dapui.async.lsp.types.SymbolTag[] Tags for this symbol.  @since 3.16.0
---@field containerName? string The name of the symbol containing this symbol. This information is for user interface purposes (e.g. to render a qualifier in the user interface if necessary). It can't be used to re-infer a hierarchy for the document symbols.

---@class dapui.async.lsp.types.Structure21
---@field range dapui.async.lsp.types.Range The range of the document that changed.
---@field rangeLength? integer The optional length of the range that got replaced.  @deprecated use range instead.
---@field text string The new text for the provided range.

--- The params sent in an open notebook document notification.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DidOpenNotebookDocumentParams
---@field notebookDocument dapui.async.lsp.types.NotebookDocument The notebook document that got opened.
---@field cellTextDocuments dapui.async.lsp.types.TextDocumentItem[] The text documents that represent the content of a notebook cell.

---@class dapui.async.lsp.types.Structure20
---@field notebook? string|dapui.async.lsp.types.NotebookDocumentFilter The notebook to be synced If a string value is provided it matches against the notebook type. '*' matches every notebook.
---@field cells dapui.async.lsp.types.Structure51[] The cells of the matching notebook to be synced.

---@class dapui.async.lsp.types.Structure19
---@field notebook string|dapui.async.lsp.types.NotebookDocumentFilter The notebook to be synced If a string value is provided it matches against the notebook type. '*' matches every notebook.
---@field cells? dapui.async.lsp.types.Structure52[] The cells of the matching notebook to be synced.

---@class dapui.async.lsp.types.Structure18
---@field delta? boolean The client will send the `textDocument/semanticTokens/full/delta` request if the server provides a corresponding handler.

--- The params sent in a change notebook document notification.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DidChangeNotebookDocumentParams
---@field notebookDocument dapui.async.lsp.types.VersionedNotebookDocumentIdentifier The notebook document that did change. The version number points to the version after all provided changes have been applied. If only the text document content of a cell changes the notebook version doesn't necessarily have to change.
---@field change dapui.async.lsp.types.NotebookDocumentChangeEvent The actual changes to the notebook document.  The changes describe single state changes to the notebook document. So if there are two changes c1 (at array index 0) and c2 (at array index 1) for a notebook in state S then c1 moves the notebook from S to S' and c2 from S' to S''. So c1 is computed on the state S and c2 is computed on the state S'.  To mirror the content of a notebook using change events use the following approach: - start with the same initial content - apply the 'notebookDocument/didChange' notifications in the order you receive them. - apply the `NotebookChangeEvent`s in a single notification in the order   you receive them.

---@class dapui.async.lsp.types.Structure17

--- The params sent in a save notebook document notification.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DidSaveNotebookDocumentParams
---@field notebookDocument dapui.async.lsp.types.NotebookDocumentIdentifier The notebook document that got saved.

--- General parameters to to register for an notification or to register a provider.
---@class dapui.async.lsp.types.Registration
---@field id string The id used to register the request. The id can be used to deregister the request again.
---@field method string The method / capability to register for.
---@field registerOptions? dapui.async.lsp.types.LSPAny Options necessary for the registration.

--- Provider options for a [DocumentSymbolRequest](#DocumentSymbolRequest).
---@class dapui.async.lsp.types.DocumentSymbolOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field label? string A human-readable string that is shown when multiple outlines trees are shown for the same document.  @since 3.16.0

--- The params sent in a close notebook document notification.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DidCloseNotebookDocumentParams
---@field notebookDocument dapui.async.lsp.types.NotebookDocumentIdentifier The notebook document that got closed.
---@field cellTextDocuments dapui.async.lsp.types.TextDocumentIdentifier[] The text documents that represent the content of a notebook cell that got closed.

--- Provide inline value through a variable lookup.
--- If only a range is specified, the variable name will be extracted from the underlying document.
--- An optional variable name can be used to override the extracted name.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlineValueVariableLookup
---@field range dapui.async.lsp.types.Range The document range for which the inline value applies. The range is used to extract the variable name from the underlying document.
---@field variableName? string If specified the name of the variable to look up.
---@field caseSensitiveLookup boolean How to perform the lookup.

---@class dapui.async.lsp.types.InitializedParams

--- Contains additional diagnostic information about the context in which
--- a [code action](#CodeActionProvider.provideCodeActions) is run.
---@class dapui.async.lsp.types.CodeActionContext
---@field diagnostics dapui.async.lsp.types.Diagnostic[] An array of diagnostics known on the client side overlapping the range provided to the `textDocument/codeAction` request. They are provided so that the server knows which errors are currently presented to the user for the given range. There is no guarantee that these accurately reflect the error state of the resource. The primary parameter to compute code actions is the provided range.
---@field only? dapui.async.lsp.types.CodeActionKind[] Requested kind of actions to return.  Actions not of this kind are filtered out by the client before being shown. So servers can omit computing them.
---@field triggerKind? dapui.async.lsp.types.CodeActionTriggerKind The reason why code actions were requested.  @since 3.17.0

---@class dapui.async.lsp.types.Structure12
---@field labelDetailsSupport? boolean The server has support for completion item label details (see also `CompletionItemLabelDetails`) when receiving a completion item in a resolve call.  @since 3.17.0

--- The parameters of a change configuration notification.
---@class dapui.async.lsp.types.DidChangeConfigurationParams
---@field settings dapui.async.lsp.types.LSPAny The actual changed settings

---@class dapui.async.lsp.types.DidChangeConfigurationRegistrationOptions
---@field section? string|string[]

---@class dapui.async.lsp.types.Structure4

--- The parameters of a notification message.
---@class dapui.async.lsp.types.ShowMessageParams
---@field type dapui.async.lsp.types.MessageType The message type. See {@link MessageType}
---@field message string The actual message.

---@class dapui.async.lsp.types.Structure11
---@field uri dapui.async.lsp.types.DocumentUri

--- The log message parameters.
---@class dapui.async.lsp.types.LogMessageParams
---@field type dapui.async.lsp.types.MessageType The message type. See {@link MessageType}
---@field message string The actual message.

---@class dapui.async.lsp.types.Structure10
---@field reason string Human readable description of why the code action is currently disabled.  This is displayed in the code actions UI.

---@class dapui.async.lsp.types.Structure8
---@field name string The name of the client as defined by the client.
---@field version? string The client's version as defined by the client.

---@class dapui.async.lsp.types.Structure7
---@field structure? dapui.async.lsp.types.Structure15 Changes to the cell structure to add or remove cells.
---@field data? dapui.async.lsp.types.NotebookCell[] Changes to notebook cells properties like its kind, execution summary or metadata.
---@field textContent? dapui.async.lsp.types.Structure16[] Changes to the text content of notebook cells.

--- The parameters sent in an open text document notification
---@class dapui.async.lsp.types.DidOpenTextDocumentParams
---@field textDocument dapui.async.lsp.types.TextDocumentItem The document that was opened.

---@class dapui.async.lsp.types.Structure6
---@field workspaceFolders? dapui.async.lsp.types.WorkspaceFoldersServerCapabilities The server supports workspace folder.  @since 3.6.0
---@field fileOperations? dapui.async.lsp.types.FileOperationOptions The server is interested in notifications/requests for operations on files.  @since 3.16.0

--- The change text document notification's parameters.
---@class dapui.async.lsp.types.DidChangeTextDocumentParams
---@field textDocument dapui.async.lsp.types.VersionedTextDocumentIdentifier The document that did change. The version number points to the version after all provided content changes have been applied.
---@field contentChanges dapui.async.lsp.types.TextDocumentContentChangeEvent[] The actual content changes. The content changes describe single state changes to the document. So if there are two content changes c1 (at array index 0) and c2 (at array index 1) for a document in state S then c1 moves the document from S to S' and c2 from S' to S''. So c1 is computed on the state S and c2 is computed on the state S'.  To mirror the content of a document using change events use the following approach: - start with the same initial content - apply the 'textDocument/didChange' notifications in the order you receive them. - apply the `TextDocumentContentChangeEvent`s in a single notification in the order   you receive them.

--- Describe options to be used when registered for text document change events.
---@class dapui.async.lsp.types.TextDocumentChangeRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions
---@field syncKind dapui.async.lsp.types.TextDocumentSyncKind How documents are synced to the server.

---@class dapui.async.lsp.types.Structure5
---@field delta? boolean The server supports deltas for full documents.

--- The parameters sent in a close text document notification
---@class dapui.async.lsp.types.DidCloseTextDocumentParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The document that was closed.
--- A symbol kind.
---@alias dapui.async.lsp.types.SymbolKind 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26

--- The parameters sent in a save text document notification
---@class dapui.async.lsp.types.DidSaveTextDocumentParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The document that was saved.
---@field text? string Optional the content when saved. Depends on the includeText value when the save notification was requested.

--- Save registration options.
---@class dapui.async.lsp.types.TextDocumentSaveRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.SaveOptions

---@class dapui.async.lsp.types.Structure0
---@field range? boolean|dapui.async.lsp.types.Structure17 The client will send the `textDocument/semanticTokens/range` request if the server provides a corresponding handler.
---@field full? boolean|dapui.async.lsp.types.Structure18 The client will send the `textDocument/semanticTokens/full` request if the server provides a corresponding handler.
---@alias dapui.async.lsp.types.TokenFormat "relative"

---@alias dapui.async.lsp.types.PrepareSupportDefaultBehavior 1

--- Defines the capabilities provided by the client.
---@class dapui.async.lsp.types.ClientCapabilities
---@field workspace? dapui.async.lsp.types.WorkspaceClientCapabilities Workspace specific client capabilities.
---@field textDocument? dapui.async.lsp.types.TextDocumentClientCapabilities Text document specific client capabilities.
---@field notebookDocument? dapui.async.lsp.types.NotebookDocumentClientCapabilities Capabilities specific to the notebook document support.  @since 3.17.0
---@field window? dapui.async.lsp.types.WindowClientCapabilities Window specific client capabilities.
---@field general? dapui.async.lsp.types.GeneralClientCapabilities General client capabilities.  @since 3.16.0
---@field experimental? dapui.async.lsp.types.LSPAny Experimental client capabilities.

--- Additional details for a completion item label.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.CompletionItemLabelDetails
---@field detail? string An optional string which is rendered less prominently directly after {@link CompletionItem.label label}, without any spacing. Should be used for function signatures and type annotations.
---@field description? string An optional string which is rendered less prominently after {@link CompletionItem.detail}. Should be used for fully qualified names and file paths.
---@alias dapui.async.lsp.types.LSPArray dapui.async.lsp.types.LSPAny[]

--- The data type of the ResponseError if the
--- initialize request fails.
---@class dapui.async.lsp.types.InitializeError
---@field retry boolean Indicates whether the client execute the following retry logic: (1) show the message provided by the ResponseError to the user (2) user selects retry or cancel (3) if user selected retry the initialize method is sent again.
---@alias dapui.async.lsp.types.ResourceOperationKind "create"|"rename"|"delete"

---@alias dapui.async.lsp.types.FailureHandlingKind "abort"|"transactional"|"textOnlyTransactional"|"undo"

--- Parameters for a [HoverRequest](#HoverRequest).
---@class dapui.async.lsp.types.HoverParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams
--- How a completion was triggered
---@alias dapui.async.lsp.types.CompletionTriggerKind 1|2|3

--- The diagnostic tags.
---
--- @since 3.15.0
---@alias dapui.async.lsp.types.DiagnosticTag 1|2

---@class dapui.async.lsp.types.TextDocumentSyncOptions
---@field openClose? boolean Open and close notifications are sent to the server. If omitted open close notification should not be sent.
---@field change? dapui.async.lsp.types.TextDocumentSyncKind Change notifications are sent to the server. See TextDocumentSyncKind.None, TextDocumentSyncKind.Full and TextDocumentSyncKind.Incremental. If omitted it defaults to TextDocumentSyncKind.None.
---@field willSave? boolean If present will save notifications are sent to the server. If omitted the notification should not be sent.
---@field willSaveWaitUntil? boolean If present will save wait until requests are sent to the server. If omitted the request should not be sent.
---@field save? boolean|dapui.async.lsp.types.SaveOptions If present save notifications are sent to the server. If omitted the notification should not be sent.
---@alias dapui.async.lsp.types.DocumentFilter dapui.async.lsp.types.TextDocumentFilter|dapui.async.lsp.types.NotebookCellTextDocumentFilter
---@alias dapui.async.lsp.types.ChangeAnnotationIdentifier string

--- Options specific to a notebook plus its cells
--- to be synced to the server.
---
--- If a selector provides a notebook document
--- filter but no cell selector all cells of a
--- matching notebook document will be synced.
---
--- If a selector provides no notebook document
--- filter but only a cell selector all notebook
--- document that contain at least one matching
--- cell will be synced.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.NotebookDocumentSyncOptions
---@field notebookSelector dapui.async.lsp.types.Structure19|dapui.async.lsp.types.Structure20[] The notebooks to be synced
---@field save? boolean Whether save notification should be forwarded to the server. Will only be honored if mode === `notebook`.

--- Registration options specific to a notebook.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.NotebookDocumentSyncRegistrationOptions : dapui.async.lsp.types.NotebookDocumentSyncOptions,dapui.async.lsp.types.StaticRegistrationOptions
---@alias dapui.async.lsp.types.WatchKind 1|2|4

---@alias dapui.async.lsp.types.TextDocumentContentChangeEvent dapui.async.lsp.types.Structure21|dapui.async.lsp.types.Structure22
---@alias dapui.async.lsp.types.TraceValues "off"|"messages"|"verbose"

--- A set of predefined code action kinds
---@alias dapui.async.lsp.types.CodeActionKind ""|"quickfix"|"refactor"|"refactor.extract"|"refactor.inline"|"refactor.rewrite"|"source"|"source.organizeImports"|"source.fixAll"

--- A set of predefined token modifiers. This set is not fixed
--- an clients can specify additional token types via the
--- corresponding client capabilities.
---
--- @since 3.16.0
---@alias dapui.async.lsp.types.SemanticTokenModifiers "declaration"|"definition"|"readonly"|"static"|"deprecated"|"abstract"|"async"|"modification"|"documentation"|"defaultLibrary"

--- Defines whether the insert text in a completion item should be interpreted as
--- plain text or a snippet.
---@alias dapui.async.lsp.types.InsertTextFormat 1|2

---@alias dapui.async.lsp.types.TextDocumentFilter dapui.async.lsp.types.Structure23|dapui.async.lsp.types.Structure24|dapui.async.lsp.types.Structure25
--- Represents reasons why a text document is saved.
---@alias dapui.async.lsp.types.TextDocumentSaveReason 1|2|3

--- A notebook cell text document filter denotes a cell text
--- document by different properties.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.NotebookCellTextDocumentFilter
---@field notebook string|dapui.async.lsp.types.NotebookDocumentFilter A filter that matches against the notebook containing the notebook cell. If a string value is provided it matches against the notebook type. '*' matches every notebook.
---@field language? string A language id like `python`.  Will be matched against the language id of the notebook cell document. '*' matches every language.
---@alias dapui.async.lsp.types.NotebookDocumentFilter dapui.async.lsp.types.Structure26|dapui.async.lsp.types.Structure27|dapui.async.lsp.types.Structure28
--- The message type
---@alias dapui.async.lsp.types.MessageType 1|2|3|4

--- The moniker kind.
---
--- @since 3.16.0
---@alias dapui.async.lsp.types.MonikerKind "import"|"export"|"local"

--- A set of predefined range kinds.
---@alias dapui.async.lsp.types.FoldingRangeKind "comment"|"imports"|"region"

---@alias dapui.async.lsp.types.LSPErrorCodes -32803|-32802|-32801|-32800

--- Predefined error codes.
---@alias dapui.async.lsp.types.ErrorCodes -32700|-32600|-32601|-32602|-32603|-32002|-32001

--- A document highlight kind.
---@alias dapui.async.lsp.types.DocumentHighlightKind 1|2|3

--- Represents a location inside a resource, such as a line
--- inside a text file.
---@class dapui.async.lsp.types.Location
---@field uri dapui.async.lsp.types.DocumentUri
---@field range dapui.async.lsp.types.Range
---@alias dapui.async.lsp.types.MarkedString string|dapui.async.lsp.types.Structure29
--- The file event type
---@alias dapui.async.lsp.types.FileChangeType 1|2|3

--- Code Lens provider options of a [CodeLensRequest](#CodeLensRequest).
---@class dapui.async.lsp.types.CodeLensOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field resolveProvider? boolean Code lens has a resolve provider as well.
---@alias dapui.async.lsp.types.DefinitionLink dapui.async.lsp.types.LocationLink

---@class dapui.async.lsp.types.ImplementationParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@alias dapui.async.lsp.types.WorkspaceDocumentDiagnosticReport dapui.async.lsp.types.WorkspaceFullDocumentDiagnosticReport|dapui.async.lsp.types.WorkspaceUnchangedDocumentDiagnosticReport
--- The diagnostic's severity.
---@alias dapui.async.lsp.types.DiagnosticSeverity 1|2|3|4

---@class dapui.async.lsp.types.ImplementationRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.ImplementationOptions,dapui.async.lsp.types.StaticRegistrationOptions
---@alias dapui.async.lsp.types.DocumentDiagnosticReport dapui.async.lsp.types.RelatedFullDocumentDiagnosticReport|dapui.async.lsp.types.RelatedUnchangedDocumentDiagnosticReport

---@class dapui.async.lsp.types.TypeDefinitionParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams

---@class dapui.async.lsp.types.TypeDefinitionRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.TypeDefinitionOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- Provider options for a [DocumentLinkRequest](#DocumentLinkRequest).
---@class dapui.async.lsp.types.DocumentLinkOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field resolveProvider? boolean Document links have a resolve provider as well.

--- A workspace folder inside a client.
---@class dapui.async.lsp.types.WorkspaceFolder
---@field uri dapui.async.lsp.types.URI The associated URI for this workspace folder.
---@field name string The name of the workspace folder. Used to refer to this workspace folder in the user interface.
---@alias dapui.async.lsp.types.DeclarationLink dapui.async.lsp.types.LocationLink

--- Value-object describing what options formatting should use.
---@class dapui.async.lsp.types.FormattingOptions
---@field tabSize integer Size of a tab in spaces.
---@field insertSpaces boolean Prefer spaces over tabs.
---@field trimTrailingWhitespace? boolean Trim trailing whitespace on a line.  @since 3.15.0
---@field insertFinalNewline? boolean Insert a newline character at the end of the file if one does not exist.  @since 3.15.0
---@field trimFinalNewlines? boolean Trim all newlines after the final newline at the end of the file.  @since 3.15.0
---@alias dapui.async.lsp.types.LSPAny dapui.async.lsp.types.LSPObject|dapui.async.lsp.types.LSPArray|string|integer|integer|number|boolean|nil

--- The parameters of a configuration request.
---@class dapui.async.lsp.types.ConfigurationParams
---@field items dapui.async.lsp.types.ConfigurationItem[]

--- Provider options for a [DocumentFormattingRequest](#DocumentFormattingRequest).
---@class dapui.async.lsp.types.DocumentFormattingOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@alias dapui.async.lsp.types.Declaration dapui.async.lsp.types.Location|dapui.async.lsp.types.Location[]

--- Represents a color range from a document.
---@class dapui.async.lsp.types.ColorInformation
---@field range dapui.async.lsp.types.Range The range in the document where this color appears.
---@field color dapui.async.lsp.types.Color The actual color value for this color range.

--- Parameters for a [DocumentColorRequest](#DocumentColorRequest).
---@class dapui.async.lsp.types.DocumentColorParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.

---@class dapui.async.lsp.types.DocumentColorRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.DocumentColorOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- Provider options for a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
---@class dapui.async.lsp.types.DocumentRangeFormattingOptions : dapui.async.lsp.types.WorkDoneProgressOptions

---@class dapui.async.lsp.types.WorkspaceFoldersServerCapabilities
---@field supported? boolean The server has support for workspace folders
---@field changeNotifications? string|boolean Whether the server wants to receive workspace folder change notifications.  If a string is provided the string is treated as an ID under which the notification is registered on the client side. The ID can be used to unregister for these events using the `client/unregisterCapability` request.

---@class dapui.async.lsp.types.ColorPresentation
---@field label string The label of this color presentation. It will be shown on the color picker header. By default this is also the text that is inserted when selecting this color presentation.
---@field textEdit? dapui.async.lsp.types.TextEdit An [edit](#TextEdit) which is applied to a document when selecting this presentation for the color.  When `falsy` the [label](#ColorPresentation.label) is used.
---@field additionalTextEdits? dapui.async.lsp.types.TextEdit[] An optional array of additional [text edits](#TextEdit) that are applied when selecting this color presentation. Edits must not overlap with the main [edit](#ColorPresentation.textEdit) nor with themselves.
---@alias dapui.async.lsp.types.Definition dapui.async.lsp.types.Location|dapui.async.lsp.types.Location[]

--- Options for notifications/requests for user operations on files.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.FileOperationOptions
---@field didCreate? dapui.async.lsp.types.FileOperationRegistrationOptions The server is interested in receiving didCreateFiles notifications.
---@field willCreate? dapui.async.lsp.types.FileOperationRegistrationOptions The server is interested in receiving willCreateFiles requests.
---@field didRename? dapui.async.lsp.types.FileOperationRegistrationOptions The server is interested in receiving didRenameFiles notifications.
---@field willRename? dapui.async.lsp.types.FileOperationRegistrationOptions The server is interested in receiving willRenameFiles requests.
---@field didDelete? dapui.async.lsp.types.FileOperationRegistrationOptions The server is interested in receiving didDeleteFiles file notifications.
---@field willDelete? dapui.async.lsp.types.FileOperationRegistrationOptions The server is interested in receiving willDeleteFiles file requests.

---@class dapui.async.lsp.types.Structure47
---@field valueSet dapui.async.lsp.types.CodeActionKind[] The code action kind values the client supports. When this property exists the client also guarantees that it will handle values outside its set gracefully and falls back to a default value when unknown.

--- Provider options for a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
---@class dapui.async.lsp.types.DocumentOnTypeFormattingOptions
---@field firstTriggerCharacter string A character on which formatting should be triggered, like `{`.
---@field moreTriggerCharacter? string[] More trigger characters.

--- Client capabilities specific to regular expressions.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.RegularExpressionsClientCapabilities
---@field engine string The engine's name.
---@field version? string The engine's version.

--- The parameters passed via a apply workspace edit request.
---@class dapui.async.lsp.types.ApplyWorkspaceEditParams
---@field label? string An optional label of the workspace edit. This label is presented in the user interface for example on an undo stack to undo the workspace edit.
---@field edit dapui.async.lsp.types.WorkspaceEdit The edits to apply.

--- Value-object that contains additional information when
--- requesting references.
---@class dapui.async.lsp.types.ReferenceContext
---@field includeDeclaration boolean Include the declaration of the current symbol.

--- Represents the signature of something callable. A signature
--- can have a label, like a function-name, a doc-comment, and
--- a set of parameters.
---@class dapui.async.lsp.types.SignatureInformation
---@field label string The label of this signature. Will be shown in the UI.
---@field documentation? string|dapui.async.lsp.types.MarkupContent The human-readable doc-comment of this signature. Will be shown in the UI but can be omitted.
---@field parameters? dapui.async.lsp.types.ParameterInformation[] The parameters of this signature.
---@field activeParameter? integer The index of the active parameter.  If provided, this is used in place of `SignatureHelp.activeParameter`.  @since 3.16.0

--- A special text edit to provide an insert and a replace operation.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.InsertReplaceEdit
---@field newText string The string to be inserted.
---@field insert dapui.async.lsp.types.Range The range if the insert is requested
---@field replace dapui.async.lsp.types.Range The range if the replace is requested.

--- Provider options for a [RenameRequest](#RenameRequest).
---@class dapui.async.lsp.types.RenameOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field prepareProvider? boolean Renames should be checked and tested before being executed.  @since version 3.12.0

--- Contains additional information about the context in which a completion request is triggered.
---@class dapui.async.lsp.types.CompletionContext
---@field triggerKind dapui.async.lsp.types.CompletionTriggerKind How the completion was triggered.
---@field triggerCharacter? string The trigger character (a single character) that has trigger code complete. Is undefined if `triggerKind !== CompletionTriggerKind.TriggerCharacter`

---@class dapui.async.lsp.types.WorkDoneProgressCreateParams
---@field token dapui.async.lsp.types.ProgressToken The token to be used to report progress.

---@class dapui.async.lsp.types.DidChangeConfigurationClientCapabilities
---@field dynamicRegistration? boolean Did change configuration notification supports dynamic registration.

--- The server capabilities of a [ExecuteCommandRequest](#ExecuteCommandRequest).
---@class dapui.async.lsp.types.ExecuteCommandOptions : dapui.async.lsp.types.WorkDoneProgressOptions
---@field commands string[] The commands to be executed on the server
---@alias dapui.async.lsp.types.GlobPattern dapui.async.lsp.types.Pattern|dapui.async.lsp.types.RelativePattern

---@class dapui.async.lsp.types.DidChangeWatchedFilesClientCapabilities
---@field dynamicRegistration? boolean Did change watched files notification supports dynamic registration. Please note that the current protocol doesn't support static configuration for file changes from the server side.
---@field relativePatternSupport? boolean Whether the client has support for {@link  RelativePattern relative pattern} or not.  @since 3.17.0

--- Type hierarchy options used during static registration.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.TypeHierarchyOptions : dapui.async.lsp.types.WorkDoneProgressOptions

--- Client capabilities for a [WorkspaceSymbolRequest](#WorkspaceSymbolRequest).
---@class dapui.async.lsp.types.WorkspaceSymbolClientCapabilities
---@field dynamicRegistration? boolean Symbol request supports dynamic registration.
---@field symbolKind? dapui.async.lsp.types.Structure30 Specific capabilities for the `SymbolKind` in the `workspace/symbol` request.
---@field tagSupport? dapui.async.lsp.types.Structure31 The client supports tags on `SymbolInformation`. Clients supporting tags have to handle unknown tags gracefully.  @since 3.16.0
---@field resolveSupport? dapui.async.lsp.types.Structure32 The client support partial workspace symbols. The client will send the request `workspaceSymbol/resolve` to the server to resolve additional properties.  @since 3.17.0

---@class dapui.async.lsp.types.Structure15
---@field array dapui.async.lsp.types.NotebookCellArrayChange The change to the cell array.
---@field didOpen? dapui.async.lsp.types.TextDocumentItem[] Additional opened cell text documents.
---@field didClose? dapui.async.lsp.types.TextDocumentIdentifier[] Additional closed cell text documents.

--- Represents information on a file/folder rename.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.FileRename
---@field oldUri string A file:// URI for the original location of the file/folder being renamed.
---@field newUri string A file:// URI for the new location of the file/folder being renamed.

--- The client capabilities of a [ExecuteCommandRequest](#ExecuteCommandRequest).
---@class dapui.async.lsp.types.ExecuteCommandClientCapabilities
---@field dynamicRegistration? boolean Execute command supports dynamic registration.

--- Structure to capture a description for an error code.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.CodeDescription
---@field href dapui.async.lsp.types.URI An URI to open with more information about the diagnostic error.

---@class dapui.async.lsp.types.Structure36
---@field groupsOnLabel? boolean Whether the client groups edits with equal labels into tree nodes, for instance all edits labelled with "Changes in Strings" would be a tree node.

--- A parameter literal used in inlay hint requests.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlayHintParams : dapui.async.lsp.types.WorkDoneProgressParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The text document.
---@field range dapui.async.lsp.types.Range The document range for which inlay hints should be computed.

---@class dapui.async.lsp.types.WorkDoneProgressBegin
---@field kind 'begin'
---@field title string Mandatory title of the progress operation. Used to briefly inform about the kind of operation being performed.  Examples: "Indexing" or "Linking dependencies".
---@field cancellable? boolean Controls if a cancel button should show to allow the user to cancel the long running operation. Clients that don't support cancellation are allowed to ignore the setting.
---@field message? string Optional, more detailed associated progress message. Contains complementary information to the `title`.  Examples: "3/25 files", "project/src/module2", "node_modules/some_dep". If unset, the previous progress message (if any) is still valid.
---@field percentage? integer Optional progress percentage to display (value 100 is considered 100%). If not provided infinite progress is assumed and clients are allowed to ignore the `percentage` value in subsequent in report notifications.  The value should be steadily rising. Clients are free to ignore values that are not following this rule. The value range is [0, 100].

---@class dapui.async.lsp.types.WorkDoneProgressEnd
---@field kind 'end'
---@field message? string Optional, a final message indicating to for example indicate the outcome of the operation.

--- Represents a related message and source code location for a diagnostic. This should be
--- used to point to code locations that cause or related to a diagnostics, e.g when duplicating
--- a symbol in a scope.
---@class dapui.async.lsp.types.DiagnosticRelatedInformation
---@field location dapui.async.lsp.types.Location The location of this related diagnostic information.
---@field message string The message of this related diagnostic information.

--- @since 3.16.0
---@class dapui.async.lsp.types.CodeLensWorkspaceClientCapabilities
---@field refreshSupport? boolean Whether the client implementation supports a refresh request sent from the server to the client.  Note that this event is global and will force the client to refresh all code lenses currently shown. It should be used with absolute care and is useful for situation where a server for example detect a project wide change that requires such a calculation.

--- Client Capabilities for a [DocumentHighlightRequest](#DocumentHighlightRequest).
---@class dapui.async.lsp.types.DocumentHighlightClientCapabilities
---@field dynamicRegistration? boolean Whether document highlight supports dynamic registration.

--- Capabilities relating to events from file operations by the user in the client.
---
--- These events do not come from the file system, they come from user operations
--- like renaming a file in the UI.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.FileOperationClientCapabilities
---@field dynamicRegistration? boolean Whether the client supports dynamic registration for file requests/notifications.
---@field didCreate? boolean The client has support for sending didCreateFiles notifications.
---@field willCreate? boolean The client has support for sending willCreateFiles requests.
---@field didRename? boolean The client has support for sending didRenameFiles notifications.
---@field willRename? boolean The client has support for sending willRenameFiles requests.
---@field didDelete? boolean The client has support for sending didDeleteFiles notifications.
---@field willDelete? boolean The client has support for sending willDeleteFiles requests.

--- Registration options for a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
---@class dapui.async.lsp.types.DocumentOnTypeFormattingRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.DocumentOnTypeFormattingOptions

---@class dapui.async.lsp.types.Structure16
---@field document dapui.async.lsp.types.VersionedTextDocumentIdentifier
---@field changes dapui.async.lsp.types.TextDocumentContentChangeEvent[]

--- Client workspace capabilities specific to inline values.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlineValueWorkspaceClientCapabilities
---@field refreshSupport? boolean Whether the client implementation supports a refresh request sent from the server to the client.  Note that this event is global and will force the client to refresh all inline values currently shown. It should be used with absolute care and is useful for situation where a server for example detects a project wide change that requires such a calculation.

---@class dapui.async.lsp.types.UnregistrationParams
---@field unregisterations dapui.async.lsp.types.Unregistration[]

---@class dapui.async.lsp.types.Structure37
---@field documentationFormat? dapui.async.lsp.types.MarkupKind[] Client supports the following content formats for the documentation property. The order describes the preferred format of the client.
---@field parameterInformation? dapui.async.lsp.types.Structure53 Client capabilities specific to parameter information.
---@field activeParameterSupport? boolean The client supports the `activeParameter` property on `SignatureInformation` literal.  @since 3.16.0

--- Parameters for a [SignatureHelpRequest](#SignatureHelpRequest).
---@class dapui.async.lsp.types.SignatureHelpParams : dapui.async.lsp.types.TextDocumentPositionParams,dapui.async.lsp.types.WorkDoneProgressParams
---@field context? dapui.async.lsp.types.SignatureHelpContext The signature help context. This is only available if the client specifies to send this using the client capability `textDocument.signatureHelp.contextSupport === true`  @since 3.15.0

--- Client workspace capabilities specific to inlay hints.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlayHintWorkspaceClientCapabilities
---@field refreshSupport? boolean Whether the client implementation supports a refresh request sent from the server to the client.  Note that this event is global and will force the client to refresh all inlay hints currently shown. It should be used with absolute care and is useful for situation where a server for example detects a project wide change that requires such a calculation.
--- Defines how the host (editor) should sync
--- document changes to the language server.
---@alias dapui.async.lsp.types.TextDocumentSyncKind 0|1|2

--- Workspace client capabilities specific to diagnostic pull requests.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DiagnosticWorkspaceClientCapabilities
---@field refreshSupport? boolean Whether the client implementation supports a refresh request sent from the server to the client.  Note that this event is global and will force the client to refresh all pulled diagnostics currently shown. It should be used with absolute care and is useful for situation where a server for example detects a project wide change that requires such a calculation.

---@class dapui.async.lsp.types.HoverClientCapabilities
---@field dynamicRegistration? boolean Whether hover supports dynamic registration.
---@field contentFormat? dapui.async.lsp.types.MarkupKind[] Client supports the following content formats for the content property. The order describes the preferred format of the client.

---@class dapui.async.lsp.types.TextDocumentSyncClientCapabilities
---@field dynamicRegistration? boolean Whether text document synchronization supports dynamic registration.
---@field willSave? boolean The client supports sending will save notifications.
---@field willSaveWaitUntil? boolean The client supports sending a will save request and waits for a response providing text edits which will be applied to the document before it is saved.
---@field didSave? boolean The client supports did save notifications.

--- A change describing how to move a `NotebookCell`
--- array from state S to S'.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.NotebookCellArrayChange
---@field start integer The start oftest of the cell that changed.
---@field deleteCount integer The deleted cells
---@field cells? dapui.async.lsp.types.NotebookCell[] The new cells, if any

--- Completion client capabilities
---@class dapui.async.lsp.types.CompletionClientCapabilities
---@field dynamicRegistration? boolean Whether completion supports dynamic registration.
---@field completionItem? dapui.async.lsp.types.Structure33 The client supports the following `CompletionItem` specific capabilities.
---@field completionItemKind? dapui.async.lsp.types.Structure34
---@field insertTextMode? dapui.async.lsp.types.InsertTextMode Defines how the client handles whitespace and indentation when accepting a completion item that uses multi line text in either `insertText` or `textEdit`.  @since 3.17.0
---@field contextSupport? boolean The client supports to send additional context information for a `textDocument/completion` request.
---@field completionList? dapui.async.lsp.types.Structure35 The client supports the following `CompletionList` specific capabilities.  @since 3.17.0

--- @since 3.16.0
---@class dapui.async.lsp.types.SemanticTokensWorkspaceClientCapabilities
---@field refreshSupport? boolean Whether the client implementation supports a refresh request sent from the server to the client.  Note that this event is global and will force the client to refresh all semantic tokens currently shown. It should be used with absolute care and is useful for situation where a server for example detects a project wide change that requires such a calculation.

--- Represents a diagnostic, such as a compiler error or warning. Diagnostic objects
--- are only valid in the scope of a resource.
---@class dapui.async.lsp.types.Diagnostic
---@field range dapui.async.lsp.types.Range The range at which the message applies
---@field severity? dapui.async.lsp.types.DiagnosticSeverity The diagnostic's severity. Can be omitted. If omitted it is up to the client to interpret diagnostics as error, warning, info or hint.
---@field code? integer|string The diagnostic's code, which usually appear in the user interface.
---@field codeDescription? dapui.async.lsp.types.CodeDescription An optional property to describe the error code. Requires the code field (above) to be present/not null.  @since 3.16.0
---@field source? string A human-readable string describing the source of this diagnostic, e.g. 'typescript' or 'super lint'. It usually appears in the user interface.
---@field message string The diagnostic's message. It usually appears in the user interface
---@field tags? dapui.async.lsp.types.DiagnosticTag[] Additional metadata about the diagnostic.  @since 3.15.0
---@field relatedInformation? dapui.async.lsp.types.DiagnosticRelatedInformation[] An array of related diagnostic information, e.g. when symbol-names within a scope collide all definitions can be marked via this property.
---@field data? dapui.async.lsp.types.LSPAny A data entry field that is preserved between a `textDocument/publishDiagnostics` notification and `textDocument/codeAction` request.  @since 3.16.0

---@class dapui.async.lsp.types.WorkspaceEditClientCapabilities
---@field documentChanges? boolean The client supports versioned document changes in `WorkspaceEdit`s
---@field resourceOperations? dapui.async.lsp.types.ResourceOperationKind[] The resource operations the client supports. Clients should at least support 'create', 'rename' and 'delete' files and folders.  @since 3.13.0
---@field failureHandling? dapui.async.lsp.types.FailureHandlingKind The failure handling strategy of a client if applying the workspace edit fails.  @since 3.13.0
---@field normalizesLineEndings? boolean Whether the client normalizes line endings to the client specific setting. If set to `true` the client will normalize line ending characters in a workspace edit to the client-specified new line character.  @since 3.16.0
---@field changeAnnotationSupport? dapui.async.lsp.types.Structure36 Whether the client in general supports change annotations on text edits, create file, rename file and delete file changes.  @since 3.16.0

--- Client Capabilities for a [SignatureHelpRequest](#SignatureHelpRequest).
---@class dapui.async.lsp.types.SignatureHelpClientCapabilities
---@field dynamicRegistration? boolean Whether signature help supports dynamic registration.
---@field signatureInformation? dapui.async.lsp.types.Structure37 The client supports the following `SignatureInformation` specific properties.
---@field contextSupport? boolean The client supports to send additional context information for a `textDocument/signatureHelp` request. A client that opts into contextSupport will also support the `retriggerCharacters` on `SignatureHelpOptions`.  @since 3.15.0

--- A workspace diagnostic report.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.WorkspaceDiagnosticReport
---@field items dapui.async.lsp.types.WorkspaceDocumentDiagnosticReport[]

--- @since 3.14.0
---@class dapui.async.lsp.types.DeclarationClientCapabilities
---@field dynamicRegistration? boolean Whether declaration supports dynamic registration. If this is set to `true` the client supports the new `DeclarationRegistrationOptions` return value for the corresponding server capability as well.
---@field linkSupport? boolean The client supports additional metadata in the form of declaration links.
--- How a signature help was triggered.
---
--- @since 3.15.0
---@alias dapui.async.lsp.types.SignatureHelpTriggerKind 1|2|3

--- A completion item represents a text snippet that is
--- proposed to complete text that is being typed.
---@class dapui.async.lsp.types.CompletionItem
---@field label string The label of this completion item.  The label property is also by default the text that is inserted when selecting this completion.  If label details are provided the label itself should be an unqualified name of the completion item.
---@field labelDetails? dapui.async.lsp.types.CompletionItemLabelDetails Additional details for the label  @since 3.17.0
---@field kind? dapui.async.lsp.types.CompletionItemKind The kind of this completion item. Based of the kind an icon is chosen by the editor.
---@field tags? dapui.async.lsp.types.CompletionItemTag[] Tags for this completion item.  @since 3.15.0
---@field detail? string A human-readable string with additional information about this item, like type or symbol information.
---@field documentation? string|dapui.async.lsp.types.MarkupContent A human-readable string that represents a doc-comment.
---@field deprecated? boolean Indicates if this item is deprecated. @deprecated Use `tags` instead.
---@field preselect? boolean Select this item when showing.  *Note* that only one completion item can be selected and that the tool / client decides which item that is. The rule is that the *first* item of those that match best is selected.
---@field sortText? string A string that should be used when comparing this item with other items. When `falsy` the [label](#CompletionItem.label) is used.
---@field filterText? string A string that should be used when filtering a set of completion items. When `falsy` the [label](#CompletionItem.label) is used.
---@field insertText? string A string that should be inserted into a document when selecting this completion. When `falsy` the [label](#CompletionItem.label) is used.  The `insertText` is subject to interpretation by the client side. Some tools might not take the string literally. For example VS Code when code complete is requested in this example `con<cursor position>` and a completion item with an `insertText` of `console` is provided it will only insert `sole`. Therefore it is recommended to use `textEdit` instead since it avoids additional client side interpretation.
---@field insertTextFormat? dapui.async.lsp.types.InsertTextFormat The format of the insert text. The format applies to both the `insertText` property and the `newText` property of a provided `textEdit`. If omitted defaults to `InsertTextFormat.PlainText`.  Please note that the insertTextFormat doesn't apply to `additionalTextEdits`.
---@field insertTextMode? dapui.async.lsp.types.InsertTextMode How whitespace and indentation is handled during completion item insertion. If not provided the clients default value depends on the `textDocument.completion.insertTextMode` client capability.  @since 3.16.0
---@field textEdit? dapui.async.lsp.types.TextEdit|dapui.async.lsp.types.InsertReplaceEdit An [edit](#TextEdit) which is applied to a document when selecting this completion. When an edit is provided the value of [insertText](#CompletionItem.insertText) is ignored.  Most editors support two different operations when accepting a completion item. One is to insert a completion text and the other is to replace an existing text with a completion text. Since this can usually not be predetermined by a server it can report both ranges. Clients need to signal support for `InsertReplaceEdits` via the `textDocument.completion.insertReplaceSupport` client capability property.  *Note 1:* The text edit's range as well as both ranges from an insert replace edit must be a [single line] and they must contain the position at which completion has been requested. *Note 2:* If an `InsertReplaceEdit` is returned the edit's insert range must be a prefix of the edit's replace range, that means it must be contained and starting at the same position.  @since 3.16.0 additional type `InsertReplaceEdit`
---@field textEditText? string The edit text used if the completion item is part of a CompletionList and CompletionList defines an item default for the text edit range.  Clients will only honor this property if they opt into completion list item defaults using the capability `completionList.itemDefaults`.  If not provided and a list's default range is provided the label property is used as a text.  @since 3.17.0
---@field additionalTextEdits? dapui.async.lsp.types.TextEdit[] An optional array of additional [text edits](#TextEdit) that are applied when selecting this completion. Edits must not overlap (including the same insert position) with the main [edit](#CompletionItem.textEdit) nor with themselves.  Additional text edits should be used to change text unrelated to the current cursor position (for example adding an import statement at the top of the file if the completion item will insert an unqualified type).
---@field commitCharacters? string[] An optional set of characters that when pressed while this completion is active will accept it first and then type that character. *Note* that all commit characters should have `length=1` and that superfluous characters will be ignored.
---@field command? dapui.async.lsp.types.Command An optional [command](#Command) that is executed *after* inserting this completion. *Note* that additional modifications to the current document should be described with the [additionalTextEdits](#CompletionItem.additionalTextEdits)-property.
---@field data? dapui.async.lsp.types.LSPAny A data entry field that is preserved on a completion item between a [CompletionRequest](#CompletionRequest) and a [CompletionResolveRequest](#CompletionResolveRequest).

--- Client Capabilities for a [DefinitionRequest](#DefinitionRequest).
---@class dapui.async.lsp.types.DefinitionClientCapabilities
---@field dynamicRegistration? boolean Whether definition supports dynamic registration.
---@field linkSupport? boolean The client supports additional metadata in the form of definition links.  @since 3.14.0

--- The result returned from an initialize request.
---@class dapui.async.lsp.types.InitializeResult
---@field capabilities dapui.async.lsp.types.ServerCapabilities The capabilities the language server provides.
---@field serverInfo? dapui.async.lsp.types.Structure38 Information about the server.  @since 3.15.0

--- Since 3.6.0
---@class dapui.async.lsp.types.TypeDefinitionClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration. If this is set to `true` the client supports the new `TypeDefinitionRegistrationOptions` return value for the corresponding server capability as well.
---@field linkSupport? boolean The client supports additional metadata in the form of definition links.  Since 3.14.0

--- The parameters of a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
---@class dapui.async.lsp.types.DocumentRangeFormattingParams : dapui.async.lsp.types.WorkDoneProgressParams
---@field textDocument dapui.async.lsp.types.TextDocumentIdentifier The document to format.
---@field range dapui.async.lsp.types.Range The range to format
---@field options dapui.async.lsp.types.FormattingOptions The format options

--- @since 3.6.0
---@class dapui.async.lsp.types.ImplementationClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration. If this is set to `true` the client supports the new `ImplementationRegistrationOptions` return value for the corresponding server capability as well.
---@field linkSupport? boolean The client supports additional metadata in the form of definition links.  @since 3.14.0

---@class dapui.async.lsp.types.Structure49
---@field properties string[] The properties that a client can resolve lazily.

--- Client Capabilities for a [ReferencesRequest](#ReferencesRequest).
---@class dapui.async.lsp.types.ReferenceClientCapabilities
---@field dynamicRegistration? boolean Whether references supports dynamic registration.

--- Parameters of the workspace diagnostic request.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.WorkspaceDiagnosticParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field identifier? string The additional identifier provided during registration.
---@field previousResultIds dapui.async.lsp.types.PreviousResultId[] The currently known diagnostic reports with their previous result ids.

--- Represents a parameter of a callable-signature. A parameter can
--- have a label and a doc-comment.
---@class dapui.async.lsp.types.ParameterInformation
---@field label string|integer,integer The label of this parameter information.  Either a string or an inclusive start and exclusive end offsets within its containing signature label. (see SignatureInformation.label). The offsets are based on a UTF-16 string representation as `Position` and `Range` does.  *Note*: a label of type string should be a substring of its containing signature label. Its intended use case is to highlight the parameter label part in the `SignatureInformation.label`.
---@field documentation? string|dapui.async.lsp.types.MarkupContent The human-readable doc-comment of this parameter. Will be shown in the UI but can be omitted.

---@class dapui.async.lsp.types.WorkDoneProgressReport
---@field kind 'report'
---@field cancellable? boolean Controls enablement state of a cancel button.  Clients that don't support cancellation or don't support controlling the button's enablement state are allowed to ignore the property.
---@field message? string Optional, more detailed associated progress message. Contains complementary information to the `title`.  Examples: "3/25 files", "project/src/module2", "node_modules/some_dep". If unset, the previous progress message (if any) is still valid.
---@field percentage? integer Optional progress percentage to display (value 100 is considered 100%). If not provided infinite progress is assumed and clients are allowed to ignore the `percentage` value in subsequent in report notifications.  The value should be steadily rising. Clients are free to ignore values that are not following this rule. The value range is [0, 100]

--- Client Capabilities for a [DocumentSymbolRequest](#DocumentSymbolRequest).
---@class dapui.async.lsp.types.DocumentSymbolClientCapabilities
---@field dynamicRegistration? boolean Whether document symbol supports dynamic registration.
---@field symbolKind? dapui.async.lsp.types.Structure39 Specific capabilities for the `SymbolKind` in the `textDocument/documentSymbol` request.
---@field hierarchicalDocumentSymbolSupport? boolean The client supports hierarchical document symbols.
---@field tagSupport? dapui.async.lsp.types.Structure40 The client supports tags on `SymbolInformation`. Tags are supported on `DocumentSymbol` if `hierarchicalDocumentSymbolSupport` is set to true. Clients supporting tags have to handle unknown tags gracefully.  @since 3.16.0
---@field labelSupport? boolean The client supports an additional label presented in the UI when registering a document symbol provider.  @since 3.16.0

--- Diagnostic registration options.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.DiagnosticRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.DiagnosticOptions,dapui.async.lsp.types.StaticRegistrationOptions

--- The Client Capabilities of a [CodeActionRequest](#CodeActionRequest).
---@class dapui.async.lsp.types.CodeActionClientCapabilities
---@field dynamicRegistration? boolean Whether code action supports dynamic registration.
---@field codeActionLiteralSupport? dapui.async.lsp.types.Structure41 The client support code action literals of type `CodeAction` as a valid response of the `textDocument/codeAction` request. If the property is not set the request can only return `Command` literals.  @since 3.8.0
---@field isPreferredSupport? boolean Whether code action supports the `isPreferred` property.  @since 3.15.0
---@field disabledSupport? boolean Whether code action supports the `disabled` property.  @since 3.16.0
---@field dataSupport? boolean Whether code action supports the `data` property which is preserved between a `textDocument/codeAction` and a `codeAction/resolve` request.  @since 3.16.0
---@field resolveSupport? dapui.async.lsp.types.Structure42 Whether the client supports resolving additional code action properties via a separate `codeAction/resolve` request.  @since 3.16.0
---@field honorsChangeAnnotations? boolean Whether the client honors the change annotations in text edits and resource operations returned via the `CodeAction#edit` property by for example presenting the workspace edit in the user interface and asking for confirmation.  @since 3.16.0

--- Inlay hint information.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlayHint
---@field position dapui.async.lsp.types.Position The position of this hint.
---@field label string|dapui.async.lsp.types.InlayHintLabelPart[] The label of this hint. A human readable string or an array of InlayHintLabelPart label parts.  *Note* that neither the string nor the label part can be empty.
---@field kind? dapui.async.lsp.types.InlayHintKind The kind of this hint. Can be omitted in which case the client should fall back to a reasonable default.
---@field textEdits? dapui.async.lsp.types.TextEdit[] Optional text edits that are performed when accepting this inlay hint.  *Note* that edits are expected to change the document so that the inlay hint (or its nearest variant) is now part of the document and the inlay hint itself is now obsolete.
---@field tooltip? string|dapui.async.lsp.types.MarkupContent The tooltip text when you hover over this item.
---@field paddingLeft? boolean Render padding before the hint.  Note: Padding should use the editor's background color, not the background color of the hint itself. That means padding can be used to visually align/separate an inlay hint.
---@field paddingRight? boolean Render padding after the hint.  Note: Padding should use the editor's background color, not the background color of the hint itself. That means padding can be used to visually align/separate an inlay hint.
---@field data? dapui.async.lsp.types.LSPAny A data entry field that is preserved on an inlay hint between a `textDocument/inlayHint` and a `inlayHint/resolve` request.

--- The client capabilities  of a [CodeLensRequest](#CodeLensRequest).
---@class dapui.async.lsp.types.CodeLensClientCapabilities
---@field dynamicRegistration? boolean Whether code lens supports dynamic registration.

---@class dapui.async.lsp.types.Structure50
---@field valueSet dapui.async.lsp.types.InsertTextMode[]

--- The parameter of a `typeHierarchy/supertypes` request.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.TypeHierarchySupertypesParams : dapui.async.lsp.types.WorkDoneProgressParams,dapui.async.lsp.types.PartialResultParams
---@field item dapui.async.lsp.types.TypeHierarchyItem

--- The client capabilities of a [DocumentLinkRequest](#DocumentLinkRequest).
---@class dapui.async.lsp.types.DocumentLinkClientCapabilities
---@field dynamicRegistration? boolean Whether document link supports dynamic registration.
---@field tooltipSupport? boolean Whether the client supports the `tooltip` property on `DocumentLink`.  @since 3.15.0

--- Provide inline value as text.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.InlineValueText
---@field range dapui.async.lsp.types.Range The document range for which the inline value applies.
---@field text string The text of the inline value.

---@class dapui.async.lsp.types.DocumentColorClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration. If this is set to `true` the client supports the new `DocumentColorRegistrationOptions` return value for the corresponding server capability as well.

---@class dapui.async.lsp.types.Structure46
---@field insert dapui.async.lsp.types.Range
---@field replace dapui.async.lsp.types.Range

--- Client capabilities of a [DocumentFormattingRequest](#DocumentFormattingRequest).
---@class dapui.async.lsp.types.DocumentFormattingClientCapabilities
---@field dynamicRegistration? boolean Whether formatting supports dynamic registration.

--- The parameters sent in notifications/requests for user-initiated creation of
--- files.
---
--- @since 3.16.0
---@class dapui.async.lsp.types.CreateFilesParams
---@field files dapui.async.lsp.types.FileCreate[] An array of all files/folders created in this operation.

--- An unchanged diagnostic report with a set of related documents.
---
--- @since 3.17.0
---@class dapui.async.lsp.types.RelatedUnchangedDocumentDiagnosticReport : dapui.async.lsp.types.UnchangedDocumentDiagnosticReport
---@field relatedDocuments? table<dapui.async.lsp.types.DocumentUri, dapui.async.lsp.types.FullDocumentDiagnosticReport|dapui.async.lsp.types.UnchangedDocumentDiagnosticReport> Diagnostics of related documents. This information is useful in programming languages where code in a file A can generate diagnostics in a file B which A depends on. An example of such a language is C/C++ where marco definitions in a file a.cpp and result in errors in a header file b.hpp.  @since 3.17.0

--- Client capabilities of a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
---@class dapui.async.lsp.types.DocumentRangeFormattingClientCapabilities
---@field dynamicRegistration? boolean Whether range formatting supports dynamic registration.

---@class dapui.async.lsp.types.PartialResultParams
---@field partialResultToken? dapui.async.lsp.types.ProgressToken An optional token that a server can use to report partial results (e.g. streaming) to the client.

--- Rename file operation
---@class dapui.async.lsp.types.RenameFile : dapui.async.lsp.types.ResourceOperation
---@field kind 'rename' A rename
---@field oldUri dapui.async.lsp.types.DocumentUri The old (existing) location.
---@field newUri dapui.async.lsp.types.DocumentUri The new location.
---@field options? dapui.async.lsp.types.RenameFileOptions Rename options.

--- Client capabilities of a [DocumentOnTypeFormattingRequest](#DocumentOnTypeFormattingRequest).
---@class dapui.async.lsp.types.DocumentOnTypeFormattingClientCapabilities
---@field dynamicRegistration? boolean Whether on type formatting supports dynamic registration.

--- Registration options for a [DocumentRangeFormattingRequest](#DocumentRangeFormattingRequest).
---@class dapui.async.lsp.types.DocumentRangeFormattingRegistrationOptions : dapui.async.lsp.types.TextDocumentRegistrationOptions,dapui.async.lsp.types.DocumentRangeFormattingOptions

---@class dapui.async.lsp.types.RenameClientCapabilities
---@field dynamicRegistration? boolean Whether rename supports dynamic registration.
---@field prepareSupport? boolean Client supports testing for validity of rename operations before execution.  @since 3.12.0
---@field prepareSupportDefaultBehavior? dapui.async.lsp.types.PrepareSupportDefaultBehavior Client supports the default behavior result.  The value indicates the default behavior used by the client.  @since 3.16.0
---@field honorsChangeAnnotations? boolean Whether the client honors the change annotations in text edits and resource operations returned via the rename request's workspace edit by for example presenting the workspace edit in the user interface and asking for confirmation.  @since 3.16.0
--- The reason why code actions were requested.
---
--- @since 3.17.0
---@alias dapui.async.lsp.types.CodeActionTriggerKind 1|2

---@class dapui.async.lsp.types.FoldingRangeClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration for folding range providers. If this is set to `true` the client supports the new `FoldingRangeRegistrationOptions` return value for the corresponding server capability as well.
---@field rangeLimit? integer The maximum number of folding ranges that the client prefers to receive per document. The value serves as a hint, servers are free to follow the limit.
---@field lineFoldingOnly? boolean If set, the client signals that it only supports folding complete lines. If set, client will ignore specified `startCharacter` and `endCharacter` properties in a FoldingRange.
---@field foldingRangeKind? dapui.async.lsp.types.Structure43 Specific options for the folding range kind.  @since 3.17.0
---@field foldingRange? dapui.async.lsp.types.Structure44 Specific options for the folding range.  @since 3.17.0

--- The watched files change notification's parameters.
---@class dapui.async.lsp.types.DidChangeWatchedFilesParams
---@field changes dapui.async.lsp.types.FileEvent[] The actual file events.

--- Additional information about the context in which a signature help request was triggered.
---
--- @since 3.15.0
---@class dapui.async.lsp.types.SignatureHelpContext
---@field triggerKind dapui.async.lsp.types.SignatureHelpTriggerKind Action that caused signature help to be triggered.
---@field triggerCharacter? string Character that caused signature help to be triggered.  This is undefined when `triggerKind !== SignatureHelpTriggerKind.TriggerCharacter`
---@field isRetrigger boolean `true` if signature help was already showing when it was triggered.  Retriggers occurs when the signature help is already active and can be caused by actions such as typing a trigger character, a cursor move, or document content changes.
---@field activeSignatureHelp? dapui.async.lsp.types.SignatureHelp The currently active `SignatureHelp`.  The `activeSignatureHelp` has its `SignatureHelp.activeSignature` field updated based on the user navigating through available signatures.

---@class dapui.async.lsp.types.SelectionRangeClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration for selection range providers. If this is set to `true` the client supports the new `SelectionRangeRegistrationOptions` return value for the corresponding server capability as well.

--- Server Capabilities for a [DefinitionRequest](#DefinitionRequest).
---@class dapui.async.lsp.types.DefinitionOptions : dapui.async.lsp.types.WorkDoneProgressOptions

--- The publish diagnostic client capabilities.
---@class dapui.async.lsp.types.PublishDiagnosticsClientCapabilities
---@field relatedInformation? boolean Whether the clients accepts diagnostics with related information.
---@field tagSupport? dapui.async.lsp.types.Structure45 Client supports the tag property to provide meta data about a diagnostic. Clients supporting tags have to handle unknown tags gracefully.  @since 3.15.0
---@field versionSupport? boolean Whether the client interprets the version property of the `textDocument/publishDiagnostics` notification's parameter.  @since 3.15.0
---@field codeDescriptionSupport? boolean Client supports a codeDescription property  @since 3.16.0
---@field dataSupport? boolean Whether code action supports the `data` property which is preserved between a `textDocument/publishDiagnostics` and `textDocument/codeAction` request.  @since 3.16.0

--- Options to create a file.
---@class dapui.async.lsp.types.CreateFileOptions
---@field overwrite? boolean Overwrite existing file. Overwrite wins over `ignoreIfExists`
---@field ignoreIfExists? boolean Ignore if exists.

--- @since 3.16.0
---@class dapui.async.lsp.types.CallHierarchyClientCapabilities
---@field dynamicRegistration? boolean Whether implementation supports dynamic registration. If this is set to `true` the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)` return value for the corresponding server capability as well.

--- Registration options for a [ExecuteCommandRequest](#ExecuteCommandRequest).
---@class dapui.async.lsp.types.ExecuteCommandRegistrationOptions : dapui.async.lsp.types.ExecuteCommandOptions
