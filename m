From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] Enable namespaced file capabilities
Date: Fri, 23 Jun 2017 13:22:12 -0500
Message-ID: <20170623182212.GA19847@mail.hallyn.com>
References: <1498157989-11814-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<CAOQ4uxj=_Riih1K+QOYasZU8vZKCSrsg393f=17mJ2O-909e=Q@mail.gmail.com>
	<20170623160026.GA18257@mail.hallyn.com>
	<aa62373e-7cd6-39dd-2e38-2b6d6dbe18a8@schaufler-ca.com>
	<20170623163030.GA18820@mail.hallyn.com>
	<1498237641.3641.15.camel@HansenPartnership.com>
	<b57803da-0e8b-594d-901b-12eb509f04b5@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <b57803da-0e8b-594d-901b-12eb509f04b5-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Aleksa Sarai (asarai-l3A5Bk7waGM@public.gmane.org):
> >>>Or maybe just security.ns.capability, taking James' comment into
> >>>account.
> >>
> >>That last one may be suitable as an option, useful for his particular
> >>(somewhat barbaric :) use case, but it's not ok for the general
> >>solution.
> >>
> >>If uid 1000 was delegated the subuids 100000-199999, it should be
> >>able to write a file capability for use by his subuids, but that file
> >>capability must not apply to other subuids.
> 
> [As an aside, I think the delegation model of sub[ug]id is not the
> right way of thinking about these features. The properties of a file
> capability should be considered based on the user namespace it is
> being evaluated in, not who set the capability or delegated the
> [ug]ids. I might be misunderstanding the problem though.]
> 
> >I don't think it's barbaric, I think it's the common use case.  Let me
> >give a more comprehensible answer in terms of docker and IMA.  Lets
> >suppose I'm running docker locally and in a test cloud both with userns
> >enabled.
> >
> >I build an image locally, mapping my uid (1000) to root.  If I begin
> >with a standard base, each of the files has a security.ima signature.
> >  Now I add my layer, which involves updating a file, so I need to write
> >a new signature to security.ima.  Because I'm running user namespaced,
> >the update gets written at security.ima@uid=1000 when I do a docker
> >save.
> >
> >Now supposing I deploy that image to a cloud.  As a tenant, the cloud
> >gives me real uid 4531 and maps that to root.  Execution of the binary
> >fails because it tries to use the underlying signature (in
> >security.ima) as there is no xattr named security.ima@uid=4531
> >
> >So my essential point is that building the real kuid into the permanent
> >record of the xattr damages image portability, which is touted as one
> >of the real advantages of container images.

I didn't address this in my reply to James, but maybe I should have.

'container images' are a higher level marketing slogan^W^W concept.
Not a kernel concept.

The kernel does not have a concept of fluid uids, or fluid kuids, so
demanding that xattrs be fluid in this way seems wrong.

As it is, 'shiftfs' is not upstream, so the more basic problems of
container images or not solved in the way you'd like either.

Certainly we want to make this as useful as possible to container
images, but that only goes to a point.

I'm open to good ideas for solving this issue we're discussing here,
but that will not include allowing an unprivileged user to write
an xattr which can give privilege to containers over which he does
not have privilege.

The core problem is "how do we allow the delegation of this privilege
on persistent disk without that privilege leaking".  As Casey had said
we would ideally be able to refer to a 'container' itself, instead of
the root kuid.  That *would* be better.  But that does not exist.

It also doesn't stand in the way of my use case.  My use case is fully
unprivileged containers.  Where I want to install/upgrade software
using file capabilities.  Currently I cannot do that.  With either this
patch or my own namespaced filecaps patch, I can, safely.  If I want to shift
the container's backing uids, then I have to create transient namespaces in
which do the uid shifting, and I can just as well do the xattr shifting there
as well, just as I have to re-set setuid/setgid etc.

> Definitely. This is somewhat of a similar issue to shiftfs (that the
> {uid,gid} being hardcoded in images makes it very difficult to make
> user namespaced containers work sanely).
> 
> Since OCI images are all basically a set of tar archives with JSON
> manifests, to make things like this work nicely for container images
> it just has to avoid hardcoding kuid (or even userspace uids) into
> attributes. It is possible for us to write special-case translation
> code for images, but that will cause the same issues that shiftfs is
> trying to resolve.

It would add another issue analogous to the ones shiftfs is trying to
solve, so the question is can shifts solve it?  

-serge
