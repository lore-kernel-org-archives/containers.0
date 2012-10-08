From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is not locking task_lock in cgroup_fork() safe?
Date: Mon, 8 Oct 2012 14:58:13 +0200
Message-ID: <CAFTL4hxWhS7xSWTAd0jguTcxoakzZEzdWbTmPRMe1a8u-AwzLw__23908.4424022169$1349701104$gmane$org@mail.gmail.com>
References: <20121008020000.GB2575@localhost> <20121008020138.GA4188@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121008020138.GA4188@localhost>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

2012/10/8 Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>:
> On Mon, Oct 08, 2012 at 11:00:00AM +0900, Tejun Heo wrote:
>> 7e381b0eb1 ("cgroup: Drop task_lock(parent) on cgroup_fork()") removed
>> task_lock from cgroup_fork citing that current->cgroups can't change
>> due to threadgroup_change locking; however, threadgroup_change locking
>> is used only during CLONE_THREAD forking.  If @current is forking a
>> new process, there's nothing preventing someone else to migrate the
>> parent while forking is in progress and delete the css_set it
>> currently is using.  Am I confused somewhere?
>
> Also, please note that task_lock is likely to be hot on local CPU at
> that point and avoiding it there might not really buy much.

Locks are expensive anyway. And I think cgroup has enough of them in
that hot path that fork is (threadgroup_lock, css_set_lock, ...)
