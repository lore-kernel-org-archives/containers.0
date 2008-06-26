From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11] sysfs: user namespaces: fix bug with
	clone(CLONE_NEWUSER) with fairsched
Date: Thu, 26 Jun 2008 08:07:52 -0500
Message-ID: <20080626130752.GA11002@us.ibm.com>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<20080618170731.746054454@theryb.frec.bull.fr>
	<485F0812.4090903@gmail.com> <20080625184409.GA8353@us.ibm.com>
	<m1wskd43uc.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1wskd43uc.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Except the sysfs mount holds no refcount on the userns.  So as long as we
> > do the ida tagging as you suggested in your response to patch 6, there
> > should be no reference to the user_ns left in sysfs code.
> >
> > The extra reference in patch #9 is for a light ref on the network
> > namespace.  I'm still not sure that needs to be there, since if the
> > network namespace goes away, it will properly unregister its sysfs
> > mounts.  Eric, Benjamin, I really don't see any use for the hold_net()
> > from sysfs.  What is it doing?
> 
> Mostly just being a sanity check.  We can remove that if it easier.
> 
> Eric

In itself it seems an ok check (temporarily) to make sure that the
net_ns hook to unset the tag.netns at netns release is properly working,
but given that it's only checking for net_ns coding errors, and Tejun
wants a whole generic hooking infrastructure for net_ns to register with
so as to keep mention of net_ns out of sysfs code, yeah I think the sane
thing is to just remove it.

But the first thing (after Daniel is finished with the patch 5 fallout)
is to address the patch 6 comments about using ida.  At first I didn't
like it (seemed like too much bookkeeping) but I think it'll actually
work out very nicely.

-serge
