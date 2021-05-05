Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [216.205.24.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A64E70
	for <containers@lists.linux.dev>; Wed,  5 May 2021 15:09:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1620227356;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=f65ENMyQ1N+0g9OsSvxp8jCBBY+W8xaRUzctsJuzZuk=;
	b=AFDiGwWfLucdqyspLX/RYt+eQ/jpMmqYc5gDXCp85lcOIoVmnau5cHMq56tygzYbYg4EBP
	XoCqwz5s3a/ij2uX4s/zfwF0LCERD2B/gyYalUB0Zv3g9yBgjaxidHTIIrCHs7ghumiVu5
	G0neZDCwZKHgoS7kh3KNB/W/UB8/Ndo=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-515-D6JOqljxNvO0oRuE4eHGMQ-1; Wed, 05 May 2021 11:09:12 -0400
X-MC-Unique: D6JOqljxNvO0oRuE4eHGMQ-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 8E50E1966327;
	Wed,  5 May 2021 15:09:11 +0000 (UTC)
Received: from localhost (ovpn-113-154.ams2.redhat.com [10.36.113.154])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EB3F819D61;
	Wed,  5 May 2021 15:09:10 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
  linux-kernel@vger.kernel.org,  christian.brauner@ubuntu.com,  "Linux
 Containers" <containers@lists.linux.dev>
Subject: Re: [PATCH] kernel: automatically split user namespace extent
References: <20201126100839.381415-1-gscrivan@redhat.com>
	<87ft4pe7km.fsf@x220.int.ebiederm.org> <87pn3schlg.fsf@redhat.com>
	<20210402143212.GA18282@mail.hallyn.com> <87zgygg2xc.fsf@redhat.com>
Date: Wed, 05 May 2021 17:09:08 +0200
In-Reply-To: <87zgygg2xc.fsf@redhat.com> (Giuseppe Scrivano's message of "Fri,
	02 Apr 2021 16:46:07 +0200")
Message-ID: <87v97x43qj.fsf@redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.2 (gnu/linux)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23

Hi Serge,

Giuseppe Scrivano <gscrivan@redhat.com> writes:

> Hi Serge,
>
> "Serge E. Hallyn" <serge@hallyn.com> writes:
>
>> On Wed, Dec 02, 2020 at 05:12:27PM +0100, Giuseppe Scrivano wrote:
>>> Hi Eric,
>>> 
>>> ebiederm@xmission.com (Eric W. Biederman) writes:
>>> 
>>> > Nit: The tag should have been "userns:" rather than kernel.
>>> >
>>> > Giuseppe Scrivano <gscrivan@redhat.com> writes:
>>> >
>>> >> writing to the id map fails when an extent overlaps multiple mappings
>>> >> in the parent user namespace, e.g.:
>>> >>
>>> >> $ cat /proc/self/uid_map
>>> >>          0       1000          1
>>> >>          1     100000      65536
>>> >> $ unshare -U sleep 100 &
>>> >> [1] 1029703
>>> >> $ printf "0 0 100\n" | tee /proc/$!/uid_map
>>> >> 0 0 100
>>> >> tee: /proc/1029703/uid_map: Operation not permitted
>>> >>
>>> >> To prevent it from happening, automatically split an extent so that
>>> >> each portion fits in one extent in the parent user namespace.
>>> >
>>> > I don't see anything fundamentally wrong with relaxing this
>>> > restriction, but more code does have more room for bugs to hide.
>>> >
>>> > What is the advantage of relaxing this restriction?
>>> 
>>> we are running rootless containers in a namespace created with
>>> newuidmap/newgidmap where the mappings look like:
>>> 
>>> $ cat /proc/self/uid_map
>>> 0       1000          1
>>> 1     110000      65536
>>> 
>>> users are allowed to create child user namespaces and specify the
>>> mappings to use.  Doing so, they often hit the issue that the mappings
>>> cannot overlap multiple extents in the parent user namespace.
>>> 
>>> The issue could be completely addressed in user space, but to me it
>>> looks like an implementation detail that user space should not know
>>> about.
>>> In addition, it would also be slower (additional read of the current
>>> uid_map and gid_map files) and must be implemented separately in each
>>> container runtime.
>>> 
>>> >> $ cat /proc/self/uid_map
>>> >>          0       1000          1
>>> >>          1     110000      65536
>>> >> $ unshare -U sleep 100 &
>>> >> [1] 1552
>>> >> $ printf "0 0 100\n" | tee /proc/$!/uid_map
>>> >> 0 0 100
>>> >> $ cat /proc/$!/uid_map
>>> >>          0          0          1
>>> >>          1          1         99
>>> >>
>>> >> Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
>>> >> ---
>>> >>  kernel/user_namespace.c | 62 ++++++++++++++++++++++++++++++++++-------
>>> >>  1 file changed, 52 insertions(+), 10 deletions(-)
>>> >>
>>> >> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
>>> >> index 87804e0371fe..b5542be2bd0a 100644
>>> >> --- a/kernel/user_namespace.c
>>> >> +++ b/kernel/user_namespace.c
>>> >> @@ -706,6 +706,41 @@ const struct seq_operations proc_projid_seq_operations = {
>>> >>  	.show = projid_m_show,
>>> >>  };
>>> >>  
>>> >> +static void split_overlapping_mappings(struct uid_gid_map *parent_map,
>>> >> +				       struct uid_gid_extent *extent,
>>> >> +				       struct uid_gid_extent *overflow_extent)
>>> >> +{
>>> >> +	unsigned int idx;
>>> >> +
>>> >> +	overflow_extent->first = (u32) -1;
>>> >> +
>>> >> +	/* Split extent if it not fully contained in an extent from parent_map.  */
>>> >> +	for (idx = 0; idx < parent_map->nr_extents; idx++) {
>>> >
>>> > Ouch!
>>> >
>>> > For the larger tree we perform binary searches typically and
>>> > here you are walking every entry unconditionally.
>>> >
>>> > It looks like this makes the write O(N^2) from O(NlogN)
>>> > which for a user facing function is not desirable.
>>> >
>>> > I think something like insert_and_split_extent may be ok.
>>> > Incorporating your loop and the part that inserts an element.
>>> >
>>> > As written this almost doubles the complexity of the code,
>>> > as well as making it perform much worse.  Which is a problem.
>>> 
>>> I've attempted to implement the new functionality at input validation
>>> time to not touch the existing security checks.
>>> 
>>> I've thought the pattern for iterating the extents was fine as I've
>>> taken it from mappings_overlap (even if it is used differently on an
>>> unsorted array).
>>> 
>>> Thanks for the hint, I'll move the new logic when map_id_range_down() is
>>> used and I'll send a v2.
>>
>> Hi,
>>
>> sorry if I miseed it.  Did you ever send a v2?
>
> no worries, the v2 is here:
>
> https://lkml.kernel.org/lkml/20201203150252.1229077-1-gscrivan@redhat.com/

have you had a chance to look at the patch?

Thanks,
Giuseppe

