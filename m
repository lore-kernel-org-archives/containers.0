From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 3/3] Compare namespaces when comparing addresses in
	auth_unix cache.
Date: Fri, 8 Apr 2011 10:08:34 -0500
Message-ID: <4D9F24F2.9020603__18753.5584824674$1302275382$gmane$org@parallels.com>
References: <4D9431B3.2070305@parallels.com> <20110405034641.GC6764@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110405034641.GC6764-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Kir Kolyshkin <kir-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Tim Spriggs <tims-DAzCR1AAk2Rg9hUCZPvPmw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 04/04/2011 10:46 PM, Serge E. Hallyn wrote:
> Quoting Rob Landley (rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
>> From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>>
>> The auth_unix cache needs to check network namespace when comparing
>> addresses. Add field to struct ip_map and extra argument to
>> __ip_map_lookup() so it has the information to do so, and add test.
>>
>> Signed-off-by: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>> ---
>>
>>  net/sunrpc/svcauth_unix.c |   21 ++++++++++++++-------
>>  1 file changed, 14 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
>> index 30916b0..63a2fa7 100644
>> --- a/net/sunrpc/svcauth_unix.c
>> +++ b/net/sunrpc/svcauth_unix.c

code code code

>> @@ -142,6 +145,7 @@ static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
>>  	struct ip_map *item = container_of(citem, struct ip_map, h);
>>  
>>  	strcpy(new->m_class, item->m_class);
>> +	new->m_net = item->m_net;
> 
> Does this need to take a reference?  Or is there no way for an
> entry to outlive its netns?  It sort of looks like
> svcauth_unix_info_release will ensure that doesn't happen, but
> I'm not convinced because other parts of the kernel can get
> to ip_map_init through the struct cache_detail.

When I wrote this I thought the transport's get_net() and put_net()
would pin it, but after re-reading, the sunrpc code is disgustingly
convoluted enough that I can't easily reconstruct my earlier reasoning.
 I'll add a get_net() and put_net() just to not have to worry about it.

Thanks,

Rob
