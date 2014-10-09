From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC] setns: return 0 directly if try to reassociate with
	current namespace
Date: Wed, 08 Oct 2014 22:52:26 -0700
Message-ID: <871tqheqn9.fsf@x220.int.ebiederm.org>
References: <1412759587-21320-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<20141008145740.GD30569@ubuntumail>
	<87r3yih2e2.fsf@x220.int.ebiederm.org>
	<5871495633F38949900D2BF2DC04883E5E0FAC@G08CNEXMBPEKD02.g08.fujitsu.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5871495633F38949900D2BF2DC04883E5E0FAC-ZEd+hNNJ6a5ZYpXjqAkB5jz3u5zwRJJDAzI0kPv9QBlmR6Xm/wNWPw@public.gmane.org>
	(Hanxiao Chen's message of "Thu, 9 Oct 2014 04:14:23 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

>> -----Original Message-----
>> From: Eric W. Biederman [mailto:ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org]
>> Sent: Thursday, October 09, 2014 1:56 AM
>> 
>> Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > Quoting Chen Hanxiao (chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>> >> We could use setns to join the current ns,
>> >> which did a lot of unnecessary work.
>> >> This patch will check this senario and
>> >> return 0 directly.
>> >>
>> >> Signed-off-by: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> >
>> > Plus it's just asking for trouble.
>> >
>> > I would ack this, except you need to fclose(file) on the
>> > return paths.  So just set err = 0 and goto out.
>> 
>> I completely disagree.
>> 
>> Nacked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> 
>> This patch adds a new code path to test, and gets that new code path
>> wrong.  So unless there is a performance advantage for some real world
>> case I don't see the point.  Is there real software that is rejoining
>> the a current namespace.
>> 
>> This patch changes the behavior of CLONE_NEWNS (which always does a
>> chdir and chroot) when you change into the current namespace.
>> 
>> This patch changes the behavior of CLONE_NEWUSER which current errors
>> out.
>> 
>
> As reentering the same namespace looks meaningless,
> and handling reentering same ns we behaved differently,

It is not meaningless in the case of CLONE_NEWNS.  It is weird but not
meaningless.  Further return -EINVAL won't make the weird semantics go
away it just makes them more expensive to take advantage of.

> How about just *reject* the behaviour of setns to current namespace?

Because we don't break userspace applications without a darn good reason.

> +	switch (ops->type) {
> +	case CLONE_NEWIPC:
> +		if (ei->ns == tsk->nsproxy->ipc_ns) {
> +            err = -EINVAL;
> +			goto out;
> +        }
> ...
>
> And things became easy, 6 simply cases could cover the whole scenario
> and will not bring troubles to users.

Since you are cavalierly suggesting changing the semantics presented to
user space I don't belive the assertion that it will not bring trouble
to users.

Maybe on a day when I am not up to my neck in weird breakage in the
mount namespace.  Because people now care because unprivileged users can
use it we are starting to see bugs as old as 2.4 and they are a pain to
deal with.

Eric
