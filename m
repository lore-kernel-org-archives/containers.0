From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC] syslog ns proof of concept
Date: Fri, 16 Nov 2012 19:14:38 -0800
Message-ID: <87haoo3opt.fsf@xmission.com>
References: <20121117002519.GA26782@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121117002519.GA26782@sergelap> (Serge Hallyn's message of
	"Fri, 16 Nov 2012 18:25:19 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, =?utf-8?Q?St=C3=A9phane?= Graber <stephane.graber-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> Introduce a system log namespace.  The syslog ns is tied to a user
> namespace.  You must create a new user namespace before you can create a
> new sylog ns.  The syslog ns is created through a new command (11) to
> the __NR_syslog system call.
>
> Once a task enters a new syslog ns, it's "dmesg", "dmesg -c" and
> /dev/kmsg actions affect only itself, so that user-created syslog
> messages no longer are confusingly combined in the host's syslog.
> "printk" itself always goes to the initial syslog_ns, and consoles
> belong only to the initial syslog_ns.  However printks relating to a
> specific network namespace, for instance, can now be targeted to the
> syslog ns for the user ns which owns the network ns, aiding in debugging
> in a container.
>
> This patch is on top of the user namespace enhanced kernel at
> git://kernel.ubuntu.com/serge/quantal-userns.  It is good enough to
> compile with stock ubuntu kernel options, boot, launch other syslog
> namespaces and exercise them.  It will need help before it will compile
> with funky options like CONFIG_PRINTK=n.  This is only being sent out to
> get feedback on the general idea.
>
> Comments greatly appreciated.
>
> (See https://wiki.ubuntu.com/LxcSyslogNs for background).

Overall I would say the goal sounds well thought out.

I am not a fan of how this ties into the user namespace.  I would prefer
closer or looser ties.  The recursive reference count loop where a
userns refers to a syslogns and that syslogns refers to the same userns
is unpleasant.

The important case as I understand it is to handle injection of messages
into dmesg by userspace?

I would really like to see how messages from networking devices and
netfilter would be handled.  Right now one of the ugliest bits of
lowering the permissions in the network namespace is what do about the
commands that set the message loglevel.

In general unless we can safely and sanely direct kernel messages into
this new dmesg I don't actually see the point of having another ring
buffer in the kernel.  If the only success is userspace having the
syslog facility simply be unavailable seems more palatable.

Eric
