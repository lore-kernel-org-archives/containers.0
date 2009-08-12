From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46183-gd8a68a4
Date: Wed, 12 Aug 2009 16:57:41 -0400
Message-ID: <200908122057.n7CKvfjv006472@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The branch, ckpt-v17-dev has been updated
       via  d8a68a4242a854ed585caa81d3aed61965c91e55 (commit)
       via  48ea8cb34960998c545ac91d77f5044bd5caefaf (commit)
      from  a101d30a3bfee4bc38fb646e44c20929f699699b (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit d8a68a4242a854ed585caa81d3aed61965c91e55
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Aug 12 13:02:29 2009 -0700

    c/r: Add AF_UNIX support (v10)
    
    This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
    has been tested with a single and multiple processes, and with data inflight
    at the time of checkpoint.  It supports socketpair()s, path-based, and
    abstract sockets.
    
    Changes in v10:
      - Moved header structure definitions back to checkpoint_hdr.h
      - Moved AF_UNIX checkpoint/restart code to net/unix/checkpoint.c
      - Make sock_unix_*() functions only compile if CONFIG_UNIX=y
      - Add TODO for CONFIG_UNIX=m case
    
    Changes in v9:
      - Fix double-free of skb's in the list and target holding queue in the
        error path of sock_copy_buffers()
      - Adjust use of ckpt_read_string() to match new signature
    
    Changes in v8:
      - Fix stale dev_alloc_skb() from before the conversion to skb_clone()
      - Fix a couple of broken error paths
      - Fix memory leak of kvec.iov_base on successful return from sendmsg()
      - Fix condition for deciding when to run sock_cptrst_verify()
      - Fix buffer queue copy algorithm to hold the lock during walk(s)
      - Log the errno when either getname() or getpeer() fails
      - Add comments about ancillary messages in the UNIX queue
      - Add TODO comments for credential restore and flags via setsockopt()
      - Add TODO comment about strangely-connected dgram sockets and the use
        of sendmsg(peer)
    
    Changes in v7:
      - Fix failure to free iov_base in error path of sock_read_buffer()
      - Change sock_read_buffer() to use _ckpt_read_obj_type() to get the
        header length and then use ckpt_kread() directly to read the payload
      - Change sock_read_buffers() to sock_unix_read_buffers() and break out
        some common functionality to better accommodate the subsequent INET
        patch
      - Generalize sock_unix_getnames() into sock_getnames() so INET can use it
      - Change skb_morph() to skb_clone() which uses the more common path and
        still avoids the copy
      - Add check to validate the socket type before creating socket
        on restore
      - Comment the CAP_NET_ADMIN override in sock_read_buffer_hdr
      - Strengthen the comment about priming the buffer limits
      - Change the objhash functions to deny direct checkpoint of sockets and
        remove the reference counting function
      - Change SOCKET_BUFFERS to SOCKET_QUEUE
      - Change this,peer objrefs to signed integers
      - Remove names from internal socket structures
      - Fix handling of sock_copy_buffers() result
      - Use ckpt_fill_fname() instead of d_path() for writing CWD
      - Use sock_getname() and sock_getpeer() for proper security hookage
      - Return -ENOSYS for unsupported socket families in checkpoint and restart
      - Use sock_setsockopt() and sock_getsockopt() where possible to save and
        restore socket option values
      - Check for SOCK_DESTROY flag in the global verify function because none
        of our supported socket types use it
      - Check for SOCK_USE_WRITE_QUEUE in AF_UNIX restore function because
        that flag should not be used on such a socket
      - Check socket state in UNIX restart path to validate the subset of valid
        values
    
    Changes in v6:
      - Moved the socket addresses to the per-type header
      - Eliminated the HASCWD flag
      - Remove use of ckpt_write_err() in restart paths
      - Change the order in which buffers are read so that we can set the
        socket's limit equal to the size of the image's buffers (if appropriate)
        and then restore the original values afterwards.
      - Use the ckpt_validate_errno() helper
      - Add a check to make sure that we didn't restore a (UNIX) socket with
        any skb's in the send buffer
      - Fix up sock_unix_join() to not leave addr uninitialized for socketpair
      - Remove inclusion of checkpoint_hdr.h in the socket files
      - Make sock_unix_write_cwd() use ckpt_write_string() and use the new
        ckpt_read_string() for reading the cwd
      - Use the restored realcred credentials in sock_unix_join()
      - Fix error path of the chdir_and_bind
      - Change the algorithm for reloading the socket buffers to use sendmsg()
        on the socket's peer for better accounting
      - For DGRAM sockets, check the backlog value against the system max
        to avoid letting a restart bypass the overloaded queue length
      - Use sock_bind() instead of sock->ops->bind() to gain the security hook
      - Change "restart" to "restore" in some of the function names
    
    Changes in v5:
      - Change laddr and raddr buffers in socket header to be long enough
        for INET6 addresses
      - Place socket.c and sock.h function definitions inside #ifdef
        CONFIG_CHECKPOINT
      - Add explicit check in sock_unix_makeaddr() to refuse if the
        checkpoint image specifies an addr length of 0
      - Split sock_unix_restart() into a few pieces to facilitate:
      - Changed behavior of the unix restore code so that unlinked LISTEN
        sockets don't do a bind()...unlink()
      - Save the base path of a bound socket's path so that we can chdir()
        to the base before bind() if it is a relative path
      - Call bind() for any socket that is not established but has a
        non-zero-length local address
      - Enforce the current sysctl limit on socket buffer size during restart
        unless the user holds CAP_NET_ADMIN
      - Unlink a path-based socket before calling bind()
    
    Changes in v4:
      - Changed the signdness of rcvlowat, rcvtimeo, sndtimeo, and backlog
        to match their struct sock definitions.  This should avoid issues
        with sign extension.
      - Add a sock_cptrst_verify() function to be run at restore time to
        validate several of the values in the checkpoint image against
        limits, flag masks, etc.
      - Write an error string with ctk_write_err() in the obscure cases
      - Don't write socket buffers for listen sockets
      - Sanity check address lengths before we agree to allocate memory
      - Check the result of inserting the peer object in the objhash on
        restart
      - Check return value of sock_cptrst() on restart
      - Change logic in remote getname() phase of checkpoint to not fail for
        closed (et al) sockets
      - Eliminate the memory copy while reading socket buffers on restart
    
    Changes in v3:
      - Move sock_file_checkpoint() above sock_file_restore()
      - Change __sock_file_*() functions to do_sock_file_*()
      - Adjust some of the struct cr_hdr_socket alignment
      - Improve the sock_copy_buffers() algorithm to avoid locking the source
        queue for the entire operation
      - Fix alignment in the socket header struct(s)
      - Move the per-protocol structure (ckpt_hdr_socket_un) out of the
        common socket header and read/write it separately
      - Fix missing call to sock_cptrst() in restore path
      - Break out the socket joining into another function
      - Fix failure to restore the socket address thus fixing getname()
      - Check the state values on restart
      - Fix case of state being TCP_CLOSE, which allows dgram sockets to be
        properly connected (if appropriate) to their peer and maintain the
        sockaddr for getname() operation
      - Fix restoring a listening socket that has been unlink()'d
      - Fix checkpointing sockets with an in-flight FD-passing SKB.  Fail
        with EBUSY.
      - Fix checkpointing listening sockets with an unaccepted connection.
        Fail with EBUSY.
      - Changed 'un' to 'unix' in function and structure names
    
    Changes in v2:
      - Change GFP_KERNEL to GFP_ATOMIC in sock_copy_buffers() (this seems
        to be rather common in other uses of skb_copy())
      - Move the ckpt_hdr_socket structure definition to linux/socket.h
      - Fix whitespace issue
      - Move sock_file_checkpoint() to net/socket.c for symmetry
    
    Cc: Oren Laaden <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 48ea8cb34960998c545ac91d77f5044bd5caefaf
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Aug 12 08:10:44 2009 -0700

    Fix prototypes for ckpt_read_{string,payload}()
    
    The exported prototypes in checkpoint.h don't match the actual functions.
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/files.c             |    7 +
 checkpoint/objhash.c           |   19 ++
 include/linux/checkpoint.h     |   16 +-
 include/linux/checkpoint_hdr.h |   72 ++++++
 include/net/af_unix.h          |   32 +++
 include/net/sock.h             |   11 +
 net/Makefile                   |    2 +
 net/checkpoint.c               |  438 +++++++++++++++++++++++++++++++++
 net/socket.c                   |   85 +++++++
 net/unix/Makefile              |    1 +
 net/unix/checkpoint.c          |  524 ++++++++++++++++++++++++++++++++++++++++
 11 files changed, 1204 insertions(+), 3 deletions(-)
 create mode 100644 net/checkpoint.c
 create mode 100644 net/unix/checkpoint.c


hooks/post-receive
--
linux-cr
