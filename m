From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCH 06/13] cpuset: cleanup cpuset[_can]_attach()
Date: Wed, 02 Jan 2013 15:12:15 +1030
Message-ID: <87zk0s5h7c.fsf__35920.8152666271$1357103580$gmane$org@rustcorp.com.au>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
	<1354138460-19286-7-git-send-email-tj@kernel.org>
	<50DACF5B.6050705@huawei.com>
	<20121226120415.GA18193@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121226120415.GA18193-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> (cc'ing Rusty, hi!)
>
> Hello, Li.
>
> On Wed, Dec 26, 2012 at 06:20:11PM +0800, Li Zefan wrote:
>> On 2012/11/29 5:34, Tejun Heo wrote:
>> > cpuset_can_attach() prepare global variables cpus_attach and
>> > cpuset_attach_nodemask_{to|from} which are used by cpuset_attach().
>> > There is no reason to prepare in cpuset_can_attach().  The same
>> > information can be accessed from cpuset_attach().
>> > 
>> > Move the prepartion logic from cpuset_can_attach() to cpuset_attach()
>> > and make the global variables static ones inside cpuset_attach().
>> > 
>> > While at it, convert cpus_attach to cpumask_t from cpumask_var_t.
>> > There's no reason to mess with dynamic allocation on a static buffer.
>> > 
>> 
>> But Rusty had been deprecating the use of cpumask_t. I don't know why
>> the final deprecation hasn't been completed yet.
>
> Hmmm?  cpumask_t can't be used for stack but other than that I don't
> see how it would be deprecated completely.  Rusty, can you please
> chime in?

The long-never-quite-complete-plan was for struct cpumask to be
undefined when CONFIG_CPUMASK_OFFSTACK=y.  That means noone can declare
them, or pass them on the stack, since they'll get a compiler error.

Now, there are some cases where it really is a reason to use a static
bitmap, and 1/2 a K of wasted space be damned.  There's a
deliberately-ugly way of doing that: declare a bitmap and use
to_cpumask().  Of course, if we ever really want to remove NR_CPUS and
make it completely generic, we have to kill all these too, but noone is
serious about that.

Cheers,
Rusty.
