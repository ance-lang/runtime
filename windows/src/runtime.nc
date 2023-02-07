extern ExitProcess (uExitCode: u32);

extern __exit__ (exit_code: u32) 
{
    ExitProcess(exit_code);
}

private const aborted_exit_code: u32 := 3:32;

extern __abort__ () 
{
    ExitProcess(aborted_exit_code);
}

extern __assert__ (is_fullfilled: bool) 
{
    if not is_fullfilled then __abort__();
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

