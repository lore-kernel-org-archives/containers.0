From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: ckpt-v20-dev, ckpt-v21-rc1
Date: Wed, 31 Mar 2010 12:33:39 -0500
Message-ID: <20100331173339.GA19371@us.ibm.com>
References: <4BB1997B.1010901@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BB1997B.1010901-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> I pulled all the recent patches in linux-cr (except for ipv6 fixup
> set), and created the following two branches:
> 
> ckpt-v20-dev - patches applied onto pof v20
> ckpt-v21-rc1 - patches folded into a clean patchset
> 
> Likewise with user-cr (but with more exceptions - working now on
> pulling more patches in).
> 
> This is totally untested except for successful compilation...
> 
> Oren.

v21 with the recent patches applied seems rock-solid to me, on
x86-64, s390x, and powerpc.

recent patches means:
	skip down interfaces v2,
	put fops->checkpoint under ifdef
	get rid of ckpt_hdr_vpids,
	export net checkpoint fns

for kernel and

	Add --nonetns switch to user-cr checkpoint
	fix vpids
	user-c/r: get rid of ckpt_hdr_vpids

to user-cr#ckpt-v20-dev

Do we want to try and incorporate Matt's patchset to clear out
linux-2.6/checkpoint/ next, or ship what we have?

-serge
