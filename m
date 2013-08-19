From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.12 2/2] cgroup: fix
	cgroup_write_event_control()
Date: Mon, 19 Aug 2013 09:57:57 -0400
Message-ID: <20130819135757.GE6176@htj.dyndns.org>
References: <20130815154236.GG14606@htj.dyndns.org>
	<20130815154315.GH14606@htj.dyndns.org>
	<521185F3.6060806@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <521185F3.6060806-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

On Mon, Aug 19, 2013 at 10:41:55AM +0800, Li Zefan wrote:
> On 2013/8/15 23:43, Tejun Heo wrote:
> >>From ced043264c9c3f03ab3c992af17461db50421dd8 Mon Sep 17 00:00:00 2001
> > From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > Date: Thu, 15 Aug 2013 11:37:54 -0400
> > 
> > 81eeaf0411 ("cgroup: make cftype->[un]register_event() deal with
> > cgroup_subsys_state inst ead of cgroup") updated the cftype event
> > methods to take @css (cgroup_subsys_state) instead of @cgroup;
> > however, it incorrectly used @css passed to
> > cgroup_write_event_control(), which the dummy_css for the cgroup as
> > the file is a cgroup core file.  This leads to oops on event
> > registration.
> > 
> > Fix it by using the css matching the event target file.  Note that
> > cgroup_write_event_control() now disallows cgroup core files from
> > being event sources.  This is for simplicity and doesn't matter as
> > cgroup_event will be moved and made specific to memcg.
> > 
> > Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> 
> Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Applied to cgroup/for-3.12.  Thanks.

-- 
tejun
