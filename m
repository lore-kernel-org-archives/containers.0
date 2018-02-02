From: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Subject: Re: RFC(V3): Audit Kernel Container IDs
Date: Fri, 2 Feb 2018 17:05:22 -0500
Message-ID: <CAHC9VhQ5ciUZDhrsb6S4YxwuzQEY-ra2RTDceWXOdjHEBoZ0BQ__8936.03385561637$1517609036$gmane$org@mail.gmail.com>
References: <20180109121620.wi7dq2423ugsraqv@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180109121620.wi7dq2423ugsraqv-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jan 9, 2018 at 7:16 AM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> Containers are a userspace concept.  The kernel knows nothing of them.
>
> The Linux audit system needs a way to be able to track the container
> provenance of events and actions.  Audit needs the kernel's help to do
> this.

Two small comments below, but I tend to think we are at a point where
you can start cobbling together some prototype/RFC patches.  Surely
there are going to be a few changes, and new comments, that come out
once we see an initial implementation so let's see what those are.

> The registration is a u64 representing the audit container identifier
> written to a special file in a pseudo filesystem (proc, since PID tree
> already exists) representing a process that will become a parent process
> in that container.  This write might place restrictions on mount
> namespaces required to define a container, or at least careful checking
> of namespaces in the kernel to verify permissions of the orchestrator so
> it can't change its own container ID.  A bind mount of nsfs may be
> necessary in the container orchestrator's mount namespace.  This write
> can only happen once per process.
>
> Note: The justification for using a u64 is that it minimizes the
> information printed in every audit record, reducing bandwidth and limits
> comparisons to a single u64 which will be faster and less error-prone.

I know Steve generally worries about audit record size, which is a
perfectly valid concern in this case, I also worry about the
additional overhead when we start routing audit records to multiple
audit daemons (see my other emails in this thread).

> ...
> When a container ceases to exist because the last process in that
> container has exited log the fact to balance the registration action.
> (This is likely needed for certification accountability.)

On the "container ceases to exist" point, I expect this "container
dead" message to come from the orchestrator and not the kernel itself
(I don't want the kernel to have to handle that level of bookkeeping).
I imagine this should be similar to what is done for VM auditing with
libvirt.

-- 
paul moore
www.paul-moore.com
