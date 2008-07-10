From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH 3/5] use next syscall data to predefine process ids
Date: Thu, 10 Jul 2008 02:36:19 -0700
Message-ID: <m1fxqi5be4.fsf@frodo.ebiederm.org>
References: <20080708112422.164370000@bull.net>
	<20080708112458.946320000@bull.net>
	<m1hcayfusi.fsf@frodo.ebiederm.org> <4875C932.2020503@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4875C932.2020503-6ktuUTfB/bM@public.gmane.org> (Nadia Derbey's message of "Thu, 10
	Jul 2008 10:32:50 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org> writes:

> If I correctly understood what you're saying, it means set min = max =
> target_pid using /proc/sys, i.e. for the whole system: don't you think this
> might be dangerous: allocating pids will fail for any other running process
> during the entire period of time where /proc/sys will be set like that.
> I really think this is a feature that should be confined to a process.

Well for a pid namespace, so that is more confined.
Grr.  We still need to move /proc/sys into /proc/<pid>/sys so it is
clear that sysctls are per namespace.

You are right that doing it that way has downsides.  In particular
it is hard to parallelize the restoration of a pid namespace.

However the interface does exist, and it didn't look like you were
reusing that code in your allocator.

It is my firm suspicion that restoring a process one syscall
at a time is too fine a granularity.  Certainly for the VM
of a process it is.

So here is my suggestion for now.  Take whatever approach you
are doing and make it work for you.  Go as far as you can
go and see what the pitfalls are.  Then on the 22nd we can
all get in a room and discuss things, and if we are lucky
agree on a path forward.

Eric
