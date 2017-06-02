From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH] KEYS: Allow a live daemon in a namespace to service
	request_key upcalls
Date: Fri, 02 Jun 2017 17:34:14 +0100
Message-ID: <2137.1496421254__23027.5955902927$1496421287$gmane$org@warthog.procyon.org.uk>
References: <1496244979.313075.994296480.7C5735E8@webmail.messagingengine.com>
	<1496239145.289295.994170312.57409998@webmail.messagingengine.com>
	<149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk>
	<3412.1496242065@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1496244979.313075.994296480.7C5735E8-2RFepEojUI2N1INw9kWLP6GC3tUn3ZHUQQ4Iyu8u01E@public.gmane.org>
Content-ID: <2136.1496421254.1-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>
Cc: James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org> wrote:

> Providing a feature without *known* users in a security-sensitive context
> seems to me to be something to think twice about.

Ummm...  Kernel DNS lookups, NFS idmapper upcalls.  CIFS could use it too.

> Kind of - what I'm getting at is that today, changing any of the kernel
> upcalls is a fully privileged operation.

Yes.  Upcalls are more secure but finding out the collection of namespaces in
which to run an upcall is a real pain - and Eric's 'concrete' method doesn't
actually work.

> (Wait, is /sbin/request-key really hardcoded in the kernel?  I guess that's
>  good from the perspective of not having containers be able to change it 
>  like they could /proc/sys/kernel/core_pattern if it was writable, but
>  it seems surprising)

Namespaces didn't exist at the time.

> Anyways, if we now expose a method to configure this, we have to look
> at the increase in attack surface.

To quote:

> In practice again, most container implementations I'm aware of use
> seccomp today to simply block off access to the keyring.

We're going to have to deal with that, but it's going to take some support on
the kernel side.  I think it may require a 'key' namespace - but that's going
to have potentially difficult interactions with the 'net' namespace for
network filesystems where your process's key and net namespaces are different
to the that of the superblock you're trying to access.

> > > Basically my instinct here is to be conservative and have
> > > KEYCTL_SERVICE_ADD require CAP_SYS_ADMIN and only affect the userns
> > > keyring.

Sorry, what 'userns' keyring?

> At a high level I'm glad you're looking at the "service fd" model instead of
> upcalls - I do think it'll get us to a better place.

I disagree, but it may be the only way, given the unholy mess in which the
Linux 'container' system works.

David
