From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: restart (mktree) program usage
Date: Fri, 18 Sep 2009 08:58:54 +0200
Message-ID: <4AB32FAE.8020404@free.fr>
References: <20090909055636.GA27622@us.ibm.com> <4AA82B7C.8080107@librato.com>
	<20090917013546.GA30161@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090917013546.GA30161-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/17/2009 03:35 AM, Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org] wrote:
> | 
> | 
> | Sukadev Bhattiprolu wrote:
> | > I have a usage question on the 'restart' (formerly mktree) program.
> | > 
> | > In the following container c/r case: 
> | > 
> | > 	- create a container
> | > 	- log in to the container,
> | > 	- restore filesystem(s) from snapshot
> | > 	- restart application from checkpoint
> | 
> | FWIW, I'd expect that future versions of 'restart' will be capable
> | of doing this entire setup, (filesystem(s) included), as it matures.
> | 
> | Note that this use case that you suggest will only work to restart
> | subtrees; it is unsuitable for full containers (with pids) because
> | the pid of init (1) will already be in use.
> 
> True. But if originally the application was started as:
> 
> 	Create container
> 	Login to contaienr
> 	Set up filesystem
> 	Start application

You should take a look at lxc, which is doing what you want.

Metacluster (IBM's proprietary C/R solution) is fully integrated with lxc 
containers and the current lxc development plans focus on externalizing 
some home made C/R plugins we've been doing for it. We should then spend 
some time on blcr.

And we expect you guys to work on oren's patchset ? but I guess that will 
all depend on how 'proprietary' is mktree, by 'proprietary' I mean 
dependent on the kernel patch. 

Cheers,

C.
