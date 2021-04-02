Return-Path: <SRS0=BAQN=I7=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_RED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC89CC433B4
	for <containers@archiver.kernel.org>; Fri,  2 Apr 2021 14:46:19 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 80E2761006
	for <containers@archiver.kernel.org>; Fri,  2 Apr 2021 14:46:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80E2761006
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 4EE3F41848;
	Fri,  2 Apr 2021 14:46:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id u3FRBCZJC8jH; Fri,  2 Apr 2021 14:46:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id EB37B41835;
	Fri,  2 Apr 2021 14:46:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C88D5C000B;
	Fri,  2 Apr 2021 14:46:17 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7B8F6C000A
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Apr 2021 14:46:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 5BEBA4182A
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Apr 2021 14:46:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id o5n5DmOf_Fyp
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Apr 2021 14:46:15 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by smtp4.osuosl.org (Postfix) with ESMTPS id CD4DE41838
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Apr 2021 14:46:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1617374773;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=aOuQw7DpFlh88fS8SosgPD/I6DgHKfzHUUKxl8sNq2w=;
 b=f6r9JbYdXeTaP8JKPQ2MVHGhFoE1lETB5BfXEVx07nZSDymuaRh22lLkjKDZMXctR7HpaU
 LE3ONU9IuVcd4sopHaDFX4ORxAUjQACIucsA9QbdYZn8pgYA1BArY+5LTP2aG/Z6JlOpYF
 1KU3VFm5bWkNWEgqhB7dDYcRkl4UE+A=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-439-Ly2ZiBT0OFOCkjUN4tiX9w-1; Fri, 02 Apr 2021 10:46:11 -0400
X-MC-Unique: Ly2ZiBT0OFOCkjUN4tiX9w-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com
 [10.5.11.14])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 682E587A826;
 Fri,  2 Apr 2021 14:46:10 +0000 (UTC)
Received: from localhost (ovpn-112-54.ams2.redhat.com [10.36.112.54])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id C310E5D9F2;
 Fri,  2 Apr 2021 14:46:09 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH] kernel: automatically split user namespace extent
References: <20201126100839.381415-1-gscrivan@redhat.com>
 <87ft4pe7km.fsf@x220.int.ebiederm.org> <87pn3schlg.fsf@redhat.com>
 <20210402143212.GA18282@mail.hallyn.com>
Date: Fri, 02 Apr 2021 16:46:07 +0200
In-Reply-To: <20210402143212.GA18282@mail.hallyn.com> (Serge E. Hallyn's
 message of "Fri, 2 Apr 2021 09:32:12 -0500")
Message-ID: <87zgygg2xc.fsf@redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Cc: Linux Containers <containers@lists.linux-foundation.org>,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

Hi Serge,

"Serge E. Hallyn" <serge@hallyn.com> writes:

> On Wed, Dec 02, 2020 at 05:12:27PM +0100, Giuseppe Scrivano wrote:
>> Hi Eric,
>> 
>> ebiederm@xmission.com (Eric W. Biederman) writes:
>> 
>> > Nit: The tag should have been "userns:" rather than kernel.
>> >
>> > Giuseppe Scrivano <gscrivan@redhat.com> writes:
>> >
>> >> writing to the id map fails when an extent overlaps multiple mappings
>> >> in the parent user namespace, e.g.:
>> >>
>> >> $ cat /proc/self/uid_map
>> >>          0       1000          1
>> >>          1     100000      65536
>> >> $ unshare -U sleep 100 &
>> >> [1] 1029703
>> >> $ printf "0 0 100\n" | tee /proc/$!/uid_map
>> >> 0 0 100
>> >> tee: /proc/1029703/uid_map: Operation not permitted
>> >>
>> >> To prevent it from happening, automatically split an extent so that
>> >> each portion fits in one extent in the parent user namespace.
>> >
>> > I don't see anything fundamentally wrong with relaxing this
>> > restriction, but more code does have more room for bugs to hide.
>> >
>> > What is the advantage of relaxing this restriction?
>> 
>> we are running rootless containers in a namespace created with
>> newuidmap/newgidmap where the mappings look like:
>> 
>> $ cat /proc/self/uid_map
>> 0       1000          1
>> 1     110000      65536
>> 
>> users are allowed to create child user namespaces and specify the
>> mappings to use.  Doing so, they often hit the issue that the mappings
>> cannot overlap multiple extents in the parent user namespace.
>> 
>> The issue could be completely addressed in user space, but to me it
>> looks like an implementation detail that user space should not know
>> about.
>> In addition, it would also be slower (additional read of the current
>> uid_map and gid_map files) and must be implemented separately in each
>> container runtime.
>> 
>> >> $ cat /proc/self/uid_map
>> >>          0       1000          1
>> >>          1     110000      65536
>> >> $ unshare -U sleep 100 &
>> >> [1] 1552
>> >> $ printf "0 0 100\n" | tee /proc/$!/uid_map
>> >> 0 0 100
>> >> $ cat /proc/$!/uid_map
>> >>          0          0          1
>> >>          1          1         99
>> >>
>> >> Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
>> >> ---
>> >>  kernel/user_namespace.c | 62 ++++++++++++++++++++++++++++++++++-------
>> >>  1 file changed, 52 insertions(+), 10 deletions(-)
>> >>
>> >> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
>> >> index 87804e0371fe..b5542be2bd0a 100644
>> >> --- a/kernel/user_namespace.c
>> >> +++ b/kernel/user_namespace.c
>> >> @@ -706,6 +706,41 @@ const struct seq_operations proc_projid_seq_operations = {
>> >>  	.show = projid_m_show,
>> >>  };
>> >>  
>> >> +static void split_overlapping_mappings(struct uid_gid_map *parent_map,
>> >> +				       struct uid_gid_extent *extent,
>> >> +				       struct uid_gid_extent *overflow_extent)
>> >> +{
>> >> +	unsigned int idx;
>> >> +
>> >> +	overflow_extent->first = (u32) -1;
>> >> +
>> >> +	/* Split extent if it not fully contained in an extent from parent_map.  */
>> >> +	for (idx = 0; idx < parent_map->nr_extents; idx++) {
>> >
>> > Ouch!
>> >
>> > For the larger tree we perform binary searches typically and
>> > here you are walking every entry unconditionally.
>> >
>> > It looks like this makes the write O(N^2) from O(NlogN)
>> > which for a user facing function is not desirable.
>> >
>> > I think something like insert_and_split_extent may be ok.
>> > Incorporating your loop and the part that inserts an element.
>> >
>> > As written this almost doubles the complexity of the code,
>> > as well as making it perform much worse.  Which is a problem.
>> 
>> I've attempted to implement the new functionality at input validation
>> time to not touch the existing security checks.
>> 
>> I've thought the pattern for iterating the extents was fine as I've
>> taken it from mappings_overlap (even if it is used differently on an
>> unsorted array).
>> 
>> Thanks for the hint, I'll move the new logic when map_id_range_down() is
>> used and I'll send a v2.
>
> Hi,
>
> sorry if I miseed it.  Did you ever send a v2?

no worries, the v2 is here:

https://lkml.kernel.org/lkml/20201203150252.1229077-1-gscrivan@redhat.com/

Regards,
Giuseppe

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
