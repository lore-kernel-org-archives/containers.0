From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] pidns: Limit kill -1 and cap_set_all
Date: Mon, 29 Oct 2007 11:59:48 -0600
Message-ID: <m1pryxpzsb.fsf@ebiederm.dsl.xmission.com>
References: <m1y7dp22d4.fsf@ebiederm.dsl.xmission.com>
	<alpine.LFD.0.999.0710261105440.30120@woody.linux-foundation.org>
	<m1r6jhzmov.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5p9zk6b.fsf_-_@ebiederm.dsl.xmission.com>
	<1193673738.24087.176.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1193673738.24087.176.camel@localhost> (Dave Hansen's message of
	"Mon, 29 Oct 2007 09:02:18 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> On Fri, 2007-10-26 at 14:37 -0600, Eric W. Biederman wrote:
>> 
>> +static int pid_in_pid_ns(struct pid *pid, struct pid_namespace *ns)
>> +{
>> +       return pid && (ns->level <= pid->level) &&
>> +               pid->numbers[ns->level].ns == ns;
>> +}
>
> Could we blow this out a little bit?  (I think the blown-out version
> lends itself to being better commented, and easier to read.)  Also, can
> we think of any better name for this?  It seems a bit funky that:
>
> 	pid_in_pid_ns(mypid, &init_pid_ns);
>
> would _ever_ return 0.

It can't.

> So, it isn't truly a test for belonging *in* a
> namespace, but having that namespace be the lowest level one. 

No.  It is precisely a test for being in a namespace.
We first check ns->level to make certain it doesn't fall out
of the array, and then we check to see if the namespace we
are looking for is at that level.

pid->numbers[0].ns == &init_pid_ns.

> I think
> Suka toyed with calling it an "active" or "primary" pid namespace.  That
> differentiated mere membership in a pid namespace from the one that
> actually molds that pid's view of the world.

What we want for the test is a test for membership.


> static int pid_in_pid_ns(struct pid *pid, struct pid_namespace *ns)
> {
> 	if (!pid)
> 		return 0;
> 	if (ns->level > pid->level)
> 		return 0;
> 	if (pid->numbers[ns->level].ns != ns)
> 		return 0;
> 	return 1;
> }

I don't have a problem with that.  The rest of the checks for
this in kernel/pid.c are in the same form.

Eric
