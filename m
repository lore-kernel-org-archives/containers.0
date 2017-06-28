From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] Enable namespaced file capabilities
Date: Wed, 28 Jun 2017 00:41:38 -0500
Message-ID: <20170628054138.GA15939__35174.7399931357$1498628504$gmane$org@mail.hallyn.com>
References: <1498157989-11814-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<CAOQ4uxj=_Riih1K+QOYasZU8vZKCSrsg393f=17mJ2O-909e=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOQ4uxj=_Riih1K+QOYasZU8vZKCSrsg393f=17mJ2O-909e=Q@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Amir Goldstein <amir73il-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jun 23, 2017 at 10:01:46AM +0300, Amir Goldstein wrote:
> On Thu, Jun 22, 2017 at 9:59 PM, Stefan Berger
> <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > This series of patches primary goal is to enable file capabilities
> > in user namespaces without affecting the file capabilities that are
> > effective on the host. This is to prevent that any unprivileged user
> > on the host maps his own uid to root in a private namespace, writes
> > the xattr, and executes the file with privilege on the host.
> >
> > We achieve this goal by writing extended attributes with a different
> > name when a user namespace is used. If for example the root user
> > in a user namespace writes the security.capability xattr, the name
> > of the xattr that is actually written is encoded as
> > security.capability@uid=1000 for root mapped to uid 1000 on the host.
> > When listing the xattrs on the host, the existing security.capability
> > as well as the security.capability@uid=1000 will be shown. Inside the
> > namespace only 'security.capability', with the value of
> > security.capability@uid=1000, is visible.
> >
> 
> Am I the only one who thinks that suffix is perhaps not the best grammar
> to use for this namespace?
> xattrs are clearly namespaced by prefix, so it seems right to me to keep
> it that way - define a new special xattr namespace "ns" and only if that
> prefix exists, the @uid suffix will be parsed.
> This could be either  ns.security.capability@uid=1000 or
> ns@uid=1000.security.capability. The latter seems more correct to me,
> because then we will be able to namespace any xattr without having to
> protect from "unprivileged xattr injection", i.e.:
> setfattr -n "user.whatever.foo@uid=0"
> 
> Amir.

Hi Amir,

I was liking the prefix at first, but I'm actually not sure it's worth
it.  THe main advantage would be so that checking for namespace or other
tags could be done always at the same offset simplifying the parser.
But since we will want to only handle namespacing for some tags, and
potentially differently for each task, it won't actually be simpler, I
don't think.

On the other hand we do want to make sure that the syntax we use is
generally usable, so I think simply specifying that >1 tags can each
be separate by '@' should suffice.  So for now we'd only have

	security.capability@uid=100000

soon we'd hopefully have

	security.ima@uid=100000

and eventually trusted.blarb@foo=bar

-serge
