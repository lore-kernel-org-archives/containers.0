From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] uts_namespace: Move boot_id in uts namespace
Date: Wed, 04 Apr 2018 19:35:46 -0500
Message-ID: <876056bicd.fsf@xmission.com>
References: <1522408620-10578-1-git-send-email-kernel@kyup.com>
	<87vad7hsdb.fsf@xmission.com>
	<e6fe4cc7-eed0-fbe2-98af-31c95e35805a@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e6fe4cc7-eed0-fbe2-98af-31c95e35805a-6AxghH7DbtA@public.gmane.org> (Marian Marinov's
	message of "Thu, 5 Apr 2018 02:43:00 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Marian Marinov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Marian Marinov <kernel-6AxghH7DbtA@public.gmane.org> writes:

> On 04/04/2018 07:02 PM, Eric W. Biederman wrote:
>> Angel Shtilianov <kernel-6AxghH7DbtA@public.gmane.org> writes:
>> 
>>> Currently the same boot_id is reported for all containers running
>>> on a host node, including the host node itself. Even after restarting
>>> a container it will still have the same persistent boot_id.
>>>
>>> This can cause troubles in cases where you have multiple containers
>>> from the same cluster on one host node. The software inside each
>>> container will get the same boot_id and thus fail to join the cluster,
>>> after the first container from the node has already joined.
>>>
>>> UTS namespace on other hand keeps the machine specific data, so it
>>> seems to be the correct place to move the boot_id and instantiate it,
>>> so each container will have unique id for its own boot lifetime, if
>>> it has its own uts namespace.
>> 
>> Technically this really needs to use the sysctl infrastructure that
>> allows you to register different files in different namespaces.  That
>> way the value you read from proc_do_uuid will be based on who opens the
>> file not on who is reading the file.
>
> Ok, so would you accept a patch that reimplements boot_id trough the sysctl infrastructure?

Assuming I am convinced this makes sense to do on the semantic level.

>> Practically why does a bind mount on top of boot_id work?  What makes
>> this a general problem worth solving in the kernel?  Why is hiding the
>> fact that you are running the same instance of the same kernel a useful
>> thing? That is the reality.
>
> The problem is, that the distros do not know that they are in
> container and don't know that they have to bind mount something on top
> of boot_id.  You need to tell Docker, LXC/LXD and all other container
> runtimes that they need to do this bind mount for boot_id.

Yes.  Anything like this is the responsibility of the container runtime
one way or another.   Magic to get around fixing the small set of
container runtimes you care about is a questionable activity.

> I consider this to be a general issue, that lacks good general
> solution in userspace.  The kernel is providing this boot_id
> interface, but it is giving wrong data in the context of containers.

I disagree.  Namespaces have never been about hiding that you are on a
given machine or a single machine.  They are about encapsulating global
identifers so that process migration can happen, and so that processes
can be better isolated.  The boot_id is not an identify of an object in
the kernel at all, and it is designed to be trully globally unique
across time and space so I am not at all certain that it makes the least
bit of sense to do anything with a boot_id.


That said my memory of boot_id is that was added so that emacs (and
related programs) could create lock files on nfs and could tell if the
current machine owns the file, and if so be able to tell if the owner
of the lock file is alive.

So there is an argument to be made that boot_id is to coarse.  That
argument suggest that boot_id is a pid_namespace property.

I have not looked at the users of boot_id, and I don't have a definition
of boot_id that makes me think it is too coarse.

If you can provide a clear description of what the semantics are and
what they should be for boot_id showing how boot_id fits into a
namespace, making it clear what should happen with checkpoint/restart.
We can definitely look at changing how the kernel supports boot_id.

The reason I suggested the bind mount is there are lots of cases where
people want to lie to applications about the reality of what is going on
for whatever reason, and we leave those lies to userspace.  Things
like changing the contents of /proc/cpuinfo.

> Proposing to fix this problem in userspace seams like ignoring the
> issue.  You could have said to the Consul guys, that they should
> simply stop using boot_id, because it doesn't work correctly on
> containers.

I don't know the Consul guys.   From a quick google search I see that
Consul is an open source project that is aims to be distributed and
highly available.  It seems a reasonable case to look at to motivate
changes to boot_id.

That said if I want to be highly available I would find every node
having the same boot_id to be very worrying, and very useful.  It allows
detecting if no hardware redundancy is present in a situation.  That
certainly seems like a good thing.

If you just want to test Consul then hacking boot_id with a bind mount
seems the right thing.  If you really want to run Consul in production
I am curious to know how removing the ability to detect if you are on
the same kernel as another piece of Consul is a good thing.

Eric
