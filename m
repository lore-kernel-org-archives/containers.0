From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: commit 7534432dcc3c654a8671b6b0cdffd1dbdbc73074
Date: Thu, 22 Jan 2009 15:07:05 -0800
Message-ID: <6599ad830901221507x796c154ck5fe4f95cc3eb8e0e@mail.gmail.com>
References: <20090122184754.GA17511@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090122184754.GA17511-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 22, 2009 at 10:47 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> #!/bin/bash
> mount -t cgroup -o freezer none /cgroup
> sleep 100 &
> pid=`jobs -p`

You can use $! to refer to the most recently started background process.

> mkdir /cgroup/1
> echo $pid > /cgroup/1/tasks
> umount /cgroup
> mount -t cgroup -o freezer,ns none /cgroup

This command should have failed with EBUSY, since freezer is already
part of an existing hierarchy. So I think it's a red herring in this
problem.

> mount -t cgroup -o freezer none /cgroup
> #kill %1

Is there a reason for this commented-out line?

> sleep 100 &
> pid=`jobs -p | tail -1`
> mkdir /cgroup/2
> echo $pid > /cgroup/2/tasks

This is the line that crashes?

> umount /cgroup
> ==============================================================
>
> ==============================================================
> The BUG output:
> ==============================================================
>
>
> ------------[ cut here ]------------
> kernel BUG at kernel/cgroup.c:468!

What is this line in your tree?

Paul
