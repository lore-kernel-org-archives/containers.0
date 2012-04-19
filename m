From: Alexander Nikiforov <a.nikiforov-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Thu, 19 Apr 2012 07:34:15 +0400
Message-ID: <4F8F87B7.2000504@samsung.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<4F86527C.2080507@samsung.com>
	<20120417010902.GA14646@somewhere.redhat.com>
	<4F8D1171.1090504@samsung.com> <20120417152350.GC32402@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <20120417152350.GC32402-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, d.solodkiy-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/17/2012 07:23 PM, Tejun Heo wrote:
> Hello,
>
> On Tue, Apr 17, 2012 at 10:45:05AM +0400, Alexander Nikiforov wrote:
>> between them. Now we have only 1 way to get notification about tasks
>> file - inotify(), but this approach works only if you work from
>> userspace with file (e.g. create struct file, for example with echo
>> $$ /sys/abc/tasks), but when something happens from kernel side
>> (do_fork()/do_exit) we cannot get any event about group of the
>> process (we can scan tasks file and count number of PID, or work
>> with
>> waitpid(), but IMHO this is ugly solutions)
> Wouldn't simply generating FS_MODIFY event on the tasks file do the
> trick?
>
> Thanks.
>
Maybe it will, but in my mind it should be with event. I thought about 
inotify before my RFD mail. Here we have file update, so FS_MODIFY very 
natural.
But on the other hand - we have event in memcg, so conventional approach 
is event.

If this functionality is acceptable in cgroup and FS_MODIFY better, 
we'll make new patch with this approach.

-- 
Best regards,
      Alex Nikiforov,
      Mobile SW, Advanced Software Group,
      Moscow R&D center, Samsung Electronics
