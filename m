From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch -mm 1/5] mqueue namespace : add struct mq_namespace
Date: Thu, 4 Oct 2007 08:32:36 -0500
Message-ID: <20071004133236.GD6460@sergelap.austin.ibm.com>
References: <m1ir5plr3c.fsf@ebiederm.dsl.xmission.com>
	<470237C7.5000902@fr.ibm.com> <20071002163020.GA11207@us.ibm.com>
	<47034868.5010505@fr.ibm.com>
	<20071003135955.GA7934@sergelap.austin.ibm.com>
	<4703A30F.2010007@fr.ibm.com> <20071003165644.GA338@us.ibm.com>
	<m1myv0ceqp.fsf@ebiederm.dsl.xmission.com>
	<20071003170930.GB338@us.ibm.com> <4704E6C7.5010908@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4704E6C7.5010908-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > Eric W. Biederman [ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org] wrote:
> > | sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:
> > | 
> > | > Cedric Le Goater [clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
> > | > | > I think you and Eric (and I) are disagreeing about those limitations.
> > | > | > You take it for granted that a sibling pidns is off limits for signals.
> > | > | > But the signal wasn't sent using a pid, but using a file (in SIGIO
> > | > | > case).  So since the fs was shared, the signal should be sent.  An
> > | > | > event happened, and the receiver wants to know about it.
> > | > | 
> > | > | seen that way I agree. 
> > | > | 
> > | > | si_code is set to SI_MESGQ, but what do we put in si_pid ? 0 ?
> > | > | 
> > | > | we could use the si_errno to pass extra info, like the sending process 
> > | > | lives in a // world ...
> > | >
> > | > Does the receiver need to know that sender is in a // world ? 
> 
> probably not. it would mean that the user is container aware. bad idea.

Remember we don't have to hide the fact that the user is in a
container.  Just enough to make it convenient, but not to the
point of going out of our way to try and hide the fact for no
other reason than to hide the fact.

> > | What is a // world ?
> > 
> > Parallel world/universe :-)
> > 
> > I am assuming Cedric used that to refer to a sibling pid ns.
> 
> yes :) 
> 
> Thanks !
> 
> C.
