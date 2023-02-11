extern ExitProcess (uExitCode: u32);

extern __exit__ (exit_code: u32) 
{
    ExitProcess(exit_code);
}

extern MessageBoxA (hWnd: ptr, lpText: *u8, lpCaption: *u8, uType: u32) : i32;

private message_box_flags: u32 := 0x0000:32  // MB_OK
                             <or> 0x0000:32  // MB_DEFBUTTON1
                             <or> 0x0010:32  // MB_ICONERROR
                             <or> 0x0100:32; // MB_SYSTEMMODAL

private const aborted_exit_code: u32 := 1:32;

extern __abort__ (reason: *u8) 
{
    MessageBoxA(null, reason, c"ance runtime error", message_box_flags);
    ExitProcess(aborted_exit_code);
}

extern GetLastError () : u32;
extern FormatMessageA (dwFlags: u32, lpSource: ptr, dwMessageId: u32, dwLanguageId: u32, lpBuffer: **u8, nSize: u32, args: ptr) : u32;
extern LocalFree (hMem: ptr) : ptr;

private format_message_flags: u32 := 0x00000100:32  // FORMAT_MESSAGE_ALLOCATE_BUFFER
                                <or> 0x00001000:32  // FORMAT_MESSAGE_FROM_SYSTEM
                                <or> 0x00000200:32; // FORMAT_MESSAGE_IGNORE_INSERTS

private abort_on_error ()
{
    let error := GetLastError();
    
    let formated_error: *u8;
    FormatMessageA(format_message_flags, null, error, 0, addressof formated_error, 0, null);
    
    MessageBoxA(null, formated_error, c"ance internal runtime error", message_box_flags);
    
    LocalFree(ptr(formated_error));
    ExitProcess(error);
}

extern __assert__ (is_fullfilled: bool, failure_reason: *u8) 
{
    if not is_fullfilled then __abort__(failure_reason);
}

extern GetProcessHeap () : ptr;
private process_heap: ptr := get_process_heap();

private get_process_heap () : ptr 
{
    let process_heap := GetProcessHeap();
    
    if process_heap == null then abort_on_error();
    
    return process_heap;
}

extern HeapAlloc (hHeap: ptr, dwFlags: u32, dwBytes: size) : ptr;
extern SetLastError (dwErrCode: u32);

private const alloc_flags: u32 := 0x0008:32; // HEAP_ZERO_MEMORY
private const alloc_error: u32 := 0x8:32; // ERROR_NOT_ENOUGH_MEMORY

extern __allocate__ (memory_size: size) : ptr 
{
    let allocated := HeapAlloc(process_heap, alloc_flags, memory_size);
    
    if allocated == null then 
    {
        SetLastError(alloc_error);
        abort_on_error();
    }
    
    return allocated;
}

extern HeapFree (hHeap: ptr, dwFlags: u32, lpMem: ptr) : u32;

private const free_flags: u32 := 0x0000:32; // -

extern __free__ (memory: ptr) 
{
    let result := HeapFree(process_heap, free_flags, memory);
    
    if result == 0 then abort_on_error();
}

