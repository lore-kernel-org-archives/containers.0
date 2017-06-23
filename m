From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] Enable namespaced file capabilities
Date: Fri, 23 Jun 2017 11:30:30 -0500
Message-ID: <20170623163030.GA18820__47979.7605461956$1498235434$gmane$org@mail.hallyn.com>
References: <1498157989-11814-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<CAOQ4uxj=_Riih1K+QOYasZU8vZKCSrsg393f=17mJ2O-909e=Q@mail.gmail.com>
	<20170623160026.GA18257@mail.hallyn.com>
	<aa62373e-7cd6-39dd-2e38-2b6d6dbe18a8@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <aa62373e-7cd6-39dd-2e38-2b6d6dbe18a8-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Cc: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org):
> On 6/23/2017 9:00 AM, Serge E. Hallyn wrote:
> > Quoting Amir Goldstein (amir73il-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> >> On Thu, Jun 22, 2017 at 9:59 PM, Stefan Berger
> >> <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >>> This series of patches primary goal is to enable file capabilities
> >>> in user namespaces without affecting the file capabilities that are
> >>> effective on the host. This is to prevent that any unprivileged user
> >>> on the host maps his own uid to root in a private namespace, writes
> >>> the xattr, and executes the file with privilege on the host.
> >>>
> >>> We achieve this goal by writing extended attributes with a different
> >>> name when a user namespace is used. If for example the root user
> >>> in a user namespace writes the security.capability xattr, the name
> >>> of the xattr that is actually written is encoded as
> >>> security.capability@uid=1000 for root mapped to uid 1000 on the host.
> >>> When listing the xattrs on the host, the existing security.capability
> >>> as well as the security.capability@uid=1000 will be shown. Inside the
> >>> namespace only 'security.capability', with the value of
> >>> security.capability@uid=1000, is visible.
> >>>
> >> Am I the only one who thinks that suffix is perhaps not the best grammar
> >> to use for this namespace?
> > You're the only one to have mentioned it so far.
> >
> >> xattrs are clearly namespaced by prefix, so it seems right to me to keep
> >> it that way - define a new special xattr namespace "ns" and only if that
> >> prefix exists, the @uid suffix will be parsed.
> >> This could be either  ns.security.capability@uid=1000 or
> >> ns@uid=1000.security.capability. The latter seems more correct to me,
> >> because then we will be able to namespace any xattr without having to
> >> protect from "unprivileged xattr injection", i.e.:
> >> setfattr -n "user.whatever.foo@uid=0"
> > I like it for simplifying the parser code.  One concern I have is that,
> > since ns.* is currently not gated, one could write ns.* on an older
> > kernel and then exploit it on a newer one.
> 
> security.ns.capability@uid=1000, then?

That loses the advantage of simpler parsing though.  (Really it's not much
of a simplification anyway.)  So I'm not sure what advantage remains.

> Or maybe just security.ns.capability, taking James' comment into account.

That last one may be suitable as an option, useful for his particular
(somewhat barbaric :) use case, but it's not ok for the general solution.

If uid 1000 was delegated the subuids 100000-199999, it should be able
to write a file capability for use by his subuids, but that file capability
must not apply to other subuids.

-serge
