From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 4/4] parse options in the vfs level
Date: Tue, 2 Aug 2011 10:04:06 -0300
Message-ID: <4E37F5C6.8060908__29934.3502535068$1312290415$gmane$org@parallels.com>
References: <1311947059-17209-1-git-send-email-glommer@parallels.com>
	<1311947059-17209-5-git-send-email-glommer@parallels.com>
	<20110731013456.GM5404@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110731013456.GM5404@dastard>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/30/2011 10:34 PM, Dave Chinner wrote:
> On Fri, Jul 29, 2011 at 05:44:19PM +0400, Glauber Costa wrote:
>> This patch introduces a simple generic vfs option parser.
>> Right now, the only option we have is to limit the size of the dcache.
>>
>> So any user that wants to have a dcache entries limit, can specify:
>>
>>    mount -o whatever_options,vfs_dcache_size=XXX<dev>  <mntpoint>
>>
>> It is supposed to work well with remounts, allowing it to change
>> multiple over the course of the filesystem's lifecycle.
>>
>> I find mount a natural interface for handling filesystem options,
>> so that's what I've choosen. Feel free to yell at it at will if
>> you disagree.
>
> IMO, the whole point of having a configurable cache size maximum is
> that is can be changed at runtime. Tying it to mount options is a
> painful way to acheive that because the only way to change it would
> be via a remount command.
And what's wrong with a remount command? It's a quite natural operation.
Furthermore, changing it at runtime is important - and as you noted, 
quite doable, but it is not "the whole point of it".
The whole point of it is to allow a piece of the fs hierarchy to have
a limit on the cache sizes. So I expect the most common usage to be
at mount itself. Specifically for the use case I have in mind, when
a new container is created.

> I'm not sure what the best API is, but I'd prefer something that is
> specific to a superblock, not a vfs mount. Perhaps something in
> /sys/fs?

I am not sure either, but I still believe my proposal is superior to 
write-to-a-file specifically. Writing to a file, be it in proc, sys, or 
wherever, leaves a window of opportunity open between mounting a 
filesystem and limiting its caches. Doing it on mount is atomic.

Effectively, I see this limit as a property of a particular instance of 
a mounted filesystem. Since all properties of a filesystem are specified 
during mount, this becomes a natural extension.

Let me know what you think
