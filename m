From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: Is not locking task_lock in cgroup_fork() safe?
Date: Fri, 19 Oct 2012 16:50:34 +0800
Message-ID: <5081145A.2010307__38376.7105675817$1350636693$gmane$org@huawei.com>
References: <20121008020000.GB2575@localhost>
	<CAFTL4hzXWtzp7megsCAEuak5=_2SWmp9age-+wrpyQAU4BRZ0w@mail.gmail.com>
	<20121016193341.GD16166@google.com>
	<CAFTL4hzo_w7HTgC9ApTk113X8WdZSpV+D+VSEe=604YEJFmKsg@mail.gmail.com>
	<20121018200705.GG13370@google.com>
	<CAFTL4hy7g4e11OUOyoihrEU8hiVgZoV1=141UtUpj9a72SNs_Q@mail.gmail.com>
	<20121019003835.GE13370@google.com>
	<20121019005801.GF13370@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121019005801.GF13370-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2012/10/19 8:58, Tejun Heo wrote:
> Hello, again.
> 
> On Thu, Oct 18, 2012 at 05:38:35PM -0700, Tejun Heo wrote:
>> Even if there isn't an actual race, the comment is dead wrong.  I'm
>> reverting the following three patches.  Let's try again later.
>>
>>   7e381b0eb1 ("cgroup: Drop task_lock(parent) on cgroup_fork()")
>>   7e3aa30ac8 ("cgroup: Remove task_lock() from cgroup_post_fork()")
> 
> So, after some more looking, I think the following is correct and
> doesn't need to be reverted.  It's depending on threadgroup locking
> from migration path to synchronize against exit path which is always
> performed.
> 
>>   c84cdf75cc ("cgroup: Remove unnecessary task_lock before fetching css_set on migration")
> 
> Frederic, were you trying to say that the above commit is correct?
> Li, do you agree?
> 

This one does look innocent.
