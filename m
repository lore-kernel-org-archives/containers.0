From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][v3][PATCH 7/7] Define clone_with_pids syscall
Date: Mon, 1 Jun 2009 10:16:50 -0500
Message-ID: <20090601151650.GA20295@us.ibm.com>
References: <20090530235714.GA4083@us.ibm.com>
	<20090531000350.GF4191@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090531000350.GF4191-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):

Bear with me as I try to get this straight...

Let's say we have the following task being checkpointed (btw, the
actual checkpoint code hopefully will, as Oren mentioned, not
be always checkpointing all of a task's pids, but only the
pids from the checkpointer's pidns level an up - but that doesn't
matter to you):

Either:

level no    |    pid
0               1001
1                50
2                 3

or

level no    |    pid
0               1001
1                50
2                 1

Now we want to restart that inside a container.  So for the
first task we have a parent task:

level no       |     pid
0                    5009
1                    1000
2                     49
3                      2

calling clone_with_pid with upids {1001,50,3} to produce task:

level no       |     pid
0                   5010
1                   1001
2                    50
3                     3

So the numbers in your code for this case become:

> +	unum_pids = pid_set.num_pids;
        unum_pids = 3
> +	knum_pids = task_pid(current)->level + 1;
        knum_pids = 3 + 1 = 4

> +	target_pids = kzalloc((knum_pids + 1) * sizeof(pid_t), GFP_KERNEL);

XXX First problem:
        target_pids gets room for 5 pids, one more than we need.

> +	j = knum_pids - unum_pids;
        j = 1, so we copy the 3 pids in the right place.

> +	rc = copy_from_user(&target_pids[j], pid_set.target_pids, size);
> +	if (rc) {
> +		rc = -EFAULT;
> +		goto out_free;
> +	}
> +
> +	return target_pids;


For the second one, we have a parent task

level no       |     pid
0                   5009
1                   1000
2                    49

calling clone_with_pid with CLONE_NEWPID and {1001,50,1} to produce:

level no       |     pid
0                   5010
1                   1001
2                    50
3                    1

So the numbers in your code become:

> +	unum_pids = pid_set.num_pids;
        unum_pids = 3
> +	knum_pids = task_pid(current)->level + 1;
        knum_pids = 2 + 1 = 3

> +	target_pids = kzalloc((knum_pids + 1) * sizeof(pid_t), GFP_KERNEL);

        target_pids gets room for 4 pids

> +	j = knum_pids - unum_pids;

XXX Second problem:
        j = 0, which is not right, should be 1?

> +	rc = copy_from_user(&target_pids[j], pid_set.target_pids, size);
> +	if (rc) {
> +		rc = -EFAULT;
> +		goto out_free;
> +	}
> +
> +	return target_pids;

So it looks like your usage of knum_pids isn't quite right.

(right?)

Or are you expecting userspace to not specify the 1, only 2
upids?  In that case, you're requiring different behavior for
pid 1 than any others, which is kind of weird?  Or is that just
me?

-serge
