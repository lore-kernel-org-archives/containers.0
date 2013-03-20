From: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] audit: provide namespace information in user
	originated records
Date: Wed, 20 Mar 2013 11:45:03 -0400
Message-ID: <20130320154503.GF20187@redhat.com>
References: <1363619405-6419-1-git-send-email-arozansk@redhat.com>
	<877gl48iaz.fsf@xmission.com> <20130319122408.GC20187@redhat.com>
	<874ng7gcst.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <874ng7gcst.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 19, 2013 at 05:00:50PM -0700, Eric W. Biederman wrote:
> It is always possible to pick the instance of /proc connected to the
> initial pid namespace.  And there is a device number you can use to say
> that.

I wasn't aware of that, I'll take a look, thanks!

> The reasons were simply that to my knowledge no one has thought through
> how audit records and namespaces make sense to interact.
> 
> My expectation would be that an extention of audit records would be
> logged on a per container basis.  But I don't have any motivating
> examples.

from what I've heard, there're two possibilites here: if a container is
understood to be "light virtualization", it should behave just like
another machine by having its own auditd daemon, sending records over
the network to the host. If that's not the case, a single auditd must be
present. But, the fact that you might want to run a sshd server inside a
container it might be desirable to have USER_AUTH records for example.
 
> I though you would have taken the time to run it at least once, or to
> perhaps have manually edited your example to see how things would fit
> together.

I did run it with different namespaces but not with userns. The example
was to show how the extra record would look like and I randomly picked
one. The idea is that auditd will know which namespaces are the original
ones and can use that to filter containers' records, which could be
filtered out by default.

> What was really missing from your RFC is a motivating example.  I sort
> of see that in your paragraph above but it isn't clear to me.
> 
> What is lost by not allowing USER audit records from processes in
> containers?  What is gained by implementing user process to have them?
> And of course what are your thoughts on preventing unprivileged users
> overwhelming the audit subsystem.

This is a bit fuzzy to me, perhaps due I'm not fully understanding
userns implementation yet, so bear with me:
I thought of changing so userns would not grant CAP_AUDIT_WRITE and
CAP_AUDIT_CONTROL unless the process already has it (i.e. it'd require
to be root on the init_ns). The 'init' process would start trusted
daemons with those capabilities then drop the capabilities for
everything else.
Does it make sense?

-- 
Aristeu
