From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Patch 0/2] Checkpoint and restart of file locks
Date: Tue, 11 Jan 2011 16:17:00 -0800
Message-ID: <20110112001700.GB7229@us.ibm.com>
References: <1288333001-28838-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1294709825-23357-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1294709825-23357-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| 
| The following two patches add c/r support for POSIX file locks. They
| are based on the series posted by Suka some time ago:
| https://lists.linux-foundation.org/pipermail/containers/2010-October/025855.html
| 
| Suka:
| 
| When I read your post I thought that boht posix and flock were   
| supported, but looking at the code I saw only posix. Am I missing
| anything ?

Hmm. I have been working with only the posix locks for starters since
it checkpoints/restarts the more general, 'struct file_lock' object.

But I should make that explicit. If a patch description implies that
it covers flocks can be checkpointed, please let me know and I will
fix it.

C/R of leases/file-owner info is blocked on C/R of 'struct pids'.

| 
| Also, I'm not sure that all the input is well sanitized during
| restart - for example, the possible values for the lock flags.
| Any thoughts ?

I have this check in restore_file_locks():

+               ret = -EBADF;
+               if (h->fl_flags & FL_POSIX)
+                       ret = restore_one_posix_lock(ctx, file, fd, 

The other fields (lock type for instance) will be validated by flock64_set()
as for a new fcntl() call - no ?

| 
| Lastly, do you have test cases to run against this patch and test
| it ?

Yes, I added some tests to cr-tests a while ago and then updated them.
Will find the updates and post them.

Sukadev
