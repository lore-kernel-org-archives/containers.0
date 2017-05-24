From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Date: Wed, 24 May 2017 03:26:45 -0500
Message-ID: <87k256ek3e.fsf@xmission.com>
References: <1495554267.27369.9.camel@HansenPartnership.com>
	<87zie3mxkc.fsf@xmission.com>
	<f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de>
	<149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
	<1495472039.2757.19.camel@HansenPartnership.com>
	<2446.1495551216@warthog.procyon.org.uk>
	<2961.1495552481@warthog.procyon.org.uk> <87bmqjmwl5.fsf@xmission.com>
	<3860.1495557363@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <3860.1495557363-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org> (David Howells's message
	of "Tue, 23 May 2017 17:36:03 +0100")
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
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> wrote:
>
>> What David is pointing out is that the kernel has a DNS cache
>> (net/dns_resolver/) it can do name to IP translations, but isn't
>> namespaced.  Once it has one entry all containers would see it if they
>> cause a lookup to go through the kernel cache, so going through the
>> cache you can't have a name resolving to different IP addresses on a
>> per container basis.
>
> Yes - and the transport to userspace, the request_key() upcall, isn't
> namespaced either.  Namespacing it isn't entirely simple since we have to set
> the right mount namespace (for execve, config, etc.), plus any other relevant
> namespaces (such as network) - which is dependent on key type.
>
> I can't record the mount namespace in the network namespace because that would
> create a dependency loop:
>
> 	mnt_ns -> mnt -> sb -> net_ns -> mnt_ns

I have already given a concrete suggest on how this might be untangled.
So I won't repeat it here.

>> I think Eric's point is that if you need the same DNS names resolving
>> to different IP addresses on a per container basis, you can do this in
>> userspace today but you have to disable the in-kernel DNS cache.
>
> You could disable the in-kernel dns resolver in your config, but then you
> don't get referrals in NFS.  Also, CIFS, AFS and other filesystems would be
> affected.  If you're fine with the restrictions, then there is no
> problem.


I haven't been arguing that at all.  I was only pointing out that this
issue is not an issue with DNS.  Userspace handles this all fine.
The issue is exclusively with this request_key api and generally user
mode upcalls.

I have no problem seeing that there is an issue with the kernel code.
I am well aware of the problem.  Unfortunately the people who cared
enough to start addressing this have not been able to write kernel
code that fixes this.

My personal experience when I tried to use the request_key api at
the beginning of this was it was too hard to test.  There was no room
for goofing up as at that time it was impossible to invalidate a cached
reply from userspace if you happened to know it was wrong.  Which meant
that if something incorrect was cached it required rebooting the kernel.

I have a lot of sympathy with the view that the best way to do
some of this is with socket activations or perhaps something with rpc
portmapper.  Where something like inetd is used to start the user space
component on-demand.  I won't call that a solution to this case but I do
think it makes a good example to compare with.

When you need run something in a clean context having that something
only need to worry about the contents of the data it is receiving and
not about it's environment as suid applications do is a nice
simplification.

The entire user mode helper paradigm removes from user space the freedom
to specify what context it's code should run in.  In a world where
everything is global that is fine.  But in a world with containers where
not everything is global it becomes a royal pain.

And I am very very sympathetic to solving this.  The only solution that
I know would work is to capture the context at some point in a process
and then to use that process to fork user mode helpers.

So far no one has even bothered to seriously try the one solution that
is guaranteed to work because it takes a lot of changes to kernel code.
I believe the last effort snagged on what a pain it is to refactor the
user mode helper infrastructure.

I don't see in your code any of that work.

I am glad to see that you also see the problem.  At least when it comes
to the request_key api.

What I am hoping to see is someone who has the will to dig in and
understand all of the interactions and refactor the kernel to solve
the problem.

This is not a case where our user space interfaces are preventing a
solution to this problem (as your patchset implies).  This is a case
where things need to be refactored kernel side to solve this.

So far this attempt is just another in the bazillion or so bad
half-assed attempts to solve this problem I have seen over the years.

Eric
