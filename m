From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: multi-threaded app fails to restart
Date: Mon, 19 Jul 2010 23:24:13 -0400
Message-ID: <4C4516DD.1000809@cs.columbia.edu>
References: <AANLkTilxfsYGyYLwO__VmDLSFQ_s_Qe03G49kIEztVja@mail.gmail.com>
	<1279569285.25071.98.camel@localhost>
	<AANLkTimpXSXQr1wew1wvZKnBFsOXD7f2tblY4EGmJoFM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTimpXSXQr1wew1wvZKnBFsOXD7f2tblY4EGmJoFM-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: John Paul Walters <jpnwalters-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


On 07/19/2010 04:27 PM, John Paul Walters wrote:
>>> Ghost state Success
>>> [ 3210.330285] [4031:4031:c/r:pgarr_release_pages:102] total pages 0
>>> [ 3210.330288] [4031:4031:c/r:do_restart:1451] sys_restart returns -512
>>>
>>> Any thoughts?
>>
>> There were two patches posted to the containers list on 11 July - "fix
>> task tree traversal for threads" and "save/restore 'sysenter_return' for
>> threads".  Can you try with those on top of ckpt-v22-dev?
>>
>>
>>
> 
> Hi Nathan,
> 
> Thanks for your help.  I applied the two patches as you suggested.
> They fixed the first of the two bad sys_restart return values, but the
> final one (quoted above, for what it's worth) still returns -512.
> When I use the -d -v switches to restart, it appears to work (no error
> messages are returned), but only the main thread is restored while the
> second thread is not.

Hi John,

I just pushed a few more fixes related to signals to ckpt-v22-dev.
Can you please see if they fix your problem ?

Also, can you please post the test program that you are using, so
we can try to replicate the problem ?

Note that it is usually ok for sys_restart() to return -512 -- it
means that the process/thread was interrupted when the checkpoint,
and it will now retry the same syscall from then.

You can use the -F (--freezer) switch of restart(1) to freeze the
restarted tasks/threads before they are allowed to run in userspace.
Using it you can tell whether the other thread dies immediately
after restart, or is not at all restarted.

Thanks,

Oren.
