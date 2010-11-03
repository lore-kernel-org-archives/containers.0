From: Li Zefan <lizf.kern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] cgroup - removing superfluous rcu_read_lock_held check
Date: Thu, 04 Nov 2010 02:40:03 +0800
Message-ID: <4CD1AC83.4030204@gmail.com>
References: <1288638909-10541-1-git-send-email-jolsa@redhat.com>
	<1288638909-10541-2-git-send-email-jolsa@redhat.com>
	<4CD0506F.6080600@gmail.com>
	<20101103085804.GB1916@jolsa.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101103085804.GB1916-4G3mNVrOt0i3oHxwIazZmlaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

> attaching changed patch
> 
> wbr,
> jirka
> 

Some small notes:

- Cgroup patches are normally Cced to LKML, except those RFC
ones.

- I think a more commonly used title should be:
  [..] cgroups: remove ...

- It's Andrew Morton that picks up cgroup patches, so he may
overlook this revised patch. So better resend this patch with
Andrew listed as receiver (and with Paul Menage, LKML ... Cced),
with a title like:
  [PATCH v2] cgroups: remove ...

> ---
> No need to specify rcu_read_lock_held() condition in rcu_dereference_check.
> 
> 
> Signed-off-by: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Normally you should retain reviewed-by and other tags that
you've got previously.

So here again:

Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
