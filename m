From: Rolando Martins <rolando.martins-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Cgroups RT scheduling
Date: Wed, 9 Sep 2009 16:49:52 +0100
Message-ID: <b6a2d2e20909090849m16a9f452h353d5a75ee61c625@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

I would like to confirm the following:
cpuset.sched_load_balance doesn't work with RT, right?
You cannot have tasks for sub-domain 2 to utilize bandwidth of
sub-domain 3, right?

                              __1__
                             /        \
                            2         3
                      (50% rt)  (50% rt )

For my application domain;) it would be interesting to have
rt_runtime_ns as a min. of allocated rt and not a max.
Ex. If an application of domain 2 needs to go up to 100% and domain 3
is idle, then it would be cool to let it utilize the full bandwidth.
(we also could have a hard upper limit in each sub-domain, like
hard_up=0.8, i.e. even if we could get 100%, we will only utilize
80%).

Thanks,
Rolando Martins
