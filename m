From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] Unify skb read/write functions and fix for fragmented
	buffers
Date: Mon, 16 Nov 2009 10:51:29 -0800
Message-ID: <87einyuwum.fsf@caffeine.danplanet.com>
References: <1257878856-25520-1-git-send-email-danms@us.ibm.com>
	<1257878856-25520-2-git-send-email-danms@us.ibm.com>
	<4B019A2C.9090507@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B019A2C.9090507-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Mon\, 16 Nov 2009 13\:30\:04 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

>> struct ckpt_hdr_socket_buffer {
>> struct ckpt_hdr h;
>> +	__u64 transport_header;
>> +	__u64 network_header;
>> +	__u64 mac_header;
>> +	__u64 lin_len; /* Length of linear data */
>> +	__u64 frg_len; /* Length of fragment data */
>> +	__u64 skb_len; /* Length of skb (adjusted) */
>> +	__u64 hdr_len; /* Length of skipped header */
>> +	__u64 mac_len;

OL> Can you use u32 (or even less ?) for these ?

Well, in the structure the len is an unsigned int, so u64 seemed
appropriate.

>> __s32 sk_objref;
>> __s32 pr_objref;
>> +	__u16 protocol;
>> +	__u16 nr_frags;
>> +	__u8 cb[48];

OL> Do you it will ever be required that cb[] be aligned ?

It's not aligned in the real structure and it's mostly opaque data, so
no, I wouldn't think so.

OL> I'm unsure how much of a performance issue this is - I sort of
OL> expected a comment from Dave Hansen about this; Did you consider
OL> reusing the restore_read_page() from checkpoint/memory.c ?  (and
OL> the matching checkpoint_dump_page() for the checkpoint).

Nope, I'll take a look.

>> +	for (i = 0; i < h->nr_frags; i++) {

OL> Sanitize h->nr_frags ?

To what?  I've already checked h->frg_len at this point, so I think
maybe just making sure frag_len never crosses zero would be
sufficient.

>> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>> +		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
>> +		u8 *vaddr = kmap(frag->page);

OL> Here, too, consider checkpoint_dump_page() to avoid kmap() ?

OL> It makes sense to have a scratch page to be used (also) for this,
OL> on ckpt_ctx - to avoid alloc/dealloc repeatedly.

Hmm, is there an alloc/dealloc here?

I'll take a look at checkpoint_dump_page()...

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
