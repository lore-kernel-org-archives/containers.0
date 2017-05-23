From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Date: Tue, 23 May 2017 15:53:36 +0100
Message-ID: <2446.1495551216__27088.1503391594$1495551230$gmane$org@warthog.procyon.org.uk>
References: <f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de>
	<149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
	<1495472039.2757.19.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <f167feeb-e653-12e3-eec8-24162f7f7c07-l3A5Bk7waGM@public.gmane.org>
Content-ID: <2442.1495551216.1-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
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
Cc: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org> wrote:

> >> The reason I think this is necessary is that the kernel has no idea
> >> how to direct upcalls to what userspace considers to be a container -
> >> current Linux practice appears to make a "container" just an
> >> arbitrarily chosen junction of namespaces, control groups and files,
> >> which may be changed individually within the "container".
> 
> Just want to point out that if the kernel APIs for containers massively
> change, then the OCI will have to completely rework how we describe containers
> (and so will all existing runtimes).
> 
> Not to mention that while I don't like how hard it is (from a runtime
> perspective) to actually set up a container securely, there are undoubtedly
> benefits to having namespaces split out. The network namespace being separate
> means that in certain contexts you actually don't want to create a new network
> namespace when creating a container.

Yep, I quite agree.

However, certain things need to be made per-net namespace that *aren't*.  DNS
results, for instance.

As an example, I could set up a client machine with two ethernet ports, set up
two DNS+NFS servers, each of which think they're called "foo.bar" and attach
each server to a different port on the client machine.  Then I could create a
pair of containers on the client machine and route the network in each
container to a different port.  Now there's a problem because the names of the
cached DNS records for each port overlap.

Further, the NFS idmapper needs to be able to direct its calls to the
appropriate network.

> I had some ideas about how you could implement bridging in userspace (as an
> unprivileged user, for rootless containers) but if you can't join namespaces
> individually then such a setup is not practically possible.

I'm not proposing to take away the ability to arbitrarily set the namespaces
in a container.  I haven't implemented it yet, but it was on the to-do list:

 (7) Directly set a container's namespaces to allow cross-container
     sharing.

David
