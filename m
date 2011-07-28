From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 05/14] userns: clamp down users of cap_raised
Date: Thu, 28 Jul 2011 18:51:19 -0500
Message-ID: <20110728235119.GA8167__31107.6969643638$1311897261$gmane$org@sergelap>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
	<1311706717-7398-6-git-send-email-serge@hallyn.com>
	<20110728232337.GA9186@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110728232337.GA9186@albatros>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vasiliy Kulikov <segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Vasiliy Kulikov (segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Tue, Jul 26, 2011 at 18:58 +0000, Serge Hallyn wrote:
> > From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > 
> > A few modules are using cap_raised(current_cap(), cap) to authorize
> > actions, but the privilege should be applicable against the initial
> > user namespace.  Refuse privilege if the caller is not in init_user_ns.
> > 
> > Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> > ---
> >  drivers/block/drbd/drbd_nl.c           |    5 +++++
> >  drivers/md/dm-log-userspace-transfer.c |    3 +++
> >  drivers/staging/pohmelfs/config.c      |    3 +++
> >  drivers/video/uvesafb.c                |    3 +++
> >  4 files changed, 14 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
> > index 515bcd9..7717f8a 100644
> > --- a/drivers/block/drbd/drbd_nl.c
> > +++ b/drivers/block/drbd/drbd_nl.c
> > @@ -2297,6 +2297,11 @@ static void drbd_connector_callback(struct cn_msg *req, struct netlink_skb_parms
> >  		return;
> >  	}
> >  
> > +	if (current_user_ns() != &init_user_ns) {
> [...]
> >  	if (!cap_raised(current_cap(), CAP_SYS_ADMIN)) {
> [...]
> 
> Looks like it is an often pattern.  Maybe move both checks to a
> function?

This pattern is used 4 times (IIRC).  The reason I didn't break it out is
that it's very close to just 'capable(CAP_SYS_ADMIN)', which also checks
for CAP_SYS_ADMIN to the init_user_ns.  But the above, rightly or wrongly,
does not set the PF_SUPERPRIV task flag.  I don't want to advocate usage
of the above, and creating a helper for the above would both further
pollute the capability-related function namespace, and make the above
look more legitimate than I think it is.

Imo 'cap-raised(current_cap(), X)' should not be used at all.  But I
didn't want to deal with that here, just make it user-ns safe.

-serge
