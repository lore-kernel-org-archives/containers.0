From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Wed, 3 Jun 2009 11:27:46 +0000
Message-ID: <20090603112746.GA7000__38113.6592281566$1244028934$gmane$org@ff.dom.local>
References: <20090602211031.GA2850@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090602211031.GA2850-dUp/P3zyUuaNj9Bq2fkWzw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02-06-2009 23:10, Jarek Poplawski wrote:
> On Tue, Jun 02, 2009 at 09:16:27AM -0400, jamal wrote:
...
> Thanks for your courtesy as well. Alas, I'm not sure I can fully
> understand the current patch. You seem to redefine the ->get() method
> usage, so it looks for handle only for configured tp's. It might be
> right but I need more time to check this.

After the second look I have some questions:
- if it's really aimed to skip checking by ->get() tp's before they're
configured in ->change(), maybe instead of using tp_c to check this it
would be simpler to generally skip calling ->get() for newly created
tp's?
- otherwise the current method probably needs adding a tp_c check for
NULL in u32_destroy()?
- it seems this method would also need adding a 'handle' lookup to
the u32_change(); otherwise its 'handle' parameter isn't controlled
for for uniqueness, unless I miss something?

Cheers,
Jarek P.

> 
>> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
>> index 07372f6..5ad0b98 100644
>> --- a/net/sched/cls_u32.c
>> +++ b/net/sched/cls_u32.c
>> @@ -249,6 +249,9 @@ static unsigned long u32_get(struct tcf_proto *tp, u32 handle)
>>  	struct tc_u_hnode *ht;
>>  	struct tc_u_common *tp_c = tp->data;
>>  
>> +	if (!tp_c)
>> +		return 0;
>> +
>>  	if (TC_U32_HTID(handle) == TC_U32_ROOT)
>>  		ht = tp->root;
>>  	else
>> @@ -311,7 +314,6 @@ static int u32_init(struct tcf_proto *tp)
>>  	root_ht->tp_c = tp_c;
>>  
>>  	tp->root = root_ht;
>> -	tp->data = tp_c;
>>  	return 0;
>>  }
>>  
>> @@ -524,7 +526,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
>>  		      struct nlattr **tca,
>>  		      unsigned long *arg)
>>  {
>> -	struct tc_u_common *tp_c = tp->data;
>> +	struct tc_u_common *tp_c = tp->root->tp_c;
>>  	struct tc_u_hnode *ht;
>>  	struct tc_u_knode *n;
>>  	struct tc_u32_sel *s;
>> @@ -540,6 +542,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
>>  	if (err < 0)
>>  		return err;
>>  
>> +	tp->data = tp_c;
>>  	if ((n = (struct tc_u_knode*)*arg) != NULL) {
>>  		if (TC_U32_KEY(n->handle) == 0)
>>  			return -EINVAL;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
