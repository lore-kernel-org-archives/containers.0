From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/3] Checkpoint/restart epoll sets
Date: Fri, 23 Oct 2009 19:30:21 -0400
Message-ID: <4AE23C8D.3070608@librato.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
	<20091021003128.GA23721@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091021003128.GA23721-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> @@ -1226,35 +1242,18 @@ SYSCALL_DEFINE1(epoll_create, int, size)
>>   * the eventpoll file that enables the insertion/removal/change of
>>   * file descriptors inside the interest set.

[...]

>> +	if (h->h.type != CKPT_HDR_FILE ||
>> +	    h->h.len  != sizeof(*h) ||
>> +	    h->f_type != CKPT_FILE_EPOLL)
>> +		return ERR_PTR(-EINVAL);
>> +
>> +	epfd = sys_epoll_create1(h->f_flags & EPOLL_CLOEXEC);
>> +	if (epfd < 0)
>> +		return ERR_PTR(epfd);
>> +	epfile = fget(epfd);
>> +	sys_close(epfd); /* harmless even if an error occured */
>> +	BUG_ON(!epfile);
> 
> Would perhaps return ERR_PTR(-ENOENT) be nicer?  (And maybe safer - I'm
> not quite clear on under which arches BUG_ON does nothing).

Serge is right: malicious userspace could fork the restarting tasks
to all share fdtable with a non-restarting task, and that other task
could close the fd ...

I'll write a patch that ensures that the root task doesn't share
anything with its parent (coordinator).

But the race still exists for self-restart. So I'd do -EBUSY here
instead.

Oren.
