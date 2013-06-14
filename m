From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 11/11] cgroup: use percpu refcnt for cgroup_subsys_states
Date: Fri, 14 Jun 2013 15:31:25 -0700
Message-ID: <20130614223125.GD6593__32161.2524836839$1371249108$gmane$org@mtj.dyndns.org>
References: <1371096298-24402-1-git-send-email-tj@kernel.org>
	<1371096298-24402-12-git-send-email-tj@kernel.org>
	<20130614132026.GD10084@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130614132026.GD10084-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mikulas Patocka <mpatocka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Alasdair G. Kergon" <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello, Michal.

On Fri, Jun 14, 2013 at 03:20:26PM +0200, Michal Hocko wrote:
> I have no objections to change css reference counting scheme if the
> guarantees we used to have are still valid. I am just missing some
> comparisons. Do you have any numbers that would show benefits clearly?

Mikulas' high scalability dm test case on top of ramdisk was affected
severely when css refcnting was added to track the original issuer's
cgroup context.  That probably is one of the more severe cases.

> You are mentioning that especially controllers that are strongly per-cpu
> oriented will see the biggest improvements. What about others?
> A single atomic_add resp. atomic_dec_return is much less heavy than the

Even with preemption enabled, the percpu ref get/put will be under ten
instructions which touch two memory areas - the preemption counter
which is usually very hot anyway and the percpu refcnt itself.  It
shouldn't be much slower than the atomic ops.  If the kernel has
preemption disabled, percpu_ref is actually likely to be cheaper even
on single CPU.

So, here are some numbers from the attached test program.  The test is
very simple - inc ref, copy N bytes into per-cpu buf, dec ref - and
see how many times it can do that in given amount of time - 15s.  Both
single CPU and all CPUs scenarios are tested.  The test is run inside
qemu on my laptop - mobile i7 2 core / 4 threads.  Yeah, I know.  I'll
run it on a proper test machine later today.

Single CPU case.  Preemption enabled.  This is the best scenario for
atomic_t.  No cacheline bouncing at all.

    copy size  atomic_t		  percpu_ref	   diff

	0      1198217077	  1747505555	  +45.84%
	32	505504457	   465714742	   -7.87%
	64	511521639	   470741887	   -7.97%
	128	485319952	   434920137	  -10.38%
	256	421809359	   384871731	   -8.76%
	512	330527059	   307587622	   -6.94%

For some reason, percpu_ref wins if copy_size is zero.  I don't know
why that is.  The body isn't optimized out so it's still doing all the
refcnting.  Maybe the CPU doesn't have enough work to mask pipeline
bubbles from atomic ops?  In other cases, it's slower by around or
under 10% which isn't exactly noise but this is the worst possible
scenario.  Unless this is the only thing a pinned CPU is doing, it's
unlikely to be noticeable.

Now doing the same thing on multiple CPUs.  Note that while this is
the best scenario for percpu_ref, the hardware the test is run on is
very favorable to atomic_t - it's just two cores on the same package
sharing the L3 cache, so cacheline ping-poinging is relatively cheap.

    copy size  atomic_t		  percpu_ref	   diff

	0      342659959	  3794775739	  +1007.45%
	32     401933493	  1337286466	   +232.71%
	64     385459752	  1353978982	   +251.26%
	128    401379622	  1234780968	   +207.63%
	256    401170676	  1052511682	   +162.36%
	512    387796881	   794101245	   +104.77%

Even on this machine, the difference is huge.  If the refcnt is used
from different CPUs in any frequency, percpu_ref will destroy
atomic_t.  Also note that percpu_ref will scale perfectly as the
number of CPUs increases while atomic_t will get worse.

I'll play with it a bit more on an actual machine and post more
results.  Test program attached.

Thanks.

-- 
tejun

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="test-pcpuref.c"

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <asm/atomic.h>
#include <linux/percpu-refcount.h>
#include <linux/workqueue.h>
#include <linux/completion.h>

static struct workqueue_struct *my_wq;

static int test_all_cpus = 0;
module_param_named(all_cpus, test_all_cpus, int, 0444);

static int test_duration = 15;
module_param_named(duration, test_duration, int, 0444);

static int test_copy_bytes = 32;
module_param_named(copy_bytes, test_copy_bytes, int, 0444);

static char test_src_buf[1024];
static DEFINE_PER_CPU(char [1024], test_dst_buf);
static DEFINE_PER_CPU(struct work_struct, test_work);

static atomic_t test_atomic_ref = ATOMIC_INIT(1);

static void test_atomic_workfn(struct work_struct *work)
{
	unsigned long end = jiffies + test_duration * HZ;
	unsigned long cnt = 0;

	do {
		int bytes = test_copy_bytes;

		atomic_inc(&test_atomic_ref);
		while (bytes) {
			int todo = min_t(int, bytes, 1024);

			memcpy(*this_cpu_ptr(&test_dst_buf), test_src_buf, todo);
			bytes -= todo;
		}
		cnt++;
		atomic_dec(&test_atomic_ref);
	} while (time_before(jiffies, end));

	printk("XXX atomic on CPU %d completed %lu loops\n",
	       smp_processor_id(), cnt);
}

static struct percpu_ref test_pcpu_ref;
static DECLARE_COMPLETION(test_cpu_ref_done);

static void test_pcpu_release(struct percpu_ref *ref)
{
	complete(&test_cpu_ref_done);
}

static void test_pcpu_workfn(struct work_struct *work)
{
	unsigned long end = jiffies + test_duration * HZ;
	unsigned long cnt = 0;

	do {
		int bytes = test_copy_bytes;

		percpu_ref_get(&test_pcpu_ref);
		while (bytes) {
			int todo = min_t(int, bytes, 1024);

			memcpy(*this_cpu_ptr(&test_dst_buf), test_src_buf, todo);
			bytes -= todo;
		}
		cnt++;
		percpu_ref_put(&test_pcpu_ref);
	} while (time_before(jiffies, end));

	printk("XXX percpu on CPU %d completed %lu loops\n",
	       smp_processor_id(), cnt);
}

static int test_pcpuref_init(void)
{
	int cpu;

	if (percpu_ref_init(&test_pcpu_ref, test_pcpu_release))
		return -ENOMEM;

	my_wq = alloc_workqueue("test-pcpuref", WQ_CPU_INTENSIVE, 0);
	if (!my_wq) {
		percpu_ref_cancel_init(&test_pcpu_ref);
		return -ENOMEM;
	}

	printk("XXX testing atomic_t for %d secs\n", test_duration);

	for_each_online_cpu(cpu) {
		INIT_WORK(per_cpu_ptr(&test_work, cpu), test_atomic_workfn);
		queue_work_on(cpu, my_wq, per_cpu_ptr(&test_work, cpu));
		if (!test_all_cpus)
			break;
	}

	flush_workqueue(my_wq);

	printk("XXX testing percpu_ref for %d secs\n", test_duration);

	for_each_online_cpu(cpu) {
		INIT_WORK(per_cpu_ptr(&test_work, cpu), test_pcpu_workfn);
		queue_work_on(cpu, my_wq, per_cpu_ptr(&test_work, cpu));
		if (!test_all_cpus)
			break;
	}

	flush_workqueue(my_wq);

	percpu_ref_kill(&test_pcpu_ref);
	wait_for_completion(&test_cpu_ref_done);

	return 0;
}
module_init(test_pcpuref_init);

static void test_pcpuref_exit(void)
{
	destroy_workqueue(my_wq);
}
module_exit(test_pcpuref_exit);

MODULE_LICENSE("GPL v2");

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--LQksG6bCIzRHxTLp--
