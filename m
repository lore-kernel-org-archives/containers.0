From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] Re: Write Error: No space left on device
Date: Tue, 28 Oct 2008 17:42:31 +0530
Message-ID: <20081028121231.GA15052@linux.vnet.ibm.com>
References: <c7704c490809050541v2df520f9ja9edc4582ee1199f@mail.gmail.com>
	<20080905080008.bf9748ab.pj@sgi.com>
	<c7704c490809150455r3376db54g8d37aba6670500a9@mail.gmail.com>
	<6599ad830809151726t4ff6082dsfda259dccd503415@mail.gmail.com>
	<c7704c490809170557o21330ceaoeca5193add14c6d4@mail.gmail.com>
	<6599ad830809171740t2cbb459dqc273f240b9877ed8@mail.gmail.com>
	<c7704c490810280028y74bb9c55pd9d6af844571fcd6@mail.gmail.com>
	<20081028083806.GB4097@linux.vnet.ibm.com>
	<c7704c490810280307s141a7a18vc708049e7f499c50@mail.gmail.com>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <c7704c490810280307s141a7a18vc708049e7f499c50-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mukesh G <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 28, 2008 at 03:37:52PM +0530, Mukesh G wrote:
> Hi Dhaval,
>     Thanks for clarifying some doubts. Further to your mail and my
> understanding, I can make some conclusions
> 
> 1) Even though there is a hierarchical order for containers, the shares are
> not allocated in terms of that order i.e. If the parent container has a
> certain no of cpu.shares and more child containers. The parent and child
> containers have the same priority.
> 

No, the hierarchy is always maintained for the group scheduler. The parent
group's shares are used to see how long/when it will get scheduled with
respect to other tasks/groups at that level. As an example, if you have
a hierarchy like this

/
|-A
| |-A1
| |-A2
|
|-B
|-t1
|-t2

Let A, B have shares 1024 and t1 and t2 be tasks at nice 0. With this
setting, A, B, t1 and t2 will get equal CPU bandwidth. The tasks and
groups in A will split bandwidth available to A in a similar fashion. So
the cpu shares is not some resource which is split but it is a value which
will decide in what proportion the CPU bandwidth will be shared. So, if
you have no tasks in /, then setting the shares of A and B to 10 is the
same as setting the shares of A and B to 1000 (not exactly in terms of
load balancing, but enough for the purpose of this discussion).

> 2) For only 2 process running on a dual core system and If I have one
> process assigned to C2048 container and another process assigned to C1024
> container, I would expect the scheduler to allocate in the order of 2:1.
> Behavior 2 indicates that allocation did not happen.
> 

Well, its not possible to run one thread on more than one core at the
sametime :-). So we do not see the 2:1 usage happen.

> 3) I ran the experiment having 2 instances of multi-threaded version of java
> workload on the same system and noticed that 2:1 scenario did not repeat.
> Hence, a multi threaded code does not benefit from this kind of a scheduler.
> 

I am not sure if I have understood your question. But I think the answer
to the previous question should help.

> 4) If you have more processes than the no of cores for the cpu shares to
> work.
> 

Well, the physical limit on how much CPU a thread can hog is 100%, so
yes, if you have lesser threads than number of CPUs, you don't expect
shares to  work as expected, and each thread will get 100% CPU time.

thanks,
-- 
regards,
Dhaval
