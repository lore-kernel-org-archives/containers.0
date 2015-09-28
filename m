From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] pidns: fix set/getpriority and ioprio_set/get in
	PRIO_USER mode
Date: Mon, 28 Sep 2015 16:00:09 -0700
Message-ID: <20150928160009.3a44a8a23a6bbdca2a0b9a57@linux-foundation.org>
References: <xm26io7a9lwz.fsf@sword-of-the-dawn.mtv.corp.google.com>
	<20150917142926.1a68072b19ef0ada47eabe43@linux-foundation.org>
	<874minis1b.fsf@x220.int.ebiederm.org>
	<xm268u7zaa1b.fsf@sword-of-the-dawn.mtv.corp.google.com>
	<87r3lnkqs3.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r3lnkqs3.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, ambrose-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bsegall-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 25 Sep 2015 00:32:28 -0500 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) wrote:

> bsegall-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org writes:
> 
> > ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:
> >
> >> Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:
> >>
> >>> On Wed, 16 Sep 2015 12:58:04 -0700 bsegall-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org wrote:
> >>>
> >>>> setpriority(PRIO_USER, 0, x) will change the priority of tasks outside
> >>>> of the current pid namespace. This is in contrast to both the other
> >>>> modes of setpriority and the example of kill(-1). Fix this. getpriority
> >>>> and ioprio have the same failure mode, fix them too.
> >>>
> >>> (cc Eric)
> >> (cc Containers)
> >>
> >> Interesting.  Strictly speaking the current behavior is not wrong.
> >> Searching for all threads with a given uid has nothing to do with pids
> >> so the pid namespace not limiting them is natural.
> >>
> >> In practice I don't think anyone cares either way (except people with
> >> one color or another of security hat on) so this might be a change we
> >> can actually make.
> >>
> >> In general it is probably better not to share uids and gids between
> >> containers.
> >>
> >> Ben do you have a use case where this actually matters?  Or was this a
> >> case of "That looks wrong..."?
> >>
> >> Eric
> >
> > I believe we generally want this for isolation of a process, without
> > requiring root initially (and a non-trivial uid_map, not to mention
> > creating the extra users, requires root). There are probably other holes
> > in using namespaces like this, but are they intended?
> 
> After some more thinking about it this patch sounds justifiable.
> 
> My goal with namespaces is not to build perfect isolation mechanisms
> as that can get into ill defined territory, but to build well defined
> mechanisms.  And to handle the corner cases so you can use only
> a single namespace with well defined results.
> 
> In this case you have found the two interfaces I am aware of that
> identify processes by uid instead of by pid.  Which quite frankly is
> weird.  Unfortunately the weird unexpected cases are hard to handle
> in the usual way.
> 
> I was hoping for a little more information.  Changes like this one we
> have to be careful of because someone might be depending on the current
> behavior.  I don't think they are and I do think this make sense as part
> of the pid namespace.
> 
> Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

My copy of the getpriority/setpriority manpage doesn't mention
interaction with namespaces at all.  Should it do so?
