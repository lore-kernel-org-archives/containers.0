From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based	checkpointing/restart
Date: Thu, 30 Oct 2008 14:32:51 -0400
Message-ID: <4909FDD3.5090806__33461.1731967472$1225391791$gmane$org@cs.columbia.edu>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<200810271707.13580.major@openvz.org>
	<4905D2AD.1070309@cs.columbia.edu>
	<200810300902.47067.major@openvz.org>
	<20081030114747.GL15171@hawkmoon.kerlabs.com>
	<4909F2B5.7040907@cs.columbia.edu>
	<20081030181418.GO15171@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081030181418.GO15171-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> On Thu, Oct 30, 2008 at 01:45:25PM -0400, Oren Laadan wrote:
>>
>> Louis Rilling wrote:
>>> In Kerrighed this is kernel-based, and will remain kernel-based because we
>>> checkpoint a distributed task tree, and want to restart it as mush as possible
>>> with the same distribution. The distributed protocol used for restart is
>>> currently too fragile and complex to rely on customized user-space
>>> implementations. That said, if someone brings very good arguments in favor of
>>> userspace implementations, we might consider changing this.
>> Zap also has distributed checkpoint which does not require strict
>> kernel-side ordering. Do you need that because you do SSI ?
> 
> Yes. Tasks from different nodes have parent-children, session leader, etc.
> relationships, and the distributed management of struct pid lifecycle is a bit
> touchy too. By the way, splitting the checkpoint image in one file for each task
> helps us a lot to make restart parallel, because it is more efficient for the file
> system to handle parallel reads of different files from different nodes than
> parallel reads on a single file descriptor from different nodes.

You can also make parallel restart work with the single stream, without
much effort. Particularly if you store everything on the file system.

In both cases, the limiting factor is shared resources - where one task
cannot proceed with checkpoint because it waits for another task to first
(re)create that resource.

[...]

Oren.
