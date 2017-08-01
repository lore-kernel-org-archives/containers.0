From: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH 3/5] ima: mamespace audit status flags
Date: Tue, 1 Aug 2017 13:25:31 -0400
Message-ID: <2848EE0A-2DB8-420B-A611-60967EB90F5C__32219.6591449485$1501608108$gmane$org@linux.vnet.ibm.com>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
	<20170720225033.21298-4-mkayaalp@linux.vnet.ibm.com>
	<20170801171702.f2szj5huzbt7fdfl@docker>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170801171702.f2szj5huzbt7fdfl@docker>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tycho Andersen <tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org


> On Aug 1, 2017, at 1:17 PM, Tycho Andersen <tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org> wrote:
> 
> Hi Mehmet,
> 
> On Thu, Jul 20, 2017 at 06:50:31PM -0400, Mehmet Kayaalp wrote:
>> --- a/security/integrity/ima/ima_ns.c
>> +++ b/security/integrity/ima/ima_ns.c
>> @@ -301,3 +301,24 @@ struct ns_status *ima_get_ns_status(struct ima_namespace *ns,
>> 
>> 	return status;
>> }
>> +
>> +#define IMA_NS_STATUS_ACTIONS	IMA_AUDIT
>> +#define IMA_NS_STATUS_FLAGS	IMA_AUDITED
>> +
> 
> Seems like these are defined in ima.h above in the patch, and
> re-defined here?

Yes, it should be in the ima.h only.

>> +unsigned long iint_flags(struct integrity_iint_cache *iint,
>> +			 struct ns_status *status)
>> +{
>> +	if (!status)
>> +		return iint->flags;
>> +
>> +	return iint->flags & (status->flags & IMA_NS_STATUS_FLAGS);
> 
> Just to confirm, is there any situation where:
> 
>    iint->flags & IMA_NS_STATUS_FLAGS != status->flags & IMA_NS_STATUS_FLAGS
> 
> ? i.e. can this line just be:
> 
>    return status->flags & IMA_NS_STATUS_FLAGS;
> 

As Guilherme had pointed out, the first & should be |.

Mehmet
