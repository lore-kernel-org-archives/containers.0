From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: bugs with ckpt-v15-dev
Date: Mon, 18 May 2009 16:36:11 -0500
Message-ID: <m3y6suhz5g.fsf@pobox.com>
References: <m3my9amczw.fsf@pobox.com> <20090518211041.GA20781@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090518211041.GA20781-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message
	of "Mon\, 18 May 2009 16\:10\:42 -0500")
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>> Last commit is ed3b275 "allow error string during checkpoint while
>> holding a spinlock".
>> 
>> # bash -c 'exec <&- >&- 2>&- ; while : ; do : ; done' &
>> [1] 2269
>> # ckpt $! > /tmp/bash.ckpt
>> 
>> BUG: sleeping function called from invalid context at mm/slub.c:1595
>
> Yeah, not only does ckpt_write_err() get called under task_lock, but
> the fn returns without ver doing put_task_struct.  (I'd generate and
> send the quick trivial patch, but my git tree is in a bit of a debugme
> state right now)

Would prefer to just rip that thing out, it's cost me more trouble then
it's worth.


> Now mind you this shows that your ckpt program isn't sending
> CHECKPOINT_SUBTREE with flags.

I don't follow.  There is "user error" here in that I'm not freezing the
task before checkpointing[1], but my ckpt command is passing the subtree
flag (0x4) afaict:

SYS_335(0x9ec, 0x1, 0x4, 0xbfdc6200, 0[2542:c/r:may_checkpoint_task] check 2540


> This in turns means you are probably
> not using the ckpt-v15-dev version of user-cr, and if that is
> the case it makes your problems with gconf shared file mapping more
> suspect ask well...?

After updating to the latest user-cr I get the same BUGs.

[1] Should CONFIG_CHECKPOINT depend on CONFIG_CGROUPS and/or
CONFIG_CGROUPS_FREEZER?  We require tasks to be put in frozen state
before checkpoint, is there any mechanism apart from
cgroup/freezer.state to do this?
