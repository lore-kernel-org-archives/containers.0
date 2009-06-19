From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] mm: clear N_HIGH_MEMORY map before se set it again -v4
Date: Fri, 19 Jun 2009 03:43:30 -0500
Message-ID: <m3prd0havh.fsf__9478.90913016654$1245401248$gmane$org@pobox.com>
References: <4A05269D.8000701@kernel.org> <20090512111623.GG25923@csn.ul.ie>
	<4A0A64FB.4080504@kernel.org> <20090513145950.GB28097@csn.ul.ie>
	<4A0C4910.7090508@kernel.org> <4A0C4A2A.6080009@kernel.org>
	<20090514095414.ba8356e5.akpm@linux-foundation.org>
	<4A0C4F67.5080802@kernel.org>
	<20090514102554.b3a36f19.akpm@linux-foundation.org>
	<4A0C563A.3020100@kernel.org> <4A2758CB.9090404@kernel.org>
	<alpine.DEB.1.10.0906041236520.5377@gentwo.org>
	<4A27FAD4.2010104@kernel.org>
	<alpine.DEB.1.10.0906041309230.8080@gentwo.org>
	<4A2803D1.4070001@kernel.org>
	<m3bpokiv0u.fsf@pobox.com> <4A3B49BA.40100@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A3B49BA.40100-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> (Yinghai Lu's message of "Fri\, 19
	Jun 2009 01\:18\:02 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: steiner-sJ/iWh9BUns@public.gmane.org, Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, suresh.b.siddha-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
>> I bisected to the commit containing this change.  Reverting fixes the
>> problem.
>> 
>
> can you use following patch to see what happens to that nodemask?

# dmesg | grep node_states
before clear: node_states [3]: 1
after online check: node_states [3]: 0

Full dmesg below.

Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.30-06725-g1d89b30-dirty (nathanl-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org) (gcc version 4.3.2 20081105 (Red Hat 4.3.2-7) (GCC) ) #126 SMP PREEMPT Fri Jun 19 03:34:03 CDT 2009
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  NSC Geode by NSC
  Cyrix CyrixInstead
  Centaur CentaurHauls
  Transmeta GenuineTMx86
  Transmeta TransmetaCPU
  UMC UMC UMC UMC
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e8000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001fff0000 (usable)
 BIOS-e820: 000000001fff0000 - 0000000020000000 (ACPI data)
 BIOS-e820: 00000000fffbd000 - 0000000100000000 (reserved)
debug: ignoring loglevel setting.
DMI 2.4 present.
last_pfn = 0x1fff0 max_arch_pfn = 0x100000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-FFFFF uncachable
MTRR variable ranges enabled:
  0 base 0000000000 mask FFE0000000 write-back
  1 disabled
  2 disabled
  3 disabled
  4 disabled
  5 disabled
  6 disabled
  7 disabled
PAT not supported by CPU.
initial memory mapped : 0 - 01400000
init_memory_mapping: 0000000000000000-000000001fff0000
 0000000000 - 001fff0000 page 4k
kernel direct mapping tables up to 1fff0000 @ 7000-8a000
RAMDISK: 1fce1000 - 1ffef7d3
ACPI: RSDP 000fb9d0 00014 (v00 QEMU  )
ACPI: RSDT 1fff0000 0002C (v01 QEMU   QEMURSDT 00000001 QEMU 00000001)
ACPI: FACP 1fff002c 00074 (v01 QEMU   QEMUFACP 00000001 QEMU 00000001)
ACPI: DSDT 1fff0100 0253C (v01   BXPC   BXDSDT 00000001 INTL 20061109)
ACPI: FACS 1fff00c0 00040
ACPI: APIC 1fff2640 000E0 (v01 QEMU   QEMUAPIC 00000001 QEMU 00000001)
ACPI: Local APIC address 0xfee00000
0MB HIGHMEM available.
511MB LOWMEM available.
  mapped low ram: 0 - 1fff0000
  low ram: 0 - 1fff0000
  node 0 low ram: 00000000 - 1fff0000
  node 0 bootmap 00002000 - 00006000
(9 early reservations) ==> bootmem [0000000000 - 001fff0000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==> [0000001000 - 0000002000]
  #2 [0000006000 - 0000007000]       TRAMPOLINE ==> [0000006000 - 0000007000]
  #3 [0000200000 - 0001149b88]    TEXT DATA BSS ==> [0000200000 - 0001149b88]
  #4 [001fce1000 - 001ffef7d3]          RAMDISK ==> [001fce1000 - 001ffef7d3]
  #5 [000009fc00 - 0000100000]    BIOS reserved ==> [000009fc00 - 0000100000]
  #6 [000114a000 - 000114f065]              BRK ==> [000114a000 - 000114f065]
  #7 [0000007000 - 0000082000]          PGTABLE ==> [0000007000 - 0000082000]
  #8 [0000002000 - 0000006000]          BOOTMAP ==> [0000002000 - 0000006000]
found SMP MP-table at [c00fb8b0] fb8b0
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  Normal   0x00001000 -> 0x0001fff0
  HighMem  0x0001fff0 -> 0x0001fff0
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x0001fff0
before clear: node_states [3]: 1
On node 0 totalpages: 130959
free_area_init_node: node 0, pgdat c0976960, node_mem_map c1151000
  DMA zone: 60 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3939 pages, LIFO batch:0
  Normal zone: 1860 pages used for memmap
  Normal zone: 125100 pages, LIFO batch:31
after online check: node_states [3]: 0
Using APIC driver default
ACPI: PM-Timer IO Port: 0xb008
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] disabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] disabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] disabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] disabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x08] disabled)
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x09] disabled)
ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x0a] disabled)
ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0b] disabled)
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0c] disabled)
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0d] disabled)
ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0e] disabled)
ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0f] disabled)
ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
ACPI: IRQ5 used by override.
ACPI: IRQ9 used by override.
ACPI: IRQ10 used by override.
ACPI: IRQ11 used by override.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
Using ACPI (MADT) for SMP configuration information
16 Processors exceeds NR_CPUS limit of 8
SMP: Allowing 8 CPUs, 7 hotplug CPUs
nr_irqs_gsi: 24
PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000e8000
PM: Registered nosave memory: 00000000000e8000 - 0000000000100000
Allocating PCI resources starting at 20000000 (gap: 20000000:dffbd000)
NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:8 nr_node_ids:1
PERCPU: Embedded 335 pages at c18d7000, static data 1347836 bytes
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 129039
Kernel command line: console=ttyS0 debug ignore_loglevel ro root=/dev/sda3 ckpt_debug=255
PID hash table entries: 2048 (order: 11, 8192 bytes)
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
Initializing HighMem for node 0 (00000000:00000000)
Memory: 485620k/524224k available (5261k kernel code, 38160k reserved, 2559k data, 1700k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xfff37000 - 0xfffff000   ( 800 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xe07f0000 - 0xff7fe000   ( 496 MB)
    lowmem  : 0xc0000000 - 0xdfff0000   ( 511 MB)
      .init : 0xc09aa000 - 0xc0b53000   (1700 kB)
      .data : 0xc0723427 - 0xc09a337c   (2559 kB)
      .text : 0xc0200000 - 0xc0723427   (5261 kB)
Checking if this processor honours the WP bit even in supervisor mode...Ok.
SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
NR_IRQS:512
CPU 0 irqstacks, hard=c18d7000 soft=c18d8000
Fast TSC calibration failed
TSC: PIT calibration matches PMTIMER. 1 loops
Detected 1994.971 MHz processor.
Console: colour VGA+ 80x25
console [ttyS0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:  8
... MAX_LOCK_DEPTH:          48
... MAX_LOCKDEP_KEYS:        8191
... CLASSHASH_SIZE:          4096
... MAX_LOCKDEP_ENTRIES:     16384
... MAX_LOCKDEP_CHAINS:      32768
... CHAINHASH_SIZE:          16384
 memory used by lock dependency info: 3743 kB
 per task-struct memory footprint: 1920 bytes
------------------------
| Locking API testsuite:
----------------------------------------------------------------------------
                                 | spin |wlock |rlock |mutex | wsem | rsem |
  --------------------------------------------------------------------------
                     A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                 A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
             A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
             A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
         A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
         A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
         A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                    double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                  initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                 bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
  --------------------------------------------------------------------------
              recursive read-lock:             |  ok  |             |  ok  |
           recursive read-lock #2:             |  ok  |             |  ok  |
            mixed read-write-lock:             |  ok  |             |  ok  |
            mixed write-read-lock:             |  ok  |             |  ok  |
  --------------------------------------------------------------------------
     hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
     soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
     hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
     soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
       sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
       sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
         hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
         soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
         hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
         soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
      hard-irq read-recursion/123:  ok  |
      soft-irq read-recursion/123:  ok  |
      hard-irq read-recursion/132:  ok  |
      soft-irq read-recursion/132:  ok  |
      hard-irq read-recursion/213:  ok  |
      soft-irq read-recursion/213:  ok  |
      hard-irq read-recursion/231:  ok  |
      soft-irq read-recursion/231:  ok  |
      hard-irq read-recursion/312:  ok  |
      soft-irq read-recursion/312:  ok  |
      hard-irq read-recursion/321:  ok  |
      soft-irq read-recursion/321:  ok  |
-------------------------------------------------------
Good, all 218 testcases passed! |
---------------------------------
Calibrating delay loop (skipped), value calculated using timer frequency.. 3989.94 BogoMIPS (lpj=1994971)
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
Mount-cache hash table entries: 512
Initializing cgroup subsys ns
Initializing cgroup subsys cpuacct
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 2048K
Checking 'hlt' instruction... OK.
lockdep: fixing up alternatives.
SMP alternatives: switching to UP code
ACPI: Core revision 20090521
ftrace: converting mcount calls to 0f 1f 44 00 00
ftrace: allocating 20993 entries in 42 pages
..TIMER: vector=0x30 apic1=0 pin1=0 apic2=-1 pin2=-1
CPU0: Intel QEMU Virtual CPU version 0.9.1 stepping 03
Testing tracer nop: PASSED
Brought up 1 CPUs
Total of 1 processors activated (3989.94 BogoMIPS).
khelper used greatest stack depth: 2752 bytes left
Time:  8:34:26  Date: 06/19/09
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xfb120, last bus=0
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: No dock devices found.
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:01.1: reg 20 io port: [0xc000-0xc00f]
pci 0000:00:01.3: quirk: region b000-b03f claimed by PIIX4 ACPI
pci 0000:00:01.3: quirk: region b100-b10f claimed by PIIX4 SMB
pci 0000:00:02.0: reg 10 32bit mmio: [0xf0000000-0xf1ffffff]
pci 0000:00:02.0: reg 14 32bit mmio: [0xf2000000-0xf2000fff]
pci 0000:00:03.0: reg 10 io port: [0xc100-0xc1ff]
pci 0000:00:03.0: reg 14 32bit mmio: [0xf2001000-0xf20010ff]
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 7 devices
ACPI: ACPI bus type pnp unregistered
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
TCP established hash table entries: 16384 (order: 5, 131072 bytes)
TCP bind hash table entries: 16384 (order: 7, 655360 bytes)
TCP: Hash tables configured (established 16384 bind 16384)
TCP reno registered
NET: Registered protocol family 1
Trying to unpack rootfs image as initramfs...
debug: unmapping init memory dfce1000..dfff0000
microcode: CPU0 sig=0x623, pf=0x0, revision=0x0
Microcode Update Driver: v2.00 <tigran-ppwZ4lME3+KI6QP4U9MhSdBc4/FLrbF6@public.gmane.org>, Peter Oruba
====[ backtrace testing ]===========
Testing a backtrace from process context.
The following trace is a kernel self test and not a bug!
Pid: 1, comm: swapper Not tainted 2.6.30-06725-g1d89b30-dirty #126
Call Trace:
 [<c071abda>] ? printk+0x1d/0x1f
 [<c027d180>] ? backtrace_regression_test+0x0/0xe0
 [<c027d1b5>] backtrace_regression_test+0x35/0xe0
 [<c09bf0b0>] ? crash_notes_memory_init+0x0/0x37
 [<c02e7c0f>] ? __alloc_percpu+0xf/0x20
 [<c09bf0c5>] ? crash_notes_memory_init+0x15/0x37
 [<c020112f>] do_one_initcall+0x2f/0x160
 [<c03358b9>] ? create_proc_entry+0x59/0xa0
 [<c0293752>] ? register_irq_proc+0xb2/0xd0
 [<c02937df>] ? init_irq_proc+0x6f/0x80
 [<c09aa35d>] kernel_init+0x168/0x1eb
 [<c09aa1f5>] ? kernel_init+0x0/0x1eb
 [<c0203d8b>] kernel_thread_helper+0x7/0x10
Testing a backtrace from irq context.
The following trace is a kernel self test and not a bug!
Pid: 4, comm: ksoftirqd/0 Not tainted 2.6.30-06725-g1d89b30-dirty #126
Call Trace:
 [<c0267d59>] ? trace_hardirqs_on_caller+0x69/0x180
 [<c027d16d>] backtrace_test_irq_callback+0xd/0x20
 [<c023f743>] tasklet_action+0x83/0x100
 [<c024054a>] __do_softirq+0xca/0x1f0
 [<c0240480>] ? __do_softirq+0x0/0x1f0
 <IRQ>  [<c024084d>] ? ksoftirqd+0x7d/0x1b0
 [<c02407d0>] ? ksoftirqd+0x0/0x1b0
 [<c02527db>] ? kthread+0x4b/0x80
 [<c0252790>] ? kthread+0x0/0x80
 [<c0203d8b>] ? kernel_thread_helper+0x7/0x10
Testing a saved backtrace.
The following trace is a kernel self test and not a bug!
 [<c020d650>] save_stack_trace+0x30/0x50
 [<c027d241>] backtrace_regression_test+0xc1/0xe0
 [<c020112f>] do_one_initcall+0x2f/0x160
 [<c09aa35d>] kernel_init+0x168/0x1eb
 [<c0203d8b>] kernel_thread_helper+0x7/0x10
 [<ffffffff>] 0xffffffff
====[ end of backtrace testing ]====
audit: initializing netlink socket (disabled)
type=2000 audit(1245400465.957:1): initialized
Testing tracer sched_switch: PASSED
Testing tracer function: 
Switched to high resolution mode on CPU 0
PASSED
Testing dynamic ftrace: PASSED
Testing tracer irqsoff: PASSED
Testing tracer preemptoff: PASSED
Testing tracer preemptirqsoff: PASSED
Testing tracer wakeup: PASSED
Testing tracer wakeup_rt: PASSED
Testing tracer function_graph: PASSED
HugeTLB registered 4 MB page size, pre-allocated 0 pages
khelper used greatest stack depth: 2732 bytes left
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
msgmni has been set to 948
SELinux:  Registering netfilter hooks
cryptomgr_test used greatest stack depth: 2444 bytes left
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci 0000:00:00.0: Limiting direct PCI/PCI transfers
pci 0000:00:01.0: PIIX3: Enabling Passive Release
pci 0000:00:01.0: Activating ISA DMA hang workarounds
pci 0000:00:02.0: Boot video device
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
input: Power Button as /class/input/input0
ACPI: Power Button [PWRF]
processor ACPI_CPU:00: registered as cooling_device0
ACPI Warning: \_PR_.CPU1._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPU2._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPU3._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPU4._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPU5._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPU6._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPU7._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPU8._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPU9._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPUA._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPUB._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPUC._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPUD._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
ACPI Warning: \_PR_.CPUE._MAT: Return type mismatch - found Integer, expected Buffer 20090521 nspredef-940
Non-volatile memory driver v1.3
Linux agpgart interface v0.103
[drm] Initialized drm 1.1.0 20060810
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
Platform driver 'serial8250' needs updating - please use dev_pm_ops
00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
brd: module loaded
loop: module loaded
Driver 'sd' needs updating - please use bus_type methods
Driver 'sr' needs updating - please use bus_type methods
ata_piix 0000:00:01.1: version 2.13
ata_piix 0000:00:01.1: setting latency timer to 64
scsi0 : ata_piix
scsi1 : ata_piix
ata1: PATA max MWDMA2 cmd 0x1f0 ctl 0x3f6 bmdma 0xc000 irq 14
ata2: PATA max MWDMA2 cmd 0x170 ctl 0x376 bmdma 0xc008 irq 15
<6>8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 2004)
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
8139cp 0000:00:03.0: PCI INT A -> Link[LNKC] -> GSI 11 (level, high) -> IRQ 11
eth0: RTL-8139C+ at 0xe080e000, 52:54:00:12:34:56, IRQ 11
8139cp 0000:00:03.0: setting latency timer to 64
console [netcon0] enabled
netconsole: network logging started
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd: block sizes: qh 128 qtd 96 itd 160 sitd 96
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd: block sizes: ed 64 td 64
uhci_hcd: USB Universal Host Controller Interface driver
usbcore: registered new interface driver usblp
usbcore: registered new interface driver libusual
PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
Platform driver 'i8042' needs updating - please use dev_pm_ops
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /class/input/input1
rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one day, 114 bytes nvram
cpuidle: using governor ladder
cpuidle: using governor menu
No iBFT detected.
ata1.00: ATA-7: QEMU HARDDISK, 0.9.1, max UDMA/100
ata1.00: 16777216 sectors, multi 16: LBA48 
ata1.00: configured for MWDMA2
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
ata2.00: ATAPI: QEMU DVD-ROM, 0.9.1, max UDMA/100
ata2.00: configured for MWDMA2
scsi 0:0:0:0: Direct-Access     ATA      QEMU HARDDISK    0.9. PQ: 0 ANSI: 5
Advanced Linux Sound Architecture Driver Version 1.0.20.
sd 0:0:0:0: [sda] 16777216 512-byte hardware sectors: (8.58 GB/8.00 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: Attached scsi generic sg0 type 0
scsi 1:0:0:0: CD-ROM            QEMU     QEMU DVD-ROM     0.9. PQ: 0 ANSI: 5
sr0: scsi3-mmc drive: 4x/4x xa/form2 tray
Uniform CD-ROM driver Revision: 3.20
sr 1:0:0:0: Attached scsi CD-ROM sr0
modprobe used greatest stack depth: 2332 bytes left
input: ImExPS/2 Generic Explorer Mouse as /class/input/input2
sr 1:0:0:0: Attached scsi generic sg1 type 5
sd 0:0:0:0: [sda] Attached SCSI disk
ALSA device list:
  No soundcards found.
Netfilter messages via NETLINK v0.30.
nf_conntrack version 0.5.0 (8191 buckets, 32764 max)
ctnetlink v0.93: registering with nfnetlink.
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 10
ip6_tables: (C) 2000-2006 Netfilter Core Team
IPv6 over IPv4 tunneling driver
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
Using IPI No-Shortcut mode
PM: Resume from disk failed.
registered taskstats version 1
Running tests on trace events:
Testing event kfree_skb: OK
Testing event block_rq_abort: OK
Testing event block_rq_insert: OK
Testing event block_rq_issue: OK
Testing event block_rq_requeue: OK
Testing event block_rq_complete: OK
Testing event block_bio_bounce: OK
Testing event block_bio_complete: OK
Testing event block_bio_backmerge: OK
Testing event block_bio_frontmerge: OK
Testing event block_bio_queue: OK
Testing event block_getrq: OK
Testing event block_sleeprq: OK
Testing event block_plug: OK
Testing event block_unplug_timer: OK
Testing event block_unplug_io: OK
Testing event block_split: OK
Testing event block_remap: OK
Testing event kmalloc: OK
Testing event kmem_cache_alloc: OK
Testing event kmalloc_node: OK
Testing event kmem_cache_alloc_node: OK
Testing event kfree: OK
Testing event kmem_cache_free: OK
Testing event lock_acquire: OK
Testing event lock_release: OK
Testing event lock_contended: OK
Testing event lock_acquired: OK
Testing event workqueue_insertion: OK
Testing event workqueue_execution: OK
Testing event workqueue_creation: OK
Testing event workqueue_destruction: OK
Testing event irq_handler_entry: OK
Testing event irq_handler_exit: OK
Testing event softirq_entry: OK
Testing event softirq_exit: OK
Testing event sched_kthread_stop: OK
Testing event sched_kthread_stop_ret: OK
Testing event sched_wait_task: OK
Testing event sched_wakeup: OK
Testing event sched_wakeup_new: OK
Testing event sched_switch: OK
Testing event sched_migrate_task: OK
Testing event sched_process_free: OK
Testing event sched_process_exit: OK
Testing event sched_process_wait: OK
Testing event sched_process_fork: OK
Testing event sched_signal_send: OK
Running tests on trace event systems:
Testing event system skb: OK
Testing event system block: OK
Testing event system kmem: OK
Testing event system lockdep: OK
Testing event system workqueue: OK
Testing event system irq: OK
Testing event system sched: OK
Running tests on all trace events:
Testing all events: OK
Running tests again, along with the function tracer
Running tests on trace events:
Testing event kfree_skb: OK
Testing event block_rq_abort: OK
Testing event block_rq_insert: OK
Testing event block_rq_issue: OK
Testing event block_rq_requeue: OK
Testing event block_rq_complete: OK
Testing event block_bio_bounce: OK
Testing event block_bio_complete: OK
Testing event block_bio_backmerge: OK
Testing event block_bio_frontmerge: OK
Testing event block_bio_queue: OK
Testing event block_getrq: OK
Testing event block_sleeprq: OK
Testing event block_plug: OK
Testing event block_unplug_timer: OK
Testing event block_unplug_io: OK
Testing event block_split: OK
Testing event block_remap: OK
Testing event kmalloc: OK
Testing event kmem_cache_alloc: OK
Testing event kmalloc_node: OK
Testing event kmem_cache_alloc_node: OK
Testing event kfree: OK
Testing event kmem_cache_free: OK
Testing event lock_acquire: OK
Testing event lock_release: OK
Testing event lock_contended: OK
Testing event lock_acquired: OK
Testing event workqueue_insertion: OK
Testing event workqueue_execution: OK
Testing event workqueue_creation: OK
Testing event workqueue_destruction: OK
Testing event irq_handler_entry: OK
Testing event irq_handler_exit: OK
Testing event softirq_entry: OK
Testing event softirq_exit: OK
Testing event sched_kthread_stop: OK
Testing event sched_kthread_stop_ret: OK
Testing event sched_wait_task: OK
Testing event sched_wakeup: OK
Testing event sched_wakeup_new: OK
Testing event sched_switch: OK
Testing event sched_migrate_task: OK
Testing event sched_process_free: OK
Testing event sched_process_exit: OK
Testing event sched_process_wait: OK
Testing event sched_process_fork: OK
Testing event sched_signal_send: OK
Running tests on trace event systems:
Testing event system skb: OK
Testing event system block: OK
Testing event system kmem: OK
Testing event system lockdep: OK
Testing event system workqueue: OK
Testing event system irq: OK
Testing event system sched: OK
Running tests on all trace events:
Testing all events: OK
  Magic number: 13:303:574
debug: unmapping init memory c09aa000..c0b53000
Write protecting the kernel text: 5264k
Write protecting the kernel read-only data: 1908k
async/0 used greatest stack depth: 2288 bytes left
async/1 used greatest stack depth: 1932 bytes left
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with writeback data mode.
type=1404 audit(1245400469.713:2): enforcing=1 old_enforcing=0 auid=4294967295 ses=4294967295
SELinux: 8192 avtab hash slots, 113721 rules.
SELinux: 8192 avtab hash slots, 113721 rules.
SELinux:  8 users, 11 roles, 2611 types, 123 bools, 1 sens, 1024 cats
SELinux:  73 classes, 113721 rules
SELinux:  class kernel_service not defined in policy
SELinux:  permission open in class sock_file not defined in policy
SELinux: the above unknown classes and permissions will be allowed
SELinux:  Completing initialization.
SELinux:  Setting up existing superblocks.
SELinux: initialized (dev sda3, type ext3), uses xattr
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts
SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses genfs_contexts
SELinux: initialized (dev devpts, type devpts), uses transition SIDs
SELinux: initialized (dev inotifyfs, type inotifyfs), uses genfs_contexts
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev anon_inodefs, type anon_inodefs), uses genfs_contexts
SELinux: initialized (dev pipefs, type pipefs), uses task SIDs
SELinux: initialized (dev debugfs, type debugfs), uses genfs_contexts
SELinux: initialized (dev sockfs, type sockfs), uses task SIDs
SELinux: initialized (dev proc, type proc), uses genfs_contexts
SELinux: initialized (dev bdev, type bdev), uses genfs_contexts
SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
type=1403 audit(1245400471.093:3): policy loaded auid=4294967295 ses=4294967295
plymouth used greatest stack depth: 1768 bytes left
awk used greatest stack depth: 1620 bytes left
udevd version 127 started
udevadm used greatest stack depth: 1524 bytes left
udevd used greatest stack depth: 1520 bytes left
grep used greatest stack depth: 1504 bytes left
gzip used greatest stack depth: 1480 bytes left
EXT3 FS on sda3, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda1, internal journal
EXT3-fs: mounted filesystem with writeback data mode.
SELinux: initialized (dev sda1, type ext3), uses xattr
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
Adding 522104k swap on /dev/sda2.  Priority:-1 extents:1 across:522104k 
SELinux: initialized (dev binfmt_misc, type binfmt_misc), uses genfs_contexts
ip used greatest stack depth: 1244 bytes left
eth0: link up, 100Mbps, full-duplex, lpa 0x05E1
device eth0 entered promiscuous mode
br0: port 1(eth0) entering forwarding state
Clocksource tsc unstable (delta = -168975068 ns)
eth0: no IPv6 routers present
br0: no IPv6 routers present
br0: port 1(eth0) entering disabled state
sshd used greatest stack depth: 1212 bytes left
eth0: link up, 100Mbps, full-duplex, lpa 0x05E1
br0: port 1(eth0) entering forwarding state
ip used greatest stack depth: 1168 bytes left
eth0: no IPv6 routers present
br0: no IPv6 routers present
