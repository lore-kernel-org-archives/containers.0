From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] hijack: update task_alloc_security
Date: Wed, 28 Nov 2007 08:54:22 -0600
Message-ID: <20071128145422.GC3820__16554.0917813361$1196262013$gmane$org@sergelap.austin.ibm.com>
References: <474B78CB.5070607@au1.ibm.com> <474B7A51.3080300@au1.ibm.com>
	<474BB095.8080302@manicmethod.com>
	<1196174188.3925.32.camel@moss-spartans.epoch.ncsc.mil>
	<20071127154356.GA32362@sergelap.austin.ibm.com>
	<474D0188.2040600@crispincowan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <474D0188.2040600-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Crispin Cowan <crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Joshua Brindle <method-PzTJMJMxY2mwxnkjfAeQoA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Crispin Cowan (crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org):
> Serge E. Hallyn wrote:
> > Quoting Stephen Smalley (sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org):
> >   
> >> I agree with this part - we don't want people to have to choose between
> >> using containers and using selinux, so if hijack is going to be a
> >> requirement for effective use of containers, then we need to make them
> >> work together.
> >>     
> > Absolutely, we just need to decide how to properly make it work with
> > selinux.  Maybe we check for
> >
> > 	allow (current_domain):(hijacked_process_domain) hijack
> > 	type_transition hijacked_process_domain \
> > 		vserver_enter_binary_t:process vserver1_hijack_admin_t;
> >   
> Is there to be an LSM hook, so that modules can decide on an arbitrary
> decision of whether to allow a hijack? So that this "do the right
> SELinux" thing can be generalized for all LSMs to do the right thing.

Currently:

	1. the permission is granted through ptrace
	2. the lsm knows a hijack is going in security_task_alloc()
		when task != current

so the lsm has all the information it needs.  But I have no objection
to a separate security_task_hijack() hook if you find the ptrace hook
insufficient.

-serge
