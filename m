Return-Path: <SRS0=BAQN=I7=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_RED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41DCDC433ED
	for <containers@archiver.kernel.org>; Fri,  2 Apr 2021 14:38:23 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9BE1A6100C
	for <containers@archiver.kernel.org>; Fri,  2 Apr 2021 14:38:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BE1A6100C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 64319414EF;
	Fri,  2 Apr 2021 14:38:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Us6teRyDcfqd; Fri,  2 Apr 2021 14:38:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id 1002F40FA3;
	Fri,  2 Apr 2021 14:38:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E7579C000B;
	Fri,  2 Apr 2021 14:38:20 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 34259C000A
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Apr 2021 14:38:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 26CEF414ED
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Apr 2021 14:38:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id WDur9sTXCafx
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Apr 2021 14:38:18 +0000 (UTC)
X-Greylist: delayed 00:06:03 by SQLgrey-1.8.0
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 675D840FA3
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Apr 2021 14:38:18 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id 93A94CD0; Fri,  2 Apr 2021 09:32:12 -0500 (CDT)
Date: Fri, 2 Apr 2021 09:32:12 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Giuseppe Scrivano <gscrivan@redhat.com>
Subject: Re: [PATCH] kernel: automatically split user namespace extent
Message-ID: <20210402143212.GA18282@mail.hallyn.com>
References: <20201126100839.381415-1-gscrivan@redhat.com>
 <87ft4pe7km.fsf@x220.int.ebiederm.org> <87pn3schlg.fsf@redhat.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87pn3schlg.fsf@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
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

On Wed, Dec 02, 2020 at 05:12:27PM +0100, Giuseppe Scrivano wrote:
> Hi Eric,
> 
> ebiederm@xmission.com (Eric W. Biederman) writes:
> 
> > Nit: The tag should have been "userns:" rather than kernel.
> >
> > Giuseppe Scrivano <gscrivan@redhat.com> writes:
> >
> >> writing to the id map fails when an extent overlaps multiple mappings
> >> in the parent user namespace, e.g.:
> >>
> >> $ cat /proc/self/uid_map
> >>          0       1000          1
> >>          1     100000      65536
> >> $ unshare -U sleep 100 &
> >> [1] 1029703
> >> $ printf "0 0 100\n" | tee /proc/$!/uid_map
> >> 0 0 100
> >> tee: /proc/1029703/uid_map: Operation not permitted
> >>
> >> To prevent it from happening, automatically split an extent so that
> >> each portion fits in one extent in the parent user namespace.
> >
> > I don't see anything fundamentally wrong with relaxing this
> > restriction, but more code does have more room for bugs to hide.
> >
> > What is the advantage of relaxing this restriction?
> 
> we are running rootless containers in a namespace created with
> newuidmap/newgidmap where the mappings look like:
> 
> $ cat /proc/self/uid_map
> 0       1000          1
> 1     110000      65536
> 
> users are allowed to create child user namespaces and specify the
> mappings to use.  Doing so, they often hit the issue that the mappings
> cannot overlap multiple extents in the parent user namespace.
> 
> The issue could be completely addressed in user space, but to me it
> looks like an implementation detail that user space should not know
> about.
> In addition, it would also be slower (additional read of the current
> uid_map and gid_map files) and must be implemented separately in each
> container runtime.
> 
> >> $ cat /proc/self/uid_map
> >>          0       1000          1
> >>          1     110000      65536
> >> $ unshare -U sleep 100 &
> >> [1] 1552
> >> $ printf "0 0 100\n" | tee /proc/$!/uid_map
> >> 0 0 100
> >> $ cat /proc/$!/uid_map
> >>          0          0          1
> >>          1          1         99
> >>
> >> Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
> >> ---
> >>  kernel/user_namespace.c | 62 ++++++++++++++++++++++++++++++++++-------
> >>  1 file changed, 52 insertions(+), 10 deletions(-)
> >>
> >> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> >> index 87804e0371fe..b5542be2bd0a 100644
> >> --- a/kernel/user_namespace.c
> >> +++ b/kernel/user_namespace.c
> >> @@ -706,6 +706,41 @@ const struct seq_operations proc_projid_seq_operations = {
> >>  	.show = projid_m_show,
> >>  };
> >>  
> >> +static void split_overlapping_mappings(struct uid_gid_map *parent_map,
> >> +				       struct uid_gid_extent *extent,
> >> +				       struct uid_gid_extent *overflow_extent)
> >> +{
> >> +	unsigned int idx;
> >> +
> >> +	overflow_extent->first = (u32) -1;
> >> +
> >> +	/* Split extent if it not fully contained in an extent from parent_map.  */
> >> +	for (idx = 0; idx < parent_map->nr_extents; idx++) {
> >
> > Ouch!
> >
> > For the larger tree we perform binary searches typically and
> > here you are walking every entry unconditionally.
> >
> > It looks like this makes the write O(N^2) from O(NlogN)
> > which for a user facing function is not desirable.
> >
> > I think something like insert_and_split_extent may be ok.
> > Incorporating your loop and the part that inserts an element.
> >
> > As written this almost doubles the complexity of the code,
> > as well as making it perform much worse.  Which is a problem.
> 
> I've attempted to implement the new functionality at input validation
> time to not touch the existing security checks.
> 
> I've thought the pattern for iterating the extents was fine as I've
> taken it from mappings_overlap (even if it is used differently on an
> unsorted array).
> 
> Thanks for the hint, I'll move the new logic when map_id_range_down() is
> used and I'll send a v2.

Hi,

sorry if I miseed it.  Did you ever send a v2?
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
