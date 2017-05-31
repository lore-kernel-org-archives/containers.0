From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH] KEYS: Allow a live daemon in a namespace to service
	request_key upcalls
Date: Wed, 31 May 2017 15:47:45 +0100
Message-ID: <3412.1496242065@warthog.procyon.org.uk>
References: <1496239145.289295.994170312.57409998@webmail.messagingengine.com>
	<149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1496239145.289295.994170312.57409998-2RFepEojUI2N1INw9kWLP6GC3tUn3ZHUQQ4Iyu8u01E@public.gmane.org>
Content-ID: <3411.1496242065.1-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
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

> > 	KEY_SERVICE_NS_UTS
> > 	KEY_SERVICE_NS_IPC
> > 	KEY_SERVICE_NS_MNT
> > 	KEY_SERVICE_NS_PID
> > 	KEY_SERVICE_NS_NET
> > 	KEY_SERVICE_NS_CGROUP
> 
> Any reasons not to reuse the CLONE_ flags?

Yes.  Most of the CLONE_* flags are completely irrelevant here.

> > which select those namespaces of the caller that must match for the daemon
> > to be given the request.  So, for example, a daemon that wanted to service
> > DNS requests from the kernel would do something like:
> > 
> > 	keyctl(KEYCTL_SERVICE_ADD, fd, "dns_resolver", KEY_SERVICE_NS_NET);
> 
> At least to me, it's not clear what the use cases really are.  Do we expect
> people to e.g. set up NFS mounts that require keys/DNS inside "a container"

Separate NFS mounts in separate net namespaces have separate superblocks.
That's enforced in the kernel right now.  However, they currently still share
a DNS cache and an idmapper cache - which they should not.

Note that this patch *only* requires that if you use the filter, then an NFS
superblock must be in the same net namespace as the service daemon that's
handling its DNS.  The program using files from the superblock doesn't have to
share a net namespace with it - though that might be considered odd.

> (and if in a container, with what namespaces?)

Linux doesn't have a container object.  I proposed one, but people objected
vociferously.

> So if the mount-in-container is mostly init containers, and for init
> containers you have *all* namespaces usually, does it make
> sense to have the capability to match namespaces for key services?

Yes.

If I don't provide it, someone will complain that I haven't provided it.

> Something that worries me a lot here is for e.g. Docker today, the default
> is uid 0 but not CAP_SYS_ADMIN.  We don't want a container that I run
> with --host=net to be able to read the "host" keyrings, even if it shares
> the host network namespace.

This is a separate issue.

> Today for Docker the default seccomp policy prevents access to keyctl()
> at all because it's only with user namespaces that the kerying is namespaced.

Keys may be relevant in different namespaces, which makes namespacing them
hard to achieve.  For instance, dns-, idmapper- and rxrpc-type keys should
probably be differentiated by network namespace.

However, it might be worth creating a keyrings namespace.

> Basically my instinct here is to be conservative and have KEYCTL_SERVICE_ADD
> require CAP_SYS_ADMIN and only affect the userns keyring.

"Affect" in what sense?

David
