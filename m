From: Ganzoo Awaasuren <ganaa.8.91-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: USB Write Checkpoint
Date: Mon, 31 May 2010 18:57:13 +0800
Message-ID: <AANLkTikYoK7EIJ4AoAT83qDujVFeDhPoo08GbzEF07b6@mail.gmail.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Dear All

Now I am changing and developing some kernel stuffs which is related to
Linux FileSystems.

My work is just to find the solution for the inconvinence use of the USB
disk. We have to click "safe remove" button for flush the buffer data to
disk before the plug off the USB disk .

So my aim of the work is just avoid to click the safe remove button and plug
off the USB disk straightly. Even if buffer cache data couldn't written to
USB disk, then plug in the USB disk again and recover the buffer cache data

Here is my Idea step by step. Please check it out

1. Let's suppose to write A.txt file to USB external hard disk or flash
disk.

in the linux kernel source code, write system call is invoke the following
function flows - sys_write (write, int, fd, __user, buf, size_t, count) ->
do_sync_write (file, buf, count, pos) -> generic_file_aio_write(kiocb,
iov,1, kiocb.ki_pos) -> generic_file_buffered_write (iocb, iov, m_segs,
pos,ppos, count, written) -> generic_performance_write (struct file,
iov_iter i, pos)

and then write operation has divided into 3 separate fields. First
block_write_begin allocating and initializing buffer heads for the page,
Second - copy the data from the user mode buffer to disk's buffer page.
Third - block_write_end marks the underlying buffers as disrty so they are
written to disk later.

So my idea is when the kernel perform the write operations then check that
the disk is USB or not, and if it is USB disk then take *Checkpoint *on this
write request. in order to get Checkpoint, i tried to copy that page buffers
to the some secure buffer which is save the page buffer. Then if we plug off
the USB disk before the flush to the disk, then this secure buffers data
will be held until that USB disk plug in again or reach the some certain
amount of deadline time. If we plug in the USB disk again then check that
USB disk and sending signal to the Secure buffer then recover the unwritten
block to the USB disk.

As far as i understand from your developed checkpoint technique on linux
kernel , probably i can get it and apply it for my purpose. So is it
possible to call that sys_checkpoint function in kernel's sys_write system
call ? if it is possible then , is this checkpointed image will include that
all of the open files ?

I am sorry for my bad english

Thanks


Best Regards
