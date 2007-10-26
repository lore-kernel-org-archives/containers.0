From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Q: How complete is the pid namespace in mainline
Date: Fri, 26 Oct 2007 12:17:33 -0600
Message-ID: <m1r6jh211e.fsf@ebiederm.dsl.xmission.com>
References: <m1bqam4fpg.fsf@ebiederm.dsl.xmission.com>
	<20071026171718.GB11942@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071026171718.GB11942-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org's message
	of "Fri, 26 Oct 2007 10:17:18 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:
>
> Dave had suggested we print a warning the first time a container-init forks()
> without a handler for a fatal signal. I was planning on adding that as
> patch 4 of the signal patch set and get some feedback.

Yes.  How to cleanly handle signalling of container init is
a tricky one.  It does sound like you have made a reasonable start
there.

Suka it is a lot more then that.  How much more I'm not certain
of.  I suspect the only way to find the rest of the cases is
just go through the code with a fine tooth come and read and look.

So far doing that it has not at all hard for me to find either
bugs or places where the implementation can be improved.

Currently we have little things like kill(-1,...) signalling the
wrong set of processes, and a couple of proc bugs.

That autofs and coda out on the fringe don't quite do the right
thing in the presence of multiple pid namespaces isn't a big
surprise, little details like that are easy to overlook.

We of course still have the kthread issue where we can get
kernel threads trapped and we have kernel threads calling
kill_proc, keeping us from removing it.

There is all cap_set_all which isn't filtering by pid namespace.

Then we have the unix domain sockets that don't appear to do the
right thing when passing credentials across pid namespaces.  I
think we may have the same issues with signals as well.

Anyway I can find a lot issues like that without trying very
hard.  Which suggests to me that there are issues that I'm missing
that are out there as well.

So it appears there is lots of cleanup work to do.

Eric
