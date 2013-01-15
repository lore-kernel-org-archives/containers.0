From: Jeff Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: don't show pid list on tasks/procs in ascending
	order
Date: Tue, 15 Jan 2013 14:56:25 +0800
Message-ID: <50F4FD99.7070406__11038.1404440433$1358233019$gmane$org@oracle.com>
References: <50F4E902.20202@oracle.com> <20130115062507.GA21358@sergelap>
	<50F4F76D.2050409@oracle.com> <20130115063412.GA25338@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130115063412.GA25338@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/15/2013 02:34 PM, Serge Hallyn wrote:
> Quoting Jeff Liu (jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org):
>> On 01/15/2013 02:25 PM, Serge Hallyn wrote:
>>> Quoting Jeff Liu (jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org):
>>>> Hello,
>>>>
>>>> Currently, the pid list shown on cgroup->procs & tasks is in ascending order.  However, this list is not
>>>> guaranteed to be sorted according to the following records mentioned at Documentation/cgroups/cgroups.txt.
>>>>
>>>>  - tasks: list of tasks (by PID) attached to that cgroup.  This list
>>>>    is not guaranteed to be sorted. 
>>>>  - cgroup.procs: list of thread group IDs in the cgroup.  This list is
>>>>    not guaranteed to be sorted or free of duplicate TGIDs, and userspace
>>>>    should sort/uniquify the list if this property is required.
>>>>
>>>> This patch remove the sorting function to make the default behavior of pid list be consistent with
>>>> the document.
> 
> ...
> 
> I've gotta say, as someone who tends to play with those files by hand, I
> don't mind not having to type | sort | uniq every time.

I did this for two reasons, one is for the documents, another is per
Cgroup TODO list from Tejun -- https://lkml.org/lkml/2012/9/13/542

. Misc issues

  * Sort & unique when listing tasks.  Even the documentation says it
    doesn't happen but we have a good hunk of code doing it in
    cgroup.c.  I'm gonna rip it out at some point.  Again, if you
    don't like it, scream.

So that we can clean out around 70-lines source code as well as shrink
the cgroup.o a bit.

Thanks,
-Jeff
