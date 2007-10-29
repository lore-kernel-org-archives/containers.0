From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH] pidns: Limit kill -1 and cap_set_all
Date: Mon, 29 Oct 2007 09:02:18 -0700
Message-ID: <1193673738.24087.176.camel@localhost>
References: <m1y7dp22d4.fsf@ebiederm.dsl.xmission.com>
	 <alpine.LFD.0.999.0710261105440.30120@woody.linux-foundation.org>
	 <m1r6jhzmov.fsf_-_@ebiederm.dsl.xmission.com>
	 <m1k5p9zk6b.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758112AbXJ2QCk@vger.kernel.org>
In-Reply-To: <m1k5p9zk6b.fsf_-_@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@tv-sign.ru>, Pavel Emelyanov <xemul@openvz.org>, "Sukadev Bhattiprolu [imap]" <sukadev@us.ibm.com>
List-Id: containers.vger.kernel.org

On Fri, 2007-10-26 at 14:37 -0600, Eric W. Biederman wrote:
> 
> +static int pid_in_pid_ns(struct pid *pid, struct pid_namespace *ns)
> +{
> +       return pid && (ns->level <= pid->level) &&
> +               pid->numbers[ns->level].ns == ns;
> +}

Could we blow this out a little bit?  (I think the blown-out version
lends itself to being better commented, and easier to read.)  Also, can
we think of any better name for this?  It seems a bit funky that:

	pid_in_pid_ns(mypid, &init_pid_ns);

would _ever_ return 0.  So, it isn't truly a test for belonging *in* a
namespace, but having that namespace be the lowest level one.  I think
Suka toyed with calling it an "active" or "primary" pid namespace.  That
differentiated mere membership in a pid namespace from the one that
actually molds that pid's view of the world.

static int pid_in_pid_ns(struct pid *pid, struct pid_namespace *ns)
{
	if (!pid)
		return 0;
	if (ns->level > pid->level)
		return 0;
	if (pid->numbers[ns->level].ns != ns)
		return 0;
	return 1;
}

-- Dave
