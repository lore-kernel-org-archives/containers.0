From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup 1/2] cgroup: move module ref handling into
	rebind_subsystems()
Date: Fri, 12 Jul 2013 13:10:02 -0700
Message-ID: <20130712201002.GH23680__23278.3454972834$1373659819$gmane$org@mtj.dyndns.org>
References: <20130629041231.GA31353@htj.dyndns.org>
	<51DFC650.9010801@huawei.com> <51DFC787.7080703@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51DFC787.7080703-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jul 12, 2013 at 05:08:23PM +0800, Li Zefan wrote:
> > so a modular cgroup subsystem can be unloaded inbetween, say it's net_cls, and
> > then it's possible that:
> > 
> > 	# mount -t cgroup -o net_cls xxx /cgroup
> > 
> > The above operation succeeds but it's not binded to cgroupfs as it just got
> > unloaded.

Ooh, right, it'd be excluded from the iteration.

> for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> 	...
> 	if (!subsys[i] && (added_mask & (1 << i))
> 		return -EINVAL;
> 	...
> }
> 
> This should work.

Yeah, I kinda dislike the raw iteration tho.  I wonder whether setting
the actually added mask and comparing would be cleaner.  I'll
experiment with it and post the updated patch.

Thanks!

-- 
tejun
