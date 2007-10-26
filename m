From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Q: How complete is the pid namespace in mainline
Date: Fri, 26 Oct 2007 17:09:26 -0600
Message-ID: <m14pgdxyl5.fsf@ebiederm.dsl.xmission.com>
References: <m1bqam4fpg.fsf@ebiederm.dsl.xmission.com>
	<20071026171718.GB11942@us.ibm.com>
	<m1r6jh211e.fsf@ebiederm.dsl.xmission.com>
	<20071026212959.GA15511@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071026212959.GA15511-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org's message
	of "Fri, 26 Oct 2007 14:29:59 -0700")
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

> Eric W. Biederman [ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org] wrote:
> | sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:
> | >
> | > Dave had suggested we print a warning the first time a container-init
> forks()
> | > without a handler for a fatal signal. I was planning on adding that as
> | > patch 4 of the signal patch set and get some feedback.
> | 
> | Yes.  How to cleanly handle signalling of container init is
> | a tricky one.  It does sound like you have made a reasonable start
> | there.
> | 
> | Suka it is a lot more then that.  How much more I'm not certain
> | of.  I suspect the only way to find the rest of the cases is
> | just go through the code with a fine tooth come and read and look.
>
> I agree. I did not mean to ignore the kthread conversions and was only
> referring to the core pid namespace clone stuff.

Sure, and that make sense.

> | So far doing that it has not at all hard for me to find either
> | bugs or places where the implementation can be improved.
> | 
> | Currently we have little things like kill(-1,...) signalling the
> | wrong set of processes, and a couple of proc bugs.
>
> I just realized the fix for this is in the signal patchset I was
> referring to.
>
> https://lists.linux-foundation.org/pipermail/containers/2007-August/006987.html
>
> I notice that you have sent a patch for the kill -1.

Yes. I'm trying to get out as many simple little bug fixes
as I can.

Sorry for missing the fact you guys had generated some patches
to address this.  Still I think mine is a little more comprehensive
and shorter ;)

That bug is on my list of really nasty bugs I want to avoid.

> The proc_mnt bug Linus found seems to have slipped through when
> merging Pavel's and my patches.

I really don't mind a handful of little bugs, it would be
surprising if something hadn't slipped through at this point.

As long as everyone is aware that it is going to take a bit
to find everything and stabilizing it all and everyone keeps
looking we should be fine.

Oh.  Do you know if there was a good reason for forcing
the tty, session, and process group of a the first process
in a pid namespace?

Eric
