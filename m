From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] cgroup freezer: Avoid lazy state changes when
	convenient
Date: Wed, 3 Jun 2009 13:15:47 -0500
Message-ID: <20090603181547.GA10141@us.ibm.com>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<03412f8681d89c99ac575330381ab49f6e5e61ba.1244019829.git.matthltc@us.ibm.com>
	<20090603161046.GC7848@us.ibm.com>
	<20090603175242.GQ9285@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090603175242.GQ9285-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Wed, Jun 03, 2009 at 11:10:46AM -0500, Serge E. Hallyn wrote:
> > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > >  When all the tasks of a cgroup were successfully frozen we can avoid
> > >  the lazy FREEZING -> FROZEN transition and move into FROZEN during the
> > >  write to freezer.state.
> > 
> > Can you remind us then what the point of the FREEZING state is?
> > It doesn't look to me like, after this patch, a cgroup will
> > ever be FREEZING?
> 
> FREEZING is an intermediate state indicating that the cgroup is
> partially frozen and, unless userspace retries, it will remain so. 

Oh, so basically a cgroup will be in CGROUP_FREEZING state only
while try_to_freeze_cgroup() is looping over the tasks now?

-serge
