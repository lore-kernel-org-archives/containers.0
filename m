From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: ns_can_attach (nsproxy cgroup)
Date: Fri, 12 Dec 2008 15:23:09 +0100
Message-ID: <20081212142309.GD16669@megiteam.pl>
References: <20081212095153.GA20956@megiteam.pl>
	<20081212140908.GA9571@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081212140908.GA9571-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 12, 2008 at 08:09:08AM -0600, Serge E. Hallyn wrote:
> Quoting Grzegorz Nosek (root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org):
> > Hi all,
> > 
> > Is there a good reason for ns_can_attach to restrict moving tasks only
> > to direct descentants of the current cgroup? I.e. could the code:
> > 
> >         orig = task_cgroup(task, ns_subsys_id);
> >         if (orig && orig != new_cgroup->parent)
> >                 return -EPERM;
> > 
> > be replaced with:
> > 
> >         orig = task_cgroup(task, ns_subsys_id);
> >         if (orig && !cgroup_is_descendant_of(new_cgroup, orig))
> >                 return -EPERM;
> > 
> > (for a suitable definition of cgroup_is_descendant_of). It would allow
> > moving tasks down the cgroup hierarchy more than one level at a time and
> > as far as I can see, would pose no additional problems.
> > 
> > Please keep CC'd, I'm not subscribed.
> 
> Well you can always move it down one level at a time, right? :)

Yeah, but I found a patch by Andrea Righi which fits my use case almost
100% [1]. The tasks are moved between cgroups by the kernel, so it's
kernel hacking for me either way and I guess modifying ns_can_attach
will be cleaner.

> But I can't think of any reason why it would be a problem.  So
> pls feel free to send a patch.

Will do.

Best regards,
 Grzegorz Nosek

[1] http://lwn.net/Articles/294364/
