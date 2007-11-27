From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] hijack: update task_alloc_security
Date: Tue, 27 Nov 2007 10:01:27 -0600
Message-ID: <20071127160127.GC32362__32392.2841962942$1196179445$gmane$org@sergelap.austin.ibm.com>
References: <474B7A51.3080300@au1.ibm.com>
	<820903.72193.qm@web36603.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <820903.72193.qm-ua+PKVt9nRSvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org):
> 
> --- Mark Nelson <markn-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org> wrote:
> 
> > Subject: [PATCH 2/2] hijack: update task_alloc_security
> > 
> > Update task_alloc_security() to take the hijacked task as a second
> > argument.
> 
> Could y'all bring me up to speed on what this is intended to
> accomplish so that I can understand the Smack implications?

It's basically like ptracing a process, forcing it to fork, then having
the child execute a file and continue as your child.  It takes part of
its state from the current process (stack etc), some from the hijacked
process (namespaces, keys?), and an lsm can decide for itself whose ->security
should be used for the child process.

There are a few reasons to do this.  One is to do an admin activity
inside a private namespace, i.e. doing a new mount in a vserver in which
only websphere is running.

Paul has another use for it - basically (iiuc) wanting to be able to
keep a set of namespaces around which he can always enter.  For mounts
namespaces that can be accomplished independent of hijack by setting up
a private mount tree and pivot_root()ing into there.  But for other
namespaces that isn't an option.

thanks,
-serge
