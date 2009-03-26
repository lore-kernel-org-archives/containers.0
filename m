From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/6] /proc/pid/checkpointable
Date: Thu, 26 Mar 2009 08:29:12 -0500
Message-ID: <20090326132912.GC13639@us.ibm.com>
References: <49C0B6FF.5030104@cs.columbia.edu>
	<20090318135953.GE22636@us.ibm.com>
	<49C1201A.3050604@cs.columbia.edu>
	<20090318171840.GA29523@us.ibm.com>
	<49C1347F.3000601@cs.columbia.edu> <49C153AF.7070504@google.com>
	<1237407213.8286.198.camel@nimitz>
	<m17i2dx00b.fsf@fess.ebiederm.org>
	<20090325172938.GA18957@us.ibm.com> <49CB504A.2080400@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49CB504A.2080400-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (legoater-GANU6spQydw@public.gmane.org):
> Serge E. Hallyn wrote:
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> >>
> >>> On Wed, 2009-03-18 at 13:03 -0700, Mike Waychison wrote:
> >>>> Polluting the dmesg buffer with messages from common failures (consider 
> >>>> a multi-user cluster where checkpoints may or may not succeed) isn't 
> >>>> very useful.
> >>> Yeah, I've already gotten an earful from Serge and Dan S. about this. :)
> >>>
> >>> Serge suggested that, perhaps, the audit framework could be used.  We
> >>> might also use an ftrace buffer if we want to keep a whole ton of
> >>> messages around, too.
> >>>
> >>> dmesg is definitely not workable long-term at all.
> >> How about having place holder objects in the generated checkpoint.
> >> Then instead of having a failure you have a non-restoreable checkpoint.
> >> But you know which fd, or which mmaped region, or which other thing
> >> is causing the problem and if you want more information you can
> >> look at that resource.
> >>
> >> That gives user space the freedom and scrub out the non-checkpointable
> >> bits and replace them with something like /dev/null so that we can
> >> continue on and restore the checkpoint anyway, if we think our
> >> app can cope with some things going away.
> >>
> >> Eric
> > 
> > I like this idea.
> 
> yes. This is something required to replace stdios for example, when 
> you execute an application under ssh, checkpoint and then restart on 
> an other host. This a topical scenario for a batch manager in an HPC 
> environment. 
> 
> identified resources of the container are tracked to be ignored by 
> checkpoint and to be replaced by similar ones at restart.

So in that case how are the resources identified?  Does the user
specify them at checkpoint?  Do you look for specific strings
(/dev/pts/*) at restart?

-serge
