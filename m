From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET] cgroup: unexport locking interface
Date: Sun, 7 Apr 2013 09:30:45 -0700
Message-ID: <20130407163045.GB12038__48422.4786902361$1365352260$gmane$org@htj.dyndns.org>
References: <1365118589-10619-1-git-send-email-tj@kernel.org>
	<5161064D.30000@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5161064D.30000-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Apr 07, 2013 at 01:38:21PM +0800, Li Zefan wrote:
> On 2013/4/5 7:36, Tejun Heo wrote:
> > Hello,
> > 
> > Most cgroup_mutex abuses outside cgroup core proper have been
> > eradicated but there's still one use remaining and locking interface
> > is still exported.  This patchset updates the last user and unexports
> > the locking interface and is composed of the following five patches.
> > 
> >  0001-cgroup-cpuset-replace-move_member_tasks_to_cpuset-wi.patch
> >  0002-cgroup-relocate-cgroup_lock_live_group-and-cgroup_at.patch
> >  0003-cgroup-unexport-locking-interface-and-cgroup_attach_.patch
> >  0004-cgroup-kill-cgroup_-un-lock.patch
> >  0005-cgroup-remove-cgroup_lock_is_held.patch
> > 
> 
> Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Applied to cgroup/for-3.10.

Thanks.

-- 
tejun
