From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: namespace documentation.
Date: Fri, 21 Dec 2012 14:58:56 -0800
Message-ID: <87fw2zj9lb.fsf__30373.7211194404$1356130777$gmane$org@xmission.com>
References: <1356117854.21178.2@driftwood>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1356117854.21178.2@driftwood> (Rob Landley's message of "Fri, 21
	Dec 2012 13:24:14 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org> writes:

> On 12/21/2012 11:51:03 AM, Eric W. Biederman wrote:
>> Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > Eric. I understand that it is too late to discuss this. And yes, I  
>> simply
>> > do not understand the problem space, I never used containers.
>> >
>> > But, stupid question. Let's ignore the pid_ns-specific oddities.
>> >
>> > 1. Ignoring setns(), why do we need /proc/pid/ns/ ?
>> >
>> > 2. Why setns() requires /proc/pid/ns/ ? IOW, why it can't be
>> >
>> > 	sys_setns(pid_t pid, int clone_flags)
>> > 	{
>> > 		truct task_struct *tsk = find_task_by_vpid(pid);
>> > 		struct nsproxy *target = get_nsproxy(tsk->nsproxy);
>> >
>> > 		new_nsproxy = create_new_namespaces(...);
>> >
>> > 		if (clone_flags & CLONE_NEWNS)
>> > 			mntns_install(...);
>> > 		if (clone_flags & CLONE_NEWIPC)
>> > 			ipcns_install(...);
>> > 		...
>> > 	}
>> >
>> > I feel I missed something trivial, but what?
>> 
>> It is a question of naming.
>> 
>> The problem I set out to solve when all of this was introduced was how
>> to name namespaces without introducing yet another namespace.
>> 
>> The solution to the naming problem that I finally found was to  
>> introduce
>> something I could mount.
>
> Where might I find documentation on this? I'm aware of  
> Documentation/namespaces but it's only got one file in it (about  
> conflicts between namespace types). I'm aware of  
> http://lxc.sourceforge.net/index.php/about/kernel-namespaces/ and  
> http://lxc.sourceforge.net/man/ but that's mixed in with the  
> implementation details of a particular userspace tool, and tends to lag  
> the kernel significantly. (Those man pages were last updated in 2010,  
> which if I recall was the last time I poked them about it.)

I'm not certain what you are asking about.

The man pages that I endeavour to keep reasonably current are.

man 5 proc
man 2 setns
man 2 unshare
man 2 clone

You won't get a design discussion but you will get a description of how
the existing pieces work.  Of course now that I look it appears my
patches have not merged yet.  But that is reasonable since my recent
changes did not merge until a few days ago.

There is also iproute2 it's man pages and source.

There is the kernel source.

There are the occassional lwn articles.

I believe there should be a reasonable amount of email in the mailing
list archives when talking about the design descision, and when I
introduced setns.

Eric
