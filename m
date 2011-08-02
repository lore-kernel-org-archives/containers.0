From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 4/4] parse options in the vfs level
Date: Tue, 2 Aug 2011 11:43:37 -0300
Message-ID: <4E380D19.7030307__14545.4923309901$1312296406$gmane$org@parallels.com>
References: <1311947059-17209-1-git-send-email-glommer@parallels.com>
	<1311947059-17209-5-git-send-email-glommer@parallels.com>
	<20110731013456.GM5404@dastard> <4E37F5C6.8060908@parallels.com>
	<20110802141806.GL2203@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110802141806.GL2203-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/02/2011 11:18 AM, Al Viro wrote:
> On Tue, Aug 02, 2011 at 10:04:06AM -0300, Glauber Costa wrote:
>
>> I am not sure either, but I still believe my proposal is superior to
>> write-to-a-file specifically. Writing to a file, be it in proc, sys,
>> or wherever, leaves a window of opportunity open between mounting a
>> filesystem and limiting its caches. Doing it on mount is atomic.
>>
>> Effectively, I see this limit as a property of a particular instance
>> of a mounted filesystem. Since all properties of a filesystem are
>> specified during mount, this becomes a natural extension.
>
> The trouble is, dentry tree is fundamentally a property of superblock.
> It's shared between *all* instances of that fs in all mount trees...

And how is it different from any fs-specific options, like the ones extX 
have, for instance ? Many of them seem to operate on a superblock.

If you mount a superblock somewhere, you can tweak specifics about its 
operation. If you mount it somewhere else, the assumption is you know 
what you're doing.
