From: Enrico Weigelt <weigelt-EU+a56NjgY8@public.gmane.org>
Subject: Re: [Devel] Re: [RFC][PATCH] ns: Syscalls for better namespace
	sharing control.
Date: Thu, 27 May 2010 14:06:15 +0200
Message-ID: <20100527120615.GB31480@nibiru.local>
References: <m1mxyvrqvk.fsf@fess.ebiederm.org> <4B88E431.6040609@parallels.com>
	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8ECD99.3040107@cs.columbia.edu>
	<m18wa9glpo.fsf@fess.ebiederm.org>
Reply-To: weigelt-EU+a56NjgY8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m18wa9glpo.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

* Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> schrieb:

> At least for the network namespace there is a lot of value in being
> able to just change that single namespace.  Having multiple logical
> network stacks has it's challenges but has a lot of practical
> applications.  Especially when there is the possibility of private
> ipv4 addresses overlapping, or you have interfaces where you never
> want to forward between them but you want forwarding enabled.

ACK. One practical example: virtualized routes, eg. for VPNs.
Several years ago, I had a customer who provided VPNs via central
hubs - one of the main problem was that he had dedicated physical
machines for the VPN hubs due overlapping IP spaces. We've 
later migrated them to coliunx-based VMs to save a lot iron.

In one of my next projects this issue will pop up again.


cu
-- 
---------------------------------------------------------------------
 Enrico Weigelt    ==   metux IT service - http://www.metux.de/
---------------------------------------------------------------------
 Please visit the OpenSource QM Taskforce:
 	http://wiki.metux.de/public/OpenSource_QM_Taskforce
 Patches / Fixes for a lot dozens of packages in dozens of versions:
	http://patches.metux.de/
---------------------------------------------------------------------
