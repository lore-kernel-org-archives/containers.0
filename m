From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/5][lxc] lxc_restart: Add --image option
Date: Wed, 24 Mar 2010 21:53:54 +0100
Message-ID: <4BAA7BE2.7060600@fr.ibm.com>
References: <20100319063912.GA25732@us.ibm.com>
	<20100319064046.GC25732@us.ibm.com> <4BA78276.2040308@fr.ibm.com>
	<20100324194851.GD20031@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100324194851.GD20031-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
> Daniel Lezcano [dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>> Sukadev Bhattiprolu wrote:
>>> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>>> Date: Wed, 10 Mar 2010 21:59:39 -0800
>>> Subject: [PATCH 2/5][lxc] lxc_restart: Add --image option
>>>
>>> The existing --directory option to lxc_restart expects the checkpoint state
>>> to be a directory. USERCR however uses a single regular file to store the
>>> checkpoint image. So add a --image option to enable checkpointing and
>>> restarting applications using USERCR.
>>>
>>> Depending on how the application was checkpointed, users should specify
>>> either --image=CHECKPOINT-IMAGE or the --directory=STATEFILE option (but not
>>> both).
>> It's a detail but I would prefer to replace --image by --statefile. So  
>> we can put --directory deprecated and use --statefile as a more generic  
>> name.
> 
> Ok will fix.

Thanks.
