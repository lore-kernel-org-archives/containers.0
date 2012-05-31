From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 01/12] container quota: add kernel configuration for
	container quota.
Date: Thu, 31 May 2012 13:01:32 +0400
Message-ID: <4FC7336C.3060802__10011.3548142419$1338455038$gmane$org@parallels.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<1338389946-13711-2-git-send-email-jeff.liu@oracle.com>
	<4FC73318.3020709@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4FC73318.3020709-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Cc: tytso-3s7WtUTddSA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 05/31/2012 01:00 PM, Glauber Costa wrote:
> On 05/30/2012 06:58 PM, jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org wrote:
>> Add kernel configuration for container quota.
>>
>> Signed-off-by: Jie Liu<jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> ---
>> fs/quota/Kconfig | 9 +++++++++
>> 1 files changed, 9 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/quota/Kconfig b/fs/quota/Kconfig
>> index 880fd98..2dd3e83 100644
>> --- a/fs/quota/Kconfig
>> +++ b/fs/quota/Kconfig
>> @@ -16,6 +16,15 @@ config QUOTA
>> with the quota tools. Probably the quota support is only useful for
>> multi user systems. If unsure, say N.
>>
>> +config NS_QUOTA
>> + bool "Mount namespace quota support"
>> + depends on QUOTA
>> + default n
>> + help
>> + If you say Y here, you will be able to set per container user limits
>> + for disk usage (also called disk quotas). Currently, it works for the
>> + ext4 file system only for demonstration purpose.
>> +
>
> That should depend on mount namespaces as well.
>

Which it already does, since there seems to be no switch for it.
duh
