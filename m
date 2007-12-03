From: Crispin Cowan <crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org>
Subject: Re: [PATCH 2/2] hijack: update task_alloc_security
Date: Mon, 03 Dec 2007 11:43:23 -0800
Message-ID: <47545C5B.8090908__1942.67663541741$1196711155$gmane$org@crispincowan.com>
References: <474B78CB.5070607@au1.ibm.com> <474B7A51.3080300@au1.ibm.com>
	<474BB095.8080302@manicmethod.com>
	<1196174188.3925.32.camel@moss-spartans.epoch.ncsc.mil>
	<20071127154356.GA32362@sergelap.austin.ibm.com>
	<474D0188.2040600@crispincowan.com>
	<20071128145422.GC3820@sergelap.austin.ibm.com>
	<474E3E4E.3060908@crispincowan.com>
	<20071129153815.GA8140@sergelap.austin.ibm.com>
	<47520568.6030108@crispincowan.com>
	<20071203145012.GB9008@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071203145012.GB9008-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Joshua Brindle <method-PzTJMJMxY2mwxnkjfAeQoA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Crispin Cowan (crispin-RL8T2ARnKKfZw9hOtrW0rA@public.gmane.org):
>   
>> I think that CAP_NS_OVERRIDE|CAP_SYS_PTRACE is a problem because of the
> Oops, yeah I meant &.
>   
Cool. With & then I have no problem at all.

Thanks,
    Crispin

-- 
Crispin Cowan, Ph.D.               http://crispincowan.com/~crispin
CEO, Mercenary Linux		   http://mercenarylinux.com/
	       Itanium. Vista. GPLv3. Complexity at work
