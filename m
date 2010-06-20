From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 4/6] pidns: Don't allow new pids after the namespace is
	dead.
Date: Sun, 20 Jun 2010 20:44:20 +0200
Message-ID: <20100620184420.GC3258@redhat.com>
References: <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com> <m1pqzmqema.fsf_-_@fess.ebiederm.org> <m1631eqeeq.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1631eqeeq.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org

On 06/20, Eric W. Biederman wrote:
>
> In the case of unsharing or joining a pid namespace, it becomes
> possible to attempt to allocate a pid after zap_pid_namespace has
> killed everything in the namespace.  Close the hole for now by simply
> not allowing any of those pid allocations to succeed.  At least for
> now it is too strange to think about.

Well, I didn't read the next patch, so I don't understand the changelog.

Still, a couple of stupid questions. Feel free to ignore me...

> --- a/include/linux/pid_namespace.h
> +++ b/include/linux/pid_namespace.h
> @@ -20,6 +20,7 @@ struct pid_namespace {
>  	struct kref kref;
>  	struct pidmap pidmap[PIDMAP_ENTRIES];
>  	int last_pid;
> +	atomic_t dead;

Why it is atomic_t? It is used like a simple boolean, and the next
patch doesn't use ns->dead.

> @@ -248,6 +248,10 @@ struct pid *alloc_pid(struct pid_namespace *ns)
>  	struct pid_namespace *tmp;
>  	struct upid *upid;
>
> +	pid = NULL;
> +	if (atomic_read(&ns->dead))
> +		goto out;
> +
> [...snip...]
> @@ -161,6 +162,7 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
>  	 *
>  	 */
>  	read_lock(&tasklist_lock);
> +	atomic_set(&pid_ns->dead, 1);
>  	nr = next_pidmap(pid_ns, 1);

The only caller of alloc_pid() is copy_process(). So, at first glance this
patch tries to block the attempts to create the tasks in this namespace.

But what if copy_process() has already called alloc_pid() using this ns,
but didn't do attach_pid() yet?

Oleg.
