From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 00/16][cr][v3]: C/R file owner, locks, leases
Date: Wed, 04 Aug 2010 15:16:17 -0400
Message-ID: <4C59BC81.80401__19539.1572466635$1280949555$gmane$org@cs.columbia.edu>
References: <1280877097-12377-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1280918720.2566.18.camel@localhost>
	<20100804190112.GA11571@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100804190112.GA11571-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


On 08/04/2010 03:01 PM, Sukadev Bhattiprolu wrote:
> Steven Whitehouse [swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org] wrote:
> | Hi,
> |
> | On Tue, 2010-08-03 at 16:11 -0700, Sukadev Bhattiprolu wrote:
> |>  Checkpoint/restart file owner, file-locks and file-lease information.
> |>
> | Can you explain roughly how this is intended to work, or point me at a
> | document explaining it?
>
> Well, there is no document atm and I tried to explain how it is supposed
> to work in the patches that restart file-locks (patches 4. 9, 16).
>
> |
> | I'm trying to figure out how the file lock checkpoint will work with
> | cluster filesystems, or if there needs to be a mechanism to turn this
> | feature off for those filesystems. What prevents the lock state changing
> | in an incompatible way between the checkpoint and the restore?
>
> But I see that your question is about the bigger picture. Given that
> this question was asked on the previous version of the patchset, I will
> add a FAQ/description in patch 0 next time.
>
> For now, please see:
>
> 	http://marc.info/?l=linux-fsdevel&m=127657580718791&w=2
>

Would probably be a good idea to put something on the wiki
and/or inside Documentation/checkpoint/...

Oren
