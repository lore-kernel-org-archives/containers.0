From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/4] cgroup freezer: Avoid lazy state changes when
	convenient
Date: Sun, 07 Jun 2009 16:36:07 -0500
Message-ID: <m3y6s3bubc.fsf@pobox.com>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<03412f8681d89c99ac575330381ab49f6e5e61ba.1244019829.git.matthltc@us.ibm.com>
	<20090603161046.GC7848@us.ibm.com> <20090603175242.GQ9285@us.ibm.com>
	<20090603181547.GA10141@us.ibm.com> <20090604031842.GR9285@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090604031842.GR9285-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Matt Helsley's message of
	"Wed\, 3 Jun 2009 20\:18\:42 -0700")
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> On Wed, Jun 03, 2009 at 01:15:47PM -0500, Serge E. Hallyn wrote:
>> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> > On Wed, Jun 03, 2009 at 11:10:46AM -0500, Serge E. Hallyn wrote:
>> > > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> > > >  When all the tasks of a cgroup were successfully frozen we can avoid
>> > > >  the lazy FREEZING -> FROZEN transition and move into FROZEN during the
>> > > >  write to freezer.state.
>> > > 
>> > > Can you remind us then what the point of the FREEZING state is?
>> > > It doesn't look to me like, after this patch, a cgroup will
>> > > ever be FREEZING?
>> > 
>> > FREEZING is an intermediate state indicating that the cgroup is
>> > partially frozen and, unless userspace retries, it will remain so. 
>> 
>> Oh, so basically a cgroup will be in CGROUP_FREEZING state only
>> while try_to_freeze_cgroup() is looping over the tasks now?
>
> Not quite. freeze_task() can fail because of vfork. If it fails we do
> some additional checks to make sure it'll eventually be freezable. If so
> then we know we missed one. That's when it stays in the FREEZING
> state until the next time userspace writes FROZEN or THAWED to freezer.state.

Not really a comment on your patch, but some puzzlement regarding this
treatment of vfork.

I see how the do_fork code makes the freezer skip a task which is
waiting in vfork.  But is there anything preventing a vfork'd child from
being frozen (e.g. before it execs or exits)?  As far as I can tell this
isn't prevented, but perhaps it should be, since the parent cannot enter
frozen state until after the child has called mm_release.

Does the FREEZING state in cgroup_freezer.c exist solely for the sake of
vfork?  If so, it would help reviewers quite a bit to have that
documented in the code.
