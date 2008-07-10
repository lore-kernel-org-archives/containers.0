From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 0/4] Container Freezer: Reuse Suspend Freezer
Date: Thu, 10 Jul 2008 09:42:31 +0900
Message-ID: <20080710094231.58d9e1b9.kamezawa.hiroyu__23294.233569368$1215650413$gmane$org@jp.fujitsu.com>
References: <20080707225823.502032693@us.ibm.com>
	<20080708123150.3034d83f.kamezawa.hiroyu@jp.fujitsu.com>
	<1215545954.9023.120.camel@localhost.localdomain>
	<6599ad830807081306l61622eadk215a25d02ee94b00@mail.gmail.com>
	<6599ad830807081307j811689aldf0f6cb38579c450@mail.gmail.com>
	<1215640723.7149.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1215640723.7149.35.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 09 Jul 2008 14:58:43 -0700
Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> 
> On Tue, 2008-07-08 at 13:07 -0700, Paul Menage wrote:
> > On Tue, Jul 8, 2008 at 1:06 PM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> > > On Tue, Jul 8, 2008 at 12:39 PM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > >>
> > >> One is to try and disallow users from moving frozen tasks. That doesn't
> > >> seem like a good approach since it would require a new cgroups interface
> > >> "can_detach()".
> > >
> > > Detaching from the old cgroup happens at the same time as attaching to
> > > the new cgroup, so can_attach() would work here.
> 
> Update: I've made a patch implementing this. However it might be better
> to just modify attach() to thaw the moving task rather than disallow
> moving the frozen task. Serge, Cedric, Kame-san, do you have any
> thoughts on which is more useful and/or intuitive?
> 

Thank you for explanation in previous mail.

Hmm, just thawing seems atractive but it will confuse people (I think).

I think some kind of process-group is freezed by this freezer and "moving
freezed task" is wrong(unexpected) operation in general.  And there will
be no demand to do that from users.
I think just taking "moving freezed task" as error-operation and returning
-EBUSY is better.

Thanks,
-Kame

> > And the whole can_attach()/attach() protocol needs reworking anyway,
> > see my email (hopefully) later today.
> > 
> > Paul
> 
> Interesting. I look forward to seeing this.
> 
> Cheers,
> 	-Matt
> 
> 
