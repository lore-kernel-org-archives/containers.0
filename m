From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: c/r rebase to 2.6.33-rc5
Date: Fri, 5 Feb 2010 08:57:22 -0600
Message-ID: <20100205145722.GA6685@us.ibm.com>
References: <4B6B04E7.9080704@cs.columbia.edu>
	<20100205014009.GA5474@us.ibm.com>
	<4B6C2EFA.3050703@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B6C2EFA.3050703-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >> I rebased the most recent patchset to 2.6.33, and pushed to
> >> ckpt-v19-rc2.10. only x86-32 is (lightly) tested.
> >>
> >> it does not include patches from 1/27 and on. working on it
> >> now.
> >>
> >> please review:
> >>
> >> * arch-specific parts that I didn't screw up anything.
> >> btw, I moved checkpoint code from mm/ to kernel/
> >>
> >> * [dan] network: net/checkpoint.c now uses sock_alloc_file();
> >> there may or may not be a leak of sock_hold().
> >>
> >> * [serge] selinux now auto-generates some include files, see
> >> the changes to classmap.h
> >>
> >> Oren.
> > 
> > For x86-64, I needed the following patch.  With this patch, only
> > the fileio and futex tests failed.  Suka is looking into the fileio
> > failure - Matt you might check the futex tests on whatever arch
> > you have available...
> > 
> > For s390, I of course still need
> > "fix 31-bit s390 checkpoint/restart wrappers" for compile with
> > CONFIG_COMPAT to succeed.
> 
> Ok, fixed, and pushed to ckpt-v19-rc2.10.
> If this is more or less ok, I'll change it to ckpt-v19-rc3 :)

My git tree isn't happy with whatever rebasing you did.  Can
you push a ckpt-v19-rc2.11 tag or just ckpt-v19-rc3?

I haven't looked at the selinux issue at all yet btw, and I'd
like to hear if anyone has figured out the issue with a pipe
being treated as Unlinked file in the robust futex testcase.
Matt?

-serge
