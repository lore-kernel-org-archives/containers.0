From: Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH] KEYS: Allow a live daemon in a namespace to service
	request_key upcalls
Date: Wed, 31 May 2017 11:36:19 -0400
Message-ID: <1496244979.313075.994296480.7C5735E8__29489.4681116149$1496244993$gmane$org@webmail.messagingengine.com>
References: <1496239145.289295.994170312.57409998@webmail.messagingengine.com>
	<149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk>
	<3412.1496242065@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <3412.1496242065-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 31, 2017, at 10:47 AM, David Howells wrote:


> > So if the mount-in-container is mostly init containers, and for init
> > containers you have *all* namespaces usually, does it make
> > sense to have the capability to match namespaces for key services?
> 
> Yes.
> 
> If I don't provide it, someone will complain that I haven't provided it.

I don't think it's as clear cut as that.  I'd agree that where possible, it makes
sense to be general since it's hard to envision every use case, but in this particualr
case there are risks around security and clear maintenance issues.  Providing
a feature without *known* users in a security-sensitive context seems to
me to be something to think twice about.

> > Something that worries me a lot here is for e.g. Docker today, the default
> > is uid 0 but not CAP_SYS_ADMIN.  We don't want a container that I run
> > with --host=net to be able to read the "host" keyrings, even if it shares
> > the host network namespace.
> 
> This is a separate issue.

Kind of - what I'm getting at is that today, changing any of the kernel
upcalls is a fully privileged operation.  Most container userspace tools
mount /proc read-only to ensure that even uid 0 containers can't change it
by default.

(Wait, is /sbin/request-key really hardcoded in the kernel?  I guess that's
 good from the perspective of not having containers be able to change it 
 like they could /proc/sys/kernel/core_pattern if it was writable, but
 it seems surprising)

Anyways, if we now expose a method to configure this, we have to look
at the increase in attack surface.

In practice again, most container implementations I'm aware of use
seccomp today to simply block off access to the keyring.   As I mentioned
Docker does it, so does flatpak:
https://github.com/flatpak/flatpak/blob/ea7077fcd431fb98fe85cd815cbd2ec13df58d09/common/flatpak-run.c#L4007
and Chrome:
https://cs.chromium.org/chromium/src/sandbox/linux/seccomp-bpf-helpers/syscall_sets.cc?q=keyctl&dr=C&l=791

But I'm a bit uncertain about *relying* on the seccomp filtering.  Particularly
because we do want the "init container" approach to work and be able
to use the kernel keyring, but also not be able to affect other containers
or the host.

> Keys may be relevant in different namespaces, which makes namespacing them
> hard to achieve.  For instance, dns-, idmapper- and rxrpc-type keys should
> probably be differentiated by network namespace.
> 
> However, it might be worth creating a keyrings namespace.

Hm, yes - I think I was conflating CLONE_NEWUSER with uid 0's keyring
but that's a distinct thing from the kernel keyrings.

> > Basically my instinct here is to be conservative and have KEYCTL_SERVICE_ADD
> > require CAP_SYS_ADMIN and only affect the userns keyring.
> 
> "Affect" in what sense?

Operate on at all - view/read/write/search etc.

At a high level I'm glad you're looking at the "service fd" model instead of
upcalls - I do think it'll get us to a better place.  The main thing I'm getting
at first though is making sure we're not introducing new security issues, and that the
new proposed API makes sense for some of the important userspace use cases.
