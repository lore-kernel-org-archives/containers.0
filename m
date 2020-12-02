Return-Path: <SRS0=YKjC=FG=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E294C64E7B
	for <containers@archiver.kernel.org>; Wed,  2 Dec 2020 16:12:42 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7E01A205CA
	for <containers@archiver.kernel.org>; Wed,  2 Dec 2020 16:12:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E01A205CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id A0A1E87165;
	Wed,  2 Dec 2020 16:12:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id asEzCEIXDLi4; Wed,  2 Dec 2020 16:12:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 85F2E8715A;
	Wed,  2 Dec 2020 16:12:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 77C5FC163C;
	Wed,  2 Dec 2020 16:12:37 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F0A57C0052
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 16:12:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id DC4062E260
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 16:12:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id EU3csIdiQWWe
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 16:12:35 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by silver.osuosl.org (Postfix) with ESMTPS id C03A7203C7
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 16:12:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1606925553;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=bAQZJi/RrInzz1owaoShDGjHWxcR9Hen4gXOOVnOH+Q=;
 b=fyg2aF0zHBvWcig+kH9LgHml2Yz1wFaS9Tb00dEFtFCb1TlYZf+NXb5ln2xk21+uSYNA6f
 dGhi/8sZv7YCXy/e5WcNR65RhfYYVO6ASFmfJXyj+5LVlgU0UnkVmCoXpYry5mN2pubc3U
 HlRGWITTgy8e7aOeGSss2SyIK/0QsRs=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-496-svKMnCgTPhmkOFkTAuKO0w-1; Wed, 02 Dec 2020 11:12:31 -0500
X-MC-Unique: svKMnCgTPhmkOFkTAuKO0w-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com
 [10.5.11.15])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 48622185E48B;
 Wed,  2 Dec 2020 16:12:30 +0000 (UTC)
Received: from localhost (ovpn-114-104.ams2.redhat.com [10.36.114.104])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id AB5D15D6AC;
 Wed,  2 Dec 2020 16:12:29 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] kernel: automatically split user namespace extent
References: <20201126100839.381415-1-gscrivan@redhat.com>
 <87ft4pe7km.fsf@x220.int.ebiederm.org>
Date: Wed, 02 Dec 2020 17:12:27 +0100
In-Reply-To: <87ft4pe7km.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
 message of "Tue, 01 Dec 2020 11:53:45 -0600")
Message-ID: <87pn3schlg.fsf@redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
Cc: Linux Containers <containers@lists.linux-foundation.org>,
 linux-kernel@vger.kernel.org
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

Hi Eric,

ebiederm@xmission.com (Eric W. Biederman) writes:

> Nit: The tag should have been "userns:" rather than kernel.
>
> Giuseppe Scrivano <gscrivan@redhat.com> writes:
>
>> writing to the id map fails when an extent overlaps multiple mappings
>> in the parent user namespace, e.g.:
>>
>> $ cat /proc/self/uid_map
>>          0       1000          1
>>          1     100000      65536
>> $ unshare -U sleep 100 &
>> [1] 1029703
>> $ printf "0 0 100\n" | tee /proc/$!/uid_map
>> 0 0 100
>> tee: /proc/1029703/uid_map: Operation not permitted
>>
>> To prevent it from happening, automatically split an extent so that
>> each portion fits in one extent in the parent user namespace.
>
> I don't see anything fundamentally wrong with relaxing this
> restriction, but more code does have more room for bugs to hide.
>
> What is the advantage of relaxing this restriction?

we are running rootless containers in a namespace created with
newuidmap/newgidmap where the mappings look like:

$ cat /proc/self/uid_map
0       1000          1
1     110000      65536

users are allowed to create child user namespaces and specify the
mappings to use.  Doing so, they often hit the issue that the mappings
cannot overlap multiple extents in the parent user namespace.

The issue could be completely addressed in user space, but to me it
looks like an implementation detail that user space should not know
about.
In addition, it would also be slower (additional read of the current
uid_map and gid_map files) and must be implemented separately in each
container runtime.

>> $ cat /proc/self/uid_map
>>          0       1000          1
>>          1     110000      65536
>> $ unshare -U sleep 100 &
>> [1] 1552
>> $ printf "0 0 100\n" | tee /proc/$!/uid_map
>> 0 0 100
>> $ cat /proc/$!/uid_map
>>          0          0          1
>>          1          1         99
>>
>> Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
>> ---
>>  kernel/user_namespace.c | 62 ++++++++++++++++++++++++++++++++++-------
>>  1 file changed, 52 insertions(+), 10 deletions(-)
>>
>> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
>> index 87804e0371fe..b5542be2bd0a 100644
>> --- a/kernel/user_namespace.c
>> +++ b/kernel/user_namespace.c
>> @@ -706,6 +706,41 @@ const struct seq_operations proc_projid_seq_operations = {
>>  	.show = projid_m_show,
>>  };
>>  
>> +static void split_overlapping_mappings(struct uid_gid_map *parent_map,
>> +				       struct uid_gid_extent *extent,
>> +				       struct uid_gid_extent *overflow_extent)
>> +{
>> +	unsigned int idx;
>> +
>> +	overflow_extent->first = (u32) -1;
>> +
>> +	/* Split extent if it not fully contained in an extent from parent_map.  */
>> +	for (idx = 0; idx < parent_map->nr_extents; idx++) {
>
> Ouch!
>
> For the larger tree we perform binary searches typically and
> here you are walking every entry unconditionally.
>
> It looks like this makes the write O(N^2) from O(NlogN)
> which for a user facing function is not desirable.
>
> I think something like insert_and_split_extent may be ok.
> Incorporating your loop and the part that inserts an element.
>
> As written this almost doubles the complexity of the code,
> as well as making it perform much worse.  Which is a problem.

I've attempted to implement the new functionality at input validation
time to not touch the existing security checks.

I've thought the pattern for iterating the extents was fine as I've
taken it from mappings_overlap (even if it is used differently on an
unsorted array).

Thanks for the hint, I'll move the new logic when map_id_range_down() is
used and I'll send a v2.

Thanks,
Giuseppe

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
