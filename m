From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC] syslog ns proof of concept
Date: Fri, 16 Nov 2012 22:08:33 -0800
Message-ID: <87pq3c223i.fsf@xmission.com>
References: <20121117002519.GA26782@sergelap> <87haoo3opt.fsf@xmission.com>
	<20121117040200.GA24079@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121117040200.GA24079-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Sat, 17 Nov 2012 04:02:00 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, =?utf-8?Q?St=C3=A9phane?= Graber <stephane.graber-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
>> 
>> > Introduce a system log namespace.  The syslog ns is tied to a user
>> > namespace.  You must create a new user namespace before you can create a
>> > new sylog ns.  The syslog ns is created through a new command (11) to
>> > the __NR_syslog system call.
>> >
>> > Once a task enters a new syslog ns, it's "dmesg", "dmesg -c" and
>> > /dev/kmsg actions affect only itself, so that user-created syslog
>> > messages no longer are confusingly combined in the host's syslog.
>> > "printk" itself always goes to the initial syslog_ns, and consoles
>> > belong only to the initial syslog_ns.  However printks relating to a
>> > specific network namespace, for instance, can now be targeted to the
>> > syslog ns for the user ns which owns the network ns, aiding in debugging
>> > in a container.
>> >
>> > This patch is on top of the user namespace enhanced kernel at
>> > git://kernel.ubuntu.com/serge/quantal-userns.  It is good enough to
>> > compile with stock ubuntu kernel options, boot, launch other syslog
>> > namespaces and exercise them.  It will need help before it will compile
>> > with funky options like CONFIG_PRINTK=n.  This is only being sent out to
>> > get feedback on the general idea.
>> >
>> > Comments greatly appreciated.
>> >
>> > (See https://wiki.ubuntu.com/LxcSyslogNs for background).
>> 
>> Overall I would say the goal sounds well thought out.
>> 
>> I am not a fan of how this ties into the user namespace.  I would prefer
>> closer or looser ties.  The recursive reference count loop where a
>> userns refers to a syslogns and that syslogns refers to the same userns
>> is unpleasant.
>
> We could make the nsproxy point to the syslog_ns, but this seemed simpler.
> Note that the syslog_ns does not need to pin the user_ns, since by design
> the user_ns owning a syslog_ns can't go away if the syslog_ns is still
> alive.
>
> But yes, the question of "what should point to the syslog_ns" is what has
> kept a syslog_ns from being seriously proposed since february 2010 :)
>
> Hm, wait.  A nagging feeling made me look back, and I see that I do in
> fact pin the user_ns from the syslog_ns.  I didn't mean to (and I don't
> release it :)  and we don't need to.  When a syslog_ns is created, it
> can only be inherited by child user_ns's, and its owner, the parent user_ns,
> can never go away until the child user_ns's go away.

There is an argument to be made that syslog messages are the kind of
security identifiers like uid, gids, and keys that should be part of a
user namespace.  I'm not fully convinced but there are some DOS attacks
that would naturally prevent.

>> The important case as I understand it is to handle injection of messages
>> into dmesg by userspace?
>
> 1. injection of messages into dmesg by userspace, 2. clearing of messages
> by userspace, but also 3. allowing appropriate kernel printks to be
> targeted to containers.
>
>> I would really like to see how messages from networking devices and
>> netfilter would be handled.  Right now one of the ugliest bits of
>
> It would simply replace a
> 	printk(KERN_NOTICE "doing something\n");
> with
> 	nsprintk(net->user_ns->syslog_ns, KERN_NOTICE "doing something\n");
>
> I'm not yet clear on whether we'd want nsprintk to print to both the
> init_syslog_ns (with a ns prefix) and the child ns.

There are some specialized forms of printk like dev_printk and in
particular netdev_printk that it would be very interesting if they
did the work behind the scenes.  So that you could code the obvious
thing and it would do the right thing automatically.

>> lowering the permissions in the network namespace is what do about the
>> commands that set the message loglevel.
>
> Here I'm not sure what you mean.

There is a possible DOS attack that by turning on debug messages in a
user namespace you can overwhelm syslog.

>> In general unless we can safely and sanely direct kernel messages into
>> this new dmesg I don't actually see the point of having another ring
>> buffer in the kernel.  If the only success is userspace having the
>> syslog facility simply be unavailable seems more palatable.
>
> No I didn't do any in this patch, but directing kernel messages into the
> new dmesg was definately a goal and should be trivial now.

Getting the semantics of which kernel messages should be directed at the
new ring buffer and what that means seems to me to be a key factor in
seeing how practical this is.  Otherwise this seems to call out for a
change in userspace.

Certainly inside a user namespace now you can't destructively touch the
kernel's syslog at all.

Eric
