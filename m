From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Wed, 09 Jan 2008 14:16:21 +0100
Message-ID: <E1JCan7-0005mP-UE@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080108214625.GE5050@ucw.cz> <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu> <20080108225820.GA9735@elf.ucw.cz> <E1JCWxm-0005Fn-36@pomaz-ex.szeredi.hu> <20080109113325.GC9735@elf.ucw.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753373AbYAINRe@vger.kernel.org>
In-reply-to: <20080109113325.GC9735@elf.ucw.cz> (message from Pavel Machek on
	Wed, 9 Jan 2008 12:33:25 +0100)
Sender: linux-kernel-owner@vger.kernel.org
To: pavel@ucw.cz
Cc: akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

> ...this will break with FUSE enabled, right? (Minor security hole by
> allowing users to stop c-a-delete, where none existed before?)

Yup (or I don't know, I'm sure there was or is some problem with
ptrace, that could be used to create unkillable processes).

Fuse could actually be fixed to exit reliably for 'killall5 -9' (it
used to), but that has other problems, and it doesn't seem very
important to me.  But this can be discussed.

What cannot be fixed is if one process is inside an fs operation
(e.g. unlink), holding a VFS lock (i_mutex) and another process goes
to uninterruptible sleep on that lock.  There's no way (other than
rewriting the VFS) in which that second process could be killed unless
you kill the first one or the fuse server.

> I'm currently suspending by 'echo "mem" > /sys/power/state'. How
> should I do that _safely_ with FUSE enabled?

You can't.  But that's only solvable with

 - rewrite of VFS (see above)
 - rewrite of freezer

> If I want to get rid of nasty user in multiuser system, I do 
> su nastyuser 'kill -9 -1' . How do I do the equivalent with FUSE
> enabled? (Without affecting other users?)

You can still do that.  If a process cannot be killed with 'kill -9',
due to being deadlocked with itself through fuse (not an easy feat to
accomplish), then it's not going to do any more harm, and you _can_
get rid of it by forced umounting the filesystem, or if it has been
detached, through the fusectl filesystem.

> Load average was never really meaningful number, but with FUSE
> enabled, users can set it to 666 without actually eating any CPU.
> 
> SIGSTOP used to work, allowing you to prevent user processes from
> working while you examine them. Now SIGSTOP can be delayed for
> arbitrary time.

Making filesystem operations restartable is not easy.  I would say
near impossible, but I haven't given a lot of enery into investigating.

> Heck, imagine malicious user process misbehaves. Before FUSE, you
> could at least attach it with gdb to look what it is doing. Now you
> can't.

Sure, but you can check in other ways (/proc/$PID/wchan), sysrq-t.

> I really believe FUSE vs. signals needs fixing. Either that, or
> updating all the manpages
> 
> man 1 kill:
> -       KILL       9   exit      this signal may not be blocked
> +       KILL       9   exit      this signal may not be blocked, except by FUSE user mount

Heh, there are all very interesting, but most of these issues are not
even on my todo list (which has grown into quite a big pile over the
years), which means, that they don't seem to matter to people in
practice.

You seem to be implying that fuse is worthless if these issues are not
fixed, but that is very far from the truth, I think.

Miklos
