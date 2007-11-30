From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/2] namespaces: introduce sys_hijack (v10)
Date: Thu, 29 Nov 2007 19:37:07 -0700
Message-ID: <m1wss0a27g.fsf@ebiederm.dsl.xmission.com>
References: <474B78CB.5070607@au1.ibm.com> <474BC017.6060801@crispincowan.com>
	<20071127161132.GD32362@sergelap.austin.ibm.com>
	<1196186964.3925.129.camel@moss-spartans.epoch.ncsc.mil>
	<20071127223829.GA21753@sergelap.austin.ibm.com>
	<1196262054.13820.23.camel@moss-spartans.epoch.ncsc.mil>
	<20071128152359.GA4756@sergelap.austin.ibm.com>
	<474F70B3.5020006@au1.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <474F70B3.5020006-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org> (Mark Nelson's message of "Fri, 30
	Nov 2007 13:08:51 +1100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mark Nelson <markn-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Crispin Cowan <crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org>, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

Mark Nelson <markn-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org> writes:

> Hi Paul and Eric,
>
> Do you guys have any objections to dropping the hijack_pid() and
> hijack_cgroup() parts of sys_hijack, leaving just hijack_ns() (see
> below for discussion)?

I need to step back and study what is being proposed.

My gut feeling is that you are proposing something that does not
support forking me a process inside a container so I can have a
shell without having to run a login program.

There is a reason I proposed ptrace as an initial prototype.

All of the other uses of enter in a namespace context I feel confident
we can support by just having proper virtual filesystems available
to processes outside of the container.  For monitoring and control.

Eric
