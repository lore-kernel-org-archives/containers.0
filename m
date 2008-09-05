From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 5 Sep 2008 06:58:38 +0400
Message-ID: <20080905025838.GA2789__27541.8142941364$1220583539$gmane$org@x200.localdomain>
References: <20080821220432.GT31136@x200.localdomain>
	<48C012B8.10606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C012B8.10606-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Sep 04, 2008 at 06:54:16PM +0200, Patrick McHardy wrote:
> adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>> Make untracked conntrack per-netns. Compare conntracks with relevant
>> untracked one.
>>
>> The following code you'll start laughing at this code:
>>
>> 	if (ct == ct->ct_net->ct.untracked)
>> 		...
>>
>> let me remind you that ->ct_net is set in only one place, and never
>> overwritten later.
>>
>> All of this requires some surgery with headers, otherwise horrible circular
>> dependencies. And we lost nf_ct_is_untracked() as function, it became macro.
>
> I think you could avoid this mess by using a struct nf_conntrack
> for the untracked conntrack instead of struct nf_conn. It shouldn't
> make any difference since its ignored anyways.

Ewww, can I?

Regardless of netns, switching to

	struct nf_conntrack nf_conntrack_untracked;

means we must be absolutely sure that every place which uses, say,
ct->status won't get untracked conntrack.

For example, does setting IPS_NAT_DONE_MASK and IPS_CONFIRMED_BIT on
untracked conntracked really necessary?

In conntrack_mt_v0() "ct->status" can be used even for untracked connection,
is this right?

>>  struct netns_ct {
>>  	atomic_t		count;
>> @@ -12,5 +13,7 @@ struct netns_ct {
>>  	struct hlist_head	*expect_hash;
>>  	int			expect_vmalloc;
>>  	struct hlist_head	unconfirmed;
>> +	/* Fake conntrack entry for untracked connections */
>> +	struct nf_conn		untracked;
>>  };
