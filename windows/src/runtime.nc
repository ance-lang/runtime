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

private const aborted_exit_code: u32 := 3:32;

extern __abort__ (reason: *u8) 
{
    MessageBoxA(null, reason, c"ance runtime error", message_box_flags);
    ExitProcess(aborted_exit_code);
}

extern __assert__ (is_fullfilled: bool, failure_reason: *u8) 
{
    if not is_fullfilled then __abort__(failure_reason);
}

extern GetProcessHeap () : ptr;
private process_heap: ptr := get_process_heap();

private get_process_heap () : ptr 
{
    let process_heap <: GetProcessHeap();
    return process_heap;
}

extern HeapAlloc (hHeap: ptr, dwFlags: u32, dwBytes: size) : ptr;
private const alloc_flags: u32 := 0x0008:32; // HEAP_ZERO_MEMORY

extern __allocate__ (memory_size: size) : ptr 
{
    return HeapAlloc(process_heap, alloc_flags, memory_size);
}

extern HeapFree (hHeap: ptr, dwFlags: u32, lpMem: ptr) : u32;
private const free_flags: u32 := 0x0000:32; // -

extern __free__ (memory: ptr) 
{
    HeapFree(process_heap, free_flags, memory);
}

