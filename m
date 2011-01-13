From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH] Teach cifs about network namespaces (take 2)
Date: Thu, 13 Jan 2011 12:52:47 -0600
Message-ID: <4D2F49FF.8070903__8517.84282499484$1294944908$gmane$org@parallels.com>
References: <4D2BDE07.40202@parallels.com>	<20110111071239.GL29064@count0.beaverton.ibm.com>	<4D2C63B2.6090109@parallels.com>	<4D2C9BC6.7000402@parallels.com>
	<20110111163000.04d02a7f@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110111163000.04d02a7f-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kir-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On 01/11/2011 03:30 PM, Jeff Layton wrote:
> On Tue, 11 Jan 2011 12:04:54 -0600
> Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> 
>> From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>>
>> Teach cifs about network namespaces, so mounting uses adresses/routing
>> visible from the container rather than from init context.
>>
>> Signed-off-by: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>> ---
>>
>> Updated with Matt's feedback and to apply to current linus-git.
>>
>>  fs/cifs/cifsglob.h |   37 +++++++++++++++++++++++++++++++++++++
>>  fs/cifs/connect.c  |   14 ++++++++++++--
>>  2 files changed, 49 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
>> index 606ca8b..8175d31 100644
>> --- a/fs/cifs/cifsglob.h
>> +++ b/fs/cifs/cifsglob.h
>> @@ -165,6 +165,9 @@ struct TCP_Server_Info {
>>  	struct socket *ssocket;
>>  	struct sockaddr_storage dstaddr;
>>  	struct sockaddr_storage srcaddr; /* locally bind to this IP */
>> +#ifdef CONFIG_NET_NS
>> +	struct net *net;
>> +#endif
>>  	wait_queue_head_t response_q;
>>  	wait_queue_head_t request_q; /* if more than maxmpx to srvr must block*/
>>  	struct list_head pending_mid_q;
>> @@ -224,6 +227,40 @@ struct TCP_Server_Info {
>>  };
>>  
> 
> I've got a patch queued that rearranges some fields in TCP_Server_Info
> according to pahole's recommendations. You may want to base this patch
> on that.

I confirmed that where it is just misses being affected by your patch
(offset but no fuzz), and it follows struct sockaddr_storage which
include/linux/socket.h A) pads to 128 bytes, B) adds an alignment
compiler directive to just to be sure.

So it seems reasonable to leave it where it is for the moment.

Rob
