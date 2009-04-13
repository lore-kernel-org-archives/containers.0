From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH 00/30] C/R OpenVZ/Virtuozzo style
Date: Mon, 13 Apr 2009 21:30:49 +0200
Message-ID: <20090413193049.GA9895__33173.3526000336$1239651335$gmane$org@elte.hu>
References: <20090410023207.GA27788@x200.localdomain>
	<alpine.LFD.2.00.0904100758410.4583@localhost.localdomain>
	<20090413073925.GB7085@x200.localdomain>
	<alpine.LFD.2.00.0904131137520.26713@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0904131137520.26713-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


* Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> On Mon, 13 Apr 2009, Alexey Dobriyan wrote:
> > 
> > Well, in OpenVZ everything is in kernel/cpt/ and prefixed with 
> > "cpt_" and "rst_".
> 
> So?
> 
> We're not merging OpenVZ code _either_.
> 
> > And I think "cr_" is super nice prefix: it's short, it's C-like, 
> > it reminds about restart part
> 
> It does no such thing. THAT'S THE POINT. "cr" means _nothing_ to 
> anybody else than some CR-specific people, and those people don't 
> even need it!
> 
> Look around you. We try to use nicer names. We spell out 
> "cpufreq", we don't call it "cf".

I've done an analysis about what a good kernel-global naming scheme 
for checkpoint/restore might be (see further below).

Here's the current namespace (from a stupid sed+grep script combo 
done on my mbox - so it combines all the submitted patches):

cr_align
cr_arch
cr_arch_check_image_header
cr_arch_check_image_task_struct
cr_arch_check_mm_struct
cr_arch_check_task_struct
cr_arch_dump_mm_struct
cr_arch_dump_task_struct
cr_arch_len_mm_struct
cr_arch_len_task_struct
cr_arch_restore_mm_struct
cr_arch_restore_task_struct
cr_arg_end
cr_arg_start
cr_attach_get_file
cr_bits
cr_blocked
cr_brk
cr_can_checkpoint_file
cr_cap_bset
cr_cap_effective
cr_cap_inheritable
cr_cap_permitted
cr_c_cc
cr_c_cflag
cr_check_*
cr_check_cred
cr_check_file
cr_check_file:
cr_check_image_header
cr_check_mm
cr_check_mm_struct
cr_check_pid_ns
cr_check_sighand
cr_check_sighand_struct
cr_check_signal
cr_check_signal_struct
cr_check_sock
cr_check_task_struct
cr_check_tty
cr_check_user_struct
cr_check_vma
cr_c_iflag
cr_c_ispeed
cr_c_lflag
cr_c_line
cr_c_oflag
cr_collect
cr_collect_all_cred
cr_collect_all_file
cr_collect_all_files_struct
cr_collect_all_fs_struct
cr_collect_all_group_info
cr_collect_all_ipc_ns
cr_collect_all_mm_struct
cr_collect_all_mnt_ns
cr_collect_all_net_ns
cr_collect_all_nsproxy
cr_collect_all_pid
cr_collect_all_pid_ns
cr_collect_all_sighand_struct
cr_collect_all_signal_struct
cr_collect_all_sock
cr_collect_all_task_struct
cr_collect_all_tty_struct
cr_collect_all_user_ns
cr_collect_all_user_struct
cr_collect_all_uts_ns
cr_collect_cred
cr_collect_file
cr_collect_files_struct
cr_collect_fs_struct
cr_collect_group_info
cr_collect_ipc_ns
cr_collect_mm
cr_collect_mm_struct
cr_collect_mnt_ns
cr_collect_net_ns
cr_collect_nsproxy
cr_collect_object
cr_collect_pid
cr_collect_pid_ns
cr_collect_sighand
cr_collect_sighand_struct
cr_collect_signal
cr_collect_signal_struct
cr_collect_sock
cr_collect_tasks
cr_collect_task_struct
cr_collect_tty
cr_collect_user_ns
cr_collect_user_struct
cr_collect_uts_ns
cr_comm
cr_context
cr_context_create
cr_context_destroy
cr_context_obj_type
cr_context_task_struct
cr_core
cr_c_ospeed
cr_cred
cr_cs
cr_ct
cr_ctrl_status
cr_ctx
cr_ctx_count
cr_ctx_put
cr_data
cr_debug
cr_def_flags
cr_domainname
cr_dr0
cr_dr1
cr_dr2
cr_dr3
cr_dr6
cr_dr7
cr_driver_flags
cr_driver_subtype
cr_driver_type
cr_ds
cr_dump
cr_dump_all_cred
cr_dump_all_file
cr_dump_all_files_struct
cr_dump_all_fs_struct
cr_dump_all_group_info
cr_dump_all_ipc_ns
cr_dump_all_mm_struct
cr_dump_all_mnt_ns
cr_dump_all_net_ns
cr_dump_all_nsproxy
cr_dump_all_pid
cr_dump_all_pid_ns
cr_dump_all_sighand_struct
cr_dump_all_signal_struct
cr_dump_all_sock
cr_dump_all_task_struct
cr_dump_all_tty
cr_dump_all_user_ns
cr_dump_all_user_struct
cr_dump_all_uts_ns
cr_dump_anonvma
cr_dump_cred
cr_dump_fd
cr_dump_file
cr_dump_files_struct
cr_dump_fs_struct
cr_dump_group_info
cr_dump_header
cr_dump_image_header
cr_dump_ipc_ns
cr_dump_mm_struct
cr_dump_mnt_ns
cr_dump_net_ns
cr_dump_nsproxy
cr_dump_pid
cr_dump_pid_ns
cr_dump_ptr
cr_dump_sighand_struct
cr_dump_signal_struct
cr_dump_sigset
cr_dump_sock
cr_dump_task_struct
cr_dump_task_struct_x86_32
cr_dump_task_struct_x86_64
cr_dump_terminator
cr_dump_tty
cr_dump_user_ns
cr_dump_user_struct
cr_dump_uts_ns
cr_dump_vma
cr_dump_vma_pages
cr_dump_xstate
cr_eax
cr_ebp
cr_ebx
cr_ecx
cr_edi
cr_edx
cr_eflags
cr_egid
cr_eip
cr_enabled
cr_end_code
cr_end_data
cr_env_end
cr_env_start
cr_es
cr_esi
cr_esp
cr_euid
cr_explain_file
cr_fd
cr_fd_flags
cr_f_flags
cr_file
cr_file_checkpoint
cr_file_checkpointable
cr_file_get_func
cr_files_struct
cr_file_supported
cr_fill_name
cr_find_obj_by_pos
cr_find_obj_by_ptr
cr_flags
cr_flow_stopped
cr_f_owner
cr_f_owner_euid
cr_f_owner_pid_type
cr_f_owner_signum
cr_f_owner_uid
cr_f_pos
cr_freeze_tasks
cr_fs
cr_fs_checkpointable
cr_fsgid
cr_fsindex
cr_fsuid
cr_gid
cr_gs
cr_gsindex
cr_hbuf_get
cr_hbuf_put
cr_hdr
cr_hdr_cpu
cr_hdr_fd
cr_hdr_fd_data
cr_hdr_fd_ent
cr_hdr_files
cr_hdr_head
cr_hdr_head_arch
cr_hdr_mm
cr_hdr_mm_context
cr_hdr_pgarr
cr_hdr_pids
cr_hdr_tail
cr_hdr_tree
cr_hdr_vma
cr_header
cr_hw_stopped
cr_imag
cr_image_arch_x86_32
cr_image_arch_x86_64
cr_image_cred
cr_image_fd
cr_image_file
cr_image_files_struct
cr_image_fs_struct
cr_image_group_info
cr_image_header
cr_image_header_arch
cr_image_ipc_ns
cr_image_magic
cr_image_mm_struct
cr_image_mnt_ns
cr_image_net_ns
cr_image_nsproxy
cr_image_pid
cr_image_pid_ns
cr_image_sighand_struct
cr_image_signal_struct
cr_image_sigset
cr_image_sock
cr_image_task_st
cr_image_task_struct
cr_image_tty
cr_image_user_ns
cr_image_user_struct
cr_image_uts_ns
cr_image_version
cr_image_vma
cr_image_vma_content
cr_image_vma_vdso
cr_i_mode
cr_index
cr_ipc_ns
cr_kill_tasks
cr_kread
cr_last_pid
cr_len
cr_len_arch
cr_len_xstate
cr_level
cr_link_index
cr_low_latency
cr_machine
cr_mm_struct
cr_mnt_ns
cr_msg_ctlmax
cr_msg_ctlmnb
cr_msg_ctlmni
cr_name
cr_name_len
cr_net_ns
cr_ngroups
cr_nodename
cr_nr
cr_nr_pages
cr_nsproxy
cr_obj
cr_obj_add_ptr
cr_obj_add_ref
cr_object
cr_object_create
cr_object_destroy
cr_object_header
cr_orig_eax
cr_orig_rax
cr_packet
cr_page_size
cr_pgarr
cr_pid_ns
cr_pid_type
cr_pos_cred
cr_pos_f_cred
cr_pos_file
cr_pos_files
cr_pos_f_owner_pid
cr_pos_fs
cr_pos_group_info
cr_pos_ipc_ns
cr_pos_mm
cr_pos_mm_struct
cr_pos_mnt_ns
cr_pos_net_ns
cr_pos_nsproxy
cr_pos_parent
cr_pos_pgrp
cr_pos_pid
cr_pos_pid_ns
cr_pos_pids
cr_pos_real_cred
cr_pos_real_parent
cr_pos_session
cr_pos_sighand
cr_pos_signal
cr_pos_sk_net
cr_pos_t
cr_pos_user
cr_pos_user_ns
cr_pos_uts_ns
cr_pos_vm_file
cr_pread
cr_prepare_image
cr_pwd
cr_pwd_len
cr_quan@163
cr_r10
cr_r11
cr_r12
cr_r13
cr_r14
cr_r15
cr_r8
cr_r9
cr_rax
cr_rbp
cr_rbx
cr_rcx
cr_rdi
cr_rdx
cr_read_buffer
cr_read_buf_type
cr_read_cpu
cr_read_cpu_fpu
cr_read_fd_data
cr_read_files
cr_read_head_arch
cr_read_mm
cr_read_mm_context
cr_read_obj_type
cr_read_open_fname
cr_read_string
cr_read_task_struct
cr_read_thread
cr_real_blocked
cr_release
cr_restart
cr_restore_all_fd
cr_restore_all_vma
cr_restore_cred
cr_restore_fd
cr_restore_file
cr_restore_files_struct
cr_restore_fs_struct
cr_restore_group_info
cr_restore_ipc_ns
cr_restore_mm_struct
cr_restore_mnt_ns
cr_restore_net_ns
cr_restore_nsproxy
cr_restore_pid
cr_restore_pid_ns
cr_restore_ptr
cr_restore_sighand_struct
cr_restore_signal_struct
cr_restore_sigset
cr_restore_task_struct
cr_restore_task_struct_x86_32
cr_restore_task_struct_x86_64
cr_restore_uts_ns
cr_restore_vma
cr_restore_vma_content
cr_restore_vma_vdso
cr_restore_xstate
cr_rflags
cr_rip
cr_rlim
cr_rlim_cur
cr_rlim_max
cr_root
cr_root_len
cr_rsi
cr_rsp
cr_s390_mm
cr_s390_regs
cr_sa
cr_sa_flags
cr_sa_handler
cr_sa_mask
cr_sa_restorer
cr_save_cpu_regs
cr_saved_auxv
cr_saved_sigmask
cr_scan_fds
cr_securebits
cr_sem_ctls
cr_sgid
cr_shm_ctlall
cr_shm_ctlmax
cr_shm_ctlmni
cr_sighand
cr_signal
cr_signature
cr_signum
cr_sk_family
cr_ss
cr_start_addr
cr_start_brk
cr_start_code
cr_start_data
cr_start_stack
cr_stopped
cr_suid
cr_sysctl_max_dgram_qlen
cr_sysctl_somaxconn
cr_sysname
cr_task_struct
cr_task_struct_arch
cr_termios
cr_thaw_tasks
cr_tls_array
cr_tsk_arch
cr_type
cr_uid
cr_umask
cr_unx
cr_uts_ns
cr_uts_release
cr_version
cr_vm_end
cr_vm_flags
cr_vm_page_prot
cr_vm_pgoff
cr_vm_start
cr_winsize
cr_write
cr_write_buffer
cr_write_cpu
cr_write_error
cr_write_fd_data
cr_write_files
cr_write_head
cr_write_head_arch
cr_write_mm_context
cr_write_obj
cr_write_thread
cr_write_vma
cr_ws_col
cr_ws_row
cr_ws_xpixel
cr_ws_ypixel
cr_xstate

The cr_ prefix for internal symbols and fields should be dropped. 

For global symbols, the following naming scheme looks pretty 
intuitive, unique and self-descriptive to me:

  state_checkpoint_XYZ()
  state_restore_XYZ()
  state_collect_XYZ()
  state_dump_XYZ()
  state_image_XYZ()
  ...

Seeing a state_*() symbol anywhere in the kernel will tell me 'ah, 
this is kernel object state checkpoint/restore related 
functionality', at a glance.

[ And equally importantly, when seeing a state_*() symbol i can
  skip it easily, as an uninteresting-to-my-current-activity item. ]

I had a quick look at various existing uses of "\<state_.*" symbols 
in the kernel, and no widely used variant looked particularly 
confusing to me, so i think this would be a good choice IMHO.

	Ingo
