From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 0/2] cr: Introduce s390x checkpoint/restart code
Date: Thu, 15 Jan 2009 10:29:43 -0600
Message-ID: <20090115162943.GA14103@us.ibm.com>
References: <20090115050523.GA10415@us.ibm.com>
	<1232012395.30152.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1232012395.30152.13.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Martin Schwidefsky (schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org):
> On Wed, 2009-01-14 at 23:05 -0600, Serge E. Hallyn wrote:
> > Hi,
> > 
> > here is a first stab at extending Oren's application c/r patchset
> > (http://lkml.org/lkml/2008/12/29/38) to s390.  I pretty much spent a day
> > or two looking through the s390 include and .S files and then took a
> > stab, so I won't be surprised to find these patches (and myself) the
> > subject of ridicule.  For instance, I'm really not *sure* whether I
> > should be backing up the acrs registers (some s390 docs suggested
> > userspace could use them), the ksp, or the vdso_base.  But one thing
> > I've got going for me at least...  it works!
> 
> The access registers need to be saved, a0/a1 contain the TLS pointer and
> the user can store anything to a2-a15. The ksp does not have to be
> stored as it cannot contain an important value. If it would then we'd

Ok, will drop the kso part.

> have kernel state which would break checkpoint/restart. The restart code
> needs to come up with a sensible initial value for ksp though. The
> vdso_base code needs to be stored as well. 

But the vdso is set up at exec() time, right?  So if I reset vdso_base
to the checkpointed value, might it actually end up at the wrong place,
since the exec() of the 'restart' program might have placed the vdso
at a different location than where it was at checkpoint time?

I also notice that on s390 vdso_base seems to always be either
20000020000 or 20000000000, and so far my checkpointed and restart
programs have always had 20000000000, so testing doesn't really help :)

-serge
