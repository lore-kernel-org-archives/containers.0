From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: failure to restart bash with ckpt-v15-dev
Date: Wed, 20 May 2009 10:12:06 -0400
Message-ID: <4A140FB6.8040201@cs.columbia.edu>
References: <m3iqjykvvf.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3iqjykvvf.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Nathan,

Thanks for the report. This is now fixed in the git tree.

Nathan Lynch wrote:
> Last commit is ed3b275 "allow error string during checkpoint while
> holding a spinlock".
> 
> The failure seems to involve a vma corresponding to
> /usr/lib/gconv/gconv-modules.cache which is mapped read-only and shared,
> e.g.
> 
> open("/usr/lib/gconv/gconv-modules.cache", O_RDONLY) = 3
> mmap2(NULL, 26048, PROT_READ, MAP_SHARED, 3, 0) = 0xb7f52000
> 
> I believe the second check in filemap_restore() is where the restart
> goes awry; the object is of type CKPT_VMA_SHM_FILE but doesn't have
> VM_SHARED set in the flags (it does have VM_MAY_SHARE set, however).

You were right, and there was another glitch fixed.

Oren.

> 
> 
> Testcase:
> 
> # bash -c 'exec <&- >&- 2>&- ; while : ; do : ; done' &
> [1] 2274
> # mkdir -p  /cgroup/foo && for k in cpus mems ; do cat /cgroup/cpuset.$k > /cgroup/foo/cpuset.$k ; done
> # echo $! > /cgroup/foo/tasks 
> # echo FROZEN > /cgroup/foo/freezer.state 
> # cat  /cgroup/foo/freezer.state 
> FROZEN
> # ckpt $! > /tmp/bash.ckpt
> # rstr < /tmp/bash.ckpt 
> Segmentation fault
> 
> 
> Debug output (which, btw, I can't figure out how to enable with
> ckpt_debug=, so I opted to hack a printk into _ckpt_debug):
> 
> [2279:c/r:may_checkpoint_task] check 2274
> [2279:c/r:may_checkpoint_task] check 2274
> [2279:c/r:ckpt_write_obj] type 1 len 48
> [2279:c/r:ckpt_write_obj_type] type 3 len 73
> [2279:c/r:ckpt_write_obj_type] type 3 len 73
> [2279:c/r:ckpt_write_obj_type] type 3 len 73
> [2279:c/r:ckpt_write_obj] type 2 len 16
> [2279:c/r:ckpt_write_obj] type 101 len 16
> [2279:c/r:checkpoint_pids] task[0]: vpid 2274 vtgid 2274 parent 2252
> [2279:c/r:checkpoint_all_tasks] dumping task #0
> [2279:c/r:ckpt_write_obj] type 102 len 32
> [2279:c/r:ckpt_write_obj_type] type 4 len 24
> [2279:c/r:checkpoint_task] ret 0
> [2279:c/r:ckpt_write_obj] type 6 len 16
> [2279:c/r:ckpt_obj_lookup_add] UTS_NS objref 2 first 1
> [2279:c/r:ckpt_obj_lookup_add] IPC_NS objref 3 first 1
> [2279:c/r:ckpt_write_obj] type 108 len 24
> [2279:c/r:ckpt_write_obj] type 109 len 16
> [2279:c/r:ckpt_write_obj_type] type 4 len 73
> [2279:c/r:ckpt_write_obj_type] type 4 len 73
> [2279:c/r:ckpt_write_obj] type 110 len 56
> [2279:c/r:checkpoint_ipc_any] ipc-shm count 0
> [2279:c/r:ckpt_write_obj] type 401 len 16
> [2279:c/r:checkpoint_ipc_any] ipc-shm ret 0
> [2279:c/r:checkpoint_ipc_any] ipc-msg count 0
> [2279:c/r:ckpt_write_obj] type 401 len 16
> [2279:c/r:checkpoint_ipc_any] ipc-msg ret 0
> [2279:c/r:checkpoint_ipc_any] ipc-sem count 0
> [2279:c/r:ckpt_write_obj] type 401 len 16
> [2279:c/r:checkpoint_ipc_any] ipc-sem ret 0
> [2279:c/r:checkpoint_task_ns] nsproxy: objref 1
> [2279:c/r:ckpt_write_obj] type 103 len 16
> [2279:c/r:ckpt_write_obj] type 6 len 16
> [2279:c/r:ckpt_write_obj] type 6 len 16
> [2279:c/r:ckpt_write_obj] type 303 len 40
> [2279:c/r:ckpt_write_obj_type] type 5 len 18
> [2279:c/r:ckpt_write_obj] type 201 len 104
> [2279:c/r:do_checkpoint_mm] vma 0x2bd000-0x2dd000 flags 0x8000875
> [2279:c/r:ckpt_write_obj] type 6 len 16
> [2279:c/r:ckpt_write_obj] type 303 len 40
> [2279:c/r:ckpt_write_obj_type] type 5 len 23
> [2279:c/r:generic_vma_checkpoint] vma 0x2bd000-0x2dd000 flags 0x8000875 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x2de000-0x2df000 flags 0x8100871
> [2279:c/r:generic_vma_checkpoint] vma 0x2de000-0x2df000 flags 0x8100871 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x2de000
> [2279:c/r:checkpoint_memory_contents] collected 1 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 1
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x2df000-0x2e0000 flags 0x8100873
> [2279:c/r:generic_vma_checkpoint] vma 0x2df000-0x2e0000 flags 0x8100873 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x2df000
> [2279:c/r:checkpoint_memory_contents] collected 1 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 1
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x2e2000-0x450000 flags 0x8000075
> [2279:c/r:ckpt_write_obj] type 6 len 16
> [2279:c/r:ckpt_write_obj] type 303 len 40
> [2279:c/r:ckpt_write_obj_type] type 5 len 25
> [2279:c/r:generic_vma_checkpoint] vma 0x2e2000-0x450000 flags 0x8000075 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x450000-0x452000 flags 0x8100071
> [2279:c/r:generic_vma_checkpoint] vma 0x450000-0x452000 flags 0x8100071 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x451000
> [2279:c/r:checkpoint_memory_contents] collected 1 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 1
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x452000-0x453000 flags 0x8100073
> [2279:c/r:generic_vma_checkpoint] vma 0x452000-0x453000 flags 0x8100073 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x452000
> [2279:c/r:checkpoint_memory_contents] collected 1 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 1
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x453000-0x456000 flags 0x100073
> [2279:c/r:generic_vma_checkpoint] vma 0x453000-0x456000 flags 0x100073 type 2
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x453000
> [2279:c/r:vma_fill_pgarr] got page 0x455000
> [2279:c/r:checkpoint_memory_contents] collected 2 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 2
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x458000-0x45b000 flags 0x8000075
> [2279:c/r:ckpt_write_obj] type 6 len 16
> [2279:c/r:ckpt_write_obj] type 303 len 40
> [2279:c/r:ckpt_write_obj_type] type 5 len 26
> [2279:c/r:generic_vma_checkpoint] vma 0x458000-0x45b000 flags 0x8000075 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x45b000-0x45c000 flags 0x8100071
> [2279:c/r:generic_vma_checkpoint] vma 0x45b000-0x45c000 flags 0x8100071 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x45b000
> [2279:c/r:checkpoint_memory_contents] collected 1 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 1
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x45c000-0x45d000 flags 0x8100073
> [2279:c/r:generic_vma_checkpoint] vma 0x45c000-0x45d000 flags 0x8100073 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x45c000
> [2279:c/r:checkpoint_memory_contents] collected 1 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 1
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x8047000-0x80fb000 flags 0x8001875
> [2279:c/r:generic_vma_checkpoint] vma 0x8047000-0x80fb000 flags 0x8001875 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x80fb000-0x8100000 flags 0x8101873
> [2279:c/r:generic_vma_checkpoint] vma 0x80fb000-0x8100000 flags 0x8101873 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x80fb000
> [2279:c/r:vma_fill_pgarr] got page 0x80fc000
> [2279:c/r:vma_fill_pgarr] got page 0x80ff000
> [2279:c/r:checkpoint_memory_contents] collected 3 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 3
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x8100000-0x8105000 flags 0x100073
> [2279:c/r:generic_vma_checkpoint] vma 0x8100000-0x8105000 flags 0x100073 type 2
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x8100000
> [2279:c/r:vma_fill_pgarr] got page 0x8101000
> [2279:c/r:vma_fill_pgarr] got page 0x8102000
> [2279:c/r:vma_fill_pgarr] got page 0x8103000
> [2279:c/r:vma_fill_pgarr] got page 0x8104000
> [2279:c/r:checkpoint_memory_contents] collected 5 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 5
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x98de000-0x98ff000 flags 0x100073
> [2279:c/r:generic_vma_checkpoint] vma 0x98de000-0x98ff000 flags 0x100073 type 2
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x98de000
> [2279:c/r:vma_fill_pgarr] got page 0x98df000
> [2279:c/r:vma_fill_pgarr] got page 0x98e0000
> [2279:c/r:vma_fill_pgarr] got page 0x98e1000
> [2279:c/r:vma_fill_pgarr] got page 0x98e2000
> [2279:c/r:checkpoint_memory_contents] collected 5 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 5
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x46bc0000-0x46bd6000 flags 0x8000075
> [2279:c/r:ckpt_write_obj] type 6 len 16
> [2279:c/r:ckpt_write_obj] type 303 len 40
> [2279:c/r:ckpt_write_obj_type] type 5 len 29
> [2279:c/r:generic_vma_checkpoint] vma 0x46bc0000-0x46bd6000 flags 0x8000075 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0x46bd6000-0x46bd9000 flags 0x8100073
> [2279:c/r:generic_vma_checkpoint] vma 0x46bd6000-0x46bd9000 flags 0x8100073 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0x46bd7000
> [2279:c/r:vma_fill_pgarr] got page 0x46bd8000
> [2279:c/r:checkpoint_memory_contents] collected 2 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 2
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0xb7e3e000-0xb803e000 flags 0x8000071
> [2279:c/r:ckpt_write_obj] type 6 len 16
> [2279:c/r:ckpt_write_obj] type 303 len 40
> [2279:c/r:ckpt_write_obj_type] type 5 len 39
> [2279:c/r:generic_vma_checkpoint] vma 0xb7e3e000-0xb803e000 flags 0x8000071 type 3
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0xb803e000-0xb8040000 flags 0x100073
> [2279:c/r:generic_vma_checkpoint] vma 0xb803e000-0xb8040000 flags 0x100073 type 2
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0xb803e000
> [2279:c/r:vma_fill_pgarr] got page 0xb803f000
> [2279:c/r:checkpoint_memory_contents] collected 2 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 2
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:do_checkpoint_mm] vma 0xb8046000-0xb804d000 flags 0x80000d1
> [2279:c/r:ckpt_write_obj] type 6 len 16
> [2279:c/r:ckpt_write_obj] type 303 len 40
> [2279:c/r:ckpt_write_obj_type] type 5 len 43
> [2279:c/r:ckpt_obj_lookup_add] INODE objref 12 first 1
> [2279:c/r:generic_vma_checkpoint] vma 0xb8046000-0xb804d000 flags 0x80000d1 type 6
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:do_checkpoint_mm] vma 0xbff38000-0xbff4d000 flags 0x100173
> [2279:c/r:generic_vma_checkpoint] vma 0xbff38000-0xbff4d000 flags 0x100173 type 2
> [2279:c/r:ckpt_write_obj] type 202 len 72
> [2279:c/r:vma_fill_pgarr] got page 0xbff49000
> [2279:c/r:vma_fill_pgarr] got page 0xbff4a000
> [2279:c/r:vma_fill_pgarr] got page 0xbff4b000
> [2279:c/r:vma_fill_pgarr] got page 0xbff4c000
> [2279:c/r:checkpoint_memory_contents] collected 4 pages
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:pgarr_release_pages] total pages 4
> [2279:c/r:ckpt_write_obj] type 203 len 16
> [2279:c/r:checkpoint_mm_context] nldt 0 vdso 0xffffe000
> [2279:c/r:ckpt_write_obj] type 204 len 24
> [2279:c/r:checkpoint_task_objs] memory: objref 4
> [2279:c/r:ckpt_write_obj] type 104 len 16
> [2279:c/r:checkpoint_task] shared: ret 0
> [2279:c/r:ckpt_write_obj] type 301 len 16
> [2279:c/r:checkpoint_fd_table] nfds 0
> [2279:c/r:checkpoint_task] files: ret 0
> [2279:c/r:ckpt_write_obj] type 106 len 16
> [2279:c/r:checkpoint_thread] ntls 1
> [2279:c/r:checkpoint_task] thread: ret 0
> [2279:c/r:checkpoint_restart_block] restart_block: non
> [2279:c/r:checkpoint_restart_block] restart_block: args 0x0 0x0 0x0 0x0 0x0
> [2279:c/r:ckpt_write_obj] type 105 len 56
> [2279:c/r:checkpoint_restart_block] restart_block ret 0
> [2279:c/r:checkpoint_task] restart-block: ret 0
> [2279:c/r:checkpoint_cpu] math 0 debug 0
> [2279:c/r:ckpt_write_obj] type 107 len 264
> [2279:c/r:checkpoint_task] cpu: ret 0
> [2279:c/r:ckpt_write_obj] type 5001 len 16
> [2279:c/r:pgarr_release_pages] total pages 0
> [2280:c/r:ckpt_read_obj] type 1 len 48(48,48)
> [2280:c/r:_ckpt_read_obj] type 3 len 73(73,73)
> [2280:c/r:_ckpt_read_obj] type 3 len 73(73,73)
> [2280:c/r:_ckpt_read_obj] type 3 len 73(73,73)
> [2280:c/r:ckpt_read_obj] type 2 len 16(16,16)
> [2280:c/r:ckpt_read_obj] type 101 len 16(16,16)
> [2280:c/r:ckpt_read_obj] type 102 len 32(32,32)
> [2280:c/r:_ckpt_read_obj] type 4 len 24(24,24)
> [2280:c/r:restore_task] ret 0
> [2280:c/r:ckpt_read_obj] type 6 len 16(16,16)
> [2280:c/r:_ckpt_read_objref] shared len 16 type 6
> [2280:c/r:restore_obj] len 16 ref 1 type 4
> [2280:c/r:ckpt_read_obj] type 108 len 24(24,24)
> SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
> [2280:c/r:ckpt_read_obj] type 109 len 16(16,16)
> [2280:c/r:_ckpt_read_obj] type 4 len 73(73,73)
> [2280:c/r:_ckpt_read_obj] type 4 len 73(73,73)
> [2280:c/r:ckpt_obj_insert] UTS_NS objref 2
> [2280:c/r:do_restore_ns] uts ns: 2
> [2280:c/r:ckpt_read_obj] type 110 len 56(56,56)
> [2280:c/r:ckpt_read_obj] type 401 len 16(16,16)
> [2280:c/r:restore_ipc_any] ipc-shm: count 0
> [2280:c/r:restore_ipc_any] ipc-shm: ret 0
> [2280:c/r:ckpt_read_obj] type 401 len 16(16,16)
> [2280:c/r:restore_ipc_any] ipc-msg: count 0
> [2280:c/r:restore_ipc_any] ipc-msg: ret 0
> [2280:c/r:ckpt_read_obj] type 401 len 16(16,16)
> [2280:c/r:restore_ipc_any] ipc-sem: count 0
> [2280:c/r:restore_ipc_any] ipc-sem: ret 0
> [2280:c/r:ckpt_obj_insert] IPC_NS objref 3
> [2280:c/r:do_restore_ns] ipc ns: 3
> [2280:c/r:ckpt_read_obj] type 103 len 16(16,16)
> [2280:c/r:ckpt_obj_fetch] NSPROXY ref 1
> [2280:c/r:restore_task_ns] nsproxy: ret 0 (df282000)
> [2280:c/r:ckpt_read_obj] type 6 len 16(16,16)
> [2280:c/r:_ckpt_read_objref] shared len 16 type 6
> [2280:c/r:restore_obj] len 16 ref 4 type 3
> [2280:c/r:ckpt_read_obj] type 6 len 16(104,104)
> [2280:c/r:_ckpt_read_objref] shared len 16 type 6
> [2280:c/r:restore_obj] len 16 ref 5 type 1
> [2280:c/r:ckpt_read_obj] type 303 len 40(0,4096)
> [2280:c/r:do_restore_file] flags 0x8000 mode 0x1d type 1
> [2280:c/r:ckpt_read_obj] type 5 len 18(0,4096)
> [2280:c/r:read_open_fname] fname '/bin/bash' flags 0x8000 mode 0x1d
> [2280:c/r:ckpt_read_obj] type 201 len 104(104,104)
> [2280:c/r:do_restore_mm] map_count 20
> [2280:c/r:ckpt_obj_fetch] FILE ref 5
> [2280:c/r:ckpt_read_obj] type 6 len 16(72,72)
> [2280:c/r:_ckpt_read_objref] shared len 16 type 6
> [2280:c/r:restore_obj] len 16 ref 6 type 1
> [2280:c/r:ckpt_read_obj] type 303 len 40(0,4096)
> [2280:c/r:do_restore_file] flags 0x8000 mode 0x1d type 1
> [2280:c/r:ckpt_read_obj] type 5 len 23(0,4096)
> [2280:c/r:read_open_fname] fname '/lib/ld-2.9.so' flags 0x8000 mode 0x1d
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x2bd000-0x2dd000 flags 0x8000875 type 3 vmaref 6 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 6
> [2280:c/r:generic_vma_restore] size 0x20000 prot 0x5 flag 0x812 pgoff 0x0 => 0x2bd000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x2de000-0x2df000 flags 0x8100871 type 3 vmaref 6 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 6
> [2280:c/r:generic_vma_restore] size 0x1000 prot 0x1 flag 0x812 pgoff 0x20 => 0x2de000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 1
> [2280:c/r:read_pages_contents] got page 0x2de000
> [2280:c/r:pgarr_release_pages] total pages 1
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x2df000-0x2e0000 flags 0x8100873 type 3 vmaref 6 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 6
> [2280:c/r:generic_vma_restore] size 0x1000 prot 0x3 flag 0x812 pgoff 0x21 => 0x2df000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 1
> [2280:c/r:read_pages_contents] got page 0x2df000
> [2280:c/r:pgarr_release_pages] total pages 1
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 6 len 16(72,72)
> [2280:c/r:_ckpt_read_objref] shared len 16 type 6
> [2280:c/r:restore_obj] len 16 ref 7 type 1
> [2280:c/r:ckpt_read_obj] type 303 len 40(0,4096)
> [2280:c/r:do_restore_file] flags 0x0 mode 0x1d type 1
> [2280:c/r:ckpt_read_obj] type 5 len 25(0,4096)
> [2280:c/r:read_open_fname] fname '/lib/libc-2.9.so' flags 0x0 mode 0x1d
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x2e2000-0x450000 flags 0x8000075 type 3 vmaref 7 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 7
> [2280:c/r:generic_vma_restore] size 0x16e000 prot 0x5 flag 0x12 pgoff 0x0 => 0x2e2000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x450000-0x452000 flags 0x8100071 type 3 vmaref 7 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 7
> [2280:c/r:generic_vma_restore] size 0x2000 prot 0x1 flag 0x12 pgoff 0x16e => 0x450000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 1
> [2280:c/r:read_pages_contents] got page 0x451000
> [2280:c/r:pgarr_release_pages] total pages 1
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x452000-0x453000 flags 0x8100073 type 3 vmaref 7 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 7
> [2280:c/r:generic_vma_restore] size 0x1000 prot 0x3 flag 0x12 pgoff 0x170 => 0x452000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 1
> [2280:c/r:read_pages_contents] got page 0x452000
> [2280:c/r:pgarr_release_pages] total pages 1
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x453000-0x456000 flags 0x100073 type 2 vmaref 0 inoref 0
> [2280:c/r:restore_vma] vma type ANON PRIVATE
> [2280:c/r:generic_vma_restore] size 0x3000 prot 0x3 flag 0x12 pgoff 0x0 => 0x453000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 2
> [2280:c/r:read_pages_contents] got page 0x453000
> [2280:c/r:read_pages_contents] got page 0x455000
> [2280:c/r:pgarr_release_pages] total pages 2
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 6 len 16(72,72)
> [2280:c/r:_ckpt_read_objref] shared len 16 type 6
> [2280:c/r:restore_obj] len 16 ref 8 type 1
> [2280:c/r:ckpt_read_obj] type 303 len 40(0,4096)
> [2280:c/r:do_restore_file] flags 0x0 mode 0x1d type 1
> [2280:c/r:ckpt_read_obj] type 5 len 26(0,4096)
> [2280:c/r:read_open_fname] fname '/lib/libdl-2.9.so' flags 0x0 mode 0x1d
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x458000-0x45b000 flags 0x8000075 type 3 vmaref 8 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 8
> [2280:c/r:generic_vma_restore] size 0x3000 prot 0x5 flag 0x12 pgoff 0x0 => 0x458000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x45b000-0x45c000 flags 0x8100071 type 3 vmaref 8 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 8
> [2280:c/r:generic_vma_restore] size 0x1000 prot 0x1 flag 0x12 pgoff 0x2 => 0x45b000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 1
> [2280:c/r:read_pages_contents] got page 0x45b000
> [2280:c/r:pgarr_release_pages] total pages 1
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x45c000-0x45d000 flags 0x8100073 type 3 vmaref 8 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 8
> [2280:c/r:generic_vma_restore] size 0x1000 prot 0x3 flag 0x12 pgoff 0x3 => 0x45c000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 1
> [2280:c/r:read_pages_contents] got page 0x45c000
> [2280:c/r:pgarr_release_pages] total pages 1
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x8047000-0x80fb000 flags 0x8001875 type 3 vmaref 5 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 5
> [2280:c/r:generic_vma_restore] size 0xb4000 prot 0x5 flag 0x1812 pgoff 0x0 => 0x8047000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x80fb000-0x8100000 flags 0x8101873 type 3 vmaref 5 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 5
> [2280:c/r:generic_vma_restore] size 0x5000 prot 0x3 flag 0x1812 pgoff 0xb3 => 0x80fb000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 3
> [2280:c/r:read_pages_contents] got page 0x80fb000
> [2280:c/r:read_pages_contents] got page 0x80fc000
> [2280:c/r:read_pages_contents] got page 0x80ff000
> [2280:c/r:pgarr_release_pages] total pages 3
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x8100000-0x8105000 flags 0x100073 type 2 vmaref 0 inoref 0
> [2280:c/r:restore_vma] vma type ANON PRIVATE
> [2280:c/r:generic_vma_restore] size 0x5000 prot 0x3 flag 0x12 pgoff 0x0 => 0x8100000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 5
> [2280:c/r:read_pages_contents] got page 0x8100000
> [2280:c/r:read_pages_contents] got page 0x8101000
> [2280:c/r:read_pages_contents] got page 0x8102000
> [2280:c/r:read_pages_contents] got page 0x8103000
> [2280:c/r:read_pages_contents] got page 0x8104000
> [2280:c/r:pgarr_release_pages] total pages 5
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x98de000-0x98ff000 flags 0x100073 type 2 vmaref 0 inoref 0
> [2280:c/r:restore_vma] vma type ANON PRIVATE
> [2280:c/r:generic_vma_restore] size 0x21000 prot 0x3 flag 0x12 pgoff 0x0 => 0x98de000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 5
> [2280:c/r:read_pages_contents] got page 0x98de000
> [2280:c/r:read_pages_contents] got page 0x98df000
> [2280:c/r:read_pages_contents] got page 0x98e0000
> [2280:c/r:read_pages_contents] got page 0x98e1000
> [2280:c/r:read_pages_contents] got page 0x98e2000
> [2280:c/r:pgarr_release_pages] total pages 5
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 6 len 16(72,72)
> [2280:c/r:_ckpt_read_objref] shared len 16 type 6
> [2280:c/r:restore_obj] len 16 ref 9 type 1
> [2280:c/r:ckpt_read_obj] type 303 len 40(0,4096)
> [2280:c/r:do_restore_file] flags 0x0 mode 0x1d type 1
> [2280:c/r:ckpt_read_obj] type 5 len 29(0,4096)
> [2280:c/r:read_open_fname] fname '/lib/libtinfo.so.5.6' flags 0x0 mode 0x1d
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x46bc0000-0x46bd6000 flags 0x8000075 type 3 vmaref 9 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 9
> [2280:c/r:generic_vma_restore] size 0x16000 prot 0x5 flag 0x12 pgoff 0x0 => 0x46bc0000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0x46bd6000-0x46bd9000 flags 0x8100073 type 3 vmaref 9 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 9
> [2280:c/r:generic_vma_restore] size 0x3000 prot 0x3 flag 0x12 pgoff 0x15 => 0x46bd6000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 2
> [2280:c/r:read_pages_contents] got page 0x46bd7000
> [2280:c/r:read_pages_contents] got page 0x46bd8000
> [2280:c/r:pgarr_release_pages] total pages 2
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 6 len 16(72,72)
> [2280:c/r:_ckpt_read_objref] shared len 16 type 6
> [2280:c/r:restore_obj] len 16 ref 10 type 1
> [2280:c/r:ckpt_read_obj] type 303 len 40(0,4096)
> [2280:c/r:do_restore_file] flags 0x8000 mode 0x1d type 1
> [2280:c/r:ckpt_read_obj] type 5 len 39(0,4096)
> [2280:c/r:read_open_fname] fname '/usr/lib/locale/locale-archive' flags 0x8000 mode 0x1d
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0xb7e3e000-0xb803e000 flags 0x8000071 type 3 vmaref 10 inoref 0
> [2280:c/r:restore_vma] vma type FILE PRIVATE
> [2280:c/r:ckpt_obj_fetch] FILE ref 10
> [2280:c/r:generic_vma_restore] size 0x200000 prot 0x1 flag 0x12 pgoff 0x0 => 0xb7e3e000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0xb803e000-0xb8040000 flags 0x100073 type 2 vmaref 0 inoref 0
> [2280:c/r:restore_vma] vma type ANON PRIVATE
> [2280:c/r:generic_vma_restore] size 0x2000 prot 0x3 flag 0x12 pgoff 0x0 => 0xb803e000
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 2
> [2280:c/r:read_pages_contents] got page 0xb803e000
> [2280:c/r:read_pages_contents] got page 0xb803f000
> [2280:c/r:pgarr_release_pages] total pages 2
> [2280:c/r:ckpt_read_obj] type 203 len 16(16,16)
> [2280:c/r:restore_memory_contents] total pages 0
> [2280:c/r:ckpt_read_obj] type 6 len 16(72,72)
> [2280:c/r:_ckpt_read_objref] shared len 16 type 6
> [2280:c/r:restore_obj] len 16 ref 11 type 1
> [2280:c/r:ckpt_read_obj] type 303 len 40(0,4096)
> [2280:c/r:do_restore_file] flags 0x0 mode 0x1d type 1
> [2280:c/r:ckpt_read_obj] type 5 len 43(0,4096)
> [2280:c/r:read_open_fname] fname '/usr/lib/gconv/gconv-modules.cache' flags 0x0 mode 0x1d
> [2280:c/r:ckpt_read_obj] type 202 len 72(72,72)
> [2280:c/r:restore_vma] vma 0xb8046000-0xb804d000 flags 0x80000d1 type 6 vmaref 11 inoref 12
> [2280:c/r:restore_vma] vma type FILE SHARED
> [2280:c/r:restore_task] shared: ret -22
> [2280:c/r:pgarr_release_pages] total pages 0
> bash[2280]: segfault at bfc943f8 ip ffffe416 sp bfc943f8 error 4
> 
> 
> 
