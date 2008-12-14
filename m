From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: ns_can_attach (nsproxy cgroup)
Date: Sun, 14 Dec 2008 15:06:04 +0100
Message-ID: <20081214140604.GA22768@megiteam.pl>
References: <20081212095153.GA20956@megiteam.pl>
	<20081212140908.GA9571@us.ibm.com>
	<20081212213042.GA23581@megiteam.pl>
	<49435E58.9050209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49435E58.9050209-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
List-Id: containers.vger.kernel.org

On sob, gru 13, 2008 at 03:03:52 +0800, Li Zefan wrote:
> >  /**
> > - * cgroup_is_descendant - see if @cgrp is a descendant of current task's cgrp
> > + * cgroup_is_descendant - see if @cgrp is a descendant of @task's cgrp
> >   * @cgrp: the cgroup in question
> > + * @task: the task in question
> > + * @subsys_id: cgroup subsystem id used to determine hierarchy; if negative,
> > + * 		use get_first_subsys()
> 
> The last argument is redundant.
> 
> [...]
> 
> It makes no difference with:
> 	if (!cgroup_is_descendant(new_cgroup, task, -1))
> 
> That's why we don't need argument 'subsys_id'.

Thanks, I thought so (the "first" subsys_id looked arbitrary to me) but not knowing
the cgroup internals I wanted to preserve the original code as much as possible.
Will update the patch.

Best regards,
 Grzegorz Nosek
