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

extern GlobalAlloc (uFlags: u32, dwBytes: size) : ptr;
private const alloc_flags: u32 := 0x0040:32; // GMEM_ZEROINIT | GMEM_FIXED

extern __allocate__ (memory_size: size) : ptr 
{
    return GlobalAlloc(alloc_flags, memory_size);
}

extern GlobalFree (memory: ptr) : ptr;

extern __free__ (memory: ptr) 
{
    GlobalFree(memory);
}

