From: Davidlohr Bueso <dave-h16yJtLeMjHk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [REVIEW][PATCH 11/11] ipc/sem: Fix semctl(..., GETPID, ...)
	between pid namespaces
Date: Wed, 28 Mar 2018 17:52:09 -0700
Message-ID: <20180329005209.fnzr3hzvyr4oy3wi__22943.9535680742$1522285356$gmane$org@linux-n805>
References: <87vadmobdw.fsf_-_@xmission.com>
	<20180323191614.32489-11-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20180323191614.32489-11-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: esyr-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, prakash.sangappa-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Nagarathnam Muthusamy <nagarathnam.muthusamy-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 23 Mar 2018, Eric W. Biederman wrote:

>Today the last process to update a semaphore is remembered and
>reported in the pid namespace of that process.  If there are processes
>in any other pid namespace querying that process id with GETPID the
>result will be unusable nonsense as it does not make any
>sense in your own pid namespace.

Yeah that sounds pretty wrong.

>
>Due to ipc_update_pid I don't think you will be able to get System V
>ipc semaphores into a troublesome cache line ping-pong.  Using struct
>pids from separate process are not a problem because they do not share
>a cache line.  Using struct pid from different threads of the same
>process are unlikely to be a problem as the reference count update
>can be avoided.
>
>Further linux futexes are a much better tool for the job of mutual
>exclusion between processes than System V semaphores.  So I expect
>programs that  are performance limited by their interprocess mutual
>exclusion primitive will be using futexes.

You would be wrong. There are plenty of real workloads out there
that do not use futexes and are care about performance; in the end
futexes are only good for the uncontended cases, it can also
destroy numa boxes if you consider the global hash table. Experience
as shown me that sysvipc sems are quite still used.

>
>So while it is possible that enhancing the storage of the last
>rocess of a System V semaphore from an integer to a struct pid
>will cause a performance regression because of the effect
>of frequently updating the pid reference count.  I don't expect
>that to happen in practice.

How's that? Now thanks to ipc_update_pid() for each semop the user
passes, perform_atomic_semop() will do two atomic updates for the
cases where there are multiple processes updating the sem. This is
not uncommon.

Could you please provide some numbers.

Thanks,
Davidlohr
