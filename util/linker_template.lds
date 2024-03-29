/* kernel.lds
 * Basic Linker Script
 *
 * 0x00000000 - 0x07ffffff - aliased to flash or sys memory depending on BOOT jumpers
 * 0x08000000 - 0x08080000 - Flash (64K ... or 128K)
 * 0x1ffff000 - 0x1ffff7ff - Boot firmware in system memory
 * 0x1ffff800 - 0x1fffffff - option bytes
 * 0x20000000 - 0x20018000 - SRAM (96k)
 * 0x40000000 - 0x40023400 - peripherals
 */

SECTIONS
{
  /* Text and interrupt vector table.*/
  /*Toggle permissions between kernel_text_start and kernel_text_end*/
  .kernel_text 0x08000000 :
  {
    _ivt_start = .;
    KEEP(*(.ivt))
    _ivt_end = .;
    _kernel_text_start = .;
    <K_OBJ_DIR>/*.o (.text*) /*END REGION*/
    _kernel_text_end = .;
  }

  . = ALIGN(16*1024); /* Align to the closest 16K-byte boundary*/

  .app_text :
  {
    _swi_stub_start = .;
    KEEP(*(.swi_stub))
    _swi_stub_end = .;
    _user_text_start = .;
    <U_OBJ_DIR>/*.o (.text*) /*END REGION*/
    _user_text_end = .;
  }


  .rodata :
  {
    /*Ensures that app data is 16kb aligned*/
    . = ALIGN(16*1024);
    _k_rodata = .;
    <K_OBJ_DIR>/*.o (.rodata*); /*END REGION*/
    /*Ensures that u rodata is 2KB aligned*/
    . = ALIGN(2*1024);
    _u_rodata = .;
    <U_OBJ_DIR>/*.o (.rodata*); /*END REGION*/
    *(.rodata);
    _u_erodata = .;
  }

  . = ALIGN(2*1024);
  _erodata = . ;

  .data 0x20000000 : AT ( _erodata )
  {
    _k_data = .;
    <K_OBJ_DIR>/*.o (.data*); /*END REGION*/
    . = ALIGN(1*1024);
    _u_data = .;
    <U_OBJ_DIR>/*.o (.data*); /*END REGION*/
    *(.data);
    _u_edata = .;
    . = ALIGN(1*1024);
  }

  .bss ALIGN(1024) :
  {
    _bss_start = .;
    _k_bss = .;
    <K_OBJ_DIR>/*.o (.bss*); /*END REGION*/
    <K_OBJ_DIR>/*.o (COMMON*); /*END REGION*/
    . = ALIGN(1024);
    _u_bss = .;
    <U_OBJ_DIR>/*.o (.bss*); /*END REGION*/
    <U_OBJ_DIR>/*.o (COMMON*); /*END REGION*/
    *(.bss) *(COMMON) ;
    _u_ebss = .;
  }

  /* Variables ld will declare for the start routine */
  _bss_size = ((_u_ebss) - (_k_bss));
  _data_size = ((_u_edata) - (_k_data));


  . = ALIGN(8*1024);

  __heap_low = .; /* for _sbrk */
  . = . + (4*1024); /* 4K of user heap */
  __heap_top = .; /* for _sbrk */

  __psp_stack_bottom = .;
  . = . + (2*1024);  /* 2kB process stack */
  __psp_stack_top = .;

  __msp_stack_bottom = .;
  . = . + (2*1024);  /* 2kB of main stack */
  __msp_stack_top = .;

  /* unused space if you need it for very large kernel data structures */
  __kheap_low_0 = .; 
  . = . + (8*1024); /* 8K of space */
  __kheap_top_0 = .;

  . = ALIGN(32*1024);
  __thread_u_stacks_low = .; /* for thread user stacks */
  . = . + (32*1024); /* 32K of space */
  __thread_u_stacks_top = .; /* for thread user stacks */

  __thread_k_stacks_low = .; /* for thread kernel stacks */
  . = . + (32*1024); /* 32K of space */
  __thread_k_stacks_top = .; /* for thread kernel stacks */


  end = .;
}
