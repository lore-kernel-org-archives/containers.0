Return-Path: <SRS0=NWjS=FF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5841FC64E8A
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 17:54:24 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8D59421741
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 17:54:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D59421741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id A173385755;
	Tue,  1 Dec 2020 17:54:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ol0g8i2HOxMb; Tue,  1 Dec 2020 17:54:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B40898560E;
	Tue,  1 Dec 2020 17:54:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9ED86C0859;
	Tue,  1 Dec 2020 17:54:21 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 83643C0052
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 17:54:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 6656E85625
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 17:54:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id onvVeKKiHnyM
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 17:54:19 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id AAD5C8560E
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 17:54:19 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out03.mta.xmission.com with esmtps (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kk9qz-006d9m-5Z; Tue, 01 Dec 2020 10:54:17 -0700
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com)
 by in02.mta.xmission.com with esmtpsa (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kk9qy-004hnJ-3X; Tue, 01 Dec 2020 10:54:16 -0700
From: ebiederm@xmission.com (Eric W. Biederman)
To: Giuseppe Scrivano <gscrivan@redhat.com>
References: <20201126100839.381415-1-gscrivan@redhat.com>
Date: Tue, 01 Dec 2020 11:53:45 -0600
In-Reply-To: <20201126100839.381415-1-gscrivan@redhat.com> (Giuseppe
 Scrivano's message of "Thu, 26 Nov 2020 11:08:39 +0100")
Message-ID: <87ft4pe7km.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kk9qy-004hnJ-3X; ; ; mid=<87ft4pe7km.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX1+Fu0dFA+bYSGa77HVml2uWF1UtEkv3LNk=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH] kernel: automatically split user namespace extent
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
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


Nit: The tag should have been "userns:" rather than kernel.

Giuseppe Scrivano <gscrivan@redhat.com> writes:

> writing to the id map fails when an extent overlaps multiple mappings
> in the parent user namespace, e.g.:
>
> $ cat /proc/self/uid_map
>          0       1000          1
>          1     100000      65536
> $ unshare -U sleep 100 &
> [1] 1029703
> $ printf "0 0 100\n" | tee /proc/$!/uid_map
> 0 0 100
> tee: /proc/1029703/uid_map: Operation not permitted
>
> To prevent it from happening, automatically split an extent so that
> each portion fits in one extent in the parent user namespace.

I don't see anything fundamentally wrong with relaxing this
restriction, but more code does have more room for bugs to hide.

What is the advantage of relaxing this restriction?

> $ cat /proc/self/uid_map
>          0       1000          1
>          1     110000      65536
> $ unshare -U sleep 100 &
> [1] 1552
> $ printf "0 0 100\n" | tee /proc/$!/uid_map
> 0 0 100
> $ cat /proc/$!/uid_map
>          0          0          1
>          1          1         99
>
> Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
> ---
>  kernel/user_namespace.c | 62 ++++++++++++++++++++++++++++++++++-------
>  1 file changed, 52 insertions(+), 10 deletions(-)
>
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index 87804e0371fe..b5542be2bd0a 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -706,6 +706,41 @@ const struct seq_operations proc_projid_seq_operations = {
>  	.show = projid_m_show,
>  };
>  
> +static void split_overlapping_mappings(struct uid_gid_map *parent_map,
> +				       struct uid_gid_extent *extent,
> +				       struct uid_gid_extent *overflow_extent)
> +{
> +	unsigned int idx;
> +
> +	overflow_extent->first = (u32) -1;
> +
> +	/* Split extent if it not fully contained in an extent from parent_map.  */
> +	for (idx = 0; idx < parent_map->nr_extents; idx++) {

Ouch!

For the larger tree we perform binary searches typically and
here you are walking every entry unconditionally.

It looks like this makes the write O(N^2) from O(NlogN)
which for a user facing function is not desirable.

I think something like insert_and_split_extent may be ok.
Incorporating your loop and the part that inserts an element.

As written this almost doubles the complexity of the code,
as well as making it perform much worse.  Which is a problem.


> +		struct uid_gid_extent *prev;
> +		u32 first, last, prev_last, size;
> +
> +		if (parent_map->nr_extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
> +			prev = &parent_map->extent[idx];
> +		else
> +			prev = &parent_map->forward[idx];
> +
> +		first = extent->lower_first;
> +		last = extent->lower_first + extent->count - 1;
> +		prev_last = prev->first + prev->count - 1;
> +
> +		if ((first <= prev_last) && (last > prev_last)) {
> +			size = prev_last - first + 1;
> +
> +			overflow_extent->first = extent->first + size;
> +			overflow_extent->lower_first = extent->lower_first + size;
> +			overflow_extent->count = extent->count - size;
> +
> +			extent->count = size;
> +			return;
> +		}
> +	}
> +}
> +
>  static bool mappings_overlap(struct uid_gid_map *new_map,
>  			     struct uid_gid_extent *extent)
>  {
> @@ -852,6 +887,7 @@ static ssize_t map_write(struct file *file, const char __user *buf,
>  	struct uid_gid_map new_map;
>  	unsigned idx;
>  	struct uid_gid_extent extent;
> +	struct uid_gid_extent overflow_extent;
>  	char *kbuf = NULL, *pos, *next_line;
>  	ssize_t ret;
>  
> @@ -946,18 +982,24 @@ static ssize_t map_write(struct file *file, const char __user *buf,
>  		     extent.lower_first)
>  			goto out;
>  
> -		/* Do the ranges in extent overlap any previous extents? */
> -		if (mappings_overlap(&new_map, &extent))
> -			goto out;
> +		do {
> +			/* Do the ranges in extent overlap any previous extents? */
> +			if (mappings_overlap(&new_map, &extent))
> +				goto out;

Why should mappings_overlap be called in the loop?   Will splitting an
extent create the possibility for creating overlapping mappings?

> -		if ((new_map.nr_extents + 1) == UID_GID_MAP_MAX_EXTENTS &&
> -		    (next_line != NULL))
> -			goto out;
> +			if ((new_map.nr_extents + 1) == UID_GID_MAP_MAX_EXTENTS &&
> +			    (next_line != NULL))
> +				goto out;
>  
> -		ret = insert_extent(&new_map, &extent);
> -		if (ret < 0)
> -			goto out;
> -		ret = -EINVAL;
> +			split_overlapping_mappings(parent_map, &extent, &overflow_extent);
> +
> +			ret = insert_extent(&new_map, &extent);
> +			if (ret < 0)
> +				goto out;
> +			ret = -EINVAL;
> +
> +			extent = overflow_extent;
> +		} while (overflow_extent.first != (u32) -1);
>  	}
>  	/* Be very certaint the new map actually exists */
>  	if (new_map.nr_extents == 0)

Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
