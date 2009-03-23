From: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: lxc : linux containers tool 0.6.0 release
Date: Mon, 23 Mar 2009 17:38:16 +0800
Message-ID: <d95d44a20903230238j216e0a0avf262ae84a457ec87@mail.gmail.com>
References: <499EC673.8020808@fr.ibm.com>
	<d95d44a20903230048ke520376gd7701de00ff4e72d@mail.gmail.com>
	<20090323081810.GB2231@hack>
	<d95d44a20903230134j5d527b3cn3e7497069c128856@mail.gmail.com>
	<d95d44a20903230145m441abd8fga4bba277ba783e42@mail.gmail.com>
	<49C74DB3.50004@fr.ibm.com>
	<d95d44a20903230158l42459b45x3cc5e0c05113bb04@mail.gmail.com>
	<49C755B2.90104@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C755B2.90104-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LXC Development <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Thank you very much.

I have already added the lines:

#ifndef PR_CAPBSET_DROP
#define PR_CAPBSET_DROP 24
#endif

in the start.c, and it works now.

>
> This compilation error is coming from the distro you are using which does
> not provide the PR_CAPBSET_DROP. It has been fixed and will be in the
> lxc-0.6.1 which will come as soon as a setcap problem is resolved.
>
> Until I release this new version, you can hack lxc/src/lxc/start.c and add:
>
> #define PR_CAPBSET_DROP 24
>
> That should fix you problem.
>
>
>
>
>
>
