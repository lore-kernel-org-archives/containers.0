From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v3][PATCH 7/7] Define clone_with_pids syscall
Date: Sat, 13 Jun 2009 11:18:38 -0700
Message-ID: <20090613181838.GA2775@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

| Call clone_with_pids as follows:
| 
| 	pid_t pids[] = { 0, 77, 99 };
| 	struct target_pid_set pid_set;
| 
| 	pid_set.num_pids = sizeof(pids) / sizeof(int);
| 	pid_set.target_pids = &pids;
| 
| 	syscall(__NR_clone_with_pids, flags, stack, NULL, NULL, NULL, &pid_set);


Now that we need to do a copy_from_user() anyway, is it worth collapsing
one or more parameters into a structure ?

	struct clone_with_pid_args {
		u64 flags;
		void *stack;
		void *tls;
		struct target_pid_set *pid_set;
	};

	struct clone_tid_info {
		int *parent_tidptr;
		int *child_tidptr;
	}

	struct clone_with_pid_args cwp_args;
	struct clone_tid_info ctid_inf;

	...

	syscall(__NR_clone_with_pids, &cwp_args, &ctid_info);

One advantage would be that it would make room for 64 bit clone flags, so we
won't need a new flavor of clone_with_pids() when clone_flags is extended.

Sukadev
