From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] cgroup: cftype based file interface, take #2
Date: Sat, 31 Mar 2012 20:56:36 +0800
Message-ID: <4F76FF04.40007__27353.4432672479$1333199155$gmane$org@huawei.com>
References: <1332368265-21586-1-git-send-email-tj@kernel.org>
	<4F75AA1F.9020007@huawei.com> <20120330154246.GE28934@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <20120330154246.GE28934-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo wrote:

> Hey, Li.
> 
> On Fri, Mar 30, 2012 at 08:42:07PM +0800, Li Zefan wrote:
>>> This patch replaces cgroup file interface with cftype based one which
>>> allows dynamic additions and removals of cftype arrays whether the
>>> target subsystem is attached or not.  This can be used to make subsys
>>> rebinding via remount work properly but I intentionally avoided doing
>>> that at the moment.
>>
>> What's the problem with remount?
> 
> Subsys can't be changed if any non-root cgroup exists.
> 


Ah, this is a long-standing defect, which is documented in Doc/../cgroups.txt.
It's not trivial to fix it, and I never heard someone request it to be fixed.

>> and is it important enough that it should be fixed even the feature
>> is marked as deprecated?
> 
> I'm not sure.  We *might* need it during multi-mount -> single-mount
> transition depending on how that's implemented, so the "at the moment"
> qualifier.  It probably won't be fixed but I'm not fully sure.
> 


fine.

>>> This makes cgroup population simpler for controllers and will be used
>>> to allow controllers to be more dynamic.  e.g. blkio subsys has
>>> sub-policies which may come and go while blkio subsys is attached and
>>> it currently uses fixed set of files which stays blank if not in use.
>>
>> Dynamic cgroup files was mentioned before. The scenario in mind was blkio
>> control files can be added/removed automatically as devices come and ago.
>>
>> So this time blkio subsystem is really going to be made more dynamic
>> soon?
> 
> Patchset already posted.
> 
>   http://thread.gmane.org/gmane.linux.kernel.cgroups/1376
> 


Thanks!
