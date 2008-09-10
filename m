From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v4][PATCH 9/9] File descriprtors (restore)
Date: Wed, 10 Sep 2008 14:55:43 -0400
Message-ID: <48C8182F.5090008__42822.0309121118$1221073309$gmane$org@cs.columbia.edu>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>	
	<1220946154-15174-10-git-send-email-orenl@cs.columbia.edu>	
	<1220977581.23386.216.camel@nimitz>
	<48C727B6.9000700@cs.columbia.edu> <1221062969.6781.5.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221062969.6781.5.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Tue, 2008-09-09 at 21:49 -0400, Oren Laadan wrote:
>> Dave Hansen wrote:
>>> On Tue, 2008-09-09 at 03:42 -0400, Oren Laadan wrote:
>>>> +static int cr_close_all_fds(struct files_struct *files)
>>>> +{
>>>> +       int *fdtable;
>>>> +       int n;
>>>> +
>>>> +       do {
>>>> +               n = cr_scan_fds(files, &fdtable);
>>>> +               if (n < 0)
>>>> +                       return n;
>>>> +               while (n--)
>>>> +                       sys_close(fdtable[n]);
>>>> +               kfree(fdtable);
>>>> +       } while (n != -1);
>>>> +
>>>> +       return 0;
>>>> +}
>>> This needs to use an ERR_PTR().  It will save using the double-pointer.
>> I suppose you refer to the call to cr_scan_fds(): either 'fdtable'
>> or 'n' will have to pass-by-reference. Is it that you prefer it to be
>> 	fdtable = cr_scan_fds(files, &n);
>> ?
> 
> I was misreading the use of 'n'.  Can you really not use close_files()
> for this operation?  You'd need to add some locking around it, but I
> think it does what you need here.

I thought about that. However, close_files() assumes that the files_struct
will be discarded thereafter, so it does not reset ->fd_open->fd_bits[] bits,
does not adjust ->next_fd field, and does not use rcu_assign_pointer(). And
then, even if we adjust, we'll have to watch future differences between
sys_close() and close_files(), so using sys_close() is more future-proof.

Besides, cr_scan_fds() is used by the checkpoint logic already, so it's easy
to reuse for restart as well.

Oren.
