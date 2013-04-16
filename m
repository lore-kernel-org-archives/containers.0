From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] devcg: remove parent_cgroup.
Date: Tue, 16 Apr 2013 16:07:25 -0500
Message-ID: <20130416210725.GA21536@sergelap>
References: <1366143895-21535-1-git-send-email-ramirose@gmail.com>
	<20130416203700.GP24899@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130416203700.GP24899-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Rami Rosen <ramirose-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Aristeu Rozanski (aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> On Tue, Apr 16, 2013 at 11:24:55PM +0300, Rami Rosen wrote:
> > In devcgroup_css_alloc(), there is no longer need for parent_cgroup.
> > bd2953ebbb("devcg: propagate local changes down the hierarchy") made
> > the variable parent_cgroup redundant. This patch removes parent_cgroup
> > from devcgroup_css_alloc().
> > 
> > Signed-off-by: Rami Rosen <ramirose-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  security/device_cgroup.c | 2 --
> >  1 file changed, 2 deletions(-)
> > 
> > diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> > index 994aecc..dd0dc57 100644
> > --- a/security/device_cgroup.c
> > +++ b/security/device_cgroup.c
> > @@ -236,7 +236,6 @@ static void devcgroup_offline(struct cgroup *cgroup)
> >  static struct cgroup_subsys_state *devcgroup_css_alloc(struct cgroup *cgroup)
> >  {
> >  	struct dev_cgroup *dev_cgroup;
> > -	struct cgroup *parent_cgroup;
> >  
> >  	dev_cgroup = kzalloc(sizeof(*dev_cgroup), GFP_KERNEL);
> >  	if (!dev_cgroup)
> > @@ -244,7 +243,6 @@ static struct cgroup_subsys_state *devcgroup_css_alloc(struct cgroup *cgroup)
> >  	INIT_LIST_HEAD(&dev_cgroup->exceptions);
> >  	INIT_LIST_HEAD(&dev_cgroup->propagate_pending);
> >  	dev_cgroup->behavior = DEVCG_DEFAULT_NONE;
> > -	parent_cgroup = cgroup->parent;
> >  
> >  	return &dev_cgroup->css;
> >  }
> 
> oops
> 
> ACK

Not seeing the patches this is based on in Linus' tree yet, but given
the context above I don't see how it could not be right :)

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
