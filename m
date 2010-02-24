From: "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>
Subject: Scheduling in atomic while restoring shm
Date: Wed, 24 Feb 2010 19:02:18 +0300
Message-ID: <201002241902.19623@zigzag.lvk.cs.msu.su>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: leo-n4oKp6kCDthKyFCjRbgQbg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi

While playing with checkpoint-restart code, version
several-commits-before-0.19, we have faced "scheduling in atomic" issue.

It is still in v0.19, below code is from there.

   247          down_write(&shm_ids->rw_mutex);
   248
   249          /* we are the sole owners/users of this ipc_ns, it can't go away */
   250          perms = ipc_lock(shm_ids, h->perms.id);
   251          BUG_ON(IS_ERR(perms));  /* ipc_ns is private to us */
   252
   253          shp = container_of(perms, struct shmid_kernel, shm_perm);
   254          file = shp->shm_file;
   255          get_file(file);
   256
   257          ret = load_ipc_shm_hdr(ctx, h, shp);
   258          if (ret < 0)
   259                  goto mutex;
   260
   261          /* deposit in objhash and read contents in */
   262          ret = ckpt_obj_insert(ctx, file, h->objref, CKPT_OBJ_FILE);
   263          if (ret < 0)
   264                  goto mutex;
   265          ret = restore_memory_contents(ctx, file->f_dentry->d_inode);
   266   mutex:
   267          fput(file);
   268          if (ret < 0) {
   269                  ckpt_debug("shm: need to remove (%d)\n", ret);
   270                  do_shm_rmid(ns, perms);
   271          } else
   272                  ipc_unlock(perms);
   273          up_write(&shm_ids->rw_mutex);

So restore_ipc_shm() calls ipc_lock() and then restore_memory_contents().
Inside ipc_lock(), a spinlock is taken.
Inside restore_memory_contents(), checkpoint data is read, that results
in vfs_read() and a schedule somewhere below.

Looks like a bug.

Here is a backtrace:

[  145.795810] BUG: scheduling while atomic: multitask/433/0x00000003
[  145.796661] Modules linked in:
[  145.796992] Pid: 433, comm: multitask Not tainted 2.6.33-rc5 #2
[  145.797520] Call Trace:
[  145.797833]  [<c11e096b>] ? schedule+0x80/0x627
[  145.798266]  [<c11e1f6b>] ? _raw_spin_unlock_irqrestore+0x1f/0x29
[  145.798823]  [<c1110c54>] ? debug_check_no_obj_freed+0x11d/0x175
[  145.799451]  [<c11e219d>] ? _raw_spin_lock_irqsave+0x11/0x2a
[  145.800244]  [<c1036623>] ? prepare_to_wait+0x14/0x54
[  145.800872]  [<c108171e>] ? pipe_wait+0x4a/0x61
[  145.801442]  [<c10364a4>] ? autoremove_wake_function+0x0/0x2d
[  145.802113]  [<c1081e39>] ? pipe_read+0x2c4/0x327
[  145.802641]  [<c107b8e5>] ? do_sync_read+0x9c/0xe0
[  145.803176]  [<c110a3b2>] ? radix_tree_insert+0x135/0x16d
[  145.803762]  [<c11e1f42>] ? _raw_spin_unlock_irq+0x1e/0x28
[  145.804561]  [<c1058e97>] ? add_to_page_cache_locked+0xc2/0xca
[  145.805191]  [<c10e60f2>] ? security_file_permission+0xc/0xd
[  145.805798]  [<c107b849>] ? do_sync_read+0x0/0xe0
[  145.806292]  [<c107c127>] ? vfs_read+0x73/0xa1
[  145.806783]  [<c10fd87c>] ? ckpt_kread+0x6e/0xc6
[  145.807297]  [<c1104c54>] ? restore_read_page+0x1a/0x49
[  145.807857]  [<c1104ec0>] ? restore_memory_contents+0x23d/0x2f7
[  145.808727]  [<c10e0231>] ? restore_ipc_shm+0x296/0x32d
[  145.809302]  [<c10df9e9>] ? restore_ipc_any+0xa5/0x119
[  145.809865]  [<c10dfb06>] ? restore_ipc_ns+0xa9/0x112
[  145.810406]  [<c10dff9b>] ? restore_ipc_shm+0x0/0x32d
[  145.810962]  [<c10fe1cc>] ? restore_obj+0x98/0x116
[  145.811483]  [<c10ffe71>] ? ckpt_read_obj_dispatch+0x220/0x246
[  145.812238]  [<c10ffead>] ? ckpt_read_obj+0x16/0xe8
[  145.812857]  [<c107b522>] ? fsnotify_access+0x5a/0x61
[  145.813406]  [<c1100001>] ? ckpt_read_obj_type+0x16/0x70
[  145.813975]  [<c1039a6c>] ? restore_ns+0x18/0x12b
[  145.814483]  [<c10fe1cc>] ? restore_obj+0x98/0x116
[  145.815011]  [<c10ffe71>] ? ckpt_read_obj_dispatch+0x220/0x246
[  145.815636]  [<c10ffead>] ? ckpt_read_obj+0x16/0xe8
[  145.816429]  [<c1100001>] ? ckpt_read_obj_type+0x16/0x70
[  145.817030]  [<c1102abc>] ? restore_task+0x512/0x9fc
[  145.817574]  [<c11011dd>] ? do_restart+0xff4/0x12f3
[  145.818114]  [<c10364a4>] ? autoremove_wake_function+0x0/0x2d
[  145.818735]  [<c10fd1a5>] ? do_sys_restart+0x66/0x77
[  145.819271]  [<c1002795>] ? ptregs_restart+0x15/0x1c
[  145.819816]  [<c1002690>] ? sysenter_do_call+0x12/0x26


Another related bug: if load_ipc_shm_hdr() fails in line 257, control
is transfered to mutex: label with negative ret value; ipc_unlock()
is not called on this path.
