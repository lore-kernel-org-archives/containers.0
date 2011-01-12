From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [Patch 0/2] Checkpoint and restart of file locks
Date: Tue, 11 Jan 2011 19:30:55 -0500
Message-ID: <4D2CF63F.5090300@cs.columbia.edu>
References: <1288333001-28838-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1294709825-23357-1-git-send-email-orenl@cs.columbia.edu>
	<20110112001700.GB7229@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110112001700.GB7229-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



On 01/11/2011 07:17 PM, Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | 
> | The following two patches add c/r support for POSIX file locks. They
> | are based on the series posted by Suka some time ago:
> | https://lists.linux-foundation.org/pipermail/containers/2010-October/025855.html
> | 
> | Suka:
> | 
> | When I read your post I thought that boht posix and flock were   
> | supported, but looking at the code I saw only posix. Am I missing
> | anything ?
> 
> Hmm. I have been working with only the posix locks for starters since
> it checkpoints/restarts the more general, 'struct file_lock' object.
> 
> But I should make that explicit. If a patch description implies that
> it covers flocks can be checkpointed, please let me know and I will
> fix it.
> 

Ok, just checking - I already modified the patch description
and the inline comments.

> C/R of leases/file-owner info is blocked on C/R of 'struct pids'.

It's in the working ...

> 
> | 
> | Also, I'm not sure that all the input is well sanitized during
> | restart - for example, the possible values for the lock flags.
> | Any thoughts ?
> 
> I have this check in restore_file_locks():
> 
> +               ret = -EBADF;
> +               if (h->fl_flags & FL_POSIX)
> +                       ret = restore_one_posix_lock(ctx, file, fd, 

In this specific example, I fixed it to ensure that only one of
FL_POSIX, FL_FLOCK and FL_LEASE is is present.

(Actually, now I see that I used fl_type, and I should fix it to
be fl_flags, but the intent was good ...)

> 
> The other fields (lock type for instance) will be validated by flock64_set()
> as for a new fcntl() call - no ?

That's what I was asking :o

> 
> | 
> | Lastly, do you have test cases to run against this patch and test
> | it ?
> 
> Yes, I added some tests to cr-tests a while ago and then updated them.
> Will find the updates and post them.

Thanks,

Oren.
