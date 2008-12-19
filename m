From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/5] pid: use namespaced iteration on processes while
	managing priority
Date: Thu, 18 Dec 2008 20:37:08 -0800
Message-ID: <1229661428.8011.24.camel@localhost>
References: <1229618553-6348-1-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
	<1229618553-6348-6-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
	<m1d4fp8ju3.fsf@frodo.ebiederm.org> <20081218181317.GA14409@us.ibm.com>
	<m1wsdx71r7.fsf@frodo.ebiederm.org>
	<1229661036.8011.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1229661036.8011.21.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Dave <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-12-18 at 20:30 -0800, Matt Helsley wrote:
> On Thu, 2008-12-18 at 10:54 -0800, Eric W. Biederman wrote:
> > "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> > 
> > 
> > > The uid check needs to be fixed for user namespaces, agreed.  I could
> > > go either way though on whether we should also restrict to the same
> > > pidns.
> > 
> > It would be a subtle unexpected semantic change, that we would need
> > to copy linux-abi and document etc.  I'm not convinced it is that
> > useful.
> > 
> > I'm inclined to keep the semantics pure until there is some real
> > experience from the field on issues like this.
> 
> Well the man page talks about PRIO_PROCESS and PRIO_PGRP and in those
> cases it looks like "who" is really a pid or pgrp id:
> 
> >        The  value  which  is one of PRIO_PROCESS, PRIO_PGRP, or PRIO_USER, and
> >        who  is  interpreted  relative  to  which  (a  process  identifier  for
> >        PRIO_PROCESS, process group identifier for PRIO_PGRP, and a user ID for
> >        PRIO_USER). 
> 
> It looks to me like restricting by pidns is required if "which" is
> PRIO_PROCESS or PRIO_PGRP. If "which" is PRIO_USER then yes, it sounds
> like a user ns issue.

Eh, ignore me. Looks like this is already the case in the code.

> Cheers,
> 	-Matt Helsley
