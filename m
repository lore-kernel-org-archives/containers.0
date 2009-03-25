From: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Can not remove the subdirectory in cgroup pseudo-filesystem
Date: Thu, 26 Mar 2009 01:11:20 +0800
Message-ID: <d95d44a20903251011u5786c780wb3a0a0cc3b759689@mail.gmail.com>
References: <d95d44a20903250924p2fb28afdq7ac47cac372c7de3@mail.gmail.com>
	<20090325163702.GA17626@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090325163702.GA17626-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

>
> Yes you have to initialize some cpuset files first.  Otherwise
> the tasks have no access to any memory or cpus.
>

Oh... thank you for reminding. Previously, I run my tests in
a experimental kernel, it seems someone has set the
parameters.


BTW, is it possible currently to combine two tasks into
one cgroup? for instance, I have run two bashes (bash_A and
bash_B). Now, in bash_A, I created a cgroup in procfs:

# mount -t cgroup cgroup /mnt/cgrp
# cd /mnt/cgrp
# mkdir test
# echo $$ > test/tasks

Then, I would like to add bash_B in this task group but
fail:

# echo #(PID_OF_bash_B) >  test/tasks
-bash: echo: write error: Operation not permitted

It seems the cgroup can not couple two irrelevant
task together, right?


Best,

Anqin
