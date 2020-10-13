Return-Path: <SRS0=kI60=DU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F2FFC43457
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 22:45:12 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 27FF821D7A
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 22:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="AXj8ChkB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27FF821D7A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id C13C08778B;
	Tue, 13 Oct 2020 22:45:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NrpfFbTTdwyq; Tue, 13 Oct 2020 22:45:11 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 201CC87774;
	Tue, 13 Oct 2020 22:45:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 12544C07FF;
	Tue, 13 Oct 2020 22:45:11 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 12EE7C0051
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 22:45:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 0E787875E5
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 22:45:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id E8aJTyZu1Iwa
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 22:45:07 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 70BAB875E3
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 22:45:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1602629106;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=eL27MHQVYn4ElBKK1XQ1LogMRdkFND/1MAckF558KzI=;
 b=AXj8ChkBAZzcbSOevsHRc7U2ksHnDXOGIYMo0TqKyWddeayUudPKTmmW14kRTqGE/3RVaE
 yKAr+Munwah12LFSdJigBNZb6UZ8HEtyCoXcGkd/X165VDklmrWTJIvLeNHrv4YoDUU8WV
 PKmL47XcYXzXK5X0580kLDn7S/hF8O8=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-103-kP5hsnsGMxK64HuHe2ZLyA-1; Tue, 13 Oct 2020 18:45:04 -0400
X-MC-Unique: kP5hsnsGMxK64HuHe2ZLyA-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com
 [10.5.11.14])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 9B9C5107AD91;
 Tue, 13 Oct 2020 22:45:02 +0000 (UTC)
Received: from localhost (ovpn-112-103.ams2.redhat.com [10.36.112.103])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id 28DD25D9CD;
 Tue, 13 Oct 2020 22:45:01 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH 1/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
References: <20201013140609.2269319-1-gscrivan@redhat.com>
 <20201013140609.2269319-2-gscrivan@redhat.com>
 <20201013205427.clvqno24ctwxbuyv@wittgenstein>
Date: Wed, 14 Oct 2020 00:45:00 +0200
In-Reply-To: <20201013205427.clvqno24ctwxbuyv@wittgenstein> (Christian
 Brauner's message of "Tue, 13 Oct 2020 22:54:27 +0200")
Message-ID: <87imbdrbir.fsf@redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
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

Christian Brauner <christian.brauner@ubuntu.com> writes:

> On Tue, Oct 13, 2020 at 04:06:08PM +0200, Giuseppe Scrivano wrote:
>
> Hey Guiseppe,
>
> Thanks for the patch!
>
>> When the flag CLOSE_RANGE_CLOEXEC is set, close_range doesn't
>> immediately close the files but it sets the close-on-exec bit.
>
> Hm, please expand on the use-cases a little here so people know where
> and how this is useful. Keeping the rationale for a change in the commit
> log is really important.
>
>> 
>> Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
>> ---
>
>>  fs/file.c                        | 56 ++++++++++++++++++++++----------
>>  include/uapi/linux/close_range.h |  3 ++
>>  2 files changed, 42 insertions(+), 17 deletions(-)
>> 
>> diff --git a/fs/file.c b/fs/file.c
>> index 21c0893f2f1d..ad4ebee41e09 100644
>> --- a/fs/file.c
>> +++ b/fs/file.c
>> @@ -672,6 +672,17 @@ int __close_fd(struct files_struct *files, unsigned fd)
>>  }
>>  EXPORT_SYMBOL(__close_fd); /* for ksys_close() */
>>  
>> +static unsigned int __get_max_fds(struct files_struct *cur_fds)
>> +{
>> +	unsigned int max_fds;
>> +
>> +	rcu_read_lock();
>> +	/* cap to last valid index into fdtable */
>> +	max_fds = files_fdtable(cur_fds)->max_fds;
>> +	rcu_read_unlock();
>> +	return max_fds;
>> +}
>> +
>>  /**
>>   * __close_range() - Close all file descriptors in a given range.
>>   *
>> @@ -683,27 +694,23 @@ EXPORT_SYMBOL(__close_fd); /* for ksys_close() */
>>   */
>>  int __close_range(unsigned fd, unsigned max_fd, unsigned int flags)
>>  {
>> -	unsigned int cur_max;
>> +	unsigned int cur_max = UINT_MAX;
>>  	struct task_struct *me = current;
>>  	struct files_struct *cur_fds = me->files, *fds = NULL;
>>  
>> -	if (flags & ~CLOSE_RANGE_UNSHARE)
>> +	if (flags & ~(CLOSE_RANGE_UNSHARE | CLOSE_RANGE_CLOEXEC))
>>  		return -EINVAL;
>>  
>>  	if (fd > max_fd)
>>  		return -EINVAL;
>>  
>> -	rcu_read_lock();
>> -	cur_max = files_fdtable(cur_fds)->max_fds;
>> -	rcu_read_unlock();
>> -
>> -	/* cap to last valid index into fdtable */
>> -	cur_max--;
>> -
>>  	if (flags & CLOSE_RANGE_UNSHARE) {
>>  		int ret;
>>  		unsigned int max_unshare_fds = NR_OPEN_MAX;
>>  
>> +		/* cap to last valid index into fdtable */
>> +		cur_max = __get_max_fds(cur_fds) - 1;
>> +
>>  		/*
>>  		 * If the requested range is greater than the current maximum,
>>  		 * we're closing everything so only copy all file descriptors
>> @@ -724,16 +731,31 @@ int __close_range(unsigned fd, unsigned max_fd, unsigned int flags)
>>  			swap(cur_fds, fds);
>>  	}
>>  
>> -	max_fd = min(max_fd, cur_max);
>> -	while (fd <= max_fd) {
>> -		struct file *file;
>> +	if (flags & CLOSE_RANGE_CLOEXEC) {
>> +		struct fdtable *fdt;
>>  
>> -		file = pick_file(cur_fds, fd++);
>> -		if (!file)
>> -			continue;
>> +		spin_lock(&cur_fds->file_lock);
>> +		fdt = files_fdtable(cur_fds);
>> +		cur_max = fdt->max_fds - 1;
>> +		max_fd = min(max_fd, cur_max);
>> +		while (fd <= max_fd)
>> +			__set_close_on_exec(fd++, fdt);
>> +		spin_unlock(&cur_fds->file_lock);
>> +	} else {
>> +		/* Initialize cur_max if needed.  */
>> +		if (cur_max == UINT_MAX)
>> +			cur_max = __get_max_fds(cur_fds) - 1;
>
> The separation between how cur_fd is retrieved in the two branches makes
> the code more difficult to follow imho. Unless there's a clear reason
> why you've done it that way I would think that something like the patch
> I appended below might be a little clearer and easier to maintain(?).

Thanks for the review!

I've opted for this version as in the flags=CLOSE_RANGE_CLOEXEC case we
can read max_fds directly from the fds table and avoid doing it from the
RCU critical section as well.  I'll change it in favor of more readable
code.

Giuseppe

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
